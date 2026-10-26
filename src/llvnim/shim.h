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

#ifdef __cplusplus
}
#endif

#endif