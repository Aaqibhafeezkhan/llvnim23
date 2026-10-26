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

extern "C" LLVMOrcJITDylibRef
jitCreateJITDylib(LLVMOrcLLJITRef J, const char *Name, char **ErrOut) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto Result = JIT->createJITDylib(Name);
  if (!Result) {
    std::string Msg = llvm::toString(Result.takeError());
    char *Buf = new char[Msg.size() + 1];
    std::strcpy(Buf, Msg.c_str());
    *ErrOut = Buf;
    return nullptr;
  }
  return reinterpret_cast<LLVMOrcJITDylibRef>(&*Result);
}

extern "C" const char*
jitMangle(LLVMOrcLLJITRef J, const char *Name) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto S = JIT->mangle(Name);
  char *Buf = new char[S.size() + 1];
  std::strcpy(Buf, S.c_str());
  return Buf;
}

extern "C" const char*
jitLookupLinkerMangled(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD, const char *Name, uint64_t *OutAddr) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto *Dylib = reinterpret_cast<llvm::orc::JITDylib*>(JD);
  auto Result = JIT->lookupLinkerMangled(*Dylib, Name);
  if (!Result) {
    std::string Msg = llvm::toString(Result.takeError());
    char *Buf = new char[Msg.size() + 1];
    std::strcpy(Buf, Msg.c_str());
    return Buf;
  }
  *OutAddr = Result->getValue();
  return nullptr;
}

extern "C" LLVMOrcJITDylibRef
jitGetJITDylibByName(LLVMOrcLLJITRef J, const char *Name) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto *Dylib = JIT->getJITDylibByName(Name);
  return reinterpret_cast<LLVMOrcJITDylibRef>(Dylib);
}

extern "C" const char*
jitInitialize(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto *Dylib = reinterpret_cast<llvm::orc::JITDylib*>(JD);
  auto Err = JIT->initialize(*Dylib);
  if (!Err) return nullptr;
  std::string Msg = llvm::toString(std::move(Err));
  char *Buf = new char[Msg.size() + 1];
  std::strcpy(Buf, Msg.c_str());
  return Buf;
}

extern "C" const char*
jitDeinitialize(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto *Dylib = reinterpret_cast<llvm::orc::JITDylib*>(JD);
  auto Err = JIT->deinitialize(*Dylib);
  if (!Err) return nullptr;
  std::string Msg = llvm::toString(std::move(Err));
  char *Buf = new char[Msg.size() + 1];
  std::strcpy(Buf, Msg.c_str());
  return Buf;
}