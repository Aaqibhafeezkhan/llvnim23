# Copyright (c) 2026 https://github.com/xlebore3o4ka

import unittest
import ../src/llvnim
import ../src/llvnim/shim
import ../src/llvnim/dx

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

  test "addModuleToDylib adds module to custom dylib":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (jd, jdErr) = jitCreateJITDylib(jit, "custom")
    check jdErr.len == 0

    let ctx = LLVMContextCreate()
    let m = LLVMModuleCreateWithNameInContext("m", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "answer", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 42, LLVMFalse))

    check addModuleToDylib(jit, jd, ctx, m).len == 0
    # ctx ownership transferred; do not dispose

  test "jitMangle returns non-empty string":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let mangled = jitMangle(jit, "my_func")
    check mangled.len > 0

  test "jitGetJITDylibByName returns existing dylib":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (jd, jdErr) = jitCreateJITDylib(jit, "custom")
    check jdErr.len == 0
    let found = jitGetJITDylibByName(jit, "custom")
    check not found.isNil
    check found == jd

  test "jitLookupLinkerMangled finds symbol after addModule":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (jd, jdErr) = jitCreateJITDylib(jit, "custom")
    check jdErr.len == 0

    let ctx = LLVMContextCreate()
    let m = LLVMModuleCreateWithNameInContext("m", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "answer", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 42, LLVMFalse))

    check addModuleToDylib(jit, jd, ctx, m).len == 0

    let mangled = jitMangle(jit, "answer")
    let (addrr, lookupErr) = jitLookupLinkerMangled(jit, jd, mangled)
    check lookupErr.len == 0
    check addrr != 0

  test "jitInitialize and jitDeinitialize on empty dylib succeed":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let (jd, jdErr) = jitCreateJITDylib(jit, "custom")
    check jdErr.len == 0
    let (ok1, msg1) = jitInitializeSafe(jit, jd)
    check ok1
    check msg1.len == 0
    let (ok2, msg2) = jitDeinitializeSafe(jit, jd)
    check ok2
    check msg2.len == 0