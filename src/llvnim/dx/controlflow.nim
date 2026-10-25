import ../../llvnim

type
  IfElseBlocks* = object
    b*: LLVMBuilderRef
    thenBB*: LLVMBasicBlockRef
    elseBB*: LLVMBasicBlockRef
    mergeBB*: LLVMBasicBlockRef

proc createIfElse*(b: LLVMBuilderRef; ctx: LLVMContextRef; fn: LLVMValueRef; cond: LLVMValueRef; thenName: string = "then"; elseName: string = "else"; mergeName: string = "merge"; createMerge: bool = true): IfElseBlocks =
  ## Creates then/else blocks and emits a conditional branch to them.
  ## If createMerge is true, a merge block is also created.
  result.b = b
  result.thenBB = LLVMAppendBasicBlockInContext(ctx, fn, thenName.cstring)
  result.elseBB = LLVMAppendBasicBlockInContext(ctx, fn, elseName.cstring)
  if createMerge:
    result.mergeBB = LLVMAppendBasicBlockInContext(ctx, fn, mergeName.cstring)
  else:
    result.mergeBB = LLVMBasicBlockRef(nil)
  discard LLVMBuildCondBr(b, cond, result.thenBB, result.elseBB)

template thenBlock*(iface: IfElseBlocks; body: untyped) =
  ## Positions the builder at the 'then' block and executes the body.
  LLVMPositionBuilderAtEnd(iface.b, iface.thenBB)
  body

template elseBlock*(iface: IfElseBlocks; body: untyped) =
  ## Positions the builder at the 'else' block and executes the body.
  LLVMPositionBuilderAtEnd(iface.b, iface.elseBB)
  body

template mergeBlock*(iface: IfElseBlocks; body: untyped) =
  ## Positions the builder at the 'merge' block and executes the body.
  LLVMPositionBuilderAtEnd(iface.b, iface.mergeBB)
  body

proc brToMerge*(iface: IfElseBlocks) =
  ## Emits an unconditional branch to the merge block.
  discard LLVMBuildBr(iface.b, iface.mergeBB)