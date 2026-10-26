// Copyright (c) 2026 https://github.com/xlebore3o4ka

#ifndef LLVNIM_SHIM_H
#define LLVNIM_SHIM_H
#include <llvm-c/Core.h>
#include <llvm-c/LLJIT.h>

#ifdef __cplusplus
extern "C" {
#endif

const char* jitLinkStaticLibraryInto(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD, const char *Path);
void jitFreeErrorMessage(const char *Msg);
const char* jitLoadPlatformDynamicLibrary(LLVMOrcLLJITRef J, const char *Path);
LLVMOrcJITDylibRef jitCreateJITDylib(LLVMOrcLLJITRef J, const char *Name, char **ErrOut);
const char* jitMangle(LLVMOrcLLJITRef J, const char *Name);
const char* jitLookupLinkerMangled(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD, const char *Name, uint64_t *OutAddr);
LLVMOrcJITDylibRef jitGetJITDylibByName(LLVMOrcLLJITRef J, const char *Name);
const char* jitInitialize(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD);
const char* jitDeinitialize(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD);

#ifdef __cplusplus
}
#endif

#endif