import ../../src/llvnim/[idiomatic, dx]
import ast, lexer
import std/[tables]

type
  Context* = ref object
    llvmCtx*: LLVMContextRef
    module*: LLVMModuleRef
    builder*: LLVMBuilderRef
    scopes*: seq[Table[string, LLVMValueRef]]
    pendingLocals*: Table[string, LLVMValueRef]
    externs*: Table[string, LLVMValueRef]
    funcs*: Table[string, LLVMValueRef]
    currentFn*: LLVMValueRef
    inDefBody*: bool
    loopStack*: seq[tuple[exitBB, continueBB: LLVMBasicBlockRef]]

  CodegenError* = object of CatchableError

proc pushScope(ctx: Context) = ctx.scopes.add initTable[string, LLVMValueRef]()
proc popScope(ctx: Context) = discard ctx.scopes.pop()

proc lookupVar(ctx: Context, name: string): LLVMValueRef =
  for i in countdown(ctx.scopes.len - 1, 0):
    if ctx.scopes[i].hasKey(name): return ctx.scopes[i][name]
  nil

proc declareVar(ctx: Context, name: string, v: LLVMValueRef) =
  ctx.scopes[^1][name] = v

proc newError(pos: int, msg: string) {.noreturn.} =
  raise newException(CodegenError, "pos " & $pos & ": " & msg)

proc newContext*(): Context =
  let c = contextCreate()
  result = Context(
    llvmCtx: c,
    module:  moduleCreateWithNameInContext("compiler", c),
    builder: createBuilderInContext(c),
    externs: initTable[string, LLVMValueRef](),
    funcs: initTable[string, LLVMValueRef](),
    scopes: @[initTable[string, LLVMValueRef]()],
    pendingLocals: initTable[string, LLVMValueRef](),
  )
  let printTy = functionType(f64(c), [f64(c)], false)
  let printFn = addFunction(result.module, "print".cstring, printTy)
  setLinkage(printFn, LLVMExternalLinkage)
  result.externs["print"] = printFn

proc blockTerminated(ctx: Context): bool =
  let bb = getInsertBlock(ctx.builder)
  if bb.isNil: return false
  LLVMGetBasicBlockTerminator(bb) != LLVMValueRef(nil)

proc analyzeScopes(node: Node, depth: int, vars: var Table[string, int]) =
  case node.kind
  of nkBinary:
    let b = BinaryNode(node)
    if b.token.kind == tkEquals and b.lvalue.kind == nkIdent:
      let name = IdentNode(b.lvalue).token.lexeme
      if not vars.hasKey(name) or vars[name] > depth:
        vars[name] = depth
    analyzeScopes(b.lvalue, depth, vars)
    analyzeScopes(b.rvalue, depth, vars)
  of nkUnary: analyzeScopes(UnaryNode(node).value, depth, vars)
  of nkBlock:
    for s in BlockNode(node).body: analyzeScopes(s, depth, vars)
  of nkCall:
    for a in CallNode(node).args: analyzeScopes(a, depth, vars)
  of nkExtern: discard
  of nkReturn:
    let r = ReturnNode(node)
    if not r.value.isNil: analyzeScopes(r.value, depth, vars)
  of nkDef: discard
  of nkBranch:
    let b = BranchNode(node)
    analyzeScopes(b.cond, depth, vars)
    analyzeScopes(b.body, depth+1, vars)
    for (c, bd) in b.elifs:
      analyzeScopes(c, depth+1, vars)
      analyzeScopes(bd, depth+1, vars)
    if not b.elseBody.isNil: analyzeScopes(b.elseBody, depth+1, vars)
  of nkFor:
    let f = ForNode(node)
    if not f.init.isNil: analyzeScopes(f.init, depth+1, vars)
    if not f.cond.isNil: analyzeScopes(f.cond, depth+1, vars)
    if not f.step.isNil: analyzeScopes(f.step, depth+1, vars)
    analyzeScopes(f.body, depth+1, vars)
  else: discard

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
    var ptrr = ctx.lookupVar(name)
    if ptrr.isNil:
      if ctx.pendingLocals.hasKey(name):
        ptrr = ctx.pendingLocals[name]
        ctx.declareVar(name, ptrr)
      else:
        node.token.pos.newError("internal: variable '" & name & "' not pre-allocated")
    discard store(ctx.builder, ptrr, v)
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

proc codegenIdent*(ctx: Context, node: IdentNode): LLVMValueRef =
  let name = node.token.lexeme
  let ptrr = ctx.lookupVar(name)
  if ptrr.isNil:
    node.token.pos.newError("Undefined identifier: " & name)
  result = buildLoad2(ctx.builder, ctx.llvmCtx.f64(), ptrr, (name & ".val").cstring)

proc codegenNumber*(ctx: Context, node: NumberNode): LLVMValueRef =
  constReal(ctx.llvmCtx.f64(), node.value)

proc codegenBlock*(ctx: Context, node: BlockNode): LLVMValueRef =
  result = constReal(ctx.llvmCtx.f64(), NaN)
  for stmt in node.body:
    if blockTerminated(ctx): break
    result = ctx.codegen(stmt)

proc codegenExtern*(ctx: Context, node: ExternNode): LLVMValueRef =
  let name = node.name.lexeme
  if ctx.externs.hasKey(name):
    return constReal(ctx.llvmCtx.f64(), NaN)
  if ctx.funcs.hasKey(name):
    node.name.pos.newError("redefinition of '" & name & "' (already a user function)")
  if not ctx.lookupVar(name).isNil:
    node.name.pos.newError("redefinition of '" & name & "' (already a variable)")
  var params = newSeq[LLVMTypeRef](node.args.len)
  for i in 0 ..< node.args.len:
    params[i] = ctx.llvmCtx.f64()
  let fnTy = functionType(ctx.llvmCtx.f64(), params, false)
  let fn = addFunction(ctx.module, name.cstring, fnTy)
  setLinkage(fn, LLVMExternalLinkage)
  ctx.externs[name] = fn
  result = constReal(ctx.llvmCtx.f64(), NaN)

proc codegenCall*(ctx: Context, node: CallNode): LLVMValueRef =
  let name = node.name.lexeme
  var fn: LLVMValueRef
  if ctx.funcs.hasKey(name):
    fn = ctx.funcs[name]
  elif ctx.externs.hasKey(name):
    fn = ctx.externs[name]
  else:
    node.token.pos.newError("Undefined function: " & name)
  var args = newSeq[LLVMValueRef](node.args.len)
  for i, a in node.args:
    args[i] = ctx.codegen(a)
  result = call(ctx.builder, fn, args, name & ".call")

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
    ctx.pushScope()
    try:
      return ctx.codegenBody(elseBody)
    finally:
      ctx.popScope()

  let (cond, body) = elifs[0]
  let iface = createIfElse(ctx.builder, ctx.llvmCtx, ctx.currentFn, condToI1(ctx, cond),
                           thenName = "elifthen", elseName = "elifelse", mergeName = "elifmerge")

  var incoming: seq[(LLVMValueRef, LLVMBasicBlockRef)]

  thenBlock(iface):
    ctx.pushScope()
    let tv = ctx.codegenBody(body)
    ctx.popScope()
    if not blockTerminated(ctx):
      incoming.add (tv, getInsertBlock(ctx.builder))
      brToMerge(iface)

  elseBlock(iface):
    let ev = ctx.codegenElseChain(elifs[1..^1], elseBody)
    if not blockTerminated(ctx):
      incoming.add (ev, getInsertBlock(ctx.builder))
      brToMerge(iface)

  mergeBlock(iface):
    if incoming.len == 0:
      discard buildUnreachable(ctx.builder)
      result = constReal(ctx.llvmCtx.f64(), NaN)
    else:
      let phi = buildPhi(ctx.builder, ctx.llvmCtx.f64(), "eliftmp")
      for (v, bb) in incoming:
        addIncoming(phi, v, bb)
      result = phi

proc codegenBranch*(ctx: Context, node: BranchNode): LLVMValueRef =
  let iface = createIfElse(ctx.builder, ctx.llvmCtx, ctx.currentFn, condToI1(ctx, node.cond))

  var incoming: seq[(LLVMValueRef, LLVMBasicBlockRef)]

  thenBlock(iface):
    ctx.pushScope()
    let tv = ctx.codegenBody(node.body)
    ctx.popScope()
    if not blockTerminated(ctx):
      incoming.add (tv, getInsertBlock(ctx.builder))
      brToMerge(iface)

  elseBlock(iface):
    let ev = ctx.codegenElseChain(node.elifs, node.elseBody)
    if not blockTerminated(ctx):
      incoming.add (ev, getInsertBlock(ctx.builder))
      brToMerge(iface)

  mergeBlock(iface):
    if incoming.len == 0:
      discard buildUnreachable(ctx.builder)
      result = constReal(ctx.llvmCtx.f64(), NaN)
    else:
      let phi = buildPhi(ctx.builder, ctx.llvmCtx.f64(), "iftmp")
      for (v, bb) in incoming:
        addIncoming(phi, v, bb)
      result = phi

proc codegenFor*(ctx: Context, node: ForNode): LLVMValueRef =
  ctx.pushScope()
  try:
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
    if not blockTerminated(ctx):
      if node.body.kind == nkBlock:
        discard ctx.codegenBlock(BlockNode(node.body))
      else:
        discard ctx.codegen(node.body)
      if not blockTerminated(ctx):
        discard buildBr(ctx.builder, stepBB)

    positionBuilderAtEnd(ctx.builder, stepBB)
    if not blockTerminated(ctx):
      if not node.step.isNil:
        discard ctx.codegen(node.step)
      discard buildBr(ctx.builder, condBB)

    positionBuilderAtEnd(ctx.builder, exitBB)
    discard ctx.loopStack.pop()
    result = constReal(ctx.llvmCtx.f64(), NaN)
  finally:
    ctx.popScope()

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

proc codegenReturn*(ctx: Context, node: ReturnNode): LLVMValueRef =
  if not ctx.inDefBody:
    node.token.pos.newError("return outside function")
  if node.value.isNil:
    discard buildRet(ctx.builder, constReal(ctx.llvmCtx.f64(), NaN))
  else:
    let v = ctx.codegen(node.value)
    discard buildRet(ctx.builder, v)
  result = constReal(ctx.llvmCtx.f64(), NaN)

proc codegenDef*(ctx: Context, node: DefNode): LLVMValueRef

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
  of nkReturn:   ctx.codegenReturn(ReturnNode(node))
  of nkDef:      ctx.codegenDef(DefNode(node))

proc verifyModule*(m: LLVMModuleRef): tuple[ok: bool, err: string] =
  var errMsg: cstring
  let bad = LLVMVerifyModule(m, LLVMReturnStatusAction, errMsg)
  result.ok = bad == 0
  if not errMsg.isNil:
    result.err = $errMsg
    LLVMDisposeMessage(errMsg)

proc genFuncBody(ctx: Context, fn: LLVMValueRef, entryBB: LLVMBasicBlockRef,
                 params: seq[Token], body: Node, isTopLevel: bool) =
  let savedBuilder = getInsertBlock(ctx.builder)
  let savedFn = ctx.currentFn
  let savedInDef = ctx.inDefBody
  let savedPending = ctx.pendingLocals

  positionBuilderAtEnd(ctx.builder, entryBB)
  ctx.currentFn = fn
  ctx.inDefBody = not isTopLevel
  ctx.pendingLocals = initTable[string, LLVMValueRef]()

  ctx.pushScope()
  try:
    for i, p in params:
      let pv = getParam(fn, cuint(i))
      let pa = alloca(ctx.builder, ctx.llvmCtx.f64(), p.lexeme)
      discard store(ctx.builder, pa, pv)
      ctx.declareVar(p.lexeme, pa)

    var varsByDepth: Table[string, int]
    analyzeScopes(body, 0, varsByDepth)
    for vname, depth in varsByDepth:
      if isTopLevel and depth == 0:
        if not ctx.scopes[0].hasKey(vname):
          let g = addGlobal(ctx.module, ctx.llvmCtx.f64(), vname.cstring)
          setInitializer(g, constReal(ctx.llvmCtx.f64(), 0.0))
          setGlobalConstant(g, LLVMFalse)
          setLinkage(g, LLVMExternalLinkage)
          ctx.scopes[0][vname] = g
      else:
        if ctx.lookupVar(vname).isNil and not ctx.pendingLocals.hasKey(vname):
          let a = alloca(ctx.builder, ctx.llvmCtx.f64(), vname)
          ctx.pendingLocals[vname] = a

    let v = ctx.codegenBody(body)
    if not blockTerminated(ctx):
      discard buildRet(ctx.builder, v)
  finally:
    ctx.popScope()
    ctx.pendingLocals = savedPending
    ctx.currentFn = savedFn
    ctx.inDefBody = savedInDef
    if not savedBuilder.isNil:
      positionBuilderAtEnd(ctx.builder, savedBuilder)

proc codegenDef*(ctx: Context, node: DefNode): LLVMValueRef =
  let name = node.name.lexeme
  if ctx.externs.hasKey(name):
    node.name.pos.newError("redefinition of '" & name & "' (already an extern)")
  if ctx.funcs.hasKey(name):
    node.name.pos.newError("redefinition of '" & name & "' (already a function)")
  if not ctx.lookupVar(name).isNil:
    node.name.pos.newError("redefinition of '" & name & "' (already a variable)")

  var params = newSeq[LLVMTypeRef](node.args.len)
  for i in 0 ..< node.args.len:
    params[i] = ctx.llvmCtx.f64()

  let (fn, entryBB) = createFunction(ctx.module, ctx.llvmCtx, name, ctx.llvmCtx.f64(), params)
  ctx.funcs[name] = fn

  try:
    ctx.genFuncBody(fn, entryBB, node.args, node.body, isTopLevel = false)
  except CatchableError:
    ctx.funcs.del(name)
    deleteFunction(fn)
    raise
  result = constReal(ctx.llvmCtx.f64(), NaN)

proc codegenFunction*(ctx: Context, name: string, body: BlockNode, isTopLevel: bool = true): LLVMValueRef =
  let (fn, entryBB) = createFunction(ctx.module, ctx.llvmCtx, name, ctx.llvmCtx.f64(), [])
  try:
    ctx.genFuncBody(fn, entryBB, @[], body, isTopLevel)
    let (ok, verr) = verifyModule(ctx.module)
    if not ok:
      newError(0, "invalid IR: " & verr)
    result = fn
  except CatchableError:
    deleteFunction(fn)
    raise