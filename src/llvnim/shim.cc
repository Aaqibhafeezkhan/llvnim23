// Copyright (c) 2026 https://github.com/xlebore3o4ka

#include "shim.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/Support/Error.h"
#include <string>
#include <cstring>

extern "C" const char*
jitLinkStaticLibraryInto(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD, const char *Path) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto *Dylib = reinterpret_cast<llvm::orc::JITDylib*>(JD);
  auto Err = JIT->linkStaticLibraryInto(*Dylib, Path);
  if (!Err) return nullptr;
  std::string Msg = llvm::toString(std::move(Err));
  char *Result = new char[Msg.size() + 1];
  std::strcpy(Result, Msg.c_str());
  return Result;
}

extern "C" void
jitFreeErrorMessage(const char *Msg) {
  delete[] Msg;
}

extern "C" const char*
jitLoadPlatformDynamicLibrary(LLVMOrcLLJITRef J, const char *Path) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto Result = JIT->loadPlatformDynamicLibrary(Path);
  if (!Result) {
    std::string Msg = llvm::toString(Result.takeError());
    char *Buf = new char[Msg.size() + 1];
    std::strcpy(Buf, Msg.c_str());
    return Buf;
  }
  return nullptr;
}