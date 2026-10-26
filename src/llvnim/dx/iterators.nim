# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../../llvnim

proc getName*(val: LLVMValueRef): string =
  ## Returns the name of a value (function, global, etc.).
  if val.isNil: return ""
  var length: csize_t
  let nameC = LLVMGetValueName2(val, length)
  if nameC.isNil: return ""
  result = newString(length)
  copyMem(addr result[0], nameC, length)

proc getName*(bb: LLVMBasicBlockRef): string =
  ## Returns the name of a basic block.
  if bb.isNil: return ""
  let nameC = LLVMGetBasicBlockName(bb)
  if nameC.isNil: return ""
  result = $nameC

proc printValueToString*(val: LLVMValueRef): string =
  ## Helper to print a value (like an instruction) directly to a string.
  let s = LLVMPrintValueToString(val)
  if s.isNil: return ""
  result = $s
  LLVMDisposeMessage(s)

iterator functions*(m: LLVMModuleRef): LLVMValueRef =
  var f = LLVMGetFirstFunction(m)
  while not f.isNil:
    yield f
    f = LLVMGetNextFunction(f)

iterator reversedFunctions*(m: LLVMModuleRef): LLVMValueRef =
  var f = LLVMGetLastFunction(m)
  while not f.isNil:
    yield f
    f = LLVMGetPreviousFunction(f)

iterator globals*(m: LLVMModuleRef): LLVMValueRef =
  var g = LLVMGetFirstGlobal(m)
  while not g.isNil:
    yield g
    g = LLVMGetNextGlobal(g)

iterator reversedGlobals*(m: LLVMModuleRef): LLVMValueRef =
  var g = LLVMGetLastGlobal(m)
  while not g.isNil:
    yield g
    g = LLVMGetPreviousGlobal(g)

iterator basicBlocks*(fn: LLVMValueRef): LLVMBasicBlockRef =
  var bb = LLVMGetFirstBasicBlock(fn)
  while not bb.isNil:
    yield bb
    bb = LLVMGetNextBasicBlock(bb)

iterator reversedBasicBlocks*(fn: LLVMValueRef): LLVMBasicBlockRef =
  var bb = LLVMGetLastBasicBlock(fn)
  while not bb.isNil:
    yield bb
    bb = LLVMGetPreviousBasicBlock(bb)

iterator instructions*(bb: LLVMBasicBlockRef): LLVMValueRef =
  var inst = LLVMGetFirstInstruction(bb)
  while not inst.isNil:
    yield inst
    inst = LLVMGetNextInstruction(inst)

iterator reversedInstructions*(bb: LLVMBasicBlockRef): LLVMValueRef =
  var inst = LLVMGetLastInstruction(bb)
  while not inst.isNil:
    yield inst
    inst = LLVMGetPreviousInstruction(inst)

proc countBasicBlocks*(fn: LLVMValueRef): cuint = LLVMCountBasicBlocks(fn)
proc countParams*(fn: LLVMValueRef): cuint = LLVMCountParams(fn)