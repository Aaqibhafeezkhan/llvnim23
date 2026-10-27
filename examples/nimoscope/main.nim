import codegen, parser, jit
import std/[rdstdin, tables, os]
import ../../src/llvnim/[idiomatic, shim, dx]

when defined(posix):
  import std/posix

  proc segvHandler(sig: cint) {.noconv.} =
    stderr.writeLine("error: segmentation fault (possible stack overflow / infinite recursion)")
    quit(1)

  signal(SIGSEGV, segvHandler)

var state = initTable[string, float]()

proc readGlobals(jctx: jit.Context, jd: LLVMOrcJITDylibRef, names: seq[string]): Table[string, float] =
  for name in names:
    let (addrr, err) = jitLookupLinkerMangled(jctx.jit, jd, name)
    if err.len == 0 and addrr != 0:
      result[name] = float(cast[ptr cdouble](addrr)[])

let ctx = codegen.newContext()
let jctx = jit.newContext(getAppDir() / "libruntime.so")
var counter = 0

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
    for name, value in state:
      if ctx.scopes[0].hasKey(name):
        setInitializer(ctx.scopes[0][name], constReal(ctx.llvmCtx.f64(), value))

    let entryName = "entry_" & $counter
    let jdName = "repl_" & $counter
    inc counter
    discard codegenFunction(ctx, entryName, parse(code))

    let (jd, err) = jitCreateJITDylib(jctx.jit, jdName)
    if err.len > 0:
      raise newException(jit.JitError, "createJITDylib: " & err)
    let ir = $printModuleToString(ctx.module)
    let merr = addModuleToDylib(jctx.jit, jd, ir)
    if merr.len > 0:
      raise newException(jit.JitError, "addModule: " & merr)
    let (addrr, lerr) = jitLookupLinkerMangled(jctx.jit, jd, entryName)
    if lerr.len > 0:
      raise newException(jit.JitError, "lookup: " & lerr)
    let fn = cast[proc(): cdouble {.cdecl.}](addrr)
    let v = float(fn())
    if v == v:
      echo v

    var names: seq[string]
    for name in ctx.scopes[0].keys: names.add name
    let updated = readGlobals(jctx, jd, names)
    for name, value in updated: state[name] = value
  except CatchableError as e:
    echo "error: ", e.msg