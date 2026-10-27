# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../../llvnim

proc createFunction*(m: LLVMModuleRef; ctx: LLVMContextRef; name: string; retTy: LLVMTypeRef; paramTys: openArray[LLVMTypeRef]; isVarArg: bool = false): tuple[fn: LLVMValueRef, entryBB: LLVMBasicBlockRef] =
  ## Creates a function with the given return type and parameter types.
  ## Automatically appends an "entry" basic block to the function.
  let varArgBool = if isVarArg: LLVMTrue else: LLVMFalse
  let paramPtr = if paramTys.len > 0: cast[ptr LLVMTypeRef](unsafeAddr paramTys[0]) else: nil
  let fnTy = LLVMFunctionType(retTy, paramPtr, cuint(paramTys.len), varArgBool)
  let fn = LLVMAddFunction(m, name.cstring, fnTy)
  let entryBB = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
  return (fn, entryBB)

proc functionType*(retTy: LLVMTypeRef; paramTys: openArray[LLVMTypeRef]; isVarArg: bool = false): LLVMTypeRef =
  ## Creates a function type without adding it to a module.
  let varArgBool = if isVarArg: LLVMTrue else: LLVMFalse
  let paramPtr = if paramTys.len > 0: cast[ptr LLVMTypeRef](unsafeAddr paramTys[0]) else: nil
  LLVMFunctionType(retTy, paramPtr, cuint(paramTys.len), varArgBool)