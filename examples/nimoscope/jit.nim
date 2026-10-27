import ../../src/llvnim/[idiomatic, dx, shim]

type
  Context* = ref object
    jit*: LLVMOrcLLJITRef
    jd*: LLVMOrcJITDylibRef

  JitError* = object of CatchableError

proc newContext*(runtimePath: string = ""): Context =
  discard LLVMInitializeNativeTarget()
  discard LLVMInitializeNativeAsmParser()
  discard LLVMInitializeNativeAsmPrinter()
  let (jit, err) = createLLJIT()
  if err.len > 0:
    raise newException(JitError, "createLLJIT: " & err)
  let (jd, err2) = jitCreateJITDylib(jit, "main")
  if err2.len > 0:
    raise newException(JitError, "createJITDylib: " & err2)
  if runtimePath.len > 0:
    let (ok, lerr) = jitLoadPlatformDynamicLibrary(jit, runtimePath)
    if not ok:
      raise newException(JitError, "load " & runtimePath & ": " & lerr)
  Context(jit: jit, jd: jd)
  
proc evalFunction*(ctx: Context, name: string, module: LLVMModuleRef): float =
  let ir = $printModuleToString(module)
  let err = addModuleToDylib(ctx.jit, ctx.jd, ir)
  if err.len > 0:
    raise newException(JitError, "addModule: " & err)
  let (addrr, lerr) = jitLookupLinkerMangled(ctx.jit, ctx.jd, name)
  if lerr.len > 0:
    raise newException(JitError, "lookup: " & lerr)
  let fn = cast[proc(): cdouble {.cdecl.}](addrr)
  result = float(fn())