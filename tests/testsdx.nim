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