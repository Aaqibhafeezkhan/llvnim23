# Copyright (c) 2026 https://github.com/xlebore3o4ka

import ../llvnim
import os
import std/strutils

{.passL: staticExec("llvm-config --libs --system-libs").splitWhitespace().join(" ").}
{.passC: "-I" & currentSourcePath().parentDir.}
{.compile: currentSourcePath().parentDir / "shim.cc".}
{.passC: "-std=c++17".}

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