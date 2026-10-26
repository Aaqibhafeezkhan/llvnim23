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

proc addModuleToDylib*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; ir: string): string =
  ## Parses LLVM IR and adds it to the specified JITDylib.
  ## Ownership of the parsed module and context is fully handled by LLVM.
  let ctx = LLVMContextCreate()
  let (m, err) = parseIR(ctx, ir)
  if err.len > 0:
    LLVMContextDispose(ctx)
    return err
  
  let tsc = LLVMOrcCreateNewThreadSafeContextFromLLVMContext(ctx)
  let tsm = LLVMOrcCreateNewThreadSafeModule(m, tsc)
  
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

proc enableDebugSupport*(jit: LLVMOrcLLJITRef): tuple[ok: bool, err: string] =
  ## Installs the debug plugin so JIT'd objects are registered with GDB.
  let errRef = LLVMOrcLLJITEnableDebugSupport(jit)
  if errRef.isNil:
    result = (true, "")
  else:
    let msg = LLVMGetErrorMessage(errRef)
    result = (false, $msg)
    LLVMDisposeErrorMessage(msg)