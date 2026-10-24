import unittest
import std/strutils
import ../src/llvnim23

suite "llvnim23":

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