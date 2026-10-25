# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../../llvnim

proc call*(b: LLVMBuilderRef; fn: LLVMValueRef; args: openArray[LLVMValueRef]; name: string = ""): LLVMValueRef =
  ## Emits a function call. Automatically extracts the function type from 'fn'.
  let fnTy = LLVMGlobalGetValueType(fn)
  let argsPtr = if args.len > 0: cast[ptr LLVMValueRef](unsafeAddr args[0]) else: nil
  result = LLVMBuildCall2(b, fnTy, fn, argsPtr, cuint(args.len), name.cstring)

proc alloca*(b: LLVMBuilderRef; ty: LLVMTypeRef; name: string = ""): LLVMValueRef =
  ## Emits an alloca instruction.
  LLVMBuildAlloca(b, ty, name.cstring)

proc store*(b: LLVMBuilderRef; ptrr, val: LLVMValueRef): LLVMValueRef =
  ## Emits a store instruction.
  LLVMBuildStore(b, val, ptrr)

proc load*(b: LLVMBuilderRef; ptrr: LLVMValueRef; ty: LLVMTypeRef; name: string = ""): LLVMValueRef =
  ## Emits a load instruction with an explicit type.
  LLVMBuildLoad2(b, ty, ptrr, name.cstring)

proc load*(b: LLVMBuilderRef; ptrr: LLVMValueRef; name: string = ""): LLVMValueRef =
  ## Emits a load instruction. Infers the type from the pointer, but requires it to be an alloca.
  let ty = LLVMGetAllocatedType(ptrr)
  doAssert not ty.isNil, "dx.load: cannot infer type from pointer (must be an alloca). Provide explicit LLVMTypeRef."
  LLVMBuildLoad2(b, ty, ptrr, name.cstring)