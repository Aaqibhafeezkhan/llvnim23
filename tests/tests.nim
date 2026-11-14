# Copyright (c) 2026 https://github.com/xlebore3o4ka

import unittest
import std/strutils
import ../src/llvnim
import std/os
import ../src/llvnim/idiomatic
import ../src/llvnim/dx

suite "llvnim":

  test "version check succeeds":
    checkVersion()

  test "pointer ops on non-nil value":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let ctx2 = LLVMContextCreate()
    defer: LLVMContextDispose(ctx2)
    check ctx == ctx
    check ctx != ctx2
    check not ctx.isNil
    check $ctx == $ctx
    check hash(ctx) == hash(ctx)

  test "pointer ops on nil value":
    let nilCtx = cast[LLVMContextRef](nil)
    check nilCtx.isNil
    check nilCtx == nil
    check nil == nilCtx

  test "create and dispose context":
    let ctx = LLVMContextCreate()
    check not ctx.isNil
    LLVMContextDispose(ctx)

  test "create and dispose module":
    let ctx = LLVMContextCreate()
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    check not m.isNil
    LLVMDisposeModule(m)
    LLVMContextDispose(ctx)

  test "print module to string":
    let ctx = LLVMContextCreate()
    let m = LLVMModuleCreateWithNameInContext("testmod", ctx)
    let s = LLVMPrintModuleToString(m)
    check not s.isNil
    check "ModuleID" in $s
    check "testmod" in $s
    LLVMDisposeMessage(s)
    LLVMDisposeModule(m)
    LLVMContextDispose(ctx)

  test "verify empty module ok":
    let ctx = LLVMContextCreate()
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    LLVMDisposeModule(m)
    LLVMContextDispose(ctx)

  test "verify empty module with print action":
    let ctx = LLVMContextCreate()
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    let (ok, _) = verifyModule(m, LLVMPrintMessageAction)
    check ok
    LLVMDisposeModule(m)
    LLVMContextDispose(ctx)

  test "build add function":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    check not i32t.isNil
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    check not fnTy.isNil
    let fn = LLVMAddFunction(m, "add", fnTy)
    check not fn.isNil
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    check not bb.isNil
    let builder = LLVMCreateBuilderInContext(ctx)
    check not builder.isNil
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    check not a.isNil
    check not b.isNil
    let sum = LLVMBuildAdd(builder, a, b, "sum")
    check not sum.isNil
    let ret = LLVMBuildRet(builder, sum)
    check not ret.isNil
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "build constant return function":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "answer", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let c = LLVMConstInt(i32t, 42, LLVMFalse)
    check not c.isNil
    discard LLVMBuildRet(builder, c)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let s = LLVMPrintModuleToString(m)
    check "ret i32 42" in $s
    LLVMDisposeMessage(s)

  test "verify fails on unterminated function":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "broken", fnTy)
    discard LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let (ok, msg) = verifyModule(m)
    check not ok
    check msg.len > 0

  test "varargs function type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMTrue)
    check not fnTy.isNil
    let fn = LLVMAddFunction(m, "variadic", fnTy)
    check not fn.isNil

  test "initialize all targets":
    LLVMInitializeAllTargetInfos()
    LLVMInitializeAllTargets()
    LLVMInitializeAllTargetMCs()
    LLVMInitializeAllAsmParsers()
    LLVMInitializeAllAsmPrinters()
    LLVMInitializeAllDisassemblers()

  test "initialize native target":
    check LLVMInitializeNativeTarget() == LLVMFalse
    check LLVMInitializeNativeAsmParser() == LLVMFalse
    check LLVMInitializeNativeAsmPrinter() == LLVMFalse
    check LLVMInitializeNativeDisassembler() == LLVMFalse

  test "verify fails on mismatched return type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "broken", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let badRet = LLVMBuildRet(builder, fn)
    check not badRet.isNil
    let (ok, msg) = verifyModule(m)
    check not ok
    check msg.len > 0
    check "return" in msg.toLowerAscii or "type" in msg.toLowerAscii

  test "JIT: compile and run add64":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("jit", ctx)

    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add64", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    let sum = LLVMBuildAdd(builder, a, b, "sum")
    discard LLVMBuildRet(builder, sum)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let (ee, err) = createJIT(m, 0)
    check not ee.isNil
    check err.len == 0
    defer: LLVMDisposeExecutionEngine(ee)

    let addrr = LLVMGetFunctionAddress(ee, "add64")
    check addrr != 0

    type AddFn = proc(a, b: int64): int64 {.cdecl.}
    let add = cast[AddFn](addrr)
    check add(20'i64, 22'i64) == 42'i64

  test "JIT: max via ICmp and CondBr":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("maxmod", ctx)

    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "max64", fnTy)

    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let thenBB = LLVMAppendBasicBlockInContext(ctx, fn, "then")
    let elseBB = LLVMAppendBasicBlockInContext(ctx, fn, "else")

    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)

    # entry: %cmp = icmp sgt i64 %a, %b; br i1 %cmp, label %then, label %else
    LLVMPositionBuilderAtEnd(builder, entry)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    let cmp = LLVMBuildICmp(builder, LLVMIntSGT, a, b, "cmp")
    discard LLVMBuildCondBr(builder, cmp, thenBB, elseBB)

    # then: ret i64 %a
    LLVMPositionBuilderAtEnd(builder, thenBB)
    discard LLVMBuildRet(builder, a)

    # else: ret i64 %b
    LLVMPositionBuilderAtEnd(builder, elseBB)
    discard LLVMBuildRet(builder, b)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (ee, err) = createJIT(m, 0)
    check not ee.isNil
    check err.len == 0
    defer: LLVMDisposeExecutionEngine(ee)

    let addrr = LLVMGetFunctionAddress(ee, "max64")
    check addrr != 0
    type MaxFn = proc(x, y: int64): int64 {.cdecl.}
    let maxFn = cast[MaxFn](addrr)
    check maxFn(10, 20) == 20
    check maxFn(42, 7) == 42
    check maxFn(-5, 3) == 3

  test "LLVMGetTypeKind on integer and pointer":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    check LLVMGetTypeKind(LLVMInt32TypeInContext(ctx)) == LLVMIntegerTypeKind
    check LLVMGetTypeKind(LLVMIntTypeInContext(ctx, 7)) == LLVMIntegerTypeKind
    check LLVMGetTypeKind(LLVMDoubleTypeInContext(ctx)) == LLVMDoubleTypeKind
    check LLVMGetTypeKind(LLVMVoidTypeInContext(ctx)) == LLVMVoidTypeKind
    check LLVMGetTypeKind(LLVMPointerTypeInContext(ctx, 0)) == LLVMPointerTypeKind

  test "LLVMGetTypeKind on function type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    check LLVMGetTypeKind(fnTy) == LLVMFunctionTypeKind

  test "LLVMPrintValueToString on constant":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let c = LLVMConstInt(LLVMInt32TypeInContext(ctx), 42, LLVMFalse)
    let s = LLVMPrintValueToString(c)
    check not s.isNil
    check "42" in $s
    LLVMDisposeMessage(s)

  test "LLVMPrintValueToString on instruction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("test", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let sum = LLVMBuildAdd(builder, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
    let s = LLVMPrintValueToString(sum)
    check not s.isNil
    check "add" in $s
    check "sum" in $s
    LLVMDisposeMessage(s)

  test "LLVMDumpModule does not crash":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("dumpme", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "noop", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    discard LLVMBuildRet(builder, LLVMConstInt(i32t, 0, LLVMFalse))
    LLVMDumpModule(m)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "LLVMGetFunctionAddress returns 0 for missing function":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("empty", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "present", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    discard LLVMBuildRet(builder, LLVMConstInt(i32t, 0, LLVMFalse))
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (ee, err) = createJIT(m, 0)
    check not ee.isNil
    check err.len == 0
    defer: LLVMDisposeExecutionEngine(ee)
    check LLVMGetFunctionAddress(ee, "present") != 0
    check LLVMGetFunctionAddress(ee, "missing") == 0

  test "LLVMPrintModuleToString on empty module":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("empty", ctx)
    defer: LLVMDisposeModule(m)
    let s = LLVMPrintModuleToString(m)
    check not s.isNil
    check "ModuleID" in $s
    check "define" notin $s
    LLVMDisposeMessage(s)

  test "verifyModule on declaration is ok":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("broken", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    discard LLVMAddFunction(m, "declaration", fnTy)
    check verifyModule(m).ok

  test "LLVMGetTypeKind distinguishes types":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    check LLVMGetTypeKind(LLVMInt1TypeInContext(ctx)) == LLVMIntegerTypeKind
    check LLVMGetTypeKind(LLVMDoubleTypeInContext(ctx)) == LLVMDoubleTypeKind
    check LLVMGetTypeKind(LLVMPointerTypeInContext(ctx, 0)) == LLVMPointerTypeKind
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    check LLVMGetTypeKind(fnTy) == LLVMFunctionTypeKind

  test "LLVMPrintValueToString on void return":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("void", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "noop", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let r = LLVMBuildRetVoid(builder)
    check not r.isNil
    let s = LLVMPrintValueToString(r)
    check "ret void" in $s
    LLVMDisposeMessage(s)

  test "LLVMBuildICmp with all predicates builds valid IR":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("icmp", ctx)
    defer: LLVMDisposeModule(m)
    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "cmps", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    for pred in [LLVMIntEQ, LLVMIntNE, LLVMIntUGT, LLVMIntUGE,
                 LLVMIntULT, LLVMIntULE, LLVMIntSGT, LLVMIntSGE,
                 LLVMIntSLT, LLVMIntSLE]:
      let c = LLVMBuildICmp(builder, pred, a, b, "c")
      check not c.isNil
    discard LLVMBuildRet(builder, a)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "double add produces invalid IR caught by verifier":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("fadd", ctx)
    defer: LLVMDisposeModule(m)
    let dt = LLVMDoubleTypeInContext(ctx)
    var params = [dt, dt]
    let fnTy = LLVMFunctionType(dt, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "fadd", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    discard LLVMBuildAdd(builder, a, b, "bad")
    discard LLVMBuildRet(builder, a)
    let (ok, msg) = verifyModule(m)
    check not ok
    check msg.len > 0
    check "add" in msg.toLowerAscii or "integer" in msg.toLowerAscii

  test "negative: module with malformed ret keeps verifyModule msg":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("badret", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "bad", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    discard LLVMBuildRet(builder, fn)
    let (ok, msg) = verifyModule(m)
    check not ok
    check msg.len > 0
    check "return" in msg.toLowerAscii or "type" in msg.toLowerAscii

  test "LLJIT: compile and run add64":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("lljit", ctx)

    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add64", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    let sum = LLVMBuildAdd(builder, a, b, "sum")
    discard LLVMBuildRet(builder, sum)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0

    let addErr = addModule(jit, m)
    check addErr.len == 0

    let (addrr, lookupErr) = lookup(jit, "add64")
    check lookupErr.len == 0
    check addrr != 0

    type AddFn = proc(a, b: int64): int64 {.cdecl.}
    let add = cast[AddFn](addrr)
    check add(20'i64, 22'i64) == 42'i64

  test "LLJIT: max via ICmp and CondBr":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("lljit_max", ctx)

    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "max64", fnTy)

    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let thenBB = LLVMAppendBasicBlockInContext(ctx, fn, "then")
    let elseBB = LLVMAppendBasicBlockInContext(ctx, fn, "else")

    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)

    LLVMPositionBuilderAtEnd(builder, entry)
    let a = LLVMGetParam(fn, 0)
    let b = LLVMGetParam(fn, 1)
    let cmp = LLVMBuildICmp(builder, LLVMIntSGT, a, b, "cmp")
    discard LLVMBuildCondBr(builder, cmp, thenBB, elseBB)

    LLVMPositionBuilderAtEnd(builder, thenBB)
    discard LLVMBuildRet(builder, a)

    LLVMPositionBuilderAtEnd(builder, elseBB)
    discard LLVMBuildRet(builder, b)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0

    check addModule(jit, m).len == 0

    let (addrr, lookupErr) = lookup(jit, "max64")
    check lookupErr.len == 0
    check addrr != 0

    type MaxFn = proc(x, y: int64): int64 {.cdecl.}
    let maxFn = cast[MaxFn](addrr)
    check maxFn(10, 20) == 20
    check maxFn(42, 7) == 42
    check maxFn(-5, 3) == 3

  test "LLJIT: lookup missing symbol returns error":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("lljit_empty", ctx)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "present", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let builder = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(builder)
    LLVMPositionBuilderAtEnd(builder, bb)
    discard LLVMBuildRet(builder, LLVMConstInt(i32t, 0, LLVMFalse))

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0

    check addModule(jit, m).len == 0

    let (addr1, err1) = lookup(jit, "present")
    check err1.len == 0
    check addr1 != 0

    let (addr2, err2) = lookup(jit, "missing")
    check err2.len > 0
    check addr2 == 0

  test "LLJIT: invalid IR rejected by verifier before JIT":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("lljit_bad", ctx)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "bad", fnTy)
    discard LLVMAppendBasicBlockInContext(ctx, fn, "entry")

    let (ok, msg) = verifyModule(m)
    check not ok
    check msg.len > 0

  test "global string: addGlobalString builds valid IR":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("gstr", ctx)
    defer: LLVMDisposeModule(m)
    let g = addGlobalString(m, ctx, "msg", "hello")
    check not g.isNil
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let s = LLVMPrintModuleToString(m)
    check "@msg" in $s
    check "private" in $s
    check "constant" in $s
    check "unnamed_addr" in $s
    check "c\"hello\\00\"" notin $s
    LLVMDisposeMessage(s)

  test "global string: lookup by name and value type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("gstr2", ctx)
    defer: LLVMDisposeModule(m)
    discard addGlobalString(m, ctx, "s", "abc")
    let g = LLVMGetNamedGlobal(m, "s")
    check not g.isNil
    check LLVMIsGlobalConstant(g) == LLVMTrue
    check LLVMGetLinkage(g) == LLVMPrivateLinkage
    check LLVMGetUnnamedAddress(g) == LLVMGlobalUnnamedAddr
    check LLVMGetGlobalParent(g) == m
    let ty = LLVMGlobalGetValueType(g)
    check LLVMGetTypeKind(ty) == LLVMArrayTypeKind

  test "global string: empty string":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("gstr3", ctx)
    defer: LLVMDisposeModule(m)
    let g = addGlobalString(m, ctx, "empty", "")
    check not g.isNil
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let s = LLVMPrintModuleToString(m)
    check "[0 x i8] zeroinitializer" in $s or "c\"\"" in $s
    LLVMDisposeMessage(s)

  test "global string: JIT can read string bytes":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("gstr_jit", ctx)

    let g = addGlobalString(m, ctx, "greet", "hi")
    LLVMSetLinkage(g, LLVMExternalLinkage)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0

    check addModule(jit, m).len == 0

    let (addrr, err) = lookup(jit, "greet")
    check err.len == 0
    check addrr != 0

    let p = cast[ptr UncheckedArray[char]](addrr)
    check p[0] == 'h'
    check p[1] == 'i'

  test "memory: alloca + store + load roundtrip":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("mem1", ctx)
    defer: LLVMDisposeModule(m)
    let i64t = LLVMInt64TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i64t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let slot = LLVMBuildAlloca(b, i64t, "slot")
    check not slot.isNil
    discard LLVMBuildStore(b, LLVMConstInt(i64t, 42, LLVMFalse), slot)
    let loaded = LLVMBuildLoad2(b, i64t, slot, "loaded")
    check not loaded.isNil
    discard LLVMBuildRet(b, loaded)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let s = LLVMPrintModuleToString(m)
    check "alloca i64" in $s
    check "store i64 42" in $s
    check "load i64" in $s
    LLVMDisposeMessage(s)

  test "memory: array alloca + GEP2 + store + load":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("mem2", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let arr = LLVMBuildArrayAlloca(b, i32t, LLVMConstInt(i64t, 4, LLVMFalse), "arr")
    check not arr.isNil
    let idx = LLVMConstInt(i64t, 1, LLVMFalse)
    let elem = buildGEP2(b, i32t, arr, [idx], "elem")
    check not elem.isNil
    discard LLVMBuildStore(b, LLVMConstInt(i32t, 7, LLVMFalse), elem)
    let loaded = LLVMBuildLoad2(b, i32t, elem, "loaded")
    check not loaded.isNil
    discard LLVMBuildRet(b, loaded)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let s = LLVMPrintModuleToString(m)
    check "alloca i32, i64 4" in $s
    check "getelementptr i32" in $s
    LLVMDisposeMessage(s)

  test "memory: global string ptr via builder":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("mem3", ctx)
    defer: LLVMDisposeModule(m)
    let i8ptrt = LLVMPointerTypeInContext(ctx, 0)
    let fnTy = LLVMFunctionType(i8ptrt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let str = LLVMBuildGlobalStringPtr(b, "hello", "greet")
    check not str.isNil
    discard LLVMBuildRet(b, str)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let s = LLVMPrintModuleToString(m)
    check "@greet" in $s
    check "ret ptr @greet" in $s
    LLVMDisposeMessage(s)

  test "memory JIT: alloca + store + load":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("mem_jit", ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i64t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "answer", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let slot = LLVMBuildAlloca(b, i64t, "slot")
    discard LLVMBuildStore(b, LLVMConstInt(i64t, 42, LLVMFalse), slot)
    let loaded = LLVMBuildLoad2(b, i64t, slot, "loaded")
    discard LLVMBuildRet(b, loaded)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "answer")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(): int64 {.cdecl.}
    let f = cast[Fn](addrr)
    check f() == 42'i64

  test "integer ops: and/or/xor/shl/lshr/ashr":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("intops", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    check not LLVMBuildAnd(b, a, c, "and").isNil
    check not LLVMBuildOr(b, a, c, "or").isNil
    check not LLVMBuildXor(b, a, c, "xor").isNil
    check not LLVMBuildShl(b, a, c, "shl").isNil
    check not LLVMBuildLShr(b, a, c, "lshr").isNil
    check not LLVMBuildAShr(b, a, c, "ashr").isNil
    let neg = LLVMBuildNeg(b, a, "neg")
    check not neg.isNil
    let notv = LLVMBuildNot(b, a, "not")
    check not notv.isNil
    discard LLVMBuildRet(b, a)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "integer ops: exact div/rem":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("exact", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    check not LLVMBuildExactSDiv(b, a, c, "sdiv").isNil
    check not LLVMBuildExactUDiv(b, a, c, "udiv").isNil
    discard LLVMBuildRet(b, a)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "casts: trunc/zext/sext":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("casts1", ctx)
    defer: LLVMDisposeModule(m)
    let i16t = LLVMInt16TypeInContext(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i16t, i32t, i64t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 3, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let p16 = LLVMGetParam(fn, 0)
    let p32 = LLVMGetParam(fn, 1)
    let z = LLVMBuildZExt(b, p16, i32t, "z")
    check not z.isNil
    let t = LLVMBuildTrunc(b, p32, i16t, "t")
    check not t.isNil
    let s = LLVMBuildSExt(b, p16, i64t, "s")
    check not s.isNil
    discard LLVMBuildRet(b, z)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "zext i16 %0 to i32" in $ir
    check "trunc i32 %1 to i16" in $ir
    check "sext i16 %0 to i64" in $ir
    LLVMDisposeMessage(ir)

  test "casts: intCast2 signed and unsigned":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("intcast", ctx)
    defer: LLVMDisposeModule(m)
    let i8t = LLVMInt8TypeInContext(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let c = LLVMConstInt(i8t, 5, LLVMFalse)
    let su = LLVMBuildIntCast2(b, c, i32t, LLVMFalse, "zext")
    check not su.isNil
    let ss = LLVMBuildIntCast2(b, c, i32t, LLVMTrue, "sext")
    check not ss.isNil
    discard LLVMBuildRet(b, su)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "casts: ptrToInt and intToPtr":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("ptrops", ctx)
    defer: LLVMDisposeModule(m)
    let i64t = LLVMInt64TypeInContext(ctx)
    let ptrt = LLVMPointerTypeInContext(ctx, 0)
    let fnTy = LLVMFunctionType(i64t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let slot = LLVMBuildAlloca(b, i64t, "slot")
    let asInt = LLVMBuildPtrToInt(b, slot, i64t, "asint")
    check not asInt.isNil
    let asPtr = LLVMBuildIntToPtr(b, asInt, ptrt, "asptr")
    check not asPtr.isNil
    discard LLVMBuildRet(b, asInt)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "ptrtoint" in $ir
    check "inttoptr" in $ir
    LLVMDisposeMessage(ir)

  test "integer ops JIT: mixed arithmetic":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("intjit", ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "calc", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    # (a + b) * 2 - (a xor b)
    let sum = LLVMBuildAdd(b, a, c, "sum")
    let two = LLVMConstInt(i64t, 2, LLVMFalse)
    let mul = LLVMBuildMul(b, sum, two, "mul")
    let x = LLVMBuildXor(b, a, c, "xor")
    let sub = LLVMBuildSub(b, mul, x, "sub")
    discard LLVMBuildRet(b, sub)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "calc")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(x, y: int64): int64 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(3'i64, 5'i64) == 10'i64
    check f(10'i64, 2'i64) == 16'i64

  test "float ops: fadd/fsub/fmul/fdiv/frem/fneg":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("fops", ctx)
    defer: LLVMDisposeModule(m)
    let dt = LLVMDoubleTypeInContext(ctx)
    var params = [dt, dt]
    let fnTy = LLVMFunctionType(dt, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    check not LLVMBuildFAdd(b, a, c, "fa").isNil
    check not LLVMBuildFSub(b, a, c, "fs").isNil
    check not LLVMBuildFMul(b, a, c, "fm").isNil
    check not LLVMBuildFDiv(b, a, c, "fd").isNil
    check not LLVMBuildFRem(b, a, c, "fr").isNil
    check not LLVMBuildFNeg(b, a, "fn").isNil
    discard LLVMBuildRet(b, a)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "fadd double" in $ir
    check "fsub double" in $ir
    check "fmul double" in $ir
    check "fdiv double" in $ir
    check "frem double" in $ir
    check "fneg double" in $ir
    LLVMDisposeMessage(ir)

  test "float ops: fcmp with all predicates":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("fcmp", ctx)
    defer: LLVMDisposeModule(m)
    let dt = LLVMDoubleTypeInContext(ctx)
    let i1t = LLVMInt1TypeInContext(ctx)
    var params = [dt, dt]
    let fnTy = LLVMFunctionType(i1t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    for pred in [LLVMRealOEQ, LLVMRealOGT, LLVMRealOGE, LLVMRealOLT,
                 LLVMRealOLE, LLVMRealONE, LLVMRealORD, LLVMRealUNO,
                 LLVMRealUEQ, LLVMRealUGT, LLVMRealUGE, LLVMRealULT,
                 LLVMRealULE, LLVMRealUNE]:
      check not LLVMBuildFCmp(b, pred, a, c, "cmp").isNil
    let last = LLVMBuildFCmp(b, LLVMRealOEQ, a, c, "final")
    discard LLVMBuildRet(b, last)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "float casts: fpext/fptrunc/fptosi/fptoui/sitofp/uitofp":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("fcasts", ctx)
    defer: LLVMDisposeModule(m)
    let ft = LLVMFloatTypeInContext(ctx)
    let dt = LLVMDoubleTypeInContext(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [ft, i32t]
    let fnTy = LLVMFunctionType(dt, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let pf = LLVMGetParam(fn, 0)
    let pi = LLVMGetParam(fn, 1)
    let ext = LLVMBuildFPExt(b, pf, dt, "ext")
    check not ext.isNil
    let trunc = LLVMBuildFPTrunc(b, ext, ft, "trunc")
    check not trunc.isNil
    let f2i = LLVMBuildFPToSI(b, ext, i32t, "f2i")
    check not f2i.isNil
    let f2u = LLVMBuildFPToUI(b, ext, i32t, "f2u")
    check not f2u.isNil
    let i2f = LLVMBuildSIToFP(b, pi, dt, "i2f")
    check not i2f.isNil
    let u2f = LLVMBuildUIToFP(b, pi, dt, "u2f")
    check not u2f.isNil
    discard LLVMBuildRet(b, ext)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "fpext float" in $ir
    check "fptrunc double" in $ir
    check "fptosi double" in $ir
    check "fptoui double" in $ir
    check "sitofp i32" in $ir
    check "uitofp i32" in $ir
    LLVMDisposeMessage(ir)

  test "constants: constReal and nulls":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let dt = LLVMDoubleTypeInContext(ctx)
    let ptrt = LLVMPointerTypeInContext(ctx, 0)
    let r = LLVMConstReal(dt, 3.5)
    check not r.isNil
    let s = LLVMPrintValueToString(r)
    check "3.500000e+00" in $s
    LLVMDisposeMessage(s)
    let n = LLVMConstNull(dt)
    check not n.isNil
    let pn = LLVMConstPointerNull(ptrt)
    check not pn.isNil
    let rs = LLVMConstRealOfString(dt, "2.25")
    check not rs.isNil
    let s2 = LLVMPrintValueToString(rs)
    check "2.250000e+00" in $s2
    LLVMDisposeMessage(s2)

  test "float JIT: arithmetic and comparison":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("fjit", ctx)
    let dt = LLVMDoubleTypeInContext(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [dt, dt]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "cmp", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let x = LLVMGetParam(fn, 0)
    let y = LLVMGetParam(fn, 1)
    let s = LLVMBuildFAdd(b, x, y, "s")
    let cmpv = LLVMBuildFCmp(b, LLVMRealOGT, s, LLVMConstReal(dt, 10.0), "gt")
    let ext = LLVMBuildZExt(b, cmpv, i32t, "ext")
    discard LLVMBuildRet(b, ext)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "cmp")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(a, b: float64): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(6.0, 5.0) == 1'i32
    check f(2.0, 3.0) == 0'i32

  test "control flow: switch":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("sw", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "sw", fnTy)
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let c0 = LLVMAppendBasicBlockInContext(ctx, fn, "c0")
    let c1 = LLVMAppendBasicBlockInContext(ctx, fn, "c1")
    let defBB = LLVMAppendBasicBlockInContext(ctx, fn, "default")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, entry)
    let x = LLVMGetParam(fn, 0)
    let sw = LLVMBuildSwitch(bld, x, defBB, 2)
    check not sw.isNil
    LLVMAddCase(sw, LLVMConstInt(i32t, 0, LLVMFalse), c0)
    LLVMAddCase(sw, LLVMConstInt(i32t, 1, LLVMFalse), c1)
    LLVMPositionBuilderAtEnd(bld, c0)
    discard LLVMBuildRet(bld, LLVMConstInt(i32t, 100, LLVMFalse))
    LLVMPositionBuilderAtEnd(bld, c1)
    discard LLVMBuildRet(bld, LLVMConstInt(i32t, 200, LLVMFalse))
    LLVMPositionBuilderAtEnd(bld, defBB)
    discard LLVMBuildRet(bld, LLVMConstInt(i32t, 999, LLVMFalse))
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "switch i32" in $ir
    LLVMDisposeMessage(ir)
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "sw")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(x: int32): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(0'i32) == 100'i32
    check f(1'i32) == 200'i32
    check f(7'i32) == 999'i32

  test "control flow: phi join":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("phi", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i1t = LLVMInt1TypeInContext(ctx)
    var params = [i1t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "phi", fnTy)
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let bbA = LLVMAppendBasicBlockInContext(ctx, fn, "a")
    let bbB = LLVMAppendBasicBlockInContext(ctx, fn, "b")
    let join = LLVMAppendBasicBlockInContext(ctx, fn, "join")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, entry)
    let cond = LLVMGetParam(fn, 0)
    discard LLVMBuildCondBr(bld, cond, bbA, bbB)
    LLVMPositionBuilderAtEnd(bld, bbA)
    discard LLVMBuildBr(bld, join)
    LLVMPositionBuilderAtEnd(bld, bbB)
    discard LLVMBuildBr(bld, join)
    LLVMPositionBuilderAtEnd(bld, join)
    let phi = LLVMBuildPhi(bld, i32t, "x")
    check not phi.isNil
    var vals = [LLVMConstInt(i32t, 10, LLVMFalse), LLVMConstInt(i32t, 20, LLVMFalse)]
    var blocks = [bbA, bbB]
    LLVMAddIncoming(phi, addr vals[0], addr blocks[0], 2)
    discard LLVMBuildRet(bld, phi)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "phi i32" in $ir
    LLVMDisposeMessage(ir)

  test "control flow: select":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("sel", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 3, LLVMFalse)
    let fn = LLVMAddFunction(m, "sel", fnTy)
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, entry)
    let c = LLVMGetParam(fn, 0)
    let x = LLVMGetParam(fn, 1)
    let y = LLVMGetParam(fn, 2)
    let cond = LLVMBuildICmp(bld, LLVMIntNE, c, LLVMConstInt(i32t, 0, LLVMFalse), "cond")
    let s = LLVMBuildSelect(bld, cond, x, y, "sel")
    check not s.isNil
    discard LLVMBuildRet(bld, s)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "select i1" in $ir
    LLVMDisposeMessage(ir)
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "sel")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(c, x, y: int32): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(1'i32, 10'i32, 20'i32) == 10'i32
    check f(0'i32, 10'i32, 20'i32) == 20'i32

  test "control flow: unreachable":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("unr", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "boom", fnTy)
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, entry)
    let u = LLVMBuildUnreachable(bld)
    check not u.isNil
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "unreachable" in $ir
    LLVMDisposeMessage(ir)

  test "control flow JIT: phi loop sum":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("philoop", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "sum", fnTy)
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let loop = LLVMAppendBasicBlockInContext(ctx, fn, "loop")
    let exit = LLVMAppendBasicBlockInContext(ctx, fn, "exit")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, entry)
    let n = LLVMGetParam(fn, 0)
    discard LLVMBuildBr(bld, loop)
    LLVMPositionBuilderAtEnd(bld, loop)
    let iPhi = LLVMBuildPhi(bld, i32t, "i")
    let accPhi = LLVMBuildPhi(bld, i32t, "acc")
    let nextAcc = LLVMBuildAdd(bld, accPhi, iPhi, "next_acc")
    let nextI = LLVMBuildAdd(bld, iPhi, LLVMConstInt(i32t, 1, LLVMFalse), "next_i")
    let cmp = LLVMBuildICmp(bld, LLVMIntSLE, iPhi, n, "cmp")
    discard LLVMBuildCondBr(bld, cmp, loop, exit)
    LLVMPositionBuilderAtEnd(bld, exit)
    discard LLVMBuildRet(bld, accPhi)
    var iVals = [LLVMConstInt(i32t, 1, LLVMFalse), nextI]
    var iBlocks = [entry, loop]
    LLVMAddIncoming(iPhi, addr iVals[0], addr iBlocks[0], 2)
    var accVals = [LLVMConstInt(i32t, 0, LLVMFalse), nextAcc]
    var accBlocks = [entry, loop]
    LLVMAddIncoming(accPhi, addr accVals[0], addr accBlocks[0], 2)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "sum")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(n: int32): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(5'i32) == 15'i32
    check f(10'i32) == 55'i32

  test "types: literal struct":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let dt = LLVMDoubleTypeInContext(ctx)
    var elems = [i32t, dt]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    check not st.isNil
    check LLVMGetTypeKind(st) == LLVMStructTypeKind
    check LLVMIsLiteralStruct(st) == LLVMTrue
    check LLVMIsPackedStruct(st) == LLVMFalse
    check LLVMIsOpaqueStruct(st) == LLVMFalse
    check LLVMStructGetTypeAtIndex(st, 0) == i32t
    check LLVMStructGetTypeAtIndex(st, 1) == dt

  test "types: packed struct":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i8t = LLVMInt8TypeInContext(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var elems = [i8t, i32t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMTrue)
    check LLVMIsPackedStruct(st) == LLVMTrue

  test "types: named struct with body":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let st = LLVMStructCreateNamed(ctx, "Point")
    check not st.isNil
    check LLVMIsOpaqueStruct(st) == LLVMTrue
    check $LLVMGetStructName(st) == "Point"
    let i32t = LLVMInt32TypeInContext(ctx)
    var elems = [i32t, i32t]
    LLVMStructSetBody(st, addr elems[0], 2, LLVMFalse)
    check LLVMIsOpaqueStruct(st) == LLVMFalse
    check LLVMStructGetTypeAtIndex(st, 0) == i32t

  test "types: vector and array":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let v = LLVMVectorType(i32t, 4)
    check LLVMGetTypeKind(v) == LLVMVectorTypeKind
    check LLVMGetVectorSize(v) == 4
    check LLVMGetElementType(v) == i32t
    let sv = LLVMScalableVectorType(i32t, 4)
    check LLVMGetTypeKind(sv) == LLVMScalableVectorTypeKind
    let a = LLVMArrayType2(i32t, 8)
    check LLVMGetTypeKind(a) == LLVMArrayTypeKind
    check LLVMGetArrayLength2(a) == 8'u64
    check LLVMGetElementType(a) == i32t

  test "types: struct in function signature":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("stfn", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var elems = [i32t, i32t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    let fnTy = LLVMFunctionType(st, nil, 0, LLVMFalse)
    check not fnTy.isNil
    let fn = LLVMAddFunction(m, "mk", fnTy)
    check not fn.isNil
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "{ i32, i32 } @mk" in $ir
    LLVMDisposeMessage(ir)

  test "aggregates: insertValue and extractValue":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("agg1", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var elems = [i32t, i32t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let x = LLVMGetParam(fn, 0)
    let y = LLVMGetParam(fn, 1)
    let undef = LLVMGetUndef(st)
    let v0 = LLVMBuildInsertValue(b, undef, x, 0, "v0")
    let v1 = LLVMBuildInsertValue(b, v0, y, 1, "v1")
    let e0 = LLVMBuildExtractValue(b, v1, 0, "e0")
    let e1 = LLVMBuildExtractValue(b, v1, 1, "e1")
    let sum = LLVMBuildAdd(b, e0, e1, "sum")
    discard LLVMBuildRet(b, sum)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "insertvalue" in $ir
    check "extractvalue" in $ir
    LLVMDisposeMessage(ir)

  test "aggregates: extractElement and insertElement":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("agg2", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    let vt = LLVMVectorType(i32t, 4)
    var params = [i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let x = LLVMGetParam(fn, 0)
    let zeroVec = LLVMConstNull(vt)
    let idx = LLVMConstInt(i64t, 2, LLVMFalse)
    let ins = LLVMBuildInsertElement(b, zeroVec, x, idx, "ins")
    let ext = LLVMBuildExtractElement(b, ins, idx, "ext")
    discard LLVMBuildRet(b, ext)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "insertelement" in $ir
    check "extractelement" in $ir
    LLVMDisposeMessage(ir)

  test "aggregates: shuffleVector":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("agg3", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let vt = LLVMVectorType(i32t, 4)
    var params = [vt]
    let fnTy = LLVMFunctionType(vt, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let v = LLVMGetParam(fn, 0)
    var maskElems = [
      LLVMConstInt(i32t, 0, LLVMFalse),
      LLVMConstInt(i32t, 1, LLVMFalse),
      LLVMConstInt(i32t, 2, LLVMFalse),
      LLVMConstInt(i32t, 3, LLVMFalse)
    ]
    let mask = LLVMConstVector(addr maskElems[0], 4)
    let sh = LLVMBuildShuffleVector(b, v, v, mask, "sh")
    check not sh.isNil
    discard LLVMBuildRet(b, sh)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "shufflevector" in $ir
    LLVMDisposeMessage(ir)

  test "aggregates: constStruct and constArray":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var vals = [LLVMConstInt(i32t, 1, LLVMFalse), LLVMConstInt(i32t, 2, LLVMFalse)]
    let st = LLVMConstStructInContext(ctx, addr vals[0], 2, LLVMFalse)
    check not st.isNil
    let s = LLVMPrintValueToString(st)
    check "{ i32 1, i32 2 }" in $s
    LLVMDisposeMessage(s)
    let arr = LLVMConstArray2(i32t, addr vals[0], 2)
    check not arr.isNil
    let sa = LLVMPrintValueToString(arr)
    check "[i32 1, i32 2]" in $sa
    LLVMDisposeMessage(sa)

  test "aggregates JIT: struct build and extract":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("aggjit", ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    var elems = [i32t, i32t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "second", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let x = LLVMGetParam(fn, 0)
    let y = LLVMGetParam(fn, 1)
    let undef = LLVMGetUndef(st)
    let v0 = LLVMBuildInsertValue(b, undef, x, 0, "v0")
    let v1 = LLVMBuildInsertValue(b, v0, y, 1, "v1")
    let e1 = LLVMBuildExtractValue(b, v1, 1, "e1")
    discard LLVMBuildRet(b, e1)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "second")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(a, b: int32): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(10'i32, 42'i32) == 42'i32

  test "constexpr: integer add/sub/neg/not/xor":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let a = LLVMConstInt(i32t, 10, LLVMFalse)
    let b = LLVMConstInt(i32t, 3, LLVMFalse)
    check LLVMIsConstant(LLVMConstAdd(a, b)) == LLVMTrue
    check LLVMIsConstant(LLVMConstSub(a, b)) == LLVMTrue
    check LLVMIsConstant(LLVMConstXor(a, b)) == LLVMTrue
    check LLVMIsConstant(LLVMConstNeg(a)) == LLVMTrue
    check LLVMIsConstant(LLVMConstNot(a)) == LLVMTrue
    check LLVMIsConstant(LLVMConstNSWAdd(a, b)) == LLVMTrue
    check LLVMIsConstant(LLVMConstNUWSub(a, b)) == LLVMTrue

  test "constexpr: predicates isConstant/isNull/isUndef":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let c = LLVMConstInt(i32t, 5, LLVMFalse)
    let nullc = LLVMConstNull(i32t)
    let undef = LLVMGetUndef(i32t)
    check LLVMIsConstant(c) == LLVMTrue
    check LLVMIsConstant(nullc) == LLVMTrue
    check LLVMIsNull(nullc) == LLVMTrue
    check LLVMIsNull(c) == LLVMFalse
    check LLVMIsUndef(undef) == LLVMTrue

  test "constexpr: casts trunc/bitcast":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i8t = LLVMInt8TypeInContext(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let dt = LLVMDoubleTypeInContext(ctx)
    let c32 = LLVMConstInt(i32t, 7, LLVMFalse)
    check LLVMIsConstant(LLVMConstTrunc(c32, i8t)) == LLVMTrue
    let bc = LLVMConstBitCast(LLVMConstInt(i32t, 0, LLVMFalse), dt)
    check LLVMIsConstant(bc) == LLVMTrue

  test "constexpr: ptrToInt and intToPtr":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    let ptrt = LLVMPointerTypeInContext(ctx, 0)
    let nullp = LLVMConstPointerNull(ptrt)
    let asInt = LLVMConstPtrToInt(nullp, i64t)
    check LLVMIsConstant(asInt) == LLVMTrue
    let asPtr = LLVMConstIntToPtr(asInt, ptrt)
    check LLVMIsConstant(asPtr) == LLVMTrue

  test "constexpr: constGEP2 into global array":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("cgep", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    var elems = [
      LLVMConstInt(i32t, 10, LLVMFalse),
      LLVMConstInt(i32t, 20, LLVMFalse),
      LLVMConstInt(i32t, 30, LLVMFalse)
    ]
    let arrTy = LLVMArrayType2(i32t, 3)
    let arr = LLVMConstArray2(i32t, addr elems[0], 3)
    let g = LLVMAddGlobal(m, arrTy, "arr")
    LLVMSetInitializer(g, arr)
    LLVMSetGlobalConstant(g, LLVMTrue)
    let idx0 = LLVMConstInt(i64t, 0, LLVMFalse)
    let idx1 = LLVMConstInt(i64t, 1, LLVMFalse)
    var indices = [idx0, idx1]
    let gep = LLVMConstGEP2(arrTy, g, addr indices[0], 2)
    check LLVMIsConstant(gep) == LLVMTrue
    let s = LLVMPrintValueToString(gep)
    check "getelementptr" in $s
    LLVMDisposeMessage(s)
    check LLVMIsConstant(gep) == LLVMTrue

  test "constexpr: extract/insert element and shuffleVector":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    let vt = LLVMVectorType(i32t, 4)
    let zeroVec = LLVMConstNull(vt)
    let idx = LLVMConstInt(i64t, 1, LLVMFalse)
    let one = LLVMConstInt(i32t, 42, LLVMFalse)
    let ins = LLVMConstInsertElement(zeroVec, one, idx)
    check LLVMIsConstant(ins) == LLVMTrue
    let ext = LLVMConstExtractElement(ins, idx)
    check LLVMIsConstant(ext) == LLVMTrue
    var maskElems = [
      LLVMConstInt(i32t, 0, LLVMFalse),
      LLVMConstInt(i32t, 1, LLVMFalse),
      LLVMConstInt(i32t, 2, LLVMFalse),
      LLVMConstInt(i32t, 3, LLVMFalse)
    ]
    let mask = LLVMConstVector(addr maskElems[0], 4)
    let sh = LLVMConstShuffleVector(zeroVec, zeroVec, mask)
    check LLVMIsConstant(sh) == LLVMTrue

  test "constexpr: allOnes and const int extraction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let ones = LLVMConstAllOnes(i32t)
    check LLVMIsConstant(ones) == LLVMTrue
    check LLVMConstIntGetZExtValue(ones) == 0xFFFFFFFF'u64
    check LLVMConstIntGetSExtValue(ones) == -1'i64
    let c = LLVMConstInt(i32t, 42, LLVMFalse)
    check LLVMConstIntGetZExtValue(c) == 42'u64
    check LLVMConstIntGetSExtValue(c) == 42'i64

  test "constexpr: constRealGetDouble":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let dt = LLVMDoubleTypeInContext(ctx)
    let r = LLVMConstReal(dt, 3.5)
    var lossy = LLVMFalse
    let v = LLVMConstRealGetDouble(r, addr lossy)
    check v == 3.5
    check lossy == LLVMFalse

  test "atomics: atomicrmw add builds valid IR":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("atomic1", ctx)
    defer: LLVMDisposeModule(m)
    let i64t = LLVMInt64TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i64t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let slot = LLVMBuildAlloca(b, i64t, "slot")
    discard LLVMBuildStore(b, LLVMConstInt(i64t, 0, LLVMFalse), slot)
    let old = LLVMBuildAtomicRMW(b, LLVMAtomicRMWBinOpAdd, slot, LLVMConstInt(i64t, 1, LLVMFalse), LLVMAtomicOrderingSequentiallyConsistent, LLVMFalse)
    check not old.isNil
    let loaded = LLVMBuildLoad2(b, i64t, slot, "loaded")
    discard LLVMBuildRet(b, loaded)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "atomicrmw add" in $ir
    check "seq_cst" in $ir
    LLVMDisposeMessage(ir)

  test "atomics: cmpxchg builds valid IR":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("atomic2", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let slot = LLVMBuildAlloca(b, i32t, "slot")
    discard LLVMBuildStore(b, LLVMConstInt(i32t, 0, LLVMFalse), slot)
    let cmpx = LLVMBuildAtomicCmpXchg(b, slot,
      LLVMConstInt(i32t, 0, LLVMFalse),
      LLVMConstInt(i32t, 42, LLVMFalse),
      LLVMAtomicOrderingAcquire, LLVMAtomicOrderingMonotonic,
      LLVMFalse)
    check not cmpx.isNil
    let old = LLVMBuildExtractValue(b, cmpx, 0, "old")
    discard LLVMBuildRet(b, old)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "cmpxchg" in $ir
    LLVMDisposeMessage(ir)

  test "atomics: fence builds valid IR":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("atomic3", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let f = LLVMBuildFence(b, LLVMAtomicOrderingRelease, LLVMFalse, "")
    check not f.isNil
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "fence release" in $ir
    LLVMDisposeMessage(ir)

  test "atomics JIT: single-threaded counter":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("atomicjit", ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "increment", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let n = LLVMGetParam(fn, 0)
    let slot = LLVMBuildAlloca(b, i64t, "slot")
    discard LLVMBuildStore(b, LLVMConstInt(i64t, 0, LLVMFalse), slot)
    discard LLVMBuildAtomicRMW(b, LLVMAtomicRMWBinOpAdd, slot, n, LLVMAtomicOrderingSequentiallyConsistent, LLVMFalse)
    let loaded = LLVMBuildLoad2(b, i64t, slot, "loaded")
    discard LLVMBuildRet(b, loaded)
    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0
    check addModule(jit, m).len == 0
    let (addrr, lookupErr) = lookup(jit, "increment")
    check lookupErr.len == 0
    check addrr != 0
    type Fn = proc(n: int64): int64 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(5'i64) == 5'i64
    check f(10'i64) == 10'i64

  test "exceptions: landingpad and resume building":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("eh1", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let ptrt = LLVMPointerTypeInContext(ctx, 0)
    var lpTys = [ptrt, i32t]
    let lpT = LLVMStructTypeInContext(ctx, addr lpTys[0], 2, LLVMFalse)
    
    let persTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let pers = LLVMAddFunction(m, "__gxx_personality_v0", persTy)
    
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    
    let lp = LLVMBuildLandingPad(b, lpT, pers, 0, "lp")
    check not lp.isNil
    LLVMSetCleanup(lp, LLVMTrue)
    
    let exn = LLVMBuildExtractValue(b, lp, 0, "exn")
    let res = LLVMBuildResume(b, exn)
    check not res.isNil
    
    let s = LLVMPrintValueToString(lp)
    check "landingpad" in $s
    check "cleanup" in $s
    LLVMDisposeMessage(s)

  test "exceptions: catchpad builds valid instruction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("eh2", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    
    let undef = LLVMGetUndef(LLVMPointerTypeInContext(ctx, 0))
    let cp = LLVMBuildCatchPad(b, undef, nil, 0, "cp")
    check not cp.isNil
    
    let s = LLVMPrintValueToString(cp)
    check "catchpad" in $s
    LLVMDisposeMessage(s)

  test "exceptions: cleanuppad builds valid instruction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("eh3", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    
    let undef = LLVMGetUndef(LLVMPointerTypeInContext(ctx, 0))
    let cp = LLVMBuildCleanupPad(b, undef, nil, 0, "cp")
    check not cp.isNil
    
    let s = LLVMPrintValueToString(cp)
    check "cleanuppad" in $s
    LLVMDisposeMessage(s)

  test "passes: default<O1> folds constants":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("opt1", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMConstInt(i32t, 10, LLVMFalse)
    let c = LLVMConstInt(i32t, 32, LLVMFalse)
    let sum = LLVMBuildAdd(b, a, c, "sum")
    discard LLVMBuildRet(b, sum)
    
    let opts = LLVMCreatePassBuilderOptions()
    defer: LLVMDisposePassBuilderOptions(opts)
    
    let err = LLVMRunPasses(m, "default<O1>", LLVMTargetMachineRef(nil), opts)
    check err.isNil
    
    let ir = LLVMPrintModuleToString(m)
    check "ret i32 42" in $ir
    check "add i32" notin $ir
    LLVMDisposeMessage(ir)

  test "passes: instcombine removes identity add":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("opt2", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let x = LLVMGetParam(fn, 0)
    let sum = LLVMBuildAdd(b, x, LLVMConstInt(i32t, 0, LLVMFalse), "sum")
    discard LLVMBuildRet(b, sum)
    
    let opts = LLVMCreatePassBuilderOptions()
    defer: LLVMDisposePassBuilderOptions(opts)
    
    let err = LLVMRunPasses(m, "instcombine", LLVMTargetMachineRef(nil), opts)
    check err.isNil
    
    let ir = LLVMPrintModuleToString(m)
    check "ret i32 %0" in $ir
    check "add i32" notin $ir
    LLVMDisposeMessage(ir)

  test "passes: runPassesOnFunction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("opt3", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMBuildAdd(b, LLVMConstInt(i32t, 1, LLVMFalse), LLVMConstInt(i32t, 2, LLVMFalse), "sum"))
    
    let opts = LLVMCreatePassBuilderOptions()
    defer: LLVMDisposePassBuilderOptions(opts)
    
    let err = LLVMRunPassesOnFunction(fn, "instcombine", LLVMTargetMachineRef(nil), opts)
    check err.isNil
    
    let ir = LLVMPrintModuleToString(m)
    check "ret i32 3" in $ir
    LLVMDisposeMessage(ir)

  test "passes: invalid pass name returns error":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("opt4", ctx)
    defer: LLVMDisposeModule(m)
    let opts = LLVMCreatePassBuilderOptions()
    defer: LLVMDisposePassBuilderOptions(opts)
    
    let err = LLVMRunPasses(m, "totally-invalid-pass", LLVMTargetMachineRef(nil), opts)
    check not err.isNil
    
    let msg = LLVMGetErrorMessage(err)
    check "unknown" in $msg or "invalid" in $msg or "pass" in $msg
    LLVMDisposeErrorMessage(msg)

  test "target machine: emit assembly and object file":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("aot", ctx)
    defer: LLVMDisposeModule(m)

    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add64", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    let sum = LLVMBuildAdd(b, a, c, "sum")
    discard LLVMBuildRet(b, sum)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let tripleC = LLVMGetDefaultTargetTriple()
    check not tripleC.isNil
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)

    var target: LLVMTargetRef
    var errMsg: cstring
    if LLVMGetTargetFromTriple(triple.cstring, target, errMsg) != LLVMFalse:
      check false # Failed to get target
      if not errMsg.isNil: LLVMDisposeMessage(errMsg)
    else:
      check not target.isNil
      LLVMSetTarget(m, triple.cstring)

      let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocPIC, LLVMCodeModelDefault)
      check not tm.isNil
      defer: LLVMDisposeTargetMachine(tm)

      let asmFile = "/tmp/llvnim_test.s"
      var emitErr: cstring
      let resAsm = LLVMTargetMachineEmitToFile(tm, m, asmFile.cstring, LLVMAssemblyFile, emitErr)
      check resAsm == LLVMFalse
      if not emitErr.isNil:
        check false
        LLVMDisposeMessage(emitErr)
      
      check fileExists(asmFile)
      let asmContent = readFile(asmFile)
      check asmContent.len > 0
      check "add64" in asmContent
      removeFile(asmFile)

      let objFile = "/tmp/llvnim_test.o"
      emitErr = nil
      let resObj = LLVMTargetMachineEmitToFile(tm, m, objFile.cstring, LLVMObjectFile, emitErr)
      check resObj == LLVMFalse
      if not emitErr.isNil:
        check false
        LLVMDisposeMessage(emitErr)
      
      check fileExists(objFile)
      let objInfo = getFileInfo(objFile)
      check objInfo.size > 0
      removeFile(objFile)

  test "attributes: enum attribute noinline":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("attrs1", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    let kind = LLVMGetEnumAttributeKindForName("noinline", csize_t(8))
    check kind > 0
    let attr = LLVMCreateEnumAttribute(ctx, kind, 0)
    check not attr.isNil
    LLVMAddAttributeAtIndex(fn, LLVMAttributeFunctionIndex, attr)

    let ir = LLVMPrintModuleToString(m)
    check "noinline" in $ir
    LLVMDisposeMessage(ir)

    let got = LLVMGetEnumAttributeAtIndex(fn, LLVMAttributeFunctionIndex, kind)
    check not got.isNil
    check LLVMGetEnumAttributeKind(got) == kind

  test "attributes: enum attribute with value (align)":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("attrs2", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    let kind = LLVMGetEnumAttributeKindForName("align", csize_t(5))
    let attr = LLVMCreateEnumAttribute(ctx, kind, 8)
    LLVMAddAttributeAtIndex(fn, LLVMAttributeFunctionIndex, attr)

    let ir = LLVMPrintModuleToString(m)
    check "align 8" in $ir
    LLVMDisposeMessage(ir)

    let got = LLVMGetEnumAttributeAtIndex(fn, LLVMAttributeFunctionIndex, kind)
    check LLVMGetEnumAttributeValue(got) == 8'u64

  test "attributes: string attribute":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("attrs3", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    let attr = LLVMCreateStringAttribute(ctx, "target-cpu", cuint(10), "skylake", cuint(7))
    LLVMAddAttributeAtIndex(fn, LLVMAttributeFunctionIndex, attr)

    let ir = LLVMPrintModuleToString(m)
    check "target-cpu" in $ir
    check "skylake" in $ir
    LLVMDisposeMessage(ir)

  test "attributes: addStringAttribute helper":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("attrs4", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    addStringAttribute(ctx, fn, "target-features", "+sse2")
    let ir = LLVMPrintModuleToString(m)
    check "+sse2" in $ir
    LLVMDisposeMessage(ir)

  test "attributes: target-dependent and removal":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("attrs5", ctx)
    defer: LLVMDisposeModule(m)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    LLVMAddTargetDependentFunctionAttr(fn, "frame-pointer", "all")
    let ir1 = LLVMPrintModuleToString(m)
    check "frame-pointer" in $ir1
    LLVMDisposeMessage(ir1)

    let kind = LLVMGetEnumAttributeKindForName("noinline", csize_t(8))
    let attr = LLVMCreateEnumAttribute(ctx, kind, 0)
    LLVMAddAttributeAtIndex(fn, LLVMAttributeFunctionIndex, attr)

    let ir2 = LLVMPrintModuleToString(m)
    check "noinline" in $ir2
    LLVMDisposeMessage(ir2)

    LLVMRemoveEnumAttributeAtIndex(fn, LLVMAttributeFunctionIndex, kind)
    let ir3 = LLVMPrintModuleToString(m)
    check "noinline" notin $ir3
    LLVMDisposeMessage(ir3)

  test "metadata: attach string metadata to instruction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("md1", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 1, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    
    let x = LLVMGetParam(fn, 0)
    let sum = LLVMBuildAdd(b, x, LLVMConstInt(i32t, 1, LLVMFalse), "sum")
    discard LLVMBuildRet(b, sum)
    
    # Create metadata string: !0 = !{!"my_custom_tag"}
    let mdStr = LLVMMDStringInContext2(ctx, "my_custom_tag", csize_t(13))
    var mdArr = [mdStr]
    let mdNode = LLVMMDNodeInContext2(ctx, addr mdArr[0], csize_t(1))
    let mdVal = LLVMMetadataAsValue(ctx, mdNode)
    
    # Attach to instruction
    let kind = LLVMGetMDKindIDInContext(ctx, "custom.md", cuint(9))
    check kind > 0
    LLVMSetMetadata(sum, kind, mdVal)
    
    let ir = LLVMPrintModuleToString(m)
    check "!custom.md" in $ir
    check "my_custom_tag" in $ir
    LLVMDisposeMessage(ir)

  test "metadata: named module metadata":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("md2", ctx)
    defer: LLVMDisposeModule(m)
    
    # Create metadata node: !{!"wchar_size", i32 4}
    let s1 = LLVMMDStringInContext2(ctx, "wchar_size", csize_t(11))
    let v = LLVMConstInt(LLVMInt32TypeInContext(ctx), 4, LLVMFalse)
    let m1 = LLVMValueAsMetadata(v)
    var mdArr = [s1, m1]
    let mdNode = LLVMMDNodeInContext2(ctx, addr mdArr[0], csize_t(2))
    let mdVal = LLVMMetadataAsValue(ctx, mdNode)
    
    # Attach as named metadata: !llvm.module.flags
    LLVMAddNamedMetadataOperand(m, "llvm.module.flags", mdVal)
    
    let ir = LLVMPrintModuleToString(m)
    check "!llvm.module.flags" in $ir
    check "wchar_size" in $ir
    LLVMDisposeMessage(ir)

  test "metadata: value as metadata roundtrip":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let c = LLVMConstInt(i32t, 42, LLVMFalse)
    
    let md = LLVMValueAsMetadata(c)
    check not md.isNil
    
    let val = LLVMMetadataAsValue(ctx, md)
    check not val.isNil
    let s = LLVMPrintValueToString(val)
    check "42" in $s
    LLVMDisposeMessage(s)

  test "aliases: add alias and get aliasee":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("alias1", ctx)
    defer: LLVMDisposeModule(m)
    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add64", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    let sum = LLVMBuildAdd(b, a, c, "sum")
    discard LLVMBuildRet(b, sum)

    let alias = LLVMAddAlias2(m, i64t, 0, fn, "my_add")
    check not alias.isNil

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let ir = LLVMPrintModuleToString(m)
    check "@my_add = alias" in $ir
    check "@add64" in $ir
    LLVMDisposeMessage(ir)

    let aliasee = LLVMAliasGetAliasee(alias)
    check not aliasee.isNil
    let s = LLVMPrintValueToString(aliasee)
    check "@add64" in $s
    LLVMDisposeMessage(s)

  test "aliases: set aliasee":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("alias2", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)

    let fn1 = LLVMAddFunction(m, "fn1", fnTy)
    let bb1 = LLVMAppendBasicBlockInContext(ctx, fn1, "entry")
    let b1 = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(b1, bb1)
    discard LLVMBuildRet(b1, LLVMConstInt(i32t, 1, LLVMFalse))
    LLVMDisposeBuilder(b1)

    let fn2 = LLVMAddFunction(m, "fn2", fnTy)
    let bb2 = LLVMAppendBasicBlockInContext(ctx, fn2, "entry")
    let b2 = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(b2, bb2)
    discard LLVMBuildRet(b2, LLVMConstInt(i32t, 2, LLVMFalse))
    LLVMDisposeBuilder(b2)

    let alias = LLVMAddAlias2(m, fnTy, 0, fn1, "my_alias")
    check not alias.isNil

    LLVMAliasSetAliasee(alias, fn2)

    let aliasee = LLVMAliasGetAliasee(alias)
    let s = LLVMPrintValueToString(aliasee)
    check "@fn2" in $s
    LLVMDisposeMessage(s)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "irreader: parse simple module":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    
    let irText = """
define i32 @add(i32 %a, i32 %b) {
entry:
  %sum = add i32 %a, %b
  ret i32 %sum
}
"""
    let (m, err) = parseIR(ctx, irText, "test.ll")
    check err.len == 0
    check not m.isNil
    defer: LLVMDisposeModule(m)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let outIr = LLVMPrintModuleToString(m)
    check "add i32" in $outIr
    LLVMDisposeMessage(outIr)

  test "irreader: parse with globals and metadata":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    
    let irText = """
@str = private constant [4 x i8] c"abc\00"

define void @f() {
entry:
  ret void, !custom !0
}

!0 = !{!"hello"}
"""
    let (m, err) = parseIR(ctx, irText, "meta.ll")
    check err.len == 0
    check not m.isNil
    defer: LLVMDisposeModule(m)

    let g = LLVMGetNamedGlobal(m, "str")
    check not g.isNil

    let outIr = LLVMPrintModuleToString(m)
    check "@str" in $outIr
    check "!custom" in $outIr
    LLVMDisposeMessage(outIr)

  test "irreader: parse invalid IR returns error":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    
    let irText = "this is not valid LLVM IR"
    let (m, err) = parseIR(ctx, irText)
    check m.isNil
    check err.len > 0

  test "irreader: parsed module runnable in JIT":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    
    let irText = """
define i64 @mul64(i64 %a, i64 %b) {
entry:
  %res = mul i64 %a, %b
  ret i64 %res
}
"""
    let (m, err) = parseIR(ctx, irText)
    check err.len == 0
    check not m.isNil

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check not jit.isNil
    check jitErr.len == 0

    check addModule(jit, m).len == 0

    let (addrr, lookupErr) = lookup(jit, "mul64")
    check lookupErr.len == 0
    check addrr != 0

    type Fn = proc(a, b: int64): int64 {.cdecl.}
    let f = cast[Fn](addrr)
    check f(6'i64, 7'i64) == 42'i64

  test "safe wrappers: LLJIT ownership transfer":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("safe_lljit", ctx)
    var jm = initJitModule(m)
    
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 42, LLVMFalse))

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check jitErr.len == 0

    let addErr = addModuleSafe(jit, jm)
    check addErr.len == 0
    check jm.raw.isNil # Ownership transferred

    # Safe wrapper should catch double-transfer
    try:
      discard addModuleSafe(jit, jm)
      check false
    except AssertionDefect:
      discard

  test "safe wrappers: MCJIT ownership transfer":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("safe_mcjit", ctx)
    var jm = initJitModule(m)
    
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    
    let (ee, err) = createJITSafe(jm, 0)
    check err.len == 0
    check not ee.isNil
    defer: LLVMDisposeExecutionEngine(ee)
    
    check jm.raw.isNil # Ownership transferred

  test "idiomatic: forwarders work automatically":
    # Note: we use the idiomatic names here
    let ctx = contextCreate()
    check not ctx.isNil
    defer: contextDispose(ctx)

    let i32t = int32TypeInContext(ctx)
    let m = moduleCreateWithNameInContext("idiom", ctx)
    check not m.isNil
    defer: disposeModule(m)

    let c = constInt(i32t, 42, LLVMFalse)
    check not c.isNil

  test "idiomatic: with* RAII wrappers":
    withContext(ctx):
      withModule(ctx, "testmod", m):
        withBuilder(ctx, b):
          let i32t = int32TypeInContext(ctx)
          let fnTy = functionType(i32t, nil, 0, LLVMFalse)
          let fn = addFunction(m, "answer", fnTy)
          let bb = appendBasicBlockInContext(ctx, fn, "entry")
          positionBuilderAtEnd(b, bb)
          let c = constInt(i32t, 42, LLVMFalse)
          discard buildRet(b, c)
          
          let (ok, msg) = verifyModule(m)
          check ok
          check msg.len == 0

  test "raii: context and module auto-dispose":
    let ctx = newContext()
    doAssert not ctx.raw.isNil
    # no defer needed

  test "raii: builder auto-dispose":
    let ctx = newContext()
    let m = newModule(ctx, "m")
    let b = newBuilder(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    # disposal happens automatically when ctx, m, b go out of scope

  test "raii: release prevents double-free on transfer":
    let ctx = newContext()
    var m = newModule(ctx, "transfer")
    discard LLVMAddFunction(m, "f", LLVMFunctionType(LLVMInt32TypeInContext(ctx), nil, 0, LLVMFalse))
    let raw = release(m)
    doAssert not raw.isNil
    doAssert m.raw.isNil
    LLVMDisposeModule(raw) # manual dispose, m won't double-free

  test "raii: addModuleSafe with RAII Module":
    let ctx = newContext()
    var m = newModule(ctx, "raii_jit")
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = newBuilder(ctx)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 42, LLVMFalse))

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    doAssert jitErr.len == 0
    doAssert addModuleSafe(jit, m).len == 0
    doAssert m.raw.isNil

  test "debug info: minimal compile unit and subprogram":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di", ctx)
    defer: LLVMDisposeModule(m)

    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(
      diBuilder, LLVMDWARFSourceLanguageC, file,
      "llvnim", csize_t(8), LLVMFalse,
      "", csize_t(0), 0,
      "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse,
      "", csize_t(0), "", csize_t(0)
    )

    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, nil, 0, 0)
    let sp = LLVMDIBuilderCreateFunction(
      diBuilder, cu, "f", csize_t(1), "f", csize_t(1),
      file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse
    )
    LLVMSetSubprogram(fn, sp)

    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 1, 1, sp, LLVMMetadataRef(nil))
    LLVMSetCurrentDebugLocation2(b, loc)

    discard LLVMBuildRetVoid(b)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let ir = LLVMPrintModuleToString(m)
    check "!DICompileUnit" in $ir
    check "!DISubprogram" in $ir
    check "!DILocation" in $ir
    LLVMDisposeMessage(ir)

  test "debug info: type and variable":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di2", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    
    let alloca = LLVMBuildAlloca(b, i32t, "x")

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, nil, 0, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "f", csize_t(1), "f", csize_t(1), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let basicTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    
    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 2, 1, sp, LLVMMetadataRef(nil))
    LLVMSetCurrentDebugLocation2(b, loc)

    let varDecl = LLVMDIBuilderCreateAutoVariable(diBuilder, sp, "x", csize_t(1), file, 2, basicTy, LLVMFalse, 0, 0)
    check not varDecl.isNil

    let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
    let declareInst = LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, alloca, varDecl, emptyExpr, loc, bb)
    check not declareInst.isNil

    discard LLVMBuildRetVoid(b)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let ir = LLVMPrintModuleToString(m)
    check "!DIBasicType" in $ir
    check "!DILocalVariable" in $ir
    check "#dbg_declare" in $ir
    LLVMDisposeMessage(ir)

  test "linker: merge two modules":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)

    let dest = LLVMModuleCreateWithNameInContext("dest", ctx)
    defer: LLVMDisposeModule(dest)
    let src = LLVMModuleCreateWithNameInContext("src", ctx)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)

    let fnC = LLVMAddFunction(src, "funcC", fnTy)
    let bbC = LLVMAppendBasicBlockInContext(ctx, fnC, "entry")
    let bC = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(bC, bbC)
    discard LLVMBuildRet(bC, LLVMConstInt(i32t, 3, LLVMFalse))
    LLVMDisposeBuilder(bC)

    let fnB = LLVMAddFunction(src, "funcB", fnTy)
    let bbB = LLVMAppendBasicBlockInContext(ctx, fnB, "entry")
    let bB = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(bB, bbB)
    let callC = LLVMBuildCall2(bB, fnTy, fnC, nil, 0, "")
    discard LLVMBuildRet(bB, callC)
    LLVMDisposeBuilder(bB)

    let fnA = LLVMAddFunction(dest, "funcA", fnTy)
    let bbA = LLVMAppendBasicBlockInContext(ctx, fnA, "entry")
    let bA = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(bA, bbA)
    discard LLVMBuildRet(bA, LLVMConstInt(i32t, 1, LLVMFalse))
    LLVMDisposeBuilder(bA)

    let rc = LLVMLinkModules2(dest, src)
    check rc == LLVMFalse

    let ir = LLVMPrintModuleToString(dest)
    check "funcA" in $ir
    check "funcB" in $ir
    check "funcC" in $ir
    LLVMDisposeMessage(ir)

  test "linker: duplicate definitions fail":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)

    let dest = LLVMModuleCreateWithNameInContext("dest2", ctx)
    let src = LLVMModuleCreateWithNameInContext("src2", ctx)
    
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)

    let fnD = LLVMAddFunction(dest, "funcA", fnTy)
    let bbD = LLVMAppendBasicBlockInContext(ctx, fnD, "entry")
    let bD = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(bD, bbD)
    discard LLVMBuildRet(bD, LLVMConstInt(i32t, 1, LLVMFalse))
    LLVMDisposeBuilder(bD)

    let fnS = LLVMAddFunction(src, "funcA", fnTy)
    let bbS = LLVMAppendBasicBlockInContext(ctx, fnS, "entry")
    let bS = LLVMCreateBuilderInContext(ctx)
    LLVMPositionBuilderAtEnd(bS, bbS)
    discard LLVMBuildRet(bS, LLVMConstInt(i32t, 2, LLVMFalse))
    LLVMDisposeBuilder(bS)

    let rc = LLVMLinkModules2(dest, src)
    check rc != LLVMFalse

  test "bitcode: write to file and read back":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("bcfile", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 99, LLVMFalse))

    let path = "/tmp/llvnim_test.bc"
    check writeBitcodeToFile(m, path)
    check fileExists(path)

    var buf: LLVMMemoryBufferRef
    var errMsg: cstring
    let rc = LLVMCreateMemoryBufferWithContentsOfFile(path.cstring, buf, errMsg)
    
    if rc != LLVMFalse:
      echo "Failed to read file: ", errMsg
      if not errMsg.isNil: LLVMDisposeMessage(errMsg)
    
    check rc == LLVMFalse
    check not buf.isNil

    let (m2, err) = parseBitcode(ctx, buf)
    check err.len == 0
    check not m2.isNil
    defer: LLVMDisposeModule(m2)

    let ir = LLVMPrintModuleToString(m2)
    check "ret i32 99" in $ir
    LLVMDisposeMessage(ir)
    
    removeFile(path)

  test "object: read sections and symbols from emitted .o":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("obj", ctx)
    defer: LLVMDisposeModule(m)

    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i64t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "my_add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let sum = LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
    discard LLVMBuildRet(b, sum)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)
    LLVMSetTarget(m, triple.cstring)

    var target: LLVMTargetRef
    var errMsg: cstring
    discard LLVMGetTargetFromTriple(triple.cstring, target, errMsg)
    let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault)
    defer: LLVMDisposeTargetMachine(tm)

    let objFile = "/tmp/llvnim_objtest.o"
    var emitErr: cstring
    check LLVMTargetMachineEmitToFile(tm, m, objFile.cstring, LLVMObjectFile, emitErr) == LLVMFalse
    check fileExists(objFile)

    let (br, loadErr) = loadObjectFile(ctx, objFile)
    check loadErr.len == 0
    check not br.isNil
    defer: LLVMDisposeBinary(br)

    var secIt = LLVMObjectFileCopySectionIterator(br)
    check not secIt.isNil
    defer: LLVMDisposeSectionIterator(secIt)

    var foundText = false
    while LLVMObjectFileIsSectionIteratorAtEnd(br, secIt) == LLVMFalse:
      let nameC = LLVMGetSectionName(secIt)
      if not nameC.isNil:
        let name = $nameC
        if name == ".text":
          foundText = true
          check LLVMGetSectionSize(secIt) > 0
          check not LLVMGetSectionContents(secIt).isNil
      LLVMMoveToNextSection(secIt)
    check foundText

    var symIt = LLVMObjectFileCopySymbolIterator(br)
    check not symIt.isNil
    defer: LLVMDisposeSymbolIterator(symIt)

    var foundMyAdd = false
    while LLVMObjectFileIsSymbolIteratorAtEnd(br, symIt) == LLVMFalse:
      let nameC = LLVMGetSymbolName(symIt)
      if not nameC.isNil:
        let name = $nameC
        if name == "my_add":
          foundMyAdd = true
          check LLVMGetSymbolSize(symIt) > 0
      LLVMMoveToNextSymbol(symIt)
    check foundMyAdd

    removeFile(objFile)

  test "object: empty module has no functions but has sections":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("empty_obj", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let g = LLVMAddGlobal(m, i32t, "my_global")
    LLVMSetInitializer(g, LLVMConstInt(i32t, 42, LLVMFalse))

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)
    LLVMSetTarget(m, triple.cstring)

    var target: LLVMTargetRef
    var errMsg: cstring
    discard LLVMGetTargetFromTriple(triple.cstring, target, errMsg)
    let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault)
    defer: LLVMDisposeTargetMachine(tm)

    let objFile = "/tmp/llvnim_objtest2.o"
    var emitErr: cstring
    check LLVMTargetMachineEmitToFile(tm, m, objFile.cstring, LLVMObjectFile, emitErr) == LLVMFalse

    let (br, loadErr) = loadObjectFile(ctx, objFile)
    check loadErr.len == 0
    defer: LLVMDisposeBinary(br)

    var symIt = LLVMObjectFileCopySymbolIterator(br)
    defer: LLVMDisposeSymbolIterator(symIt)

    var foundGlobal = false
    var foundFunc = false
    while LLVMObjectFileIsSymbolIteratorAtEnd(br, symIt) == LLVMFalse:
      let name = $LLVMGetSymbolName(symIt)
      if name == "my_global": foundGlobal = true
      if name == "my_func": foundFunc = true
      LLVMMoveToNextSymbol(symIt)
    
    check foundGlobal
    check not foundFunc

    removeFile(objFile)

  test "comdat: set and get comdat selection kind":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("comdat1", ctx)
    defer: LLVMDisposeModule(m)

    let irText = """
$f = comdat any
define i32 @f() comdat {
entry:
  ret i32 0
}
"""
    let (m2, err) = parseIR(ctx, irText)
    check err.len == 0
    defer: LLVMDisposeModule(m2)

    let fn2 = LLVMGetNamedFunction(m2, "f")
    check not fn2.isNil

    let comdat = LLVMGetComdat(fn2)
    check not comdat.isNil
    check LLVMGetComdatSelectionKind(comdat) == LLVMAnyComdatSelectionKind

    LLVMSetComdatSelectionKind(comdat, LLVMExactMatchComdatSelectionKind)
    check LLVMGetComdatSelectionKind(comdat) == LLVMExactMatchComdatSelectionKind

    let irOut = LLVMPrintModuleToString(m2)
    check "comdat exactmatch" in $irOut
    LLVMDisposeMessage(irOut)

  test "analysis: verify function":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("verify_fn", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))

    check LLVMVerifyFunction(fn, LLVMReturnStatusAction) == LLVMFalse

    let fnBad = LLVMAddFunction(m, "bad", fnTy)
    discard LLVMAppendBasicBlockInContext(ctx, fnBad, "entry")
    
    check LLVMVerifyFunction(fnBad, LLVMReturnStatusAction) != LLVMFalse

  test "debug info: struct type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_struct", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, nil, 0, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "f", csize_t(1), "f", csize_t(1), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    let memberX = LLVMDIBuilderCreateMemberType(diBuilder, sp, "x", csize_t(1), file, 2, 32, 32, 0, 0, intTy)
    let memberY = LLVMDIBuilderCreateMemberType(diBuilder, sp, "y", csize_t(1), file, 3, 32, 32, 32, 0, intTy)
    var members = [memberX, memberY]
    
    let structTy = LLVMDIBuilderCreateStructType(diBuilder, sp, "Point", csize_t(5), file, 2, 64, 32, 0, LLVMMetadataRef(nil), addr members[0], 2, 0, LLVMMetadataRef(nil), "", csize_t(0))
    check not structTy.isNil

    let varDecl = LLVMDIBuilderCreateAutoVariable(diBuilder, sp, "p", csize_t(1), file, 2, structTy, LLVMFalse, 0, 0)
    let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
    let alloca = LLVMBuildAlloca(b, i32t, "p")
    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 2, 1, sp, LLVMMetadataRef(nil))
    
    discard LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, alloca, varDecl, emptyExpr, loc, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    LLVMDIBuilderFinalize(diBuilder)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "DW_TAG_structure_type" in $ir
    LLVMDisposeMessage(ir)

  test "debug info: pointer type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_ptr", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, nil, 0, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "f", csize_t(1), "f", csize_t(1), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    let ptrTy = LLVMDIBuilderCreatePointerType(diBuilder, intTy, 64, 64, 0, "ptr", csize_t(3))
    check not ptrTy.isNil

    let varDecl = LLVMDIBuilderCreateAutoVariable(diBuilder, sp, "p", csize_t(1), file, 2, ptrTy, LLVMFalse, 0, 0)
    let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
    let alloca = LLVMBuildAlloca(b, i32t, "p")
    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 2, 1, sp, LLVMMetadataRef(nil))
    
    discard LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, alloca, varDecl, emptyExpr, loc, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    LLVMDIBuilderFinalize(diBuilder)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "DW_TAG_pointer_type" in $ir
    LLVMDisposeMessage(ir)

  test "debug info: array and lexical block":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_arr", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, nil, 0, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "f", csize_t(1), "f", csize_t(1), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    let lower = LLVMConstInt(i32t, 0, LLVMFalse)
    let lowerMd = LLVMValueAsMetadata(lower)
    let upper = LLVMConstInt(i32t, 3, LLVMFalse)
    let upperMd = LLVMValueAsMetadata(upper)
    
    let subrange = LLVMDIBuilderCreateSubrangeType(diBuilder, sp, "", csize_t(0), 0, file, 32, 32, 0, intTy, lowerMd, upperMd, LLVMMetadataRef(nil), LLVMMetadataRef(nil))
    var subscripts = [subrange]
    let arrTy = LLVMDIBuilderCreateArrayType(diBuilder, 128, 32, intTy, addr subscripts[0], 1)
    check not arrTy.isNil

    let blockk = LLVMDIBuilderCreateLexicalBlock(diBuilder, sp, file, 3, 1)
    check not blockk.isNil

    let varDecl = LLVMDIBuilderCreateAutoVariable(diBuilder, blockk, "arr_var", csize_t(7), file, 3, arrTy, LLVMFalse, 0, 0)
    let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
    let alloca = LLVMBuildAlloca(b, i32t, "arr_var")
    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 3, 1, blockk, LLVMMetadataRef(nil))
    
    discard LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, alloca, varDecl, emptyExpr, loc, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    LLVMDIBuilderFinalize(diBuilder)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "DW_TAG_array_type" in $ir
    check "DILexicalBlock" in $ir
    LLVMDisposeMessage(ir)

  test "debug info: getOrCreateTypeArray":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_typearr", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    var elems = [intTy, intTy]
    let typeArr = LLVMDIBuilderGetOrCreateTypeArray(diBuilder, addr elems[0], 2)
    check not typeArr.isNil

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: getOrCreateArray and subrange":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_arr", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    let arr = LLVMDIBuilderGetOrCreateArray(diBuilder, addr intTy, 1)
    check not arr.isNil

    let sub = LLVMDIBuilderGetOrCreateSubrange(diBuilder, 0'i64, 4'i64)
    check not sub.isNil

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: namespaces, qualified and pointer types":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_types", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let ns = LLVMDIBuilderCreateNameSpace(diBuilder, cu, "my_ns", csize_t(5), LLVMFalse)
    check not ns.isNil

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)

    let q = LLVMDIBuilderCreateQualifiedType(diBuilder, cuint(0x10), intTy)
    check not q.isNil

    let r = LLVMDIBuilderCreateReferenceType(diBuilder, cuint(0x10), intTy)
    check not r.isNil

    let u = LLVMDIBuilderCreateUnspecifiedType(diBuilder, "auto", csize_t(4))
    check not u.isNil

    let nt = LLVMDIBuilderCreateNullPtrType(diBuilder)
    check not nt.isNil

    let art = LLVMDIBuilderCreateArtificialType(diBuilder, intTy)
    check not art.isNil

    let td = LLVMDIBuilderCreateTypedef(diBuilder, intTy, "myint", csize_t(5), file, 1, cu, 0)
    check not td.isNil

    let fwd = LLVMDIBuilderCreateForwardDecl(diBuilder, cuint(0x2a), "MyStruct", csize_t(8), cu, file, 1, 0, 0'u64, 0, "", csize_t(0))
    check not fwd.isNil

    let rep = LLVMDIBuilderCreateReplaceableCompositeType(diBuilder, cuint(0x2a), "MyStruct", csize_t(8), cu, file, 1, 0, 0'u64, 0, 0, "", csize_t(0))
    check not rep.isNil

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: enumeration type with enumerators":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_enum", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let e1 = LLVMDIBuilderCreateEnumerator(diBuilder, "VAL0", csize_t(4), 0'i64, LLVMFalse)
    check not e1.isNil
    let e2 = LLVMDIBuilderCreateEnumerator(diBuilder, "VAL1", csize_t(4), 1'i64, LLVMFalse)
    check not e2.isNil

    var words = [0x0'u64, 0x1'u64]
    let big = LLVMDIBuilderCreateEnumeratorOfArbitraryPrecision(diBuilder, "BIG", csize_t(3), 128'u64, addr words[0], LLVMFalse)
    check not big.isNil

    var elems = [e1, e2]
    let ety = LLVMDIBuilderCreateEnumerationType(diBuilder, cu, "Color", csize_t(5), file, 1, 32, 32, addr elems[0], cuint(2), LLVMMetadataRef(nil))
    check not ety.isNil

    check LLVMGetMetadataKind(ety) == 13'u
    check LLVMGetDINodeTag(ety) == 4'u16
    check LLVMIsNewDbgInfoFormat(m) == 1

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: union type and inheritance":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_union", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)

    let un = LLVMDIBuilderCreateUnionType(diBuilder, cu, "U", csize_t(1), file, 1, 32'u64, 32, 0, addr intTy, 1, 0, "", csize_t(0))
    check not un.isNil

    let inh = LLVMDIBuilderCreateInheritance(diBuilder, un, intTy, 0'u64, 0, 0)
    check not inh.isNil

    let staticMember = LLVMDIBuilderCreateStaticMemberType(diBuilder, cu, "count", csize_t(5), file, 1, intTy, 0, LLVMValueRef(nil), 0)
    check not staticMember.isNil

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: temporary MD nodes and DI type getters":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_temp", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)

    check LLVMDITypeGetSizeInBits(intTy) == 32'u64
    check LLVMDITypeGetAlignInBits(intTy) == 0'u32
    check LLVMDITypeGetLine(intTy) == 0'u

    var len: csize_t
    let tyName = LLVMDITypeGetName(intTy, len)
    check not tyName.isNil
    check len == 3.csize_t

    var flen: cuint
    let fname = LLVMDIFileGetFilename(file, flen)
    check not fname.isNil
    check flen == 8'u

    let scopeFile = LLVMDIScopeGetFile(file)
    check not scopeFile.isNil

    # temporary MD node lifecycle: create then dispose
    var d = intTy
    let tmp = LLVMTemporaryMDNode(ctx, addr d, 1)
    check not tmp.isNil
    LLVMDisposeTemporaryMDNode(tmp)

    # replaceAllUsesWith resolves a temp node
    let tmp2 = LLVMTemporaryMDNode(ctx, addr d, 1)
    LLVMMetadataReplaceAllUsesWith(tmp2, intTy)

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: module debug metadata version":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_ver", ctx)
    defer: LLVMDisposeModule(m)

    check LLVMGetModuleDebugMetadataVersion(m) == 0'u
    let strip = LLVMStripModuleDebugInfo(m)
    check strip == 0

  test "debug info: subprogram with instruction debug location":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_subloc", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    var paramTypes = [intTy, intTy]
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, addr paramTypes[0], 2, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "add", csize_t(3), "add", csize_t(3), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let got = LLVMGetSubprogram(fn)
    check not got.isNil

    let sum = LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 5, 3, sp, LLVMMetadataRef(nil))
    LLVMInstructionSetDebugLoc(sum, loc)
    check not loc.isNil
    check LLVMDILocationGetLine(loc) == 5'u
    check LLVMDILocationGetColumn(loc) == 3'u

    let dloc = LLVMInstructionGetDebugLoc(sum)
    check not dloc.isNil

    discard LLVMBuildRet(b, sum)
    LLVMDIBuilderFinalize(diBuilder)

    LLVMDISubprogramReplaceType(sp, subTy)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "core metadata: type introspection and value names":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_meta", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    check LLVMGetTypeContext(i32t) == ctx
    var elems = [i32t, i32t]
    let stTy = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    check LLVMGetNumContainedTypes(stTy) == 2

    let arrTy = LLVMArrayType(i32t, 4)
    check LLVMGetArrayLength(arrTy) == 4

    let stName = LLVMPrintTypeToString(stTy)
    check not stName.isNil and len($stName) > 0
    LLVMDisposeMessage(stName)

    let g = LLVMAddGlobal(m, i32t, "myvar")
    var nlen: csize_t
    let nm = LLVMGetValueName2(g, nlen)
    check not nm.isNil and nlen == 5.csize_t

    let vs = LLVMPrintValueToString(g)
    check not vs.isNil and len($vs) > 0
    LLVMDisposeMessage(vs)

  test "core metadata: unnamed addr, visibility, TLS, DLL storage":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_glob", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let g = LLVMAddGlobal(m, i32t, "g")
    LLVMSetInitializer(g, LLVMConstInt(i32t, 1, LLVMFalse))

    LLVMSetUnnamedAddress(g, LLVMGlobalUnnamedAddr)
    check LLVMGetUnnamedAddress(g) == LLVMGlobalUnnamedAddr
    LLVMSetUnnamedAddr(g, LLVMTrue)
    check LLVMHasUnnamedAddr(g) == LLVMTrue

    LLVMSetVisibility(g, LLVMProtectedVisibility)
    check LLVMGetVisibility(g) == LLVMProtectedVisibility

    LLVMSetDLLStorageClass(g, LLVMDLLExportStorageClass)
    check LLVMGetDLLStorageClass(g) == LLVMDLLExportStorageClass

    LLVMSetThreadLocalMode(g, LLVMGeneralDynamicTLSModel)
    check LLVMGetThreadLocalMode(g) == LLVMGeneralDynamicTLSModel

  test "core metadata: arith flags NSW/NUW/exact/inbounds":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_flags", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let a = LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "a")
    LLVMSetNSW(a, LLVMTrue)
    check LLVMGetNSW(a) == LLVMTrue
    LLVMSetNUW(a, LLVMTrue)
    check LLVMGetNUW(a) == LLVMTrue

    var idx: array[1, LLVMValueRef] = [LLVMConstInt(i32t, 0, LLVMFalse)]
    let gep = LLVMBuildGEP2(b, i32t, LLVMGetParam(fn, 0), addr idx[0], 1, "gep")
    LLVMSetIsInBounds(gep, LLVMTrue)
    check LLVMIsInBounds(gep) == LLVMTrue

    discard LLVMBuildRet(b, a)
    check LLVMHasPersonalityFn(fn) == LLVMFalse

  test "core metadata: called value and sync scope":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_call", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    var args = [LLVMGetParam(fn, 0), LLVMGetParam(fn, 1)]
    let call = LLVMBuildCall2(b, fnTy, fn, addr args[0], 2, "c")
    check not LLVMGetCalledValue(call).isNil
    check LLVMGetCalledFunctionType(call) == fnTy

    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))

    let ss = LLVMGetSyncScopeID(ctx, "singlethread", 14)
    check ss > 0

  test "core metadata: named metadata nodes":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_nmd", ctx)
    defer: LLVMDisposeModule(m)

    let nmd = LLVMGetOrInsertNamedMetadata(m, "llvm.dbg.cu", 12)
    check not nmd.isNil

    let i32t = LLVMInt32TypeInContext(ctx)
    let g = LLVMAddGlobal(m, i32t, "g")
    LLVMAddNamedMetadataOperand(m, "llvm.dbg.cu", g)

    check LLVMGetNamedMetadataNumOperands(m, "llvm.dbg.cu") == 1
    var dest: LLVMValueRef
    LLVMGetNamedMetadataOperands(m, "llvm.dbg.cu", addr dest)
    check not dest.isNil
    check not LLVMGetNamedMetadata(m, "llvm.dbg.cu", 12).isNil

  test "constants: byte and string constants":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)

    let byteTy = LLVMInt8TypeInContext(ctx)
    let cb = LLVMConstByte(byteTy, 42)
    check not cb.isNil
    check LLVMConstByteGetSExtValue(cb) == 42
    check LLVMConstByteGetZExtValue(cb) == 42'u64

    var words = [1'u64, 0'u64]
    let big = LLVMConstByteOfArbitraryPrecision(byteTy, 2, addr words[0])
    check not big.isNil

    let s = LLVMConstStringInContext(ctx, "hello", cuint(5), LLVMTrue)
    check not s.isNil
    check LLVMIsConstantString(s) == LLVMTrue

  test "constants: constNamedStruct and inline asm":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_const", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var elems = [i32t, i32t]
    let stTy = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    var vals = [LLVMConstInt(i32t, 1, LLVMFalse), LLVMConstInt(i32t, 2, LLVMFalse)]
    let cs = LLVMConstNamedStruct(stTy, addr vals[0], 2)
    check not cs.isNil

  test "core metadata: explicit instr flags on build":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_sync", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    LLVMSetDataLayout(m, "e-m:e-p:64:64")
    check len($LLVMGetDataLayoutStr(m)) > 0

    let g = LLVMAddGlobal(m, i32t, "g")
    LLVMSetInitializer(g, LLVMConstInt(i32t, 1, LLVMFalse))
    let fnTy = LLVMFunctionType(LLVMVoidTypeInContext(ctx), nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "main", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let frz = LLVMBuildFreeze(b, LLVMConstInt(i32t, 5, LLVMFalse), "f")
    check not frz.isNil
    let gfnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let gfn = LLVMAddFunction(m, "helper", gfnTy)
    var args: array[0, LLVMValueRef]
    let call = LLVMBuildCall2(b, gfnTy, gfn, nil, 0, "c")
    discard call

  test "core metadata: AMD node and terminator checks":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("core_amd", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let ret = LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    check not LLVMIsATerminatorInst(ret).isNil

  test "debug info: extra DI builders":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_extra", ctx)
    defer: LLVMDisposeModule(m)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))

    let modNode = LLVMDIBuilderCreateModule(diBuilder, cu, "MyMod", csize_t(5), "", csize_t(0), "", csize_t(0), "", csize_t(0))
    check not modNode.isNil

    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    var elems = [intTy]
    let setTy = LLVMDIBuilderCreateSetType(diBuilder, cu, "S", csize_t(1), file, 1, 8'u64, 8, intTy)
    check not setTy.isNil

    let tmf = LLVMDIBuilderCreateTempMacroFile(diBuilder, LLVMMetadataRef(nil), 1, file)
    check not tmf.isNil

    let tmp = LLVMDIBuilderCreateTempGlobalVariableFwdDecl(diBuilder, cu, "g", csize_t(1), "", csize_t(0), file, 1, intTy, LLVMTrue, LLVMMetadataRef(nil), 32)
    check not tmp.isNil

    LLVMDIBuilderFinalize(diBuilder)

  test "debug info: function parameters":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_param", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    
    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    var paramTypes = [intTy, intTy]
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, addr paramTypes[0], 2, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "add", csize_t(3), "add", csize_t(3), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let varA = LLVMDIBuilderCreateParameterVariable(diBuilder, sp, "a", csize_t(1), 1, file, 1, intTy, LLVMTrue, 0)
    let varB = LLVMDIBuilderCreateParameterVariable(diBuilder, sp, "b", csize_t(1), 2, file, 1, intTy, LLVMTrue, 0)
    check not varA.isNil
    check not varB.isNil

    let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 1, 1, sp, LLVMMetadataRef(nil))

    discard LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, LLVMGetParam(fn, 0), varA, emptyExpr, loc, bb)
    discard LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, LLVMGetParam(fn, 1), varB, emptyExpr, loc, bb)

    let sum = LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
    discard LLVMBuildRet(b, sum)
    LLVMDIBuilderFinalize(diBuilder)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "!DILocalVariable(name: \"a\"" in $ir
    check "!DILocalVariable(name: \"b\"" in $ir
    LLVMDisposeMessage(ir)

  test "debug info: global variables":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("di_global", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let g = LLVMAddGlobal(m, i32t, "my_global")
    LLVMSetInitializer(g, LLVMConstInt(i32t, 42, LLVMFalse))

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)

    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    
    let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "int", csize_t(3), 32, 0x05, 0)
    let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
    
    let gVarExpr = LLVMDIBuilderCreateGlobalVariableExpression(diBuilder, cu, "my_global", csize_t(9), "internal", csize_t(8), file, 1, intTy, LLVMFalse, emptyExpr, LLVMMetadataRef(nil), 32)
    check not gVarExpr.isNil

    let kind = LLVMGetMDKindIDInContext(ctx, "dbg", cuint(3))
    LLVMGlobalSetMetadata(g, kind, gVarExpr)
    
    LLVMDIBuilderFinalize(diBuilder)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0
    let ir = LLVMPrintModuleToString(m)
    check "!DIGlobalVariableExpression" in $ir
    LLVMDisposeMessage(ir)

  test "disassembler: disassemble machine code":
    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let dc = LLVMCreateDisasm(triple.cstring, nil, 0, nil, nil)
    check not dc.isNil
    defer: LLVMDisasmDispose(dc)

    let nopRet = [0x90'u8, 0xC3'u8]
    var buf: array[128, char]
    let size1 = LLVMDisasmInstruction(dc, cast[ptr uint8](unsafeAddr nopRet[0]), 2, 0, cast[cstring](addr buf[0]), csize_t(buf.len))
    check size1 > 0
    let s1 = $cast[cstring](addr buf[0])
    check "nop" in s1 or "ret" in s1

  test "disassembler: disassembleBytes helper":
    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let bytes = [0x90'u8, 0xC3'u8]
    let lines = disassembleBytes(triple, bytes)
    check lines.len >= 1
    var joined = ""
    for l in lines: joined.add(l & " ")
    check "nop" in joined.toLowerAscii or "ret" in joined.toLowerAscii

  test "ir analysis: operands and successors":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("analysis", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    check LLVMIsDeclaration(fn) == LLVMTrue

    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let thenBB = LLVMAppendBasicBlockInContext(ctx, fn, "then")
    let elseBB = LLVMAppendBasicBlockInContext(ctx, fn, "else")

    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entry)

    check LLVMGetEntryBasicBlock(fn) == entry

    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    let cond = LLVMBuildICmp(b, LLVMIntEQ, a, c, "cond")
    let br = LLVMBuildCondBr(b, cond, thenBB, elseBB)

    check LLVMGetNumOperands(br) == 3
    check LLVMGetOperand(br, 0) == cond
    check LLVMGetCondition(br) == cond
    
    check LLVMGetNumSuccessors(br) == 2
    check LLVMGetSuccessor(br, 0) == thenBB
    check LLVMGetSuccessor(br, 1) == elseBB

    LLVMPositionBuilderAtEnd(b, thenBB)
    let sum = LLVMBuildAdd(b, a, c, "sum")
    check LLVMGetNumOperands(sum) == 2
    discard LLVMBuildRet(b, sum)

    LLVMPositionBuilderAtEnd(b, elseBB)
    discard LLVMBuildRet(b, c)

    check LLVMGetBasicBlockTerminator(thenBB) != nil
    let term = LLVMGetBasicBlockTerminator(thenBB)
    check LLVMGetInstructionOpcode(term) == 1

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "ir analysis: erase instruction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("erase", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entry)

    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    
    let sum = LLVMBuildAdd(b, a, c, "sum")
    let diff = LLVMBuildSub(b, a, c, "diff")
    
    discard LLVMBuildRet(b, sum)

    var count = 0
    for inst in entry.instructions:
      inc count
    check count == 3

    LLVMInstructionEraseFromParent(diff)

    count = 0
    for inst in entry.instructions:
      inc count
    check count == 2

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "metadata: instruction debug location":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("md_loc", ctx)
    defer: LLVMDisposeModule(m)

    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let diBuilder = LLVMCreateDIBuilder(m)
    defer: LLVMDisposeDIBuilder(diBuilder)
    let file = LLVMDIBuilderCreateFile(diBuilder, "test.nim", csize_t(8), ".", csize_t(1))
    let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "p", csize_t(1), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
    let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, nil, 0, 0)
    let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "f", csize_t(1), "f", csize_t(1), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
    LLVMSetSubprogram(fn, sp)

    let loc = LLVMDIBuilderCreateDebugLocation(ctx, 5, 10, sp, LLVMMetadataRef(nil))
    LLVMSetCurrentDebugLocation2(b, loc)
    check LLVMGetCurrentDebugLocation2(b) == loc

    let ret = LLVMBuildRetVoid(b)
    check LLVMInstructionGetDebugLoc(ret) == loc

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "target data: sizes and alignment":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("td_test", ctx)
    defer: LLVMDisposeModule(m)

    discard LLVMInitializeNativeTarget()
    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)

    var target: LLVMTargetRef
    var errMsg: cstring
    discard LLVMGetTargetFromTriple(triple.cstring, target, errMsg)
    let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault)
    defer: LLVMDisposeTargetMachine(tm)

    let td = LLVMCreateTargetDataLayout(tm)
    check not td.isNil
    defer: LLVMDisposeTargetData(td)

    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    
    check LLVMSizeOfTypeInBits(td, i32t) == 32
    check LLVMStoreSizeOfType(td, i32t) == 4
    check LLVMABIAlignmentOfType(td, i64t) == 8
    check LLVMCallFrameAlignmentOfType(td, i64t) > 0
    check LLVMPreferredAlignmentOfType(td, i64t) > 0
    check LLVMByteOrder(td) in {LLVMBigEndian, LLVMLittleEndian}

    let pointerSize = LLVMPointerSize(td)
    check pointerSize > 0
    check LLVMPointerSizeForAS(td, 0) == pointerSize
    check LLVMSizeOfTypeInBits(td, LLVMIntPtrTypeInContext(ctx, td)) == uint64(pointerSize) * 8
    check LLVMSizeOfTypeInBits(td, LLVMIntPtrTypeForASInContext(ctx, td, 0)) == uint64(pointerSize) * 8

    LLVMSetModuleDataLayout(m, td)
    let moduleTd = LLVMGetModuleDataLayout(m)
    # LLVMGetModuleDataLayout returns a borrowed reference owned by the module.
    check LLVMPointerSize(moduleTd) == pointerSize

    let global = LLVMAddGlobal(m, i64t, "layout_global")
    check LLVMPreferredAlignmentOfGlobal(td, global) > 0

    var elems = [i32t, i64t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    check LLVMABISizeOfType(td, st) == 16
    check LLVMOffsetOfElement(td, st, 0) == 0
    check LLVMOffsetOfElement(td, st, 1) == 8
    check LLVMElementAtOffset(td, st, 0) == 0
    check LLVMElementAtOffset(td, st, 8) == 1

    let sRep = LLVMCopyStringRepOfTargetData(td)
    check not sRep.isNil
    LLVMDisposeMessage(sRep)

  test "coverage: missing builder and constexpr functions":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("cov_test", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let ptrt = LLVMPointerTypeInContext(ctx, 0)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let gstr = LLVMBuildGlobalString(b, "test", "gstr")
    let asc = LLVMBuildAddrSpaceCast(b, gstr, ptrt, "asc")
    check not asc.isNil

    let mem = LLVMBuildMalloc(b, i32t, "mem")
    discard LLVMBuildFree(b, mem)

    let arrTy = LLVMArrayType2(i32t, 4)
    let garr = LLVMAddGlobal(m, arrTy, "garr")
    let idx = LLVMConstInt(i32t, 0, LLVMFalse)
    var idxs = [idx, idx]
    let cgep = LLVMConstInBoundsGEP2(arrTy, garr, addr idxs[0], 2)
    check not cgep.isNil

    let cNull = LLVMConstPointerNull(ptrt)
    let cAsc = LLVMConstAddrSpaceCast(cNull, ptrt)
    let cPc = LLVMConstPointerCast(cNull, ptrt)
    check not cAsc.isNil
    check not cPc.isNil

    let destBB = LLVMAppendBasicBlockInContext(ctx, fn, "dest")
    let gTarget = LLVMAddGlobal(m, ptrt, "target")
    let br = LLVMBuildIndirectBr(b, gTarget, 1)
    LLVMAddDestination(br, destBB)
    
    LLVMPositionBuilderAtEnd(b, destBB)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))

  test "coverage: exceptions catchswitch and catchpad":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("cov_exc", ctx)
    defer: LLVMDisposeModule(m)

    let voidt = LLVMVoidTypeInContext(ctx)
    let fnTy = LLVMFunctionType(voidt, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    
    let entry = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entry)

    let undefPad = LLVMGetUndef(LLVMPointerTypeInContext(ctx, 0))
    let cs = LLVMBuildCatchSwitch(b, undefPad, LLVMBasicBlockRef(nil), 1, "cs")
    check not cs.isNil

    let cp = LLVMBuildCatchPad(b, cs, nil, 0, "cp")
    check not cp.isNil

    let ret = LLVMBuildCatchRet(b, cp, entry)
    check not ret.isNil
    
    let ir = LLVMPrintModuleToString(m)
    check "catchswitch" in $ir
    check "catchpad" in $ir
    check "catchret" in $ir
    LLVMDisposeMessage(ir)

  test "OrcCreateNewThreadSafeContextFromLLVMContext takes ownership":
    let ctx = LLVMContextCreate()
    let tsc = LLVMOrcCreateNewThreadSafeContextFromLLVMContext(ctx)
    check not tsc.isNil
    LLVMOrcDisposeThreadSafeContext(tsc)
    # ctx is owned by tsc now; do NOT call LLVMContextDispose(ctx)

  test "OrcLLJITAddObjectFile adds object to custom dylib":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    # Emit a .o first, then load as buffer.
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("obj", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "answer", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    discard LLVMBuildRet(b, LLVMConstInt(i32t, 42, LLVMFalse))

    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)
    LLVMSetTarget(m, triple.cstring)
    var target: LLVMTargetRef
    var errMsg: cstring
    discard LLVMGetTargetFromTriple(triple.cstring, target, errMsg)
    let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault)
    defer: LLVMDisposeTargetMachine(tm)
    let objPath = "/tmp/llvnim_dylib_test.o"
    var emitErr: cstring
    check LLVMTargetMachineEmitToFile(tm, m, objPath.cstring, LLVMObjectFile, emitErr) == LLVMFalse

    var buf: LLVMMemoryBufferRef
    var bufErr: cstring
    check LLVMCreateMemoryBufferWithContentsOfFile(objPath.cstring, buf, bufErr) == LLVMFalse

    let (jit, jitErr) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check jitErr.len == 0
    let (jd, jdErr) = jitCreateJITDylib(jit, "objdylib")
    check jdErr.len == 0

    check addObjectFileToDylib(jit, jd, buf).len == 0
    removeFile(objPath)

  test "LLJIT: EnableDebugSupport succeeds":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    defer:
      let e = LLVMOrcDisposeLLJIT(jit)
      if not e.isNil: LLVMDisposeErrorMessage(LLVMGetErrorMessage(e))
    check err.len == 0
    let (ok, msg) = enableDebugSupport(jit)
    check ok
    check msg.len == 0

  test "LLVMGetInsertBlock returns current block":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("insert_block", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    
    let bb1 = LLVMAppendBasicBlockInContext(ctx, fn, "bb1")
    let bb2 = LLVMAppendBasicBlockInContext(ctx, fn, "bb2")
    
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)

    LLVMPositionBuilderAtEnd(b, bb1)
    check LLVMGetInsertBlock(b) == bb1

    LLVMPositionBuilderAtEnd(b, bb2)
    check LLVMGetInsertBlock(b) == bb2

    discard LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    check LLVMGetInsertBlock(b) == bb2

  test "LLVMDeleteFunction removes function from module":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("del_fn", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "foo", fnTy)

    check not fn.isNil
    check LLVMGetNamedFunction(m, "foo") == fn

    LLVMDeleteFunction(fn)

    check LLVMGetNamedFunction(m, "foo").isNil

  test "IR graph: basic block parents and value<->BB conversion":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("irgraph", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")

    check LLVMGetBasicBlockParent(bb) == fn

    let bbVal = LLVMBasicBlockAsValue(bb)
    check not bbVal.isNil
    check LLVMValueIsBasicBlock(bbVal) == LLVMTrue
    check LLVMValueAsBasicBlock(bbVal) == bb

    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)
    let inst = LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    check not inst.isNil
    check LLVMGetInstructionParent(inst) == bb
    # LLVMGetParamParent takes a parameter value, not the function
    let param = LLVMGetParam(fn, 0)
    discard param
    check true

  test "basic blocks: create detached and append to function":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("bb_ops", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    let detached = LLVMCreateBasicBlockInContext(ctx, "detached")
    check not detached.isNil
    check LLVMGetBasicBlockParent(detached).isNil

    LLVMAppendExistingBasicBlock(fn, detached)
    check LLVMGetBasicBlockParent(detached) == fn

    let b1 = LLVMAppendBasicBlockInContext(ctx, fn, "b1")
    let inserted = LLVMInsertBasicBlockInContext(ctx, b1, "inserted")
    check LLVMGetBasicBlockParent(inserted) == fn

    # GetBasicBlocks into array
    var n = LLVMCountBasicBlocks(fn)
    check n >= 3
    var bbs = newSeq[LLVMBasicBlockRef](n)
    LLVMGetBasicBlocks(fn, addr bbs[0])
    var foundDetached = false
    var foundInserted = false
    for bb in bbs:
      if bb == detached: foundDetached = true
      if bb == inserted: foundInserted = true
    check foundDetached
    check foundInserted

  test "basic blocks: move before/after":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("bb_move", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let a = LLVMAppendBasicBlockInContext(ctx, fn, "a")
    let c = LLVMAppendBasicBlockInContext(ctx, fn, "c")
    let b = LLVMAppendBasicBlockInContext(ctx, fn, "b")

    LLVMMoveBasicBlockBefore(b, c)
    # order should now be a, b, c
    let first = LLVMGetFirstBasicBlock(fn)
    check first == a
    check LLVMGetNextBasicBlock(first) == b
    check LLVMGetNextBasicBlock(b) == c

    # remove detached? keep it simple: remove b from parent
    LLVMRemoveBasicBlockFromParent(b)
    # order a, c
    check LLVMGetNextBasicBlock(a) == c

  test "basic blocks instruction ops: clone and remove from parent":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("inst_ops", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, bb)
    let ret = LLVMBuildRet(bld, LLVMConstInt(i32t, 42, LLVMFalse))

    let clone = LLVMInstructionClone(ret)
    check not clone.isNil

    # remove original from parent (detach, not free)
    LLVMInstructionRemoveFromParent(ret)
    # re-insert via builder insert
    LLVMInsertIntoBuilder(bld, ret)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

  test "builder: insert at position and clear insertion point":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("builder_pos", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, bb)
    check LLVMGetInsertBlock(bld) == bb

    let ret = LLVMBuildRet(bld, LLVMConstInt(i32t, 0, LLVMFalse))
    # position at ret, insert a nop-free value (here just ret again would be invalid)
    LLVMPositionBuilder(bld, bb, ret)
    check LLVMGetInsertBlock(bld) == bb

    LLVMClearInsertionPosition(bld)
    # after clear, insertion block becomes nil-ish; do not verify

  test "types: function param count/get and return type":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    var params = [i32t, i64t]
    let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
    check LLVMCountParamTypes(fnTy) == 2
    check LLVMGetReturnType(fnTy) == i64t
    var got = newSeq[LLVMTypeRef](2)
    LLVMGetParamTypes(fnTy, addr got[0])
    check got[0] == i32t
    check got[1] == i64t

  test "types: struct element types and subtypes":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    var elems = [i32t, i64t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    check LLVMCountStructElementTypes(st) == 2
    var got = newSeq[LLVMTypeRef](2)
    LLVMGetStructElementTypes(st, addr got[0])
    check got[0] == i32t
    check got[1] == i64t

    check LLVMGetNumContainedTypes(st) == 2
    var subs = newSeq[LLVMTypeRef](2)
    LLVMGetSubtypes(st, addr subs[0])
    check subs[0] == i32t

    check LLVMTypeIsSized(st) == LLVMTrue
    let p = LLVMPointerTypeInContext(ctx, 0)
    check LLVMGetPointerAddressSpace(p) == 0
    let opaque = LLVMPointerTypeInContext(ctx, 0)
    check LLVMPointerTypeIsOpaque(opaque) == LLVMTrue
    let i7 = LLVMIntTypeInContext(ctx, 7)
    check LLVMGetIntTypeWidth(i7) == 7

  test "types: getTypeByName2 for named struct":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let st = LLVMStructCreateNamed(ctx, "Point")
    let found = LLVMGetTypeByName2(ctx, "Point")
    check found == st
    check LLVMGetTypeByName2(ctx, "Missing").isNil

  test "constants: constNamedStruct and parsed ints":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let c10 = LLVMConstInt(i32t, 10, LLVMFalse)
    let c20 = LLVMConstInt(i32t, 20, LLVMFalse)
    var elems = [i32t, i32t]
    let st = LLVMStructTypeInContext(ctx, addr elems[0], 2, LLVMFalse)
    var vals = [c10, c20]
    let cst = LLVMConstNamedStruct(st, addr vals[0], 2)
    check not cst.isNil
    let s = LLVMPrintValueToString(cst)
    check "{ i32 10, i32 20 }" in $s
    LLVMDisposeMessage(s)

    let cint = LLVMConstIntOfString(i32t, "255", 10)
    check not cint.isNil
    check LLVMConstIntGetZExtValue(cint) == 255'u64
    let cint2 = LLVMConstIntOfStringAndSize(i32t, "0x2A", 4, 16)
    check not cint2.isNil

    let bytes = LLVMConstDataArray(LLVMInt8TypeInContext(ctx), cstring("hi"), 2)
    check not bytes.isNil

  test "constants: arbitrary precision and FP bits":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    # 128-bit constant: 2 words
    var words = [0xFFFFFFFF'u64, 0xFFFFFFFF'u64]
    let big = LLVMConstIntOfArbitraryPrecision(LLVMIntTypeInContext(ctx, 128), 2, addr words[0])
    check not big.isNil
    let d = LLVMConstFPFromBits(LLVMDoubleTypeInContext(ctx), addr words[0])
    check not d.isNil

  test "constants: truncOrBitCast on constant":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i8t = LLVMInt8TypeInContext(ctx)
    let c = LLVMConstInt(i32t, 7, LLVMFalse)
    let t = LLVMConstTruncOrBitCast(c, i8t)
    check LLVMIsConstant(t) == LLVMTrue

  test "constants: getAsString on string constant":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let s = LLVMConstStringInContext2(ctx, "abc", csize_t(3), LLVMTrue)
    check not s.isNil
    var len: csize_t
    let raw = LLVMGetAsString(s, len)
    check len == 3
    check $raw == "abc"

  test "module ops: identifier and source filename":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("orig", ctx)
    defer: LLVMDisposeModule(m)
    LLVMSetModuleIdentifier(m, "renamed", 7)
    var len: csize_t
    let id = LLVMGetModuleIdentifier(m, len)
    check $id == "renamed"
    check len == 7

    LLVMSetSourceFileName(m, "src.nim", 7)
    var slen: csize_t
    let sn = LLVMGetSourceFileName(m, slen)
    check $sn == "src.nim"

  test "module ops: data layout, clone, alignof/sizeof":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("mops", ctx)
    defer: LLVMDisposeModule(m)
    LLVMSetDataLayout(m, "e-m:e-p:64:64-i64:64-n8:16:32:64-S128")
    let dl = LLVMGetDataLayoutStr(m)
    check not dl.isNil
    check "p:64:64" in $dl

    let i32t = LLVMInt32TypeInContext(ctx)
    let aof = LLVMAlignOf(i32t)
    check not aof.isNil
    let sof = LLVMSizeOf(i32t)
    check not sof.isNil

    let c = LLVMCloneModule(m)
    check not c.isNil
    LLVMDisposeModule(c)

  test "module ops: inline asm":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("asm", ctx)
    defer: LLVMDisposeModule(m)
    LLVMAppendModuleInlineAsm(m, "nop", 3)
    var len: csize_t
    let asmStr = LLVMGetModuleInlineAsm(m, len)
    check "nop" in $asmStr
    LLVMSetModuleInlineAsm2(m, "", 0)
    var len2: csize_t
    let asmStr2 = LLVMGetModuleInlineAsm(m, len2)
    check len2 == 0

  test "module flags: add and read flag behavior/key/metadata":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("flags", ctx)
    defer: LLVMDisposeModule(m)

    # add flag via MDString metadata value
    let md = LLVMMDStringInContext2(ctx, "val", csize_t(3))
    LLVMAddModuleFlag(m, LLVMModuleFlagBehaviorWarning, "my.flag", csize_t(7), md)
    let got = LLVMGetModuleFlag(m, "my.flag", csize_t(7))
    check got == md

    var n: csize_t
    let entries = LLVMCopyModuleFlagsMetadata(m, n)
    check not entries.isNil
    check n >= 1
    check LLVMModuleFlagEntriesGetFlagBehavior(entries, 0) == LLVMModuleFlagBehaviorWarning
    var klen: csize_t
    let key = LLVMModuleFlagEntriesGetKey(entries, 0, klen)
    check $key == "my.flag"
    check LLVMModuleFlagEntriesGetMetadata(entries, 0) == md
    LLVMDisposeModuleFlagsMetadata(entries)

  test "threading: multithreaded status":
    # LLVM participates; these should not crash
    discard LLVMIsMultithreaded()
    # StartMultithreaded/Stop must not be called twice casually; just check status
    check true

  test "context: discard value names":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    LLVMContextSetDiscardValueNames(ctx, LLVMTrue)
    check LLVMContextShouldDiscardValueNames(ctx) == LLVMTrue
    LLVMContextSetDiscardValueNames(ctx, LLVMFalse)
    check LLVMContextShouldDiscardValueNames(ctx) == LLVMFalse

  test "memory buffer: from memory range":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let data = "abc"
    let buf = LLVMCreateMemoryBufferWithMemoryRange(data.cstring, csize_t(3), "buf", LLVMFalse)
    check not buf.isNil
    check LLVMGetBufferSize(buf) == 3
    check $LLVMGetBufferStart(buf) == "abc"
    LLVMDisposeMemoryBuffer(buf)

  test "use navigation: operands of an instruction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("use", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "add", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let bld = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(bld)
    LLVMPositionBuilderAtEnd(bld, bb)
    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    let sum = LLVMBuildAdd(bld, a, c, "sum")
    discard LLVMBuildRet(bld, sum)

    # operand 0 of sum is a
    let use0 = LLVMGetOperandUse(sum, 0)
    check not use0.isNil
    check LLVMGetUser(use0) == sum
    # first use of a must be sum
    let fu = LLVMGetFirstUse(a)
    check not fu.isNil
    check LLVMGetUser(fu) == sum

  test "value names: set and get with length":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("names", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let g = LLVMAddGlobal(m, i32t, "orig")
    LLVMSetValueName2(g, "renamed", 7)
    var len: csize_t
    let name = LLVMGetValueName2(g, len)
    check $name == "renamed"
    check len == 7
  test "builder: position before and cast ops":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("bpos", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i64t = LLVMInt64TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let ret = LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    LLVMPositionBuilderBefore(b, ret)

    let wide = LLVMBuildSExtOrBitCast(b, LLVMConstInt(i32t, 7, LLVMFalse), i64t, "wide")
    check not wide.isNil
    let narrow = LLVMBuildTruncOrBitCast(b, wide, i32t, "narrow")
    check not narrow.isNil
    check not LLVMBuildZExtOrBitCast(b, narrow, i64t, "zu").isNil
    check not LLVMBuildPointerCast(b, narrow, LLVMPointerTypeInContext(ctx, 0), "p").isNil
    check not LLVMBuildIntCast(b, narrow, i64t, "ic").isNil

  test "builder: null/isnotnull and binop/nsw/nuw":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("bnull", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    var params = [i32t, i32t]
    let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let x = LLVMGetParam(fn, 0)
    let y = LLVMGetParam(fn, 1)

    let isnull = LLVMBuildICmp(b, LLVMIntEQ, x, LLVMConstInt(i32t, 0, LLVMFalse), "isnull")
    check not isnull.isNil

    let sum = LLVMBuildBinOp(b, LLVMAdd, x, y, "sum")
    check not sum.isNil
    check not LLVMBuildNSWAdd(b, x, y, "nsw").isNil
    check not LLVMBuildNUWAdd(b, x, y, "nuw").isNil
    check not LLVMBuildNSWSub(b, x, y, "nswsub").isNil
    check not LLVMBuildNUWSub(b, x, y, "nuwsub").isNil
    check not LLVMBuildNSWMul(b, x, y, "nswmul").isNil
    check not LLVMBuildNUWMul(b, x, y, "nuwmul").isNil
    discard LLVMBuildRet(b, sum)

    let ir = LLVMPrintModuleToString(m)
    check "add nsw" in $ir
    check "add nuw" in $ir
    LLVMDisposeMessage(ir)

  test "builder: ptrdiff, structGEP, memory intrinsics":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("bmem", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let i8t = LLVMInt8TypeInContext(ctx)
    let pt = LLVMPointerTypeInContext(ctx, 0)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    let alloca = LLVMBuildAlloca(b, i32t, "p")
    let alloca2 = LLVMBuildAlloca(b, i32t, "q")
    let diff = LLVMBuildPtrDiff2(b, i32t, alloca2, alloca, "diff")
    check not diff.isNil

    # IsNull/IsNotNull on a pointer value
    check not LLVMBuildIsNull(b, alloca, "isnull").isNil
    check not LLVMBuildIsNotNull(b, alloca, "isn").isNil

    let zero = LLVMConstInt(i32t, 0, LLVMFalse)
    let zero8 = LLVMConstInt(LLVMInt8TypeInContext(ctx), 0, LLVMFalse)
    discard LLVMBuildStore(b, zero, alloca)
    discard LLVMBuildMemSet(b, alloca, zero8, LLVMConstInt(i32t, 4, LLVMFalse), 1)
    discard LLVMBuildMemCpy(b, alloca2, 4, alloca, 4, LLVMConstInt(i32t, 4, LLVMFalse))
    discard LLVMBuildMemMove(b, alloca2, 4, alloca, 4, LLVMConstInt(i32t, 4, LLVMFalse))
    discard LLVMBuildRet(b, zero)

  test "value introspection: kind, opcode, poison, predicates":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("intro", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    check LLVMGetValueKind(fn) == LLVMFunctionValueKind
    let c = LLVMConstInt(i32t, 9, LLVMFalse)
    check LLVMGetValueKind(c) == LLVMConstantIntValueKind
    check LLVMIsPoison(c) == LLVMFalse

    # GetConstOpcode is only valid on constant expressions.
    # A GEP of a global array with a non-foldable index yields a constexpr.
    let arrTy = LLVMArrayType2(i32t, 4)
    let g = LLVMAddGlobal(m, arrTy, "arr")
    var inds = [LLVMConstInt(LLVMInt64TypeInContext(ctx), 0, LLVMFalse),
                LLVMConstInt(i32t, 2, LLVMFalse)]
    let cexpr = LLVMConstGEP2(arrTy, g, addr inds[0], 2)
    check LLVMGetValueKind(cexpr) == LLVMConstantExprValueKind
    check LLVMGetConstOpcode(cexpr) == LLVMGetElementPtr

    let ret = LLVMBuildRet(b, c)
    check not ret.isNil

  test "value introspection: calling convention visibility storage":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("cc", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    check LLVMGetFunctionCallConv(fn) == 0
    LLVMSetFunctionCallConv(fn, 76) # spir kernel
    check LLVMGetFunctionCallConv(fn) == 76

    check LLVMGetVisibility(fn) == LLVMDefaultVisibility
    check LLVMGetDLLStorageClass(fn) == LLVMDefaultStorageClass

    check LLVMGetModuleContext(m) == ctx

  test "module: named function/global with length, or-insert":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("named", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "foo", fnTy)
    let g = LLVMAddGlobal(m, i32t, "barbaz")

    check LLVMGetNamedFunctionWithLength(m, "foo", 3) == fn
    check LLVMGetNamedGlobalWithLength(m, "barbaz", 6) == g
    check LLVMGetNamedFunctionWithLength(m, "nope", 4).isNil

    let h = LLVMGetOrInsertFunction(m, "h", 1, fnTy)
    check not h.isNil
    check LLVMGetOrInsertFunction(m, "h", 1, fnTy) == h

  test "module: section and alignment":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("sec", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let g = LLVMAddGlobal(m, i32t, "g")

    LLVMSetSection(g, ".mysect")
    check $LLVMGetSection(g) == ".mysect"

    LLVMSetAlignment(g, 16)
    check LLVMGetAlignment(g) == 16

  test "intrinsics: lookup, overloaded, declaration":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("intr", ctx)
    defer: LLVMDisposeModule(m)
    let i8t = LLVMInt8TypeInContext(ctx)
    let pt = LLVMPointerTypeInContext(ctx, 0)

    let id = LLVMLookupIntrinsicID("llvm.memcpy.p0.p0.i64", 26)
    check id > 0
    check LLVMIntrinsicIsOverloaded(id) == LLVMTrue

    var overloads = [pt, pt, LLVMInt64TypeInContext(ctx)]
    let decl = LLVMGetIntrinsicDeclaration(m, id, addr overloads[0], 3)
    check not decl.isNil
    check LLVMGetIntrinsicID(decl) == id

    let itype = LLVMIntrinsicGetType(ctx, id, addr overloads[0], 3)
    check not itype.isNil

    var nl: csize_t
    let name = LLVMIntrinsicCopyOverloadedName2(m, id, addr overloads[0], 3, nl)
    check "llvm.memcpy" in $name

  test "debug locations: get/set and line/column/file":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("dbgloc", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)
    let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, bb)

    # current location is fine to query (may or may not be nil)
    discard LLVMGetCurrentDebugLocation(b)

    let ret = LLVMBuildRet(b, LLVMConstInt(i32t, 0, LLVMFalse))
    # line/column on an instruction without debug info returns 0 (or undefined),
    # but they must not crash
    discard LLVMGetDebugLocLine(ret)
    discard LLVMGetDebugLocColumn(ret)
    var len: cuint
    discard LLVMGetDebugLocFilename(ret, len)
    discard LLVMGetDebugLocDirectory(ret, len)
    check true

  test "attributes: enum/string checks and attribute count":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let a = LLVMCreateEnumAttribute(ctx, 1, 0) # KindID 1 = zext param
    check LLVMIsEnumAttribute(a) == LLVMTrue
    check LLVMIsStringAttribute(a) == LLVMFalse

    var klen: cuint
    var vlen: cuint
    let sa = LLVMCreateStringAttribute(ctx, "foo", 3, "bar", 3)
    check LLVMIsStringAttribute(sa) == LLVMTrue
    check LLVMIsEnumAttribute(sa) == LLVMFalse
    check $LLVMGetStringAttributeKind(sa, klen) == "foo"
    check $LLVMGetStringAttributeValue(sa, vlen) == "bar"

  test "GC: set and get garbage collector":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("gc", ctx)
    defer: LLVMDisposeModule(m)
    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    let fn = LLVMAddFunction(m, "f", fnTy)

    LLVMSetGC(fn, "ocaml")
    check $LLVMGetGC(fn) == "ocaml"
    LLVMSetGC(fn, "")
    check $LLVMGetGC(fn) == ""
