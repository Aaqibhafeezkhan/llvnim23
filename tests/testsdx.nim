# Copyright (c) 2026 https://github.com/xlebore3o4ka

import unittest
import std/strutils
import ../src/llvnim
import ../src/llvnim/dx

suite "llvnim dx":

  test "createFunction":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("dx_fn", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let (fn, entryBB) = createFunction(m, ctx, "add", i32t, [i32t, i32t])
    
    check not fn.isNil
    check not entryBB.isNil
    
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entryBB)
    
    let sum = LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
    discard LLVMBuildRet(b, sum)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    let ir = LLVMPrintModuleToString(m)
    check "define i32 @add(i32 %0, i32 %1)" in $ir
    LLVMDisposeMessage(ir)

  test "iterators: functions and basic blocks":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("iter_test", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let fnTy = LLVMFunctionType(i32t, nil, 0, LLVMFalse)
    
    discard LLVMAddFunction(m, "funcA", fnTy)
    discard LLVMAddFunction(m, "funcB", fnTy)

    var fnCount = 0
    for _ in m.functions: inc fnCount
    check fnCount == 2

    var names: seq[string]
    for fn in m.functions:
      names.add(fn.getName)
    check names == @["funcA", "funcB"]

    names.setLen(0)
    for fn in m.reversedFunctions:
      names.add(fn.getName)
    check names == @["funcB", "funcA"]

  test "iterators: instructions and params":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("iter_test2", ctx)
    defer: LLVMDisposeModule(m)

    let i32t = LLVMInt32TypeInContext(ctx)
    let (fn, entry) = createFunction(m, ctx, "add", i32t, [i32t, i32t])
    
    check fn.countParams == 2

    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entry)
    discard LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
    discard LLVMBuildRetVoid(b)

    check fn.countBasicBlocks == 1
    check entry.getName == "entry"

    var instCount = 0
    for inst in entry.instructions:
      inc instCount
    check instCount == 2

    instCount = 0
    for inst in entry.reversedInstructions:
      inc instCount
    check instCount == 2

  test "controlflow: if/else building and JIT":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("dx_if", ctx)

    let i32t = LLVMInt32TypeInContext(ctx)
    let (fn, entry) = createFunction(m, ctx, "max", i32t, [i32t, i32t])
    
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entry)

    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    let cond = LLVMBuildICmp(b, LLVMIntSGT, a, c, "cmp")

    let iface = createIfElse(b, ctx, fn, cond, createMerge = false)

    iface.thenBlock:
      discard LLVMBuildRet(b, a)

    iface.elseBlock:
      discard LLVMBuildRet(b, c)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    check jitErr.len == 0
    check addModule(jit, m).len == 0

    let (addrr, lookupErr) = lookup(jit, "max")
    check lookupErr.len == 0

    type MaxFn = proc(x, y: int32): int32 {.cdecl.}
    let maxFn = cast[MaxFn](addrr)
    check maxFn(10, 20) == 20
    check maxFn(42, 7) == 42

  test "controlflow: if/else with merge and phi":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("dx_merge", ctx)

    let i32t = LLVMInt32TypeInContext(ctx)
    let (fn, entry) = createFunction(m, ctx, "select_val", i32t, [i32t, i32t])
    
    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)
    LLVMPositionBuilderAtEnd(b, entry)

    let a = LLVMGetParam(fn, 0)
    let c = LLVMGetParam(fn, 1)
    
    let cond = LLVMBuildICmp(b, LLVMIntSLT, a, c, "cmp")
    let iface = createIfElse(b, ctx, fn, cond)

    var valFromThen: LLVMValueRef
    iface.thenBlock:
      valFromThen = LLVMBuildAdd(b, a, c, "sum")
      iface.brToMerge()

    var valFromElse: LLVMValueRef
    iface.elseBlock:
      valFromElse = LLVMBuildSub(b, a, c, "diff")
      iface.brToMerge()

    iface.mergeBlock:
      let phi = LLVMBuildPhi(b, i32t, "result")
      var vals = [valFromThen, valFromElse]
      var blocks = [iface.thenBB, iface.elseBB]
      LLVMAddIncoming(phi, addr vals[0], addr blocks[0], 2)
      discard LLVMBuildRet(b, phi)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    check jitErr.len == 0
    check addModule(jit, m).len == 0

    let (addrr, lookupErr) = lookup(jit, "select_val")
    check lookupErr.len == 0

    type Fn = proc(x, y: int32): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    
    check f(2, 5) == 7
    check f(10, 3) == 7

  test "builders: call, alloca, load, store":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("dx_builders", ctx)

    let i32t = LLVMInt32TypeInContext(ctx)
    let (addFn, addEntry) = createFunction(m, ctx, "add", i32t, [i32t, i32t])
    let (_, testEntry) = createFunction(m, ctx, "test", i32t, [])

    let b = LLVMCreateBuilderInContext(ctx)
    defer: LLVMDisposeBuilder(b)

    LLVMPositionBuilderAtEnd(b, addEntry)
    let sum = LLVMBuildAdd(b, LLVMGetParam(addFn, 0), LLVMGetParam(addFn, 1), "sum")
    discard LLVMBuildRet(b, sum)

    LLVMPositionBuilderAtEnd(b, testEntry)
    let slot = b.alloca(i32t, "slot")
    discard b.store(slot, LLVMConstInt(i32t, 42, LLVMFalse))
    let val = b.load(slot, "val")
    let res = b.call(addFn, [val, LLVMConstInt(i32t, 10, LLVMFalse)], "res")
    discard LLVMBuildRet(b, res)

    let (ok, msg) = verifyModule(m)
    check ok
    check msg.len == 0

    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, jitErr) = createLLJIT()
    check jitErr.len == 0
    check addModule(jit, m).len == 0

    let (addrr, lookupErr) = lookup(jit, "test")
    check lookupErr.len == 0

    type Fn = proc(): int32 {.cdecl.}
    let f = cast[Fn](addrr)
    check f() == 52

  test "types: complex type helpers":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)

    let arrTy = array(ctx, i32(ctx), 10)
    check LLVMGetArrayLength2(arrTy) == 10
    check LLVMGetElementType(arrTy) == i32(ctx)

    let vecTy = vector(ctx, f32(ctx), 4)
    check LLVMGetVectorSize(vecTy) == 4

    let stTy = struct(ctx, [i32(ctx), f64(ctx)])
    check LLVMStructGetTypeAtIndex(stTy, 0) == i32(ctx)
    check LLVMStructGetTypeAtIndex(stTy, 1) == f64(ctx)
    check LLVMIsPackedStruct(stTy) == LLVMFalse

    let packedTy = struct(ctx, [i32(ctx), i8(ctx)], packed = true)
    check LLVMIsPackedStruct(packedTy) == LLVMTrue

    check ptrTy(ctx) == LLVMPointerTypeInContext(ctx, 0)

  test "strings: string global and constant":
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let m = LLVMModuleCreateWithNameInContext("str_test", ctx)
    defer: LLVMDisposeModule(m)

    let c = stringConstant(ctx, "hello")
    check not c.isNil
    let s = LLVMPrintValueToString(c)
    check "c\"hello\\00\"" in $s
    LLVMDisposeMessage(s)

    let g = stringGlobal(m, ctx, "world", "my_str")
    check not g.isNil
    
    let ir = LLVMPrintModuleToString(m)
    check "@my_str = private unnamed_addr constant" in $ir
    check "c\"world\\00\"" in $ir
    LLVMDisposeMessage(ir)

  test "LLJIT: TargetData from DataLayout":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()
    let (jit, err) = createLLJIT()
    check err.len == 0
    let td = targetDataFromJit(jit)
    check not td.isNil
    defer: LLVMDisposeTargetData(td)
    let ctx = LLVMContextCreate()
    defer: LLVMContextDispose(ctx)
    let i32t = LLVMInt32TypeInContext(ctx)
    check LLVMStoreSizeOfType(td, i32t) == 4