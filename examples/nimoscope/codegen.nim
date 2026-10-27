import ../../src/llvnim/[idiomatic, dx]
import ast, lexer
import std/[tables, sets]

type
  Context* = ref object
    llvmCtx*: LLVMContextRef
    module*: LLVMModuleRef
    builder*: LLVMBuilderRef
    env*: Table[string, LLVMValueRef]
    externs*: Table[string, LLVMValueRef]
    currentFn*: LLVMValueRef
    loopExit*: LLVMBasicBlockRef
    loopContinue*: LLVMBasicBlockRef
    loopStack*: seq[tuple[exitBB, continueBB: LLVMBasicBlockRef]]

  CodegenError* = object of CatchableError

proc newError(pos: int, msg: string) {.noreturn.} =
  raise newException(CodegenError, "pos " & $pos & ": " & msg)

proc nimPrint*(x: cdouble): cdouble {.exportc: "print", cdecl.} =
  echo x
  result = x

proc newContext*(): Context =
  let c = contextCreate()
  result = Context(
    llvmCtx: c,
    module:  moduleCreateWithNameInContext("compiler", c),
    builder: createBuilderInContext(c),
    env: initTable[string, LLVMValueRef](),
    externs: initTable[string, LLVMValueRef](),
  )
  let printTy = functionType(f64(c), [f64(c)], false)
  let printFn = addFunction(result.module, "print".cstring, printTy)
  setLinkage(printFn, LLVMExternalLinkage)
  result.externs["print"] = printFn

proc collectVars(node: Node, acc: var HashSet[string]) =
  case node.kind
  of nkBinary:
    let b = BinaryNode(node)
    if b.token.kind == tkEquals and b.lvalue.kind == nkIdent:
      acc.incl IdentNode(b.lvalue).token.lexeme
    collectVars(b.lvalue, acc)
    collectVars(b.rvalue, acc)
  of nkUnary: collectVars(UnaryNode(node).value, acc)
  of nkBlock:
    for s in BlockNode(node).body: collectVars(s, acc)
  of nkCall:
    for a in CallNode(node).args: collectVars(a, acc)
  of nkExtern: discard
  of nkBranch:
    let b = BranchNode(node)
    collectVars(b.cond, acc)
    collectVars(b.body, acc)
    for (c, bd) in b.elifs:
      collectVars(c, acc); collectVars(bd, acc)
    if not b.elseBody.isNil: collectVars(b.elseBody, acc)
  of nkFor:
    let f = ForNode(node)
    if not f.init.isNil: collectVars(f.init, acc)
    if not f.cond.isNil: collectVars(f.cond, acc)
    if not f.step.isNil: collectVars(f.step, acc)
    collectVars(f.body, acc)
  else: discard

proc allocaVars(ctx: Context, names: HashSet[string]) =
  for name in names:
    if ctx.env.hasKey(name): continue
    let g = addGlobal(ctx.module, ctx.llvmCtx.f64(), name.cstring)
    setInitializer(g, constReal(ctx.llvmCtx.f64(), 0.0))
    setGlobalConstant(g, LLVMFalse)
    setLinkage(g, LLVMExternalLinkage)
    ctx.env[name] = g

proc codegen*(ctx: Context, node: Node): LLVMValueRef

proc codegenUnary*(ctx: Context, node: UnaryNode): LLVMValueRef =
  let v = ctx.codegen(node.value)
  case node.token.kind
  of tkMinus: return buildFNeg(ctx.builder, v, "negtmp")
  of tkPlus:  return v
  else:       node.token.pos.newError("Unsupported unary: " & node.token.mean())

proc cmpPredicate(k: TokenKind): LLVMRealPredicate =
  case k
  of tkGT:  LLVMRealOGT
  of tkLT:  LLVMRealOLT
  of tkGTE: LLVMRealOGE
  of tkLTE: LLVMRealOLE
  of tkEQ:  LLVMRealOEQ
  of tkNEQ: LLVMRealONE
  else:     LLVMRealONE

proc addIncoming1(phi, v: LLVMValueRef, bb: LLVMBasicBlockRef) =
  var vals = [v]
  var blocks = [bb]
  LLVMAddIncoming(phi, addr vals[0], addr blocks[0], 1)

proc codegenAnd(ctx: Context, l, r: Node): LLVMValueRef =
  let lv = ctx.codegen(l)
  let condA = buildFCmp(ctx.builder, LLVMRealONE, lv, constReal(ctx.llvmCtx.f64(), 0.0), "andcond")
  let iface = createIfElse(ctx.builder, ctx.llvmCtx, ctx.currentFn, condA,
                           thenName = "andthen", elseName = "andelse", mergeName = "andmerge")
  var incomingVal: seq[LLVMValueRef]
  var incomingBB: seq[LLVMBasicBlockRef]
  thenBlock(iface):
    let rv = ctx.codegen(r)
    incomingVal.add rv
    incomingBB.add getInsertBlock(ctx.builder)
    brToMerge(iface)
  elseBlock(iface):
    incomingVal.add lv
    incomingBB.add getInsertBlock(ctx.builder)
    brToMerge(iface)
  mergeBlock(iface):
    let phi = buildPhi(ctx.builder, ctx.llvmCtx.f64(), "andphi")
    addIncoming1(phi, incomingVal[0], incomingBB[0])
    addIncoming1(phi, incomingVal[1], incomingBB[1])
    result = phi

proc codegenOr(ctx: Context, l, r: Node): LLVMValueRef =
  let lv = ctx.codegen(l)
  let condA = buildFCmp(ctx.builder, LLVMRealONE, lv, constReal(ctx.llvmCtx.f64(), 0.0), "orcond")
  let iface = createIfElse(ctx.builder, ctx.llvmCtx, ctx.currentFn, condA,
                           thenName = "orthen", elseName = "orelse", mergeName = "ormerge")
  var incomingVal: seq[LLVMValueRef]
  var incomingBB: seq[LLVMBasicBlockRef]
  thenBlock(iface):
    incomingVal.add lv
    incomingBB.add getInsertBlock(ctx.builder)
    brToMerge(iface)
  elseBlock(iface):
    let rv = ctx.codegen(r)
    incomingVal.add rv
    incomingBB.add getInsertBlock(ctx.builder)
    brToMerge(iface)
  mergeBlock(iface):
    let phi = buildPhi(ctx.builder, ctx.llvmCtx.f64(), "orphi")
    addIncoming1(phi, incomingVal[0], incomingBB[0])
    addIncoming1(phi, incomingVal[1], incomingBB[1])
    result = phi

proc codegenBinary*(ctx: Context, node: BinaryNode): LLVMValueRef =
  case node.token.kind
  of tkAnd: return ctx.codegenAnd(node.lvalue, node.rvalue)
  of tkOr:  return ctx.codegenOr(node.lvalue, node.rvalue)
  else: discard

  if node.token.kind == tkEquals:
    let name = IdentNode(node.lvalue).token.lexeme
    let v = ctx.codegen(node.rvalue)
    discard store(ctx.builder, ctx.env[name], v)
    return v

  let l = ctx.codegen(node.lvalue)
  let r = ctx.codegen(node.rvalue)
  case node.token.kind
  of tkPlus:  result = buildFAdd(ctx.builder, l, r, "addtmp")
  of tkMinus: result = buildFSub(ctx.builder, l, r, "subtmp")
  of tkStar:  result = buildFMul(ctx.builder, l, r, "multmp")
  of tkSlash: result = buildFDiv(ctx.builder, l, r, "divtmp")
  of tkGT, tkLT, tkGTE, tkLTE, tkEQ, tkNEQ:
    let cmp = buildFCmp(ctx.builder, cmpPredicate(node.token.kind), l, r, "cmptmp")
    result = buildUIToFP(ctx.builder, cmp, ctx.llvmCtx.f64(), "booltmp")
  else:       node.token.pos.newError("Unsupported binary: " & node.token.mean())

proc codegenIdent(ctx: Context, node: IdentNode): LLVMValueRef =
  let name = node.token.lexeme
  if not ctx.env.hasKey(name):
    node.token.pos.newError("Undefined identifier: " & name)
  result = buildLoad2(ctx.builder, ctx.llvmCtx.f64(), ctx.env[name], (name & ".val").cstring)

proc codegenNumber(ctx: Context, node: NumberNode): LLVMValueRef =
  constReal(ctx.llvmCtx.f64(), node.value)

proc codegenBlock*(ctx: Context, node: BlockNode): LLVMValueRef =
  var names: HashSet[string]
  collectVars(node, names)
  allocaVars(ctx, names)
  result = constReal(ctx.llvmCtx.f64(), NaN)
  for stmt in node.body:
    result = ctx.codegen(stmt)

proc codegenExtern(ctx: Context, node: ExternNode): LLVMValueRef =
  let name = node.name.lexeme
  if ctx.externs.hasKey(name):
    return ctx.externs[name]
  var params = newSeq[LLVMTypeRef](node.args.len)
  for i in 0 ..< node.args.len:
    params[i] = ctx.llvmCtx.f64()
  let fnTy = functionType(ctx.llvmCtx.f64(), params, false)
  let fn = addFunction(ctx.module, name.cstring, fnTy)
  setLinkage(fn, LLVMExternalLinkage)
  ctx.externs[name] = fn
  result = fn

proc codegenCall(ctx: Context, node: CallNode): LLVMValueRef =
  let name = node.name.lexeme
  if not ctx.externs.hasKey(name):
    node.token.pos.newError("Undefined function: " & name)
  var args = newSeq[LLVMValueRef](node.args.len)
  for i, a in node.args:
    args[i] = ctx.codegen(a)
  result = call(ctx.builder, ctx.externs[name], args, name & ".call")

proc condToI1(ctx: Context, cond: Node): LLVMValueRef =
  let v = ctx.codegen(cond)
  buildFCmp(ctx.builder, LLVMRealONE, v, constReal(ctx.llvmCtx.f64(), 0.0), "ifcond")

proc codegenBody(ctx: Context, body: Node): LLVMValueRef =
  if body.kind == nkBlock:
    ctx.codegenBlock(BlockNode(body))
  else:
    ctx.codegen(body)

proc addIncoming(phi, v: LLVMValueRef, bb: LLVMBasicBlockRef) =
  var vals = [v]
  var blocks = [bb]
  LLVMAddIncoming(phi, addr vals[0], addr blocks[0], 1)

proc codegenElseChain(ctx: Context, elifs: seq[(Node, Node)], elseBody: Node): LLVMValueRef =
  if elifs.len == 0:
    if elseBody.isNil:
      return constReal(ctx.llvmCtx.f64(), NaN)
    return ctx.codegenBody(elseBody)

  let (cond, body) = elifs[0]
  let iface = createIfElse(ctx.builder, ctx.llvmCtx, ctx.currentFn, condToI1(ctx, cond),
                           thenName = "elifthen", elseName = "elifelse", mergeName = "elifmerge")

  var incoming: seq[(LLVMValueRef, LLVMBasicBlockRef)]

  thenBlock(iface):
    let tv = ctx.codegenBody(body)
    incoming.add (tv, getInsertBlock(ctx.builder))
    brToMerge(iface)

  elseBlock(iface):
    let ev = ctx.codegenElseChain(elifs[1..^1], elseBody)
    incoming.add (ev, getInsertBlock(ctx.builder))
    brToMerge(iface)

  mergeBlock(iface):
    let phi = buildPhi(ctx.builder, ctx.llvmCtx.f64(), "eliftmp")
    for (v, bb) in incoming:
      addIncoming(phi, v, bb)
    result = phi

proc codegenBranch*(ctx: Context, node: BranchNode): LLVMValueRef =
  let iface = createIfElse(ctx.builder, ctx.llvmCtx, ctx.currentFn, condToI1(ctx, node.cond))

  var incoming: seq[(LLVMValueRef, LLVMBasicBlockRef)]

  thenBlock(iface):
    let tv = ctx.codegenBody(node.body)
    incoming.add (tv, getInsertBlock(ctx.builder))
    brToMerge(iface)

  elseBlock(iface):
    let ev = ctx.codegenElseChain(node.elifs, node.elseBody)
    incoming.add (ev, getInsertBlock(ctx.builder))
    brToMerge(iface)

  mergeBlock(iface):
    let phi = buildPhi(ctx.builder, ctx.llvmCtx.f64(), "iftmp")
    for (v, bb) in incoming:
      addIncoming(phi, v, bb)
    result = phi

proc codegenFor*(ctx: Context, node: ForNode): LLVMValueRef =
  if not node.init.isNil:
    discard ctx.codegen(node.init)

  let condBB = appendBasicBlockInContext(ctx.llvmCtx, ctx.currentFn, "forcond")
  let bodyBB = appendBasicBlockInContext(ctx.llvmCtx, ctx.currentFn, "forbody")
  let stepBB = appendBasicBlockInContext(ctx.llvmCtx, ctx.currentFn, "forstep")
  let exitBB = appendBasicBlockInContext(ctx.llvmCtx, ctx.currentFn, "forexit")
  discard buildBr(ctx.builder, condBB)

  positionBuilderAtEnd(ctx.builder, condBB)
  if node.cond.isNil:
    discard buildCondBr(ctx.builder, constInt(i1(ctx.llvmCtx), 1), bodyBB, exitBB)
  else:
    discard buildCondBr(ctx.builder, condToI1(ctx, node.cond), bodyBB, exitBB)

  ctx.loopStack.add (exitBB, stepBB)

  positionBuilderAtEnd(ctx.builder, bodyBB)
  if node.body.kind == nkBlock:
    discard ctx.codegenBlock(BlockNode(node.body))
  else:
    discard ctx.codegen(node.body)
  discard buildBr(ctx.builder, stepBB)

  positionBuilderAtEnd(ctx.builder, stepBB)
  if not node.step.isNil:
    discard ctx.codegen(node.step)
  discard buildBr(ctx.builder, condBB)

  positionBuilderAtEnd(ctx.builder, exitBB)
  discard ctx.loopStack.pop()
  result = constReal(ctx.llvmCtx.f64(), NaN)

proc codegenBreak*(ctx: Context, pos: int): LLVMValueRef =
  if ctx.loopStack.len == 0:
    newError(pos, "break outside loop")
  discard buildBr(ctx.builder, ctx.loopStack[^1].exitBB)
  let dead = appendBasicBlockInContext(ctx.llvmCtx, ctx.currentFn, "afterbreak")
  positionBuilderAtEnd(ctx.builder, dead)
  result = constReal(ctx.llvmCtx.f64(), NaN)

proc codegenContinue*(ctx: Context, pos: int): LLVMValueRef =
  if ctx.loopStack.len == 0:
    newError(pos, "continue outside loop")
  discard buildBr(ctx.builder, ctx.loopStack[^1].continueBB)
  let dead = appendBasicBlockInContext(ctx.llvmCtx, ctx.currentFn, "aftercontinue")
  positionBuilderAtEnd(ctx.builder, dead)
  result = constReal(ctx.llvmCtx.f64(), NaN)

proc codegen*(ctx: Context, node: Node): LLVMValueRef =
  case node.kind
  of nkNumber:   ctx.codegenNumber(NumberNode(node))
  of nkUnary:    ctx.codegenUnary(UnaryNode(node))
  of nkBinary:   ctx.codegenBinary(BinaryNode(node))
  of nkIdent:    ctx.codegenIdent(IdentNode(node))
  of nkBlock:    ctx.codegenBlock(BlockNode(node))
  of nkExtern:   ctx.codegenExtern(ExternNode(node))
  of nkCall:     ctx.codegenCall(CallNode(node))
  of nkBranch:   ctx.codegenBranch(BranchNode(node))
  of nkFor:      ctx.codegenFor(ForNode(node))
  of nkBreak:    ctx.codegenBreak(BreakNode(node).token.pos)
  of nkContinue: ctx.codegenContinue(ContinueNode(node).token.pos)

proc verifyModule*(m: LLVMModuleRef): tuple[ok: bool, err: string] =
  var errMsg: cstring
  let bad = LLVMVerifyModule(m, LLVMReturnStatusAction, errMsg)
  result.ok = bad == 0
  if not errMsg.isNil:
    result.err = $errMsg
    LLVMDisposeMessage(errMsg)

proc codegenFunction*(ctx: Context, name: string, body: BlockNode): LLVMValueRef =
  let (fn, entryBB) = createFunction(ctx.module, ctx.llvmCtx, name, ctx.llvmCtx.f64(), [])
  positionBuilderAtEnd(ctx.builder, entryBB)
  ctx.currentFn = fn
  try:
    let v = ctx.codegenBlock(body)
    discard buildRet(ctx.builder, v)
    let (ok, verr) = verifyModule(ctx.module)
    if not ok:
      newError(0, "invalid IR: " & verr)
    result = fn
  finally:
    ctx.currentFn = LLVMValueRef(nil)