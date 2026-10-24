# llvnim23.nim
# Bindings for the LLVM-C API, version 23.1.1.
#
# Target/JIT initialization functions (LLVMInitialize*) are declared at the
# bottom of this file. Call them before creating an ExecutionEngine.

import std/hashes
import std/macros

when defined(windows):
  # Official LLVM 23.x Windows builds ship LLVM-C.dll.
  const LlvmLib {.strdefine.} = "LLVM-C.dll"
elif defined(macosx):
  # Homebrew: /opt/homebrew/opt/llvm/lib/libLLVM.dylib (or libLLVM-23.dylib).
  # Locate via `llvm-config --libdir`. Override with -d:LlvmLib=...
  const LlvmLib {.strdefine.} = "libLLVM.dylib"
else:
  # Fedora/Ubuntu/Debian: libLLVM-23.so.1; Arch: libLLVM.so;
  # upstream tarball: libLLVM.so.23.1. Override with -d:LlvmLib=...
  const LlvmLib {.strdefine.} = "libLLVM.so.23.1"

{.pragma: llvmImport, cdecl, importc, dynlib: LlvmLib.}

proc LLVMGetVersion*(Major, Minor, Patch: var cuint) {.llvmImport.}

const
  ExpectedMajor* = 23
  ExpectedMinor* = 1
  ExpectedPatch* = 1

proc checkVersion*() =
  ## Raises ValueError if the loaded LLVM library version does not match
  ## ExpectedMajor.ExpectedMinor.ExpectedPatch.
  var major, minor, patch: cuint
  LLVMGetVersion(major, minor, patch)
  if major != ExpectedMajor or minor != ExpectedMinor or patch != ExpectedPatch:
    raise newException(
      ValueError,
      "LLVM version mismatch: expected " &
        $ExpectedMajor & "." & $ExpectedMinor & "." & $ExpectedPatch &
        ", got " & $major & "." & $minor & "." & $patch
    )

type
  LLVMContextRef*    = distinct pointer
  LLVMModuleRef*     = distinct pointer
  LLVMTypeRef*       = distinct pointer
  LLVMValueRef*      = distinct pointer
  LLVMBasicBlockRef* = distinct pointer
  LLVMBuilderRef*    = distinct pointer

  LLVMBool* = cint
  LLVMVerifierFailureAction* = cint

const
  LLVMFalse*: LLVMBool = 0
  LLVMTrue*:  LLVMBool = 1

  LLVMAbortProcessAction*:  LLVMVerifierFailureAction = 0
  LLVMPrintMessageAction*:  LLVMVerifierFailureAction = 1
  LLVMReturnStatusAction*:  LLVMVerifierFailureAction = 2

template definePointerOps(T: typedesc) =
  proc `==`*(a, b: T): bool {.inline.} =
    cast[pointer](a) == cast[pointer](b)
  proc isNil*(a: T): bool {.inline.} =
    cast[pointer](a).isNil
  proc `==`*(a: T; b: typeof(nil)): bool {.inline.} = a.isNil
  proc `==`*(a: typeof(nil); b: T): bool {.inline.} = b.isNil
  proc `$`*(a: T): string {.inline.} = $cast[uint](a)
  proc hash*(a: T): Hash {.inline.} = hash(cast[uint](a))

definePointerOps(LLVMContextRef)
definePointerOps(LLVMModuleRef)
definePointerOps(LLVMTypeRef)
definePointerOps(LLVMValueRef)
definePointerOps(LLVMBasicBlockRef)
definePointerOps(LLVMBuilderRef)

proc LLVMContextCreate*(): LLVMContextRef {.llvmImport.}
  ## A single context is not thread-safe; use one context per thread.

proc LLVMContextDisposeImpl(C: LLVMContextRef) {.llvmImport, importc: "LLVMContextDispose".}
proc LLVMContextDispose*(C: LLVMContextRef) {.inline.} =
  ## Do not call while modules/values created in C are still alive.
  doAssert not C.isNil, "LLVMContextDispose: nil context"
  LLVMContextDisposeImpl(C)

proc LLVMModuleCreateWithNameInContext*(
  ModuleID: cstring,
  C: LLVMContextRef
): LLVMModuleRef {.llvmImport.}
  ## Module is bound to C; C must outlive the module.

proc LLVMDisposeModuleImpl(M: LLVMModuleRef) {.llvmImport, importc: "LLVMDisposeModule".}
proc LLVMDisposeModule*(M: LLVMModuleRef) {.inline.} =
  doAssert not M.isNil, "LLVMDisposeModule: nil module"
  LLVMDisposeModuleImpl(M)

proc LLVMPrintModuleToString*(M: LLVMModuleRef): cstring {.llvmImport.}
  ## Free the result with LLVMDisposeMessage.

proc LLVMDisposeMessage*(Message: cstring) {.llvmImport.}

proc LLVMVerifyModule*(
  M: LLVMModuleRef,
  Action: LLVMVerifierFailureAction,
  OutMessage: var cstring
): LLVMBool {.llvmImport.}
  ## If OutMessage is non-nil after the call, free it with LLVMDisposeMessage.

proc verifyModule*(
  M: LLVMModuleRef,
  Action: LLVMVerifierFailureAction = LLVMReturnStatusAction
): tuple[ok: bool, msg: string] =
  ## Safe wrapper around LLVMVerifyModule: frees OutMessage automatically.
  ## `ok` is true when the module verifies; `msg` is empty on success.
  var outMsg: cstring
  defer:
    if not outMsg.isNil:
      LLVMDisposeMessage(outMsg)
  let rc = LLVMVerifyModule(M, Action, outMsg)
  result.ok = rc == LLVMFalse
  result.msg = if outMsg.isNil: "" else: $outMsg

proc LLVMInt32TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}

proc LLVMFunctionType*(
  ReturnType: LLVMTypeRef,
  ParamTypes: ptr LLVMTypeRef,
  ParamCount: cuint,
  IsVarArg: LLVMBool
): LLVMTypeRef {.llvmImport.}

proc LLVMAddFunction*(
  M: LLVMModuleRef,
  Name: cstring,
  FunctionTy: LLVMTypeRef
): LLVMValueRef {.llvmImport.}

proc LLVMAppendBasicBlockInContext*(
  C: LLVMContextRef,
  Fn: LLVMValueRef,
  Name: cstring
): LLVMBasicBlockRef {.llvmImport.}

proc LLVMCreateBuilderInContext*(C: LLVMContextRef): LLVMBuilderRef {.llvmImport.}

proc LLVMDisposeBuilderImpl(B: LLVMBuilderRef) {.llvmImport, importc: "LLVMDisposeBuilder".}
proc LLVMDisposeBuilder*(B: LLVMBuilderRef) {.inline.} =
  doAssert not B.isNil, "LLVMDisposeBuilder: nil builder"
  LLVMDisposeBuilderImpl(B)

proc LLVMPositionBuilderAtEnd*(
  Builder: LLVMBuilderRef,
  BB: LLVMBasicBlockRef
) {.llvmImport.}

proc LLVMBuildAdd*(
  Builder: LLVMBuilderRef,
  LHS: LLVMValueRef,
  RHS: LLVMValueRef,
  Name: cstring
): LLVMValueRef {.llvmImport.}

proc LLVMBuildRet*(
  Builder: LLVMBuilderRef,
  V: LLVMValueRef
): LLVMValueRef {.llvmImport.}

# LLVMBuildUnwind was removed from the C API in LLVM 23.

proc LLVMConstInt*(
  IntTy: LLVMTypeRef,
  N: culonglong,
  SignExtend: LLVMBool
): LLVMValueRef {.llvmImport.}

proc LLVMGetParam*(
  Fn: LLVMValueRef,
  Index: cuint
): LLVMValueRef {.llvmImport.}

# LLVMInitializeAll* and LLVMInitializeNative* are `static inline` in
# llvm-c/Target.h and are not exported from libLLVM.so; reimplemented here
# via the per-architecture initializers, which are exported.
# NVPTX and SPIRV have no AsmParser/Disassembler backends in LLVM 23.1.1.

macro defineArchInit(arch: static string): untyped =
  result = newStmtList()
  for suffix in ["TargetInfo", "Target", "TargetMC",
                 "AsmParser", "AsmPrinter", "Disassembler"]:
    let name = ident("LLVMInitialize" & arch & suffix)
    result.add quote do:
      proc `name`*() {.llvmImport.}

macro defineArchInitNoAsm(arch: static string): untyped =
  result = newStmtList()
  for suffix in ["TargetInfo", "Target", "TargetMC", "AsmPrinter"]:
    let name = ident("LLVMInitialize" & arch & suffix)
    result.add quote do:
      proc `name`*() {.llvmImport.}

macro defineArchInitNoParser(arch: static string): untyped =
  result = newStmtList()
  for suffix in ["TargetInfo", "Target", "TargetMC",
                 "AsmPrinter", "Disassembler"]:
    let name = ident("LLVMInitialize" & arch & suffix)
    result.add quote do:
      proc `name`*() {.llvmImport.}

defineArchInit("AArch64")
defineArchInit("AMDGPU")
defineArchInit("ARM")
defineArchInit("AVR")
defineArchInit("BPF")
defineArchInit("Hexagon")
defineArchInit("Lanai")
defineArchInit("LoongArch")
defineArchInit("Mips")
defineArchInit("MSP430")
defineArchInitNoAsm("NVPTX")
defineArchInit("PowerPC")
defineArchInit("RISCV")
defineArchInit("Sparc")
defineArchInitNoAsm("SPIRV")
defineArchInit("SystemZ")
defineArchInit("VE")
defineArchInit("WebAssembly")
defineArchInit("X86")
defineArchInitNoParser("XCore")

const AllTargetArchs = [
  "AArch64", "AMDGPU", "ARM", "AVR", "BPF", "Hexagon",
  "Lanai", "LoongArch", "Mips", "MSP430", "NVPTX",
  "PowerPC", "RISCV", "Sparc", "SPIRV", "SystemZ", "VE",
  "WebAssembly", "X86", "XCore"
]

const AllAsmParserArchs = [
  "AArch64", "AMDGPU", "ARM", "AVR", "BPF", "Hexagon",
  "Lanai", "LoongArch", "Mips", "MSP430",
  "PowerPC", "RISCV", "Sparc", "SystemZ", "VE",
  "WebAssembly", "X86"
]

const AllDisassemblerArchs = [
  "AArch64", "AMDGPU", "ARM", "AVR", "BPF", "Hexagon",
  "Lanai", "LoongArch", "Mips", "MSP430",
  "PowerPC", "RISCV", "Sparc", "SystemZ", "VE",
  "WebAssembly", "X86", "XCore"
]

macro defineAllInit(name, suffix: static string, archs: static openArray[string]): untyped =
  let procName = ident(name)
  var body = newStmtList()
  for arch in archs:
    body.add newCall(ident("LLVMInitialize" & arch & suffix))
  result = quote do:
    proc `procName`*() =
      `body`

defineAllInit("LLVMInitializeAllTargetInfos", "TargetInfo", AllTargetArchs)
defineAllInit("LLVMInitializeAllTargets", "Target", AllTargetArchs)
defineAllInit("LLVMInitializeAllTargetMCs", "TargetMC", AllTargetArchs)
defineAllInit("LLVMInitializeAllAsmParsers", "AsmParser", AllAsmParserArchs)
defineAllInit("LLVMInitializeAllAsmPrinters", "AsmPrinter", AllTargetArchs)
defineAllInit("LLVMInitializeAllDisassemblers", "Disassembler", AllDisassemblerArchs)

proc LLVMInitializeNativeTarget*(): LLVMBool =
  when hostCPU == "amd64" or hostCPU == "i386":
    LLVMInitializeX86TargetInfo()
    LLVMInitializeX86Target()
    LLVMInitializeX86TargetMC()
  elif hostCPU == "arm64":
    LLVMInitializeAArch64TargetInfo()
    LLVMInitializeAArch64Target()
    LLVMInitializeAArch64TargetMC()
  else:
    {.error: "unsupported host CPU".}
  LLVMFalse

proc LLVMInitializeNativeAsmParser*(): LLVMBool =
  when hostCPU == "amd64" or hostCPU == "i386":
    LLVMInitializeX86AsmParser()
  elif hostCPU == "arm64":
    LLVMInitializeAArch64AsmParser()
  else:
    {.error: "unsupported host CPU".}
  LLVMFalse

proc LLVMInitializeNativeAsmPrinter*(): LLVMBool =
  when hostCPU == "amd64" or hostCPU == "i386":
    LLVMInitializeX86AsmPrinter()
  elif hostCPU == "arm64":
    LLVMInitializeAArch64AsmPrinter()
  else:
    {.error: "unsupported host CPU".}
  LLVMFalse

proc LLVMInitializeNativeDisassembler*(): LLVMBool =
  when hostCPU == "amd64" or hostCPU == "i386":
    LLVMInitializeX86Disassembler()
  elif hostCPU == "arm64":
    LLVMInitializeAArch64Disassembler()
  else:
    {.error: "unsupported host CPU".}
  LLVMFalse

# JIT (ExecutionEngine). Call LLVMInitializeNative* before createJIT.
# LLVMDisposeExecutionEngine frees the module: do not dispose it separately.

type
  LLVMExecutionEngineRef* = distinct pointer

definePointerOps(LLVMExecutionEngineRef)

proc LLVMCreateJITCompilerForModule*(
  OutJIT: var LLVMExecutionEngineRef,
  M: LLVMModuleRef,
  OptLevel: cuint,
  OutError: var cstring
): LLVMBool {.llvmImport.}

proc LLVMDisposeExecutionEngine*(EE: LLVMExecutionEngineRef) {.llvmImport.}

proc LLVMGetFunctionAddress*(
  EE: LLVMExecutionEngineRef,
  Name: cstring
): uint64 {.llvmImport.}

proc createJIT*(
  M: LLVMModuleRef,
  OptLevel: cuint = 0
): tuple[ee: LLVMExecutionEngineRef, err: string] =
  ## Creates an MCJIT engine for M. Returns ee=nil and a non-empty err on failure.
  ## On success, the engine owns M: do not dispose M separately.
  var ee: LLVMExecutionEngineRef
  var errMsg: cstring
  defer:
    if not errMsg.isNil:
      LLVMDisposeMessage(errMsg)
  let rc = LLVMCreateJITCompilerForModule(ee, M, OptLevel, errMsg)
  result.ee = if rc == LLVMFalse: ee else: default(LLVMExecutionEngineRef)
  result.err = if errMsg.isNil: "" else: $errMsg

# Additional types (iN, float, double, void, pointer) and basic instructions.
proc LLVMInt1TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMInt8TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMInt16TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMInt64TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMInt128TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMIntTypeInContext*(C: LLVMContextRef, NumBits: cuint): LLVMTypeRef {.llvmImport.}

proc LLVMFloatTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMDoubleTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMVoidTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.llvmImport.}
proc LLVMPointerType*(ElementType: LLVMTypeRef, AddressSpace: cuint): LLVMTypeRef {.llvmImport.}
proc LLVMPointerTypeInContext*(C: LLVMContextRef, AddressSpace: cuint): LLVMTypeRef {.llvmImport.}

type
  LLVMIntPredicate* = enum
    LLVMIntEQ = 32
    LLVMIntNE = 33
    LLVMIntUGT = 34
    LLVMIntUGE = 35
    LLVMIntULT = 36
    LLVMIntULE = 37
    LLVMIntSGT = 38
    LLVMIntSGE = 39
    LLVMIntSLT = 40
    LLVMIntSLE = 41

proc LLVMBuildSub*(Builder: LLVMBuilderRef, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildMul*(Builder: LLVMBuilderRef, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildUDiv*(Builder: LLVMBuilderRef, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildSDiv*(Builder: LLVMBuilderRef, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildURem*(Builder: LLVMBuilderRef, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildSRem*(Builder: LLVMBuilderRef, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}

proc LLVMBuildICmp*(Builder: LLVMBuilderRef, Op: LLVMIntPredicate, LHS, RHS: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}

proc LLVMBuildBr*(Builder: LLVMBuilderRef, Dest: LLVMBasicBlockRef): LLVMValueRef {.llvmImport.}
proc LLVMBuildCondBr*(Builder: LLVMBuilderRef, If: LLVMValueRef, Then, Else: LLVMBasicBlockRef): LLVMValueRef {.llvmImport.}
proc LLVMBuildRetVoid*(Builder: LLVMBuilderRef): LLVMValueRef {.llvmImport.}

proc LLVMBuildAlloca*(Builder: LLVMBuilderRef, Ty: LLVMTypeRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildLoad2*(Builder: LLVMBuilderRef, Ty: LLVMTypeRef, PointerVal: LLVMValueRef, Name: cstring): LLVMValueRef {.llvmImport.}
proc LLVMBuildStore*(Builder: LLVMBuilderRef, Val, Ptr: LLVMValueRef): LLVMValueRef {.llvmImport.}

proc LLVMBuildCall2*(
  Builder: LLVMBuilderRef,
  FnTy: LLVMTypeRef,
  Fn: LLVMValueRef,
  Args: ptr LLVMValueRef,
  NumArgs: cuint,
  Name: cstring
): LLVMValueRef {.llvmImport.}

type
  LLVMTypeKind* {.size: sizeof(cint).} = enum
    LLVMVoidTypeKind = 0
    LLVMHalfTypeKind = 1
    LLVMFloatTypeKind = 2
    LLVMDoubleTypeKind = 3
    LLVMX86_FP80TypeKind = 4
    LLVMFP128TypeKind = 5
    LLVMPPC_FP128TypeKind = 6
    LLVMLabelTypeKind = 7
    LLVMIntegerTypeKind = 8
    LLVMFunctionTypeKind = 9
    LLVMStructTypeKind = 10
    LLVMArrayTypeKind = 11
    LLVMPointerTypeKind = 12
    LLVMVectorTypeKind = 13
    LLVMMetadataTypeKind = 14
    LLVMTokenTypeKind = 15
    LLVMScalableVectorTypeKind = 16
    LLVMBFloatTypeKind = 17
    LLVMX86_AMXTypeKind = 18
    LLVMX86_MMXTypeKind = 19
    LLVMTargetExtTypeKind = 20

proc LLVMGetTypeKind*(Ty: LLVMTypeRef): LLVMTypeKind {.llvmImport.}

proc LLVMPrintValueToString*(Val: LLVMValueRef): cstring {.llvmImport.}
  ## Free with LLVMDisposeMessage.

proc LLVMDumpModule*(M: LLVMModuleRef) {.llvmImport.}
  ## Dumps to stderr. For quick debugging; prefer LLVMPrintModuleToString.