# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../../llvnim
import ../shim

export shim.jitCreateJITDylib
export shim.jitInitializeSafe
export shim.jitDeinitializeSafe
export shim.jitMangle
export shim.jitLookupLinkerMangled
export shim.jitGetJITDylibByName

proc targetDataFromJit*(jit: LLVMOrcLLJITRef): LLVMTargetDataRef =
  ## Returns TargetData built from the LLJIT's DataLayout string.
  ## The caller owns the result and must free it with LLVMDisposeTargetData.
  let s = LLVMOrcLLJITGetDataLayoutStr(jit)
  doAssert not s.isNil, "targetDataFromJit: nil DataLayout"
  LLVMCreateTargetData(s)

proc addModuleToDylib*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; ctx: LLVMContextRef; m: LLVMModuleRef): string =
  ## Transfers ownership of m to the JIT, tracked by jd.
  let tsc = LLVMOrcCreateNewThreadSafeContextFromLLVMContext(ctx)
  let tsm = LLVMOrcCreateNewThreadSafeModule(m, tsc)
  LLVMOrcDisposeThreadSafeContext(tsc)
  let errRef = LLVMOrcLLJITAddLLVMIRModule(jit, jd, tsm)
  if not errRef.isNil:
    let msg = LLVMGetErrorMessage(errRef)
    result = $msg
    LLVMDisposeErrorMessage(msg)

proc addObjectFileToDylib*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; buf: LLVMMemoryBufferRef): string =
  ## Transfers ownership of buf to the JIT. Do not dispose buf afterwards.
  let errRef = LLVMOrcLLJITAddObjectFile(jit, jd, buf)
  if not errRef.isNil:
    let msg = LLVMGetErrorMessage(errRef)
    result = $msg
    LLVMDisposeErrorMessage(msg)