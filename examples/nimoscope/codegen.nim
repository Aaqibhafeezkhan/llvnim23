import ../../src/llvnim/[idiomatic, dx]
import ast, lexer
import std/[tables, sets]

type
  Context* = ref object
    llvmCtx*: LLVMContextRef
    module*: LLVMModuleRef
    builder*: LLVMBuilderRef
    env*: Table[string, LLVMValueRef]

  CodegenError* = object of CatchableError

proc newError(pos: int, msg: string) {.noreturn.} =
  raise newException(CodegenError, "pos " & $pos & ": " & msg)

proc newContext*(): Context =
  let c = contextCreate()
  Context(
    llvmCtx: c,
    module:  moduleCreateWithNameInContext("compiler", c),
    builder: createBuilderInContext(c),
    env: initTable[string, LLVMValueRef]()
  )

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
  else: discard

proc allocaVars(ctx: Context, names: HashSet[string]) =
  for name in names:
    ctx.env[name] = alloca(ctx.builder, ctx.llvmCtx.f64(), name)

proc codegen*(ctx: Context, node: Node): LLVMValueRef

proc codegenUnary*(ctx: Context, node: UnaryNode): LLVMValueRef =
  let v = ctx.codegen(node.value)
  case node.token.kind
  of tkMinus: return buildFNeg(ctx.builder, v, "negtmp")
  of tkPlus:  return v
  else:       node.token.pos.newError("Unsupported unary: " & node.token.mean())

proc codegenBinary*(ctx: Context, node: BinaryNode): LLVMValueRef =
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
  else:       node.token.pos.newError("Unsupported binary: " & node.token.mean())

proc codegenIdent(ctx: Context, node: IdentNode): LLVMValueRef =
  let name = node.token.lexeme
  if not ctx.env.hasKey(name):
    node.token.pos.newError("Undefined identifier: " & name)
  result = load(ctx.builder, ctx.env[name], name & ".val")

proc codegenNumber(ctx: Context, node: NumberNode): LLVMValueRef =
  constReal(ctx.llvmCtx.f64(), node.value)

proc codegenBlock*(ctx: Context, node: BlockNode): LLVMValueRef =
  var names: HashSet[string]
  collectVars(node, names)
  allocaVars(ctx, names)
  result = constReal(ctx.llvmCtx.f64(), 0.0)
  for stmt in node.body:
    result = ctx.codegen(stmt)

proc codegen*(ctx: Context, node: Node): LLVMValueRef =
  case node.kind
  of nkNumber: ctx.codegenNumber(NumberNode(node))
  of nkUnary:  ctx.codegenUnary(UnaryNode(node))
  of nkBinary: ctx.codegenBinary(BinaryNode(node))
  of nkIdent:  ctx.codegenIdent(IdentNode(node))
  of nkBlock:  ctx.codegenBlock(BlockNode(node))

proc codegenFunction*(ctx: Context, name: string, body: BlockNode): LLVMValueRef =
  let (fn, entryBB) = createFunction(ctx.module, ctx.llvmCtx, name, ctx.llvmCtx.f64(), [])
  positionBuilderAtEnd(ctx.builder, entryBB)
  let v = ctx.codegenBlock(body)
  discard buildRet(ctx.builder, v)
  result = fn