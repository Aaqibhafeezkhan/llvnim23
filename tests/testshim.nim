# Copyright (c) 2026 https://github.com/xlebore3o4ka

import unittest
import ../src/llvnim
import ../src/llvnim/shim

suite "shim":

  test "jitLinkStaticLibraryInto succeeds":
    discard LLVMInitializeNativeTarget()
    discard LLVMInitializeNativeAsmPrinter()

    let (jit, err) = createLLJIT()
    check err.len == 0

    let jd = LLVMOrcLLJITGetMainJITDylib(jit)
    let (ok, msg) = jitLinkStaticLibraryInto(jit, jd, "/usr/lib/libLLVMDemangle.a")
    check ok
    check msg.len == 0