# Copyright (c) 2026 https://github.com/xlebore3o4ka

import unittest
import ../src/llvnim
import ../src/llvnim/shim

suite "shim":

  test "jitLinkStaticLibraryInto succeeds":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (jit, err) = createLLJIT()
    check err.len == 0

    let jd = LLVMOrcLLJITGetMainJITDylib(jit)
    let (ok, msg) = jitLinkStaticLibraryInto(jit, jd, "/usr/lib/libLLVMDemangle.a")
    check ok
    check msg.len == 0

  test "jitLoadPlatformDynamicLibrary loads libc":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (ok, msg) = jitLoadPlatformDynamicLibrary(jit, "libc.so.6")
    check ok
    check msg.len == 0

  test "jitCreateJITDylib creates named dylib":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (jd, msg) = jitCreateJITDylib(jit, "plugins")
    check msg.len == 0
    check not jd.isNil

  test "jitAddIRModuleToDylib adds to custom dylib":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (jd, jdErr) = jitCreateJITDylib(jit, "custom")
    check jdErr.len == 0

    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("m", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "answer", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 42, LLVMFalse))

    let (ok, msg) = jitAddIRModuleToDylibSafe(jit, jd, m)
    check ok
    check msg.len == 0