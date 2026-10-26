// Copyright (c) 2026 https://github.com/xlebore3o4ka

#include "shim.h"
#include "llvm/ExecutionEngine/Orc/LLJIT.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/Error.h"
#include "llvm-c/Core.h"
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
jitAddIRModuleToDylib(LLVMOrcLLJITRef J, LLVMOrcJITDylibRef JD, LLVMModuleRef M) {
  auto *JIT = reinterpret_cast<llvm::orc::LLJIT*>(J);
  auto *Dylib = reinterpret_cast<llvm::orc::JITDylib*>(JD);
  auto *Mod = reinterpret_cast<llvm::Module*>(M);

  auto TSC = llvm::orc::ThreadSafeContext(llvm::wrap(&Mod->getContext()));
  auto TSM = llvm::orc::ThreadSafeModule(std::unique_ptr<llvm::Module>(Mod), std::move(TSC));

  auto Err = JIT->addIRModule(*Dylib, std::move(TSM));
  if (!Err) return nullptr;
  std::string Msg = llvm::toString(std::move(Err));
  char *Buf = new char[Msg.size() + 1];
  std::strcpy(Buf, Msg.c_str());
  return Buf;
}