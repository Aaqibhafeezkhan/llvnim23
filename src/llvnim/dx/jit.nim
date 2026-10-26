# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../../llvnim

proc targetDataFromJit*(jit: LLVMOrcLLJITRef): LLVMTargetDataRef =
  ## Returns TargetData built from the LLJIT's DataLayout string.
  ## The caller owns the result and must free it with LLVMDisposeTargetData.
  let s = LLVMOrcLLJITGetDataLayoutStr(jit)
  doAssert not s.isNil, "targetDataFromJit: nil DataLayout"
  LLVMCreateTargetData(s)