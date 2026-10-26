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