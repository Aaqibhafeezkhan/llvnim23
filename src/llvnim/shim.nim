# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../llvnim
import std/[strutils, os]

proc getLlvmCflags(): string =
  let (outp, rc) = gorgeEx("llvm-config --includedir")
  if rc == 0 and outp.strip().len > 0:
    return "-I" & outp.strip()
  
  for p in ["/usr/lib/llvm-23/include", "/usr/lib/llvm/include", "/usr/include"]:
    if dirExists(p) and fileExists(p / "llvm-c" / "Core.h"):
      return "-I" & p
      
  return ""

proc getLlvmLflags(): string =
  let (outp, rc) = gorgeEx("llvm-config --libs --system-libs")
  if rc == 0 and outp.strip().len > 0:
    return outp.strip().splitWhitespace().join(" ")
  
  return "-lLLVM-23 -lstdc++ -lm -ldl"

{.compile: currentSourcePath().parentDir / "shim.cc".}
{.passC: "-I" & currentSourcePath().parentDir.}
{.passC: getLlvmCflags().}
{.passC: "-std=c++17".}
{.passL: getLlvmLflags().}

proc jitLinkStaticLibraryInto*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; path: cstring): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitFreeErrorMessage*(msg: cstring)
  {.importc, cdecl, header: "shim.h".}

proc jitLinkStaticLibraryInto*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; path: string): tuple[ok: bool, err: string] =
  let c = jitLinkStaticLibraryInto(jit, jd, path.cstring)
  if c.isNil:
    result = (true, "")
  else:
    result = (false, $c)
    jitFreeErrorMessage(c)

proc jitLoadPlatformDynamicLibrary*(jit: LLVMOrcLLJITRef; path: cstring): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitLoadPlatformDynamicLibrary*(jit: LLVMOrcLLJITRef; path: string): tuple[ok: bool, err: string] =
  let c = jitLoadPlatformDynamicLibrary(jit, path.cstring)
  if c.isNil:
    result = (true, "")
  else:
    result = (false, $c)
    jitFreeErrorMessage(c)

proc jitCreateJITDylib*(jit: LLVMOrcLLJITRef; name: cstring; errOut: ptr cstring): LLVMOrcJITDylibRef
  {.importc, cdecl, header: "shim.h".}

proc jitCreateJITDylib*(jit: LLVMOrcLLJITRef; name: string): tuple[jd: LLVMOrcJITDylibRef, err: string] =
  var errMsg: cstring
  let jd = jitCreateJITDylib(jit, name.cstring, addr errMsg)
  if not errMsg.isNil:
    result = (LLVMOrcJITDylibRef(nil), $errMsg)
    jitFreeErrorMessage(errMsg)
  else:
    result = (jd, "")

proc jitMangle*(jit: LLVMOrcLLJITRef; name: cstring): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitLookupLinkerMangled*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; name: cstring; outAddr: ptr uint64): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitGetJITDylibByName*(jit: LLVMOrcLLJITRef; name: cstring): LLVMOrcJITDylibRef
  {.importc, cdecl, header: "shim.h".}

proc jitMangle*(jit: LLVMOrcLLJITRef; name: string): string =
  let c = jitMangle(jit, name.cstring)
  result = $c
  jitFreeErrorMessage(c)

proc jitLookupLinkerMangled*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; name: string): tuple[addrr: uint64, err: string] =
  var addrr: uint64
  let c = jitLookupLinkerMangled(jit, jd, name.cstring, addr addrr)
  if c.isNil:
    result = (addrr, "")
  else:
    result = (0'u64, $c)
    jitFreeErrorMessage(c)

proc jitGetJITDylibByName*(jit: LLVMOrcLLJITRef; name: string): LLVMOrcJITDylibRef =
  jitGetJITDylibByName(jit, name.cstring)

proc jitInitialize*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitDeinitialize*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitInitializeSafe*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef): tuple[ok: bool, err: string] =
  let c = jitInitialize(jit, jd)
  if c.isNil:
    return (true, "")
  else:
    result = (false, $c)
    jitFreeErrorMessage(c)

proc jitDeinitializeSafe*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef): tuple[ok: bool, err: string] =
  let c = jitDeinitialize(jit, jd)
  if c.isNil:
    return (true, "")
  else:
    result = (false, $c)
    jitFreeErrorMessage(c)

proc jitLookupInDylib*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; name: cstring; outAddr: ptr uint64): cstring
  {.importc, cdecl, header: "shim.h".}

proc jitLookupInDylib*(jit: LLVMOrcLLJITRef; jd: LLVMOrcJITDylibRef; name: string): tuple[addrr: uint64, err: string] =
  var addrr: uint64
  let c = jitLookupInDylib(jit, jd, name.cstring, addr addrr)
  if c.isNil:
    result = (addrr, "")
  else:
    result = (0'u64, $c)
    jitFreeErrorMessage(c)