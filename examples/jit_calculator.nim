# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../src/llvnim

proc main() =
  checkVersion()

  discard LLVMInitializeNativeTarget()
  discard LLVMInitializeNativeAsmPrinter()

  let ctx = LLVMContextCreate()
  defer: LLVMContextDispose(ctx)

  let m = LLVMModuleCreateWithNameInContext("calculator", ctx)

  let i32t = LLVMInt32TypeInContext(ctx)
  var params = [i32t, i32t]
  let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
  let fn = LLVMAddFunction(m, "add", fnTy)

  let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
  let b = LLVMCreateBuilderInContext(ctx)
  defer: LLVMDisposeBuilder(b)
  LLVMPositionBuilderAtEnd(b, bb)

  let a = LLVMGetParam(fn, 0)
  let c = LLVMGetParam(fn, 1)
  let sum = LLVMBuildAdd(b, a, c, "sum")
  discard LLVMBuildRet(b, sum)

  let (ok, msg) = verifyModule(m)
  doAssert ok, msg

  let opts = LLVMCreatePassBuilderOptions()
  defer: LLVMDisposePassBuilderOptions(opts)
  let passErr = LLVMRunPasses(m, "default<O2>", LLVMTargetMachineRef(nil), opts)
  if not passErr.isNil:
    let errMsg = LLVMGetErrorMessage(passErr)
    echo "Optimization failed: ", errMsg
    LLVMDisposeErrorMessage(errMsg)
    quit(1)

  let (jit, jitErr) = createLLJIT()
  doAssert jitErr.len == 0, jitErr

  let addErr = addModule(jit, m)
  doAssert addErr.len == 0, addErr

  let (addrr, lookupErr) = lookup(jit, "add")
  doAssert lookupErr.len == 0, lookupErr

  type AddFn = proc(x, y: int32): int32 {.cdecl.}
  let f = cast[AddFn](addrr)

  echo "Executing JIT compiled function:"
  echo "add(20, 22) = ", f(20'i32, 22'i32)

when isMainModule:
  main()