import codegen, parser, jit
import std/[rdstdin, tables, os]
import ../../src/llvnim/[idiomatic, shim, dx]

var state = initTable[string, float]()

proc readGlobals(jctx: jit.Context, names: seq[string]): Table[string, float] =
  for name in names:
    let (addrr, err) = jitLookupLinkerMangled(jctx.jit, jctx.jd, name)
    if err.len == 0 and addrr != 0:
      result[name] = float(cast[ptr cdouble](addrr)[])

while true:
  var code = readLineFromStdin("  >>> ")
  if code == ":q": break

  if code == "":
    code = ""
    while true:
      let l = readLineFromStdin("  ... ")
      code &= l & "\n"
      if l == "": break

  try:
    let ctx = codegen.newContext()
    for name, value in state:
      let g = addGlobal(ctx.module, ctx.llvmCtx.f64(), name.cstring)
      setInitializer(g, constReal(ctx.llvmCtx.f64(), value))
      setGlobalConstant(g, LLVMFalse)
      setLinkage(g, LLVMExternalLinkage)
      ctx.env[name] = g
    discard codegenFunction(ctx, "entry", parse(code))
    let jctx = jit.newContext(getAppDir() / "libruntime.so")
    let v = jctx.evalFunction("entry", ctx.module)
    if v == v:
      echo v

    var names: seq[string]
    for name in state.keys: names.add name
    for name in ctx.env.keys:
      if name notin names: names.add name
    let updated = readGlobals(jctx, names)
    for name, value in updated: state[name] = value
  except CatchableError as e:
    echo "error: ", e.msg