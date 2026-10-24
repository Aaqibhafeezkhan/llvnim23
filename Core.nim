## ===-- llvm-c/Core.h - Core Library C Interface ------------------*- C -*-===*\
## |*                                                                            *|
## |* Part of the LLVM Project, under the Apache License v2.0 with LLVM          *|
## |* Exceptions.                                                                *|
## |* See https://llvm.org/LICENSE.txt for license information.                  *|
## |* SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception                    *|
## |*                                                                            *|
## |*===----------------------------------------------------------------------===*|
## |*                                                                            *|
## |* This header declares the C interface to libLLVMCore.a, which implements    *|
## |* the LLVM intermediate representation.                                      *|
## |*                                                                            *|
## \*===----------------------------------------------------------------------===

## !!!Ignored construct:  # LLVM_C_CORE_H [NewLine] # LLVM_C_CORE_H [NewLine] # llvm-c/Deprecated.h [NewLine] # llvm-c/ErrorHandling.h [NewLine] # llvm-c/ExternC.h [NewLine] # llvm-c/Visibility.h [NewLine] # llvm-c/Types.h [NewLine]
##  @defgroup LLVMC LLVM-C: C interface to LLVM
##
##  This module exposes parts of the LLVM library as a C API.
##
##  @{
##
##  @defgroup LLVMCTransforms Transforms
##
##  @defgroup LLVMCCore Core
##
##  This modules provide an interface to libLLVMCore, which implements
##  the LLVM intermediate representation as well as other related types
##  and utilities.
##
##  Many exotic languages can interoperate with C code but have a harder time
##  with C++ due to name mangling. So in addition to C, this interface enables
##  tools written in such languages.
##
##  @{
##
##  @defgroup LLVMCCoreTypes Types and Enumerations
##
##  @{
##   External users depend on the following values being stable. It is not safe
##  to reorder them. typedef enum {  Terminator Instructions LLVMRet = 1 ,  removed 2 due to API changes LLVMUncondBr = 70 , LLVMCondBr = 71 , LLVMSwitch = 3 , LLVMIndirectBr = 4 , LLVMInvoke = 5 ,  removed 6 due to API changes LLVMUnreachable = 7 , LLVMCallBr = 67 ,  Standard Unary Operators LLVMFNeg = 66 ,  Standard Binary Operators LLVMAdd = 8 , LLVMFAdd = 9 , LLVMSub = 10 , LLVMFSub = 11 , LLVMMul = 12 , LLVMFMul = 13 , LLVMUDiv = 14 , LLVMSDiv = 15 , LLVMFDiv = 16 , LLVMURem = 17 , LLVMSRem = 18 , LLVMFRem = 19 ,  Logical Operators LLVMShl = 20 , LLVMLShr = 21 , LLVMAShr = 22 , LLVMAnd = 23 , LLVMOr = 24 , LLVMXor = 25 ,  Memory Operators LLVMAlloca = 26 , LLVMLoad = 27 , LLVMStore = 28 , LLVMGetElementPtr = 29 ,  Cast Operators LLVMTrunc = 30 , LLVMZExt = 31 , LLVMSExt = 32 , LLVMFPToUI = 33 , LLVMFPToSI = 34 , LLVMUIToFP = 35 , LLVMSIToFP = 36 , LLVMFPTrunc = 37 , LLVMFPExt = 38 , LLVMPtrToInt = 39 , LLVMPtrToAddr = 69 , LLVMIntToPtr = 40 , LLVMBitCast = 41 , LLVMAddrSpaceCast = 60 ,  Other Operators LLVMICmp = 42 , LLVMFCmp = 43 , LLVMPHI = 44 , LLVMCall = 45 , LLVMSelect = 46 , LLVMUserOp1 = 47 , LLVMUserOp2 = 48 , LLVMVAArg = 49 , LLVMExtractElement = 50 , LLVMInsertElement = 51 , LLVMShuffleVector = 52 , LLVMExtractValue = 53 , LLVMInsertValue = 54 , LLVMFreeze = 68 ,  Atomic operators LLVMFence = 55 , LLVMAtomicCmpXchg = 56 , LLVMAtomicRMW = 57 ,  Exception Handling Operators LLVMResume = 58 , LLVMLandingPad = 59 , LLVMCleanupRet = 61 , LLVMCatchRet = 62 , LLVMCatchPad = 63 , LLVMCleanupPad = 64 , LLVMCatchSwitch = 65 } LLVMOpcode ;
## Error: identifier expected, but got: ;!!!

type ##
    ##  Emits an error if two values disagree, otherwise the resulting value is
    ##  that of the operands.
    ##
    ##  @see Module::ModFlagBehavior::Error
    ##
  LLVMTypeKind* {.size: sizeof(cint).} = enum
    LLVMVoidTypeKind = 0,       ## < type with no size
    LLVMHalfTypeKind = 1,       ## < 16 bit floating point type
    LLVMFloatTypeKind = 2,      ## < 32 bit floating point type
    LLVMDoubleTypeKind = 3,     ## < 64 bit floating point type
    LLVMX86_FP80TypeKind = 4,   ## < 80 bit floating point type (X87)
    LLVMFP128TypeKind = 5,      ## < 128 bit floating point type (112-bit mantissa)
    LLVMPPC_FP128TypeKind = 6,  ## < 128 bit floating point type (two 64-bits)
    LLVMLabelTypeKind = 7,      ## < Labels
    LLVMIntegerTypeKind = 8,    ## < Arbitrary bit width integers
    LLVMFunctionTypeKind = 9,   ## < Functions
    LLVMStructTypeKind = 10,    ## < Structures
    LLVMArrayTypeKind = 11,     ## < Arrays
    LLVMPointerTypeKind = 12,   ## < Pointers
    LLVMVectorTypeKind = 13,    ## < Fixed width SIMD vector type
    LLVMMetadataTypeKind = 14,  ## < Metadata
                            ##  15 previously used by LLVMX86_MMXTypeKind
    LLVMTokenTypeKind = 16,     ## < Tokens
    LLVMScalableVectorTypeKind = 17, ## < Scalable SIMD vector type
    LLVMBFloatTypeKind = 18,    ## < 16 bit brain floating point type
    LLVMX86_AMXTypeKind = 19,   ## < X86 AMX
    LLVMTargetExtTypeKind = 20, ## < Target extension type
    LLVMByteTypeKind = 21       ## < Arbitrary bit width bytes
  LLVMLinkage* {.size: sizeof(cint).} = enum
    LLVMExternalLinkage,      ## < Externally visible function
    LLVMAvailableExternallyLinkage, LLVMLinkOnceAnyLinkage, ## < Keep one copy of function when linking (inline)
    LLVMLinkOnceODRLinkage,   ## < Same, but only replaced by something
                           ##                             equivalent.
    LLVMLinkOnceODRAutoHideLinkage, ## < Obsolete
    LLVMWeakAnyLinkage,       ## < Keep one copy of function when linking (weak)
    LLVMWeakODRLinkage,       ## < Same, but only replaced by something
                       ##                             equivalent.
    LLVMAppendingLinkage,     ## < Special purpose, only applies to global arrays
    LLVMInternalLinkage,      ## < Rename collisions when linking (static
                        ##                                functions)
    LLVMPrivateLinkage,       ## < Like Internal, but omit from symbol table
    LLVMDLLImportLinkage,     ## < Obsolete
    LLVMDLLExportLinkage,     ## < Obsolete
    LLVMExternalWeakLinkage,  ## < ExternalWeak linkage description
    LLVMGhostLinkage,         ## < Obsolete
    LLVMCommonLinkage,        ## < Tentative definitions
    LLVMLinkerPrivateLinkage, ## < Like Private, but linker removes.
    LLVMLinkerPrivateWeakLinkage ## < Like LinkerPrivate, but is weak.
  LLVMVisibility* {.size: sizeof(cint).} = enum
    LLVMDefaultVisibility,    ## < The GV is visible
    LLVMHiddenVisibility,     ## < The GV is hidden
    LLVMProtectedVisibility   ## < The GV is protected
  LLVMUnnamedAddr* {.size: sizeof(cint).} = enum
    LLVMNoUnnamedAddr,        ## < Address of the GV is significant.
    LLVMLocalUnnamedAddr,     ## < Address of the GV is locally insignificant.
    LLVMGlobalUnnamedAddr     ## < Address of the GV is globally insignificant.
  LLVMDLLStorageClass* {.size: sizeof(cint).} = enum
    LLVMDefaultStorageClass = 0, LLVMDLLImportStorageClass = 1, ## < Function to be imported from DLL.
    LLVMDLLExportStorageClass = 2 ## < Function to be accessible from DLL.
  LLVMCallConv* {.size: sizeof(cint).} = enum
    LLVMCCallConv = 0, LLVMFastCallConv = 8, LLVMColdCallConv = 9, LLVMGHCCallConv = 10,
    LLVMHiPECallConv = 11, LLVMAnyRegCallConv = 13, LLVMPreserveMostCallConv = 14,
    LLVMPreserveAllCallConv = 15, LLVMSwiftCallConv = 16, LLVMCXXFASTTLSCallConv = 17,
    LLVMX86StdcallCallConv = 64, LLVMX86FastcallCallConv = 65,
    LLVMARMAPCSCallConv = 66, LLVMARMAAPCSCallConv = 67, LLVMARMAAPCSVFPCallConv = 68,
    LLVMMSP430INTRCallConv = 69, LLVMX86ThisCallCallConv = 70,
    LLVMPTXKernelCallConv = 71, LLVMPTXDeviceCallConv = 72, LLVMSPIRFUNCCallConv = 75,
    LLVMSPIRKERNELCallConv = 76, LLVMIntelOCLBICallConv = 77,
    LLVMX8664SysVCallConv = 78, LLVMWin64CallConv = 79,
    LLVMX86VectorCallCallConv = 80, LLVMHHVMCallConv = 81, LLVMHHVMCCallConv = 82,
    LLVMX86INTRCallConv = 83, LLVMAVRINTRCallConv = 84, LLVMAVRSIGNALCallConv = 85,
    LLVMAVRBUILTINCallConv = 86, LLVMAMDGPUVSCallConv = 87, LLVMAMDGPUGSCallConv = 88,
    LLVMAMDGPUPSCallConv = 89, LLVMAMDGPUCSCallConv = 90,
    LLVMAMDGPUKERNELCallConv = 91, LLVMX86RegCallCallConv = 92,
    LLVMAMDGPUHSCallConv = 93, LLVMMSP430BUILTINCallConv = 94,
    LLVMAMDGPULSCallConv = 95, LLVMAMDGPUESCallConv = 96
  LLVMValueKind* {.size: sizeof(cint).} = enum
    LLVMArgumentValueKind, LLVMBasicBlockValueKind, LLVMMemoryUseValueKind,
    LLVMMemoryDefValueKind, LLVMMemoryPhiValueKind, LLVMFunctionValueKind,
    LLVMGlobalAliasValueKind, LLVMGlobalIFuncValueKind,
    LLVMGlobalVariableValueKind, LLVMBlockAddressValueKind,
    LLVMConstantExprValueKind, LLVMConstantArrayValueKind,
    LLVMConstantStructValueKind, LLVMConstantVectorValueKind,
    LLVMUndefValueValueKind, LLVMConstantAggregateZeroValueKind,
    LLVMConstantDataArrayValueKind, LLVMConstantDataVectorValueKind,
    LLVMConstantIntValueKind, LLVMConstantByteValueKind, LLVMConstantFPValueKind,
    LLVMConstantPointerNullValueKind, LLVMConstantTokenNoneValueKind,
    LLVMMetadataAsValueValueKind, LLVMInlineAsmValueKind,
    LLVMInstructionValueKind, LLVMPoisonValueValueKind,
    LLVMConstantTargetNoneValueKind, LLVMConstantPtrAuthValueKind
  LLVMIntPredicate* {.size: sizeof(cint).} = enum
    LLVMIntEQ = 32,             ## < equal
    LLVMIntNE,                ## < not equal
    LLVMIntUGT,               ## < unsigned greater than
    LLVMIntUGE,               ## < unsigned greater or equal
    LLVMIntULT,               ## < unsigned less than
    LLVMIntULE,               ## < unsigned less or equal
    LLVMIntSGT,               ## < signed greater than
    LLVMIntSGE,               ## < signed greater or equal
    LLVMIntSLT,               ## < signed less than
    LLVMIntSLE                ## < signed less or equal
  LLVMRealPredicate* {.size: sizeof(cint).} = enum
    LLVMRealPredicateFalse,   ## < Always false (always folded)
    LLVMRealOEQ,              ## < True if ordered and equal
    LLVMRealOGT,              ## < True if ordered and greater than
    LLVMRealOGE,              ## < True if ordered and greater than or equal
    LLVMRealOLT,              ## < True if ordered and less than
    LLVMRealOLE,              ## < True if ordered and less than or equal
    LLVMRealONE,              ## < True if ordered and operands are unequal
    LLVMRealORD,              ## < True if ordered (no nans)
    LLVMRealUNO,              ## < True if unordered: isnan(X) | isnan(Y)
    LLVMRealUEQ,              ## < True if unordered or equal
    LLVMRealUGT,              ## < True if unordered or greater than
    LLVMRealUGE,              ## < True if unordered, greater than, or equal
    LLVMRealULT,              ## < True if unordered or less than
    LLVMRealULE,              ## < True if unordered, less than, or equal
    LLVMRealUNE,              ## < True if unordered or not equal
    LLVMRealPredicateTrue     ## < Always true (always folded)
  LLVMThreadLocalMode* {.size: sizeof(cint).} = enum
    LLVMNotThreadLocal = 0, LLVMGeneralDynamicTLSModel, LLVMLocalDynamicTLSModel,
    LLVMInitialExecTLSModel, LLVMLocalExecTLSModel
  LLVMAtomicOrdering* {.size: sizeof(cint).} = enum
    LLVMAtomicOrderingNotAtomic = 0, ## < A load or store which is not atomic
    LLVMAtomicOrderingUnordered = 1, ## < Lowest level of atomicity, guarantees
                                  ##                                      somewhat sane results, lock free.
    LLVMAtomicOrderingMonotonic = 2, ## < guarantees that if you take all the
                                  ##                                      operations affecting a specific address,
                                  ##                                      a consistent ordering exists
    LLVMAtomicOrderingAcquire = 4, ## < Acquire provides a barrier of the sort
                                ##                                    necessary to acquire a lock to access other
                                ##                                    memory with normal loads and stores.
    LLVMAtomicOrderingRelease = 5, ## < Release is similar to Acquire, but with
                                ##                                    a barrier of the sort necessary to release
                                ##                                    a lock.
    LLVMAtomicOrderingAcquireRelease = 6, ## < provides both an Acquire and a
                                       ##                                           Release barrier (for fences and
                                       ##                                           operations which both read and write
                                       ##                                            memory).
    LLVMAtomicOrderingSequentiallyConsistent = 7 ## < provides Acquire semantics
                                              ##                                                  for loads and Release
                                              ##                                                  semantics for stores.
                                              ##                                                  Additionally, it guarantees
                                              ##                                                  that a total ordering exists
                                              ##                                                  between all
                                              ##                                                  SequentiallyConsistent
                                              ##                                                  operations.
  LLVMAtomicRMWBinOp* {.size: sizeof(cint).} = enum
    LLVMAtomicRMWBinOpXchg,   ## < Set the new value and return the one old
    LLVMAtomicRMWBinOpAdd,    ## < Add a value and return the old one
    LLVMAtomicRMWBinOpSub,    ## < Subtract a value and return the old one
    LLVMAtomicRMWBinOpAnd,    ## < And a value and return the old one
    LLVMAtomicRMWBinOpNand,   ## < Not-And a value and return the old one
    LLVMAtomicRMWBinOpOr,     ## < OR a value and return the old one
    LLVMAtomicRMWBinOpXor,    ## < Xor a value and return the old one
    LLVMAtomicRMWBinOpMax, ## < Sets the value if it's greater than the
                          ##                             original using a signed comparison and return
                          ##                             the old one
    LLVMAtomicRMWBinOpMin, ## < Sets the value if it's Smaller than the
                          ##                             original using a signed comparison and return
                          ##                             the old one
    LLVMAtomicRMWBinOpUMax, ## < Sets the value if it's greater than the
                           ##                            original using an unsigned comparison and return
                           ##                            the old one
    LLVMAtomicRMWBinOpUMin, ## < Sets the value if it's greater than the
                           ##                             original using an unsigned comparison and return
                           ##                             the old one
    LLVMAtomicRMWBinOpFAdd,   ## < Add a floating point value and return the
                           ##                             old one
    LLVMAtomicRMWBinOpFSub,   ## < Subtract a floating point value and return the
                           ##                           old one
    LLVMAtomicRMWBinOpFMax, ## < Sets the value if it's greater than the
                           ##                            original using an floating point comparison and
                           ##                            return the old one
    LLVMAtomicRMWBinOpFMin, ## < Sets the value if it's smaller than the
                           ##                            original using an floating point comparison and
                           ##                            return the old one
    LLVMAtomicRMWBinOpUIncWrap, ## < Increments the value, wrapping back to zero
                               ##                                when incremented above input value
    LLVMAtomicRMWBinOpUDecWrap, ## < Decrements the value, wrapping back to
                               ##                                the input value when decremented below zero
    LLVMAtomicRMWBinOpUSubCond, ## <Subtracts the value only if no unsigned
                               ##                                  overflow
    LLVMAtomicRMWBinOpUSubSat, ## <Subtracts the value, clamping to zero
    LLVMAtomicRMWBinOpFMaximum, ## < Sets the value if it's greater than the
                               ##                            original using an floating point comparison and
                               ##                            return the old one
    LLVMAtomicRMWBinOpFMinimum, ## < Sets the value if it's smaller than the
                               ##                            original using an floating point comparison and
                               ##                            return the old one
    LLVMAtomicRMWBinOpFMaximumNum, ## < Sets the value if it's greater than the
                                  ##                            original using an floating point comparison and
                                  ##                            return the old one
    LLVMAtomicRMWBinOpFMinimumNum ## < Sets the value if it's smaller than the
                                 ##                            original using an floating point comparison and
                                 ##                            return the old one
  LLVMDiagnosticSeverity* {.size: sizeof(cint).} = enum
    LLVMDSError, LLVMDSWarning, LLVMDSRemark, LLVMDSNote
  LLVMInlineAsmDialect* {.size: sizeof(cint).} = enum
    LLVMInlineAsmDialectATT, LLVMInlineAsmDialectIntel
  LLVMModuleFlagBehavior* {.size: sizeof(cint).} = enum
    LLVMModuleFlagBehaviorError, ##
                                ##  Emits a warning if two values disagree. The result value will be the
                                ##  operand for the flag from the first module being linked.
                                ##
                                ##  @see Module::ModFlagBehavior::Warning
                                ##
    LLVMModuleFlagBehaviorWarning, ##
                                  ##  Adds a requirement that another module flag be present and have a
                                  ##  specified value after linking is performed. The value must be a metadata
                                  ##  pair, where the first element of the pair is the ID of the module flag
                                  ##  to be restricted, and the second element of the pair is the value the
                                  ##  module flag should be restricted to. This behavior can be used to
                                  ##  restrict the allowable results (via triggering of an error) of linking
                                  ##  IDs with the **Override** behavior.
                                  ##
                                  ##  @see Module::ModFlagBehavior::Require
                                  ##
    LLVMModuleFlagBehaviorRequire, ##
                                  ##  Uses the specified value, regardless of the behavior or value of the
                                  ##  other module. If both modules specify **Override**, but the values
                                  ##  differ, an error will be emitted.
                                  ##
                                  ##  @see Module::ModFlagBehavior::Override
                                  ##
    LLVMModuleFlagBehaviorOverride, ##
                                   ##  Appends the two values, which are required to be metadata nodes.
                                   ##
                                   ##  @see Module::ModFlagBehavior::Append
                                   ##
    LLVMModuleFlagBehaviorAppend, ##
                                 ##  Appends the two values, which are required to be metadata
                                 ##  nodes. However, duplicate entries in the second list are dropped
                                 ##  during the append operation.
                                 ##
                                 ##  @see Module::ModFlagBehavior::AppendUnique
                                 ##
    LLVMModuleFlagBehaviorAppendUnique
















##
##  Attribute index are either LLVMAttributeReturnIndex,
##  LLVMAttributeFunctionIndex or a parameter number from 1 to N.
##

const
  LLVMAttributeReturnIndex* = 0'u ##  ISO C restricts enumerator values to range of 'int'
                               ##  (4294967295 is too large)
                               ##  LLVMAttributeFunctionIndex = ~0U,
  LLVMAttributeFunctionIndex* = -1

## !!!Ignored construct:  typedef unsigned LLVMAttributeIndex ;
## Error: identifier expected, but got: ;!!!

##
##  Tail call kind for LLVMSetTailCallKind and LLVMGetTailCallKind.
##
##  Note that 'musttail' implies 'tail'.
##
##  @see CallInst::TailCallKind
##

type
  LLVMTailCallKind* {.size: sizeof(cint).} = enum
    LLVMTailCallKindNone = 0, LLVMTailCallKindTail = 1, LLVMTailCallKindMustTail = 2,
    LLVMTailCallKindNoTail = 3


const
  LLVMFastMathAllowReassoc* = (1 shl 0)
  LLVMFastMathNoNaNs* = (1 shl 1)
  LLVMFastMathNoInfs* = (1 shl 2)
  LLVMFastMathNoSignedZeros* = (1 shl 3)
  LLVMFastMathAllowReciprocal* = (1 shl 4)
  LLVMFastMathAllowContract* = (1 shl 5)
  LLVMFastMathApproxFunc* = (1 shl 6)
  LLVMFastMathNone* = 0
  LLVMFastMathAll* = LLVMFastMathAllowReassoc or LLVMFastMathNoNaNs or
      LLVMFastMathNoInfs or LLVMFastMathNoSignedZeros or
      LLVMFastMathAllowReciprocal or LLVMFastMathAllowContract or
      LLVMFastMathApproxFunc

##
##  Flags to indicate what fast-math-style optimizations are allowed
##  on operations.
##
##  See https://llvm.org/docs/LangRef.html#fast-math-flags
##

## !!!Ignored construct:  typedef unsigned LLVMFastMathFlags ;
## Error: identifier expected, but got: ;!!!

const
  LLVMGEPFlagInBounds* = (1 shl 0)
  LLVMGEPFlagNUSW* = (1 shl 1)
  LLVMGEPFlagNUW* = (1 shl 2)

##
##  Flags that constrain the allowed wrap semantics of a getelementptr
##  instruction.
##
##  See https://llvm.org/docs/LangRef.html#getelementptr-instruction
##

## !!!Ignored construct:  typedef unsigned LLVMGEPNoWrapFlags ;
## Error: identifier expected, but got: ;!!!

type
  LLVMDbgRecordKind* {.size: sizeof(cint).} = enum
    LLVMDbgRecordLabel, LLVMDbgRecordDeclare, LLVMDbgRecordValue,
    LLVMDbgRecordAssign


##
##  @}
##
##  Deallocate and destroy all ManagedStatic variables.
##     @see llvm::llvm_shutdown
##     @see ManagedStatic

proc LLVMShutdown*() {.cdecl, importc: "LLVMShutdown", dynlib: libLLVM.so.23.1.}
## ===-- Version query -----------------------------------------------------===
##
##  Return the major, minor, and patch version of LLVM
##
##  The version components are returned via the function's three output
##  parameters or skipped if a NULL pointer was supplied.
##

proc LLVMGetVersion*(Major: ptr cuint; Minor: ptr cuint; Patch: ptr cuint) {.cdecl,
    importc: "LLVMGetVersion", dynlib: libLLVM.so.23.1.}
## ===-- Error handling ----------------------------------------------------===

proc LLVMCreateMessage*(Message: cstring): cstring {.cdecl,
    importc: "LLVMCreateMessage", dynlib: libLLVM.so.23.1.}
proc LLVMDisposeMessage*(Message: cstring) {.cdecl, importc: "LLVMDisposeMessage",
    dynlib: libLLVM.so.23.1.}
##
##  @defgroup LLVMCCoreContext Contexts
##
##  Contexts are execution states for the core LLVM IR system.
##
##  Most types are tied to a context instance. Multiple contexts can
##  exist simultaneously. A single context is not thread safe. However,
##  different contexts can execute on different threads simultaneously.
##
##  @{
##

type
  LLVMDiagnosticHandler* = proc (a1: LLVMDiagnosticInfoRef; a2: pointer) {.cdecl.}
  LLVMYieldCallback* = proc (a1: LLVMContextRef; a2: pointer) {.cdecl.}

##
##  Create a new context.
##
##  Every call to this function should be paired with a call to
##  LLVMContextDispose() or the context will leak memory.
##

proc LLVMContextCreate*(): LLVMContextRef {.cdecl, importc: "LLVMContextCreate",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain the global context instance.
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMContextRef, LLVMGetGlobalContext(void), "Use of the global context is deprecated, create one using LLVMContextCreate instead")
##
##  Set the diagnostic handler for this context.
##

proc LLVMContextSetDiagnosticHandler*(C: LLVMContextRef;
                                     Handler: LLVMDiagnosticHandler;
                                     DiagnosticContext: pointer) {.cdecl,
    importc: "LLVMContextSetDiagnosticHandler", dynlib: libLLVM.so.23.1.}
##
##  Get the diagnostic handler of this context.
##

proc LLVMContextGetDiagnosticHandler*(C: LLVMContextRef): LLVMDiagnosticHandler {.
    cdecl, importc: "LLVMContextGetDiagnosticHandler", dynlib: libLLVM.so.23.1.}
##
##  Get the diagnostic context of this context.
##

proc LLVMContextGetDiagnosticContext*(C: LLVMContextRef): pointer {.cdecl,
    importc: "LLVMContextGetDiagnosticContext", dynlib: libLLVM.so.23.1.}
##
##  Set the yield callback function for this context.
##
##  @see LLVMContext::setYieldCallback()
##

proc LLVMContextSetYieldCallback*(C: LLVMContextRef; Callback: LLVMYieldCallback;
                                 OpaqueHandle: pointer) {.cdecl,
    importc: "LLVMContextSetYieldCallback", dynlib: libLLVM.so.23.1.}
##
##  Retrieve whether the given context is set to discard all value names.
##
##  @see LLVMContext::shouldDiscardValueNames()
##

proc LLVMContextShouldDiscardValueNames*(C: LLVMContextRef): LLVMBool {.cdecl,
    importc: "LLVMContextShouldDiscardValueNames", dynlib: libLLVM.so.23.1.}
##
##  Set whether the given context discards all value names.
##
##  If true, only the names of GlobalValue objects will be available in the IR.
##  This can be used to save memory and runtime, especially in release mode.
##
##  @see LLVMContext::setDiscardValueNames()
##

proc LLVMContextSetDiscardValueNames*(C: LLVMContextRef; Discard: LLVMBool) {.cdecl,
    importc: "LLVMContextSetDiscardValueNames", dynlib: libLLVM.so.23.1.}
##
##  Destroy a context instance.
##
##  This should be called for every call to LLVMContextCreate() or memory
##  will be leaked.
##

proc LLVMContextDispose*(C: LLVMContextRef) {.cdecl, importc: "LLVMContextDispose",
    dynlib: libLLVM.so.23.1.}
##
##  Return a string representation of the DiagnosticInfo. Use
##  LLVMDisposeMessage to free the string.
##
##  @see DiagnosticInfo::print()
##

proc LLVMGetDiagInfoDescription*(DI: LLVMDiagnosticInfoRef): cstring {.cdecl,
    importc: "LLVMGetDiagInfoDescription", dynlib: libLLVM.so.23.1.}
##
##  Return an enum LLVMDiagnosticSeverity.
##
##  @see DiagnosticInfo::getSeverity()
##

proc LLVMGetDiagInfoSeverity*(DI: LLVMDiagnosticInfoRef): LLVMDiagnosticSeverity {.
    cdecl, importc: "LLVMGetDiagInfoSeverity", dynlib: libLLVM.so.23.1.}
proc LLVMGetMDKindIDInContext*(C: LLVMContextRef; Name: cstring; SLen: cuint): cuint {.
    cdecl, importc: "LLVMGetMDKindIDInContext", dynlib: libLLVM.so.23.1.}
LLVM_ATTRIBUTE_C_DEPRECATED(unsigned, LLVMGetMDKindID(`const`, char * Name, unsigned,
    SLen), "Use of the global context is deprecated, use LLVMGetMDKindIDInContext instead")
##
##  Maps a synchronization scope name to a ID unique within this context.
##

proc LLVMGetSyncScopeID*(C: LLVMContextRef; Name: cstring; SLen: csize_t): cuint {.
    cdecl, importc: "LLVMGetSyncScopeID", dynlib: libLLVM.so.23.1.}
##
##  Return an unique id given the name of a enum attribute,
##  or 0 if no attribute by that name exists.
##
##  See http://llvm.org/docs/LangRef.html#parameter-attributes
##  and http://llvm.org/docs/LangRef.html#function-attributes
##  for the list of available attributes.
##
##  NB: Attribute names and/or id are subject to change without
##  going through the C API deprecation cycle.
##

proc LLVMGetEnumAttributeKindForName*(Name: cstring; SLen: csize_t): cuint {.cdecl,
    importc: "LLVMGetEnumAttributeKindForName", dynlib: libLLVM.so.23.1.}
proc LLVMGetLastEnumAttributeKind*(): cuint {.cdecl,
    importc: "LLVMGetLastEnumAttributeKind", dynlib: libLLVM.so.23.1.}
##
##  Create an enum attribute.
##

proc LLVMCreateEnumAttribute*(C: LLVMContextRef; KindID: cuint; Val: uint64_t): LLVMAttributeRef {.
    cdecl, importc: "LLVMCreateEnumAttribute", dynlib: libLLVM.so.23.1.}
##
##  Get the unique id corresponding to the enum attribute
##  passed as argument.
##

proc LLVMGetEnumAttributeKind*(A: LLVMAttributeRef): cuint {.cdecl,
    importc: "LLVMGetEnumAttributeKind", dynlib: libLLVM.so.23.1.}
##
##  Get the enum attribute's value. 0 is returned if none exists.
##

proc LLVMGetEnumAttributeValue*(A: LLVMAttributeRef): uint64_t {.cdecl,
    importc: "LLVMGetEnumAttributeValue", dynlib: libLLVM.so.23.1.}
##
##  Create a type attribute
##

proc LLVMCreateTypeAttribute*(C: LLVMContextRef; KindID: cuint; type_ref: LLVMTypeRef): LLVMAttributeRef {.
    cdecl, importc: "LLVMCreateTypeAttribute", dynlib: libLLVM.so.23.1.}
##
##  Get the type attribute's value.
##

proc LLVMGetTypeAttributeValue*(A: LLVMAttributeRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetTypeAttributeValue", dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantRange attribute.
##
##  LowerWords and UpperWords need to be NumBits divided by 64 rounded up
##  elements long.
##

proc LLVMCreateConstantRangeAttribute*(C: LLVMContextRef; KindID: cuint;
                                      NumBits: cuint; LowerWords: ptr uint64_t;
                                      UpperWords: ptr uint64_t): LLVMAttributeRef {.
    cdecl, importc: "LLVMCreateConstantRangeAttribute", dynlib: libLLVM.so.23.1.}
##
##  Represent different denormal handling kinds for use with
##  LLVMCreateDenormalFPEnvAttribute.
##

type
  LLVMDenormalModeKind* {.size: sizeof(cint).} = enum
    LLVMDenormalModeKindIEEE = 0, LLVMDenormalModeKindPreserveSign = 1,
    LLVMDenormalModeKindPositiveZero = 2, LLVMDenormalModeKindDynamic = 3


##
##  Create a DenormalFPEnv attribute.
##
##  \p DefaultModeOutput is the assumed denormal handling for the outputs of most
##     floating-point types.
##
##  \p DefaultModeInput is the assumed denormal handling for the inputs of most
##     floating-point types.
##
##  \p FloatModeOutput is the assumed denormal handling for the outputs of
##     float. This should always be the same as as DefaultModeOutput for most
##     targets.
##
##  \p FloatModeInput is the assumed denormal handling for the inputs of
##     float. This should always be the same as as DefaultModeInput for most
##     targets.
##
##

proc LLVMCreateDenormalFPEnvAttribute*(C: LLVMContextRef;
                                      DefaultModeOutput: LLVMDenormalModeKind;
                                      DefaultModeInput: LLVMDenormalModeKind;
                                      FloatModeOutput: LLVMDenormalModeKind;
                                      FloatModeInput: LLVMDenormalModeKind): LLVMAttributeRef {.
    cdecl, importc: "LLVMCreateDenormalFPEnvAttribute", dynlib: libLLVM.so.23.1.}
##
##  Create a string attribute.
##

proc LLVMCreateStringAttribute*(C: LLVMContextRef; K: cstring; KLength: cuint;
                               V: cstring; VLength: cuint): LLVMAttributeRef {.cdecl,
    importc: "LLVMCreateStringAttribute", dynlib: libLLVM.so.23.1.}
##
##  Get the string attribute's kind.
##

proc LLVMGetStringAttributeKind*(A: LLVMAttributeRef; Length: ptr cuint): cstring {.
    cdecl, importc: "LLVMGetStringAttributeKind", dynlib: libLLVM.so.23.1.}
##
##  Get the string attribute's value.
##

proc LLVMGetStringAttributeValue*(A: LLVMAttributeRef; Length: ptr cuint): cstring {.
    cdecl, importc: "LLVMGetStringAttributeValue", dynlib: libLLVM.so.23.1.}
##
##  Check for the different types of attributes.
##

proc LLVMIsEnumAttribute*(A: LLVMAttributeRef): LLVMBool {.cdecl,
    importc: "LLVMIsEnumAttribute", dynlib: libLLVM.so.23.1.}
proc LLVMIsStringAttribute*(A: LLVMAttributeRef): LLVMBool {.cdecl,
    importc: "LLVMIsStringAttribute", dynlib: libLLVM.so.23.1.}
proc LLVMIsTypeAttribute*(A: LLVMAttributeRef): LLVMBool {.cdecl,
    importc: "LLVMIsTypeAttribute", dynlib: libLLVM.so.23.1.}
##
##  Obtain a Type from a context by its registered name.
##

proc LLVMGetTypeByName2*(C: LLVMContextRef; Name: cstring): LLVMTypeRef {.cdecl,
    importc: "LLVMGetTypeByName2", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreModule Modules
##
##  Modules represent the top-level structure in an LLVM program. An LLVM
##  module is effectively a translation unit or a collection of
##  translation units merged together.
##
##  @{
##
##
##  Create a new, empty module in the global context.
##
##  This is equivalent to calling LLVMModuleCreateWithNameInContext with
##  LLVMGetGlobalContext() as the context parameter.
##
##  Every invocation should be paired with LLVMDisposeModule() or memory
##  will be leaked.
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMModuleRef,
                            LLVMModuleCreateWithName(`const`, char * ModuleID), "Use of the global context is deprecated, use LLVMModuleCreateWithNameInContext instead")
##
##  Create a new, empty module in a specific context.
##
##  Every invocation should be paired with LLVMDisposeModule() or memory
##  will be leaked.
##

proc LLVMModuleCreateWithNameInContext*(ModuleID: cstring; C: LLVMContextRef): LLVMModuleRef {.
    cdecl, importc: "LLVMModuleCreateWithNameInContext", dynlib: libLLVM.so.23.1.}
##
##  Return an exact copy of the specified module.
##

proc LLVMCloneModule*(M: LLVMModuleRef): LLVMModuleRef {.cdecl,
    importc: "LLVMCloneModule", dynlib: libLLVM.so.23.1.}
##
##  Destroy a module instance.
##
##  This must be called for every created module or memory will be
##  leaked.
##

proc LLVMDisposeModule*(M: LLVMModuleRef) {.cdecl, importc: "LLVMDisposeModule",
    dynlib: libLLVM.so.23.1.}
##
##  Soon to be deprecated.
##  See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
##
##  Returns true if the module is in the new debug info mode which uses
##  non-instruction debug records instead of debug intrinsics for variable
##  location tracking.
##

proc LLVMIsNewDbgInfoFormat*(M: LLVMModuleRef): LLVMBool {.cdecl,
    importc: "LLVMIsNewDbgInfoFormat", dynlib: libLLVM.so.23.1.}
##
##  Soon to be deprecated.
##  See https://llvm.org/docs/RemoveDIsDebugInfo.html#c-api-changes
##
##  Convert module into desired debug info format.
##

proc LLVMSetIsNewDbgInfoFormat*(M: LLVMModuleRef; UseNewFormat: LLVMBool) {.cdecl,
    importc: "LLVMSetIsNewDbgInfoFormat", dynlib: libLLVM.so.23.1.}
##
##  Obtain the identifier of a module.
##
##  @param M Module to obtain identifier of
##  @param Len Out parameter which holds the length of the returned string.
##  @return The identifier of M.
##  @see Module::getModuleIdentifier()
##

proc LLVMGetModuleIdentifier*(M: LLVMModuleRef; Len: ptr csize_t): cstring {.cdecl,
    importc: "LLVMGetModuleIdentifier", dynlib: libLLVM.so.23.1.}
##
##  Set the identifier of a module to a string Ident with length Len.
##
##  @param M The module to set identifier
##  @param Ident The string to set M's identifier to
##  @param Len Length of Ident
##  @see Module::setModuleIdentifier()
##

proc LLVMSetModuleIdentifier*(M: LLVMModuleRef; Ident: cstring; Len: csize_t) {.cdecl,
    importc: "LLVMSetModuleIdentifier", dynlib: libLLVM.so.23.1.}
##
##  Obtain the module's original source file name.
##
##  @param M Module to obtain the name of
##  @param Len Out parameter which holds the length of the returned string
##  @return The original source file name of M
##  @see Module::getSourceFileName()
##

proc LLVMGetSourceFileName*(M: LLVMModuleRef; Len: ptr csize_t): cstring {.cdecl,
    importc: "LLVMGetSourceFileName", dynlib: libLLVM.so.23.1.}
##
##  Set the original source file name of a module to a string Name with length
##  Len.
##
##  @param M The module to set the source file name of
##  @param Name The string to set M's source file name to
##  @param Len Length of Name
##  @see Module::setSourceFileName()
##

proc LLVMSetSourceFileName*(M: LLVMModuleRef; Name: cstring; Len: csize_t) {.cdecl,
    importc: "LLVMSetSourceFileName", dynlib: libLLVM.so.23.1.}
##
##  Obtain the data layout for a module.
##
##  @see Module::getDataLayoutStr()
##
##  LLVMGetDataLayout is DEPRECATED, as the name is not only incorrect,
##  but match the name of another method on the module. Prefer the use
##  of LLVMGetDataLayoutStr, which is not ambiguous.
##

proc LLVMGetDataLayoutStr*(M: LLVMModuleRef): cstring {.cdecl,
    importc: "LLVMGetDataLayoutStr", dynlib: libLLVM.so.23.1.}
proc LLVMGetDataLayout*(M: LLVMModuleRef): cstring {.cdecl,
    importc: "LLVMGetDataLayout", dynlib: libLLVM.so.23.1.}
##
##  Set the data layout for a module.
##
##  @see Module::setDataLayout()
##

proc LLVMSetDataLayout*(M: LLVMModuleRef; DataLayoutStr: cstring) {.cdecl,
    importc: "LLVMSetDataLayout", dynlib: libLLVM.so.23.1.}
##
##  Obtain the target triple for a module.
##
##  @see Module::getTargetTriple()
##

proc LLVMGetTarget*(M: LLVMModuleRef): cstring {.cdecl, importc: "LLVMGetTarget",
    dynlib: libLLVM.so.23.1.}
##
##  Set the target triple for a module.
##
##  @see Module::setTargetTriple()
##

proc LLVMSetTarget*(M: LLVMModuleRef; Triple: cstring) {.cdecl,
    importc: "LLVMSetTarget", dynlib: libLLVM.so.23.1.}
##
##  Returns the module flags as an array of flag-key-value triples.  The caller
##  is responsible for freeing this array by calling
##  \c LLVMDisposeModuleFlagsMetadata.
##
##  @see Module::getModuleFlagsMetadata()
##

proc LLVMCopyModuleFlagsMetadata*(M: LLVMModuleRef; Len: ptr csize_t): ptr LLVMModuleFlagEntry {.
    cdecl, importc: "LLVMCopyModuleFlagsMetadata", dynlib: libLLVM.so.23.1.}
##
##  Destroys module flags metadata entries.
##

proc LLVMDisposeModuleFlagsMetadata*(Entries: ptr LLVMModuleFlagEntry) {.cdecl,
    importc: "LLVMDisposeModuleFlagsMetadata", dynlib: libLLVM.so.23.1.}
##
##  Returns the flag behavior for a module flag entry at a specific index.
##
##  @see Module::ModuleFlagEntry::Behavior
##

proc LLVMModuleFlagEntriesGetFlagBehavior*(Entries: ptr LLVMModuleFlagEntry;
    Index: cuint): LLVMModuleFlagBehavior {.cdecl,
    importc: "LLVMModuleFlagEntriesGetFlagBehavior", dynlib: libLLVM.so.23.1.}
##
##  Returns the key for a module flag entry at a specific index.
##
##  @see Module::ModuleFlagEntry::Key
##

proc LLVMModuleFlagEntriesGetKey*(Entries: ptr LLVMModuleFlagEntry; Index: cuint;
                                 Len: ptr csize_t): cstring {.cdecl,
    importc: "LLVMModuleFlagEntriesGetKey", dynlib: libLLVM.so.23.1.}
##
##  Returns the metadata for a module flag entry at a specific index.
##
##  @see Module::ModuleFlagEntry::Val
##

proc LLVMModuleFlagEntriesGetMetadata*(Entries: ptr LLVMModuleFlagEntry;
                                      Index: cuint): LLVMMetadataRef {.cdecl,
    importc: "LLVMModuleFlagEntriesGetMetadata", dynlib: libLLVM.so.23.1.}
##
##  Add a module-level flag to the module-level flags metadata if it doesn't
##  already exist.
##
##  @see Module::getModuleFlag()
##

proc LLVMGetModuleFlag*(M: LLVMModuleRef; Key: cstring; KeyLen: csize_t): LLVMMetadataRef {.
    cdecl, importc: "LLVMGetModuleFlag", dynlib: libLLVM.so.23.1.}
##
##  Add a module-level flag to the module-level flags metadata if it doesn't
##  already exist.
##
##  @see Module::addModuleFlag()
##

proc LLVMAddModuleFlag*(M: LLVMModuleRef; Behavior: LLVMModuleFlagBehavior;
                       Key: cstring; KeyLen: csize_t; Val: LLVMMetadataRef) {.cdecl,
    importc: "LLVMAddModuleFlag", dynlib: libLLVM.so.23.1.}
##
##  Dump a representation of a module to stderr.
##
##  @see Module::dump()
##

proc LLVMDumpModule*(M: LLVMModuleRef) {.cdecl, importc: "LLVMDumpModule",
                                      dynlib: libLLVM.so.23.1.}
##
##  Print a representation of a module to a file. The ErrorMessage needs to be
##  disposed with LLVMDisposeMessage. Returns 0 on success, 1 otherwise.
##
##  @see Module::print()
##

proc LLVMPrintModuleToFile*(M: LLVMModuleRef; Filename: cstring;
                           ErrorMessage: cstringArray): LLVMBool {.cdecl,
    importc: "LLVMPrintModuleToFile", dynlib: libLLVM.so.23.1.}
##
##  Return a string representation of the module. Use
##  LLVMDisposeMessage to free the string.
##
##  @see Module::print()
##

proc LLVMPrintModuleToString*(M: LLVMModuleRef): cstring {.cdecl,
    importc: "LLVMPrintModuleToString", dynlib: libLLVM.so.23.1.}
##
##  Get inline assembly for a module.
##
##  @see Module::getModuleInlineAsm()
##

proc LLVMGetModuleInlineAsm*(M: LLVMModuleRef; Len: ptr csize_t): cstring {.cdecl,
    importc: "LLVMGetModuleInlineAsm", dynlib: libLLVM.so.23.1.}
##
##  Set inline assembly for a module.
##
##  @see Module::setModuleInlineAsm()
##

proc LLVMSetModuleInlineAsm2*(M: LLVMModuleRef; Asm: cstring; Len: csize_t) {.cdecl,
    importc: "LLVMSetModuleInlineAsm2", dynlib: libLLVM.so.23.1.}
##
##  Append inline assembly to a module.
##
##  @see Module::appendModuleInlineAsm()
##

proc LLVMAppendModuleInlineAsm*(M: LLVMModuleRef; Asm: cstring; Len: csize_t) {.cdecl,
    importc: "LLVMAppendModuleInlineAsm", dynlib: libLLVM.so.23.1.}
##
##  Create the specified uniqued inline asm string.
##
##  @see InlineAsm::get()
##

proc LLVMGetInlineAsm*(Ty: LLVMTypeRef; AsmString: cstring; AsmStringSize: csize_t;
                      Constraints: cstring; ConstraintsSize: csize_t;
                      HasSideEffects: LLVMBool; IsAlignStack: LLVMBool;
                      Dialect: LLVMInlineAsmDialect; CanThrow: LLVMBool): LLVMValueRef {.
    cdecl, importc: "LLVMGetInlineAsm", dynlib: libLLVM.so.23.1.}
##
##  Get the template string used for an inline assembly snippet
##
##

proc LLVMGetInlineAsmAsmString*(InlineAsmVal: LLVMValueRef; Len: ptr csize_t): cstring {.
    cdecl, importc: "LLVMGetInlineAsmAsmString", dynlib: libLLVM.so.23.1.}
##
##  Get the raw constraint string for an inline assembly snippet
##
##

proc LLVMGetInlineAsmConstraintString*(InlineAsmVal: LLVMValueRef; Len: ptr csize_t): cstring {.
    cdecl, importc: "LLVMGetInlineAsmConstraintString", dynlib: libLLVM.so.23.1.}
##
##  Get the dialect used by the inline asm snippet
##
##

proc LLVMGetInlineAsmDialect*(InlineAsmVal: LLVMValueRef): LLVMInlineAsmDialect {.
    cdecl, importc: "LLVMGetInlineAsmDialect", dynlib: libLLVM.so.23.1.}
##
##  Get the function type of the inline assembly snippet. The same type that
##  was passed into LLVMGetInlineAsm originally
##
##  @see LLVMGetInlineAsm
##
##

proc LLVMGetInlineAsmFunctionType*(InlineAsmVal: LLVMValueRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetInlineAsmFunctionType", dynlib: libLLVM.so.23.1.}
##
##  Get if the inline asm snippet has side effects
##
##

proc LLVMGetInlineAsmHasSideEffects*(InlineAsmVal: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetInlineAsmHasSideEffects", dynlib: libLLVM.so.23.1.}
##
##  Get if the inline asm snippet needs an aligned stack
##
##

proc LLVMGetInlineAsmNeedsAlignedStack*(InlineAsmVal: LLVMValueRef): LLVMBool {.
    cdecl, importc: "LLVMGetInlineAsmNeedsAlignedStack", dynlib: libLLVM.so.23.1.}
##
##  Get if the inline asm snippet may unwind the stack
##
##

proc LLVMGetInlineAsmCanUnwind*(InlineAsmVal: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetInlineAsmCanUnwind", dynlib: libLLVM.so.23.1.}
##
##  Obtain the context to which this module is associated.
##
##  @see Module::getContext()
##

proc LLVMGetModuleContext*(M: LLVMModuleRef): LLVMContextRef {.cdecl,
    importc: "LLVMGetModuleContext", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMGetTypeByName2 instead.

proc LLVMGetTypeByName*(M: LLVMModuleRef; Name: cstring): LLVMTypeRef {.cdecl,
    importc: "LLVMGetTypeByName", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the first NamedMDNode in a Module.
##
##  @see llvm::Module::named_metadata_begin()
##

proc LLVMGetFirstNamedMetadata*(M: LLVMModuleRef): LLVMNamedMDNodeRef {.cdecl,
    importc: "LLVMGetFirstNamedMetadata", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the last NamedMDNode in a Module.
##
##  @see llvm::Module::named_metadata_end()
##

proc LLVMGetLastNamedMetadata*(M: LLVMModuleRef): LLVMNamedMDNodeRef {.cdecl,
    importc: "LLVMGetLastNamedMetadata", dynlib: libLLVM.so.23.1.}
##
##  Advance a NamedMDNode iterator to the next NamedMDNode.
##
##  Returns NULL if the iterator was already at the end and there are no more
##  named metadata nodes.
##

proc LLVMGetNextNamedMetadata*(NamedMDNode: LLVMNamedMDNodeRef): LLVMNamedMDNodeRef {.
    cdecl, importc: "LLVMGetNextNamedMetadata", dynlib: libLLVM.so.23.1.}
##
##  Decrement a NamedMDNode iterator to the previous NamedMDNode.
##
##  Returns NULL if the iterator was already at the beginning and there are
##  no previous named metadata nodes.
##

proc LLVMGetPreviousNamedMetadata*(NamedMDNode: LLVMNamedMDNodeRef): LLVMNamedMDNodeRef {.
    cdecl, importc: "LLVMGetPreviousNamedMetadata", dynlib: libLLVM.so.23.1.}
##
##  Retrieve a NamedMDNode with the given name, returning NULL if no such
##  node exists.
##
##  @see llvm::Module::getNamedMetadata()
##

proc LLVMGetNamedMetadata*(M: LLVMModuleRef; Name: cstring; NameLen: csize_t): LLVMNamedMDNodeRef {.
    cdecl, importc: "LLVMGetNamedMetadata", dynlib: libLLVM.so.23.1.}
##
##  Retrieve a NamedMDNode with the given name, creating a new node if no such
##  node exists.
##
##  @see llvm::Module::getOrInsertNamedMetadata()
##

proc LLVMGetOrInsertNamedMetadata*(M: LLVMModuleRef; Name: cstring; NameLen: csize_t): LLVMNamedMDNodeRef {.
    cdecl, importc: "LLVMGetOrInsertNamedMetadata", dynlib: libLLVM.so.23.1.}
##
##  Retrieve the name of a NamedMDNode.
##
##  @see llvm::NamedMDNode::getName()
##

proc LLVMGetNamedMetadataName*(NamedMD: LLVMNamedMDNodeRef; NameLen: ptr csize_t): cstring {.
    cdecl, importc: "LLVMGetNamedMetadataName", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of operands for named metadata in a module.
##
##  @see llvm::Module::getNamedMetadata()
##

proc LLVMGetNamedMetadataNumOperands*(M: LLVMModuleRef; Name: cstring): cuint {.cdecl,
    importc: "LLVMGetNamedMetadataNumOperands", dynlib: libLLVM.so.23.1.}
##
##  Obtain the named metadata operands for a module.
##
##  The passed LLVMValueRef pointer should refer to an array of
##  LLVMValueRef at least LLVMGetNamedMetadataNumOperands long. This
##  array will be populated with the LLVMValueRef instances. Each
##  instance corresponds to a llvm::MDNode.
##
##  @see llvm::Module::getNamedMetadata()
##  @see llvm::MDNode::getOperand()
##

proc LLVMGetNamedMetadataOperands*(M: LLVMModuleRef; Name: cstring;
                                  Dest: ptr LLVMValueRef) {.cdecl,
    importc: "LLVMGetNamedMetadataOperands", dynlib: libLLVM.so.23.1.}
##
##  Add an operand to named metadata.
##
##  @see llvm::Module::getNamedMetadata()
##  @see llvm::MDNode::addOperand()
##

proc LLVMAddNamedMetadataOperand*(M: LLVMModuleRef; Name: cstring; Val: LLVMValueRef) {.
    cdecl, importc: "LLVMAddNamedMetadataOperand", dynlib: libLLVM.so.23.1.}
##
##  Return the directory of the debug location for this value, which must be
##  an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
##
##  @see llvm::Instruction::getDebugLoc()
##  @see llvm::GlobalVariable::getDebugInfo()
##  @see llvm::Function::getSubprogram()
##

proc LLVMGetDebugLocDirectory*(Val: LLVMValueRef; Length: ptr cuint): cstring {.cdecl,
    importc: "LLVMGetDebugLocDirectory", dynlib: libLLVM.so.23.1.}
##
##  Return the filename of the debug location for this value, which must be
##  an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
##
##  @see llvm::Instruction::getDebugLoc()
##  @see llvm::GlobalVariable::getDebugInfo()
##  @see llvm::Function::getSubprogram()
##

proc LLVMGetDebugLocFilename*(Val: LLVMValueRef; Length: ptr cuint): cstring {.cdecl,
    importc: "LLVMGetDebugLocFilename", dynlib: libLLVM.so.23.1.}
##
##  Return the line number of the debug location for this value, which must be
##  an llvm::Instruction, llvm::GlobalVariable, or llvm::Function.
##
##  @see llvm::Instruction::getDebugLoc()
##  @see llvm::GlobalVariable::getDebugInfo()
##  @see llvm::Function::getSubprogram()
##

proc LLVMGetDebugLocLine*(Val: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetDebugLocLine", dynlib: libLLVM.so.23.1.}
##
##  Return the column number of the debug location for this value, which must be
##  an llvm::Instruction.
##
##  @see llvm::Instruction::getDebugLoc()
##

proc LLVMGetDebugLocColumn*(Val: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetDebugLocColumn", dynlib: libLLVM.so.23.1.}
##
##  Add a function to a module under a specified name.
##
##  @see llvm::Function::Create()
##

proc LLVMAddFunction*(M: LLVMModuleRef; Name: cstring; FunctionTy: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMAddFunction", dynlib: libLLVM.so.23.1.}
##
##  Obtain or insert a function into a module.
##
##  If a function with the specified name already exists in the module, it
##  is returned. Otherwise, a new function is created in the module with the
##  specified name and type and is returned.
##
##  The returned value corresponds to a llvm::Function instance.
##
##  @see llvm::Module::getOrInsertFunction()
##

proc LLVMGetOrInsertFunction*(M: LLVMModuleRef; Name: cstring; NameLen: csize_t;
                             FunctionTy: LLVMTypeRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetOrInsertFunction", dynlib: libLLVM.so.23.1.}
##
##  Obtain a Function value from a Module by its name.
##
##  The returned value corresponds to a llvm::Function value.
##
##  @see llvm::Module::getFunction()
##

proc LLVMGetNamedFunction*(M: LLVMModuleRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMGetNamedFunction", dynlib: libLLVM.so.23.1.}
##
##  Obtain a Function value from a Module by its name.
##
##  The returned value corresponds to a llvm::Function value.
##
##  @see llvm::Module::getFunction()
##

proc LLVMGetNamedFunctionWithLength*(M: LLVMModuleRef; Name: cstring; Length: csize_t): LLVMValueRef {.
    cdecl, importc: "LLVMGetNamedFunctionWithLength", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the first Function in a Module.
##
##  @see llvm::Module::begin()
##

proc LLVMGetFirstFunction*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetFirstFunction", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the last Function in a Module.
##
##  @see llvm::Module::end()
##

proc LLVMGetLastFunction*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetLastFunction", dynlib: libLLVM.so.23.1.}
##
##  Advance a Function iterator to the next Function.
##
##  Returns NULL if the iterator was already at the end and there are no more
##  functions.
##

proc LLVMGetNextFunction*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetNextFunction", dynlib: libLLVM.so.23.1.}
##
##  Decrement a Function iterator to the previous Function.
##
##  Returns NULL if the iterator was already at the beginning and there are
##  no previous functions.
##

proc LLVMGetPreviousFunction*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPreviousFunction", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMSetModuleInlineAsm2 instead.

proc LLVMSetModuleInlineAsm*(M: LLVMModuleRef; Asm: cstring) {.cdecl,
    importc: "LLVMSetModuleInlineAsm", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreType Types
##
##  Types represent the type of a value.
##
##  Types are associated with a context instance. The context internally
##  deduplicates types so there is only 1 instance of a specific type
##  alive at a time. In other words, a unique type is shared among all
##  consumers within a context.
##
##  A Type in the C API corresponds to llvm::Type.
##
##  Types have the following hierarchy:
##
##    types:
##      integer type
##      byte type
##      real type
##      function type
##      sequence types:
##        array type
##        pointer type
##        vector type
##      void type
##      label type
##      opaque type
##
##  @{
##
##
##  Obtain the enumerated type of a Type instance.
##
##  @see llvm::Type:getTypeID()
##

proc LLVMGetTypeKind*(Ty: LLVMTypeRef): LLVMTypeKind {.cdecl,
    importc: "LLVMGetTypeKind", dynlib: libLLVM.so.23.1.}
##
##  Whether the type has a known size.
##
##  Things that don't have a size are abstract types, labels, and void.a
##
##  @see llvm::Type::isSized()
##

proc LLVMTypeIsSized*(Ty: LLVMTypeRef): LLVMBool {.cdecl, importc: "LLVMTypeIsSized",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain the context to which this type instance is associated.
##
##  @see llvm::Type::getContext()
##

proc LLVMGetTypeContext*(Ty: LLVMTypeRef): LLVMContextRef {.cdecl,
    importc: "LLVMGetTypeContext", dynlib: libLLVM.so.23.1.}
##
##  Dump a representation of a type to stderr.
##
##  @see llvm::Type::dump()
##

proc LLVMDumpType*(Val: LLVMTypeRef) {.cdecl, importc: "LLVMDumpType",
                                    dynlib: libLLVM.so.23.1.}
##
##  Return a string representation of the type. Use
##  LLVMDisposeMessage to free the string.
##
##  @see llvm::Type::print()
##

proc LLVMPrintTypeToString*(Val: LLVMTypeRef): cstring {.cdecl,
    importc: "LLVMPrintTypeToString", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreTypeByte Byte Types
##
##  Functions in this section operate on byte types.
##
##  @{
##
##
##  Obtain a byte type from a context with specified bit width.
##

proc LLVMByteTypeInContext*(C: LLVMContextRef; NumBits: cuint): LLVMTypeRef {.cdecl,
    importc: "LLVMByteTypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMGetByteTypeWidth*(ByteTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetByteTypeWidth", dynlib: libLLVM.so.23.1.}
##
##  @defgroup LLVMCCoreTypeInt Integer Types
##
##  Functions in this section operate on integer types.
##
##  @{
##
##
##  Obtain an integer type from a context with specified bit width.
##

proc LLVMInt1TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMInt1TypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMInt8TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMInt8TypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMInt16TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMInt16TypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMInt32TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMInt32TypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMInt64TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMInt64TypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMInt128TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMInt128TypeInContext", dynlib: libLLVM.so.23.1.}
proc LLVMIntTypeInContext*(C: LLVMContextRef; NumBits: cuint): LLVMTypeRef {.cdecl,
    importc: "LLVMIntTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain an integer type from the global context with a specified bit
##  width.
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMInt1Type(void), "Use of the global context is deprecated, use LLVMInt1TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMInt8Type(void), "Use of the global context is deprecated, use LLVMInt8TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMInt16Type(void), "Use of the global context is deprecated, use LLVMInt16TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMInt32Type(void), "Use of the global context is deprecated, use LLVMInt32TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMInt64Type(void), "Use of the global context is deprecated, use LLVMInt64TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMInt128Type(void), "Use of the global context is deprecated, use LLVMInt128TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMIntType(unsigned, NumBits), "Use of the global context is deprecated, use LLVMIntTypeInContext instead")
proc LLVMGetIntTypeWidth*(IntegerTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetIntTypeWidth", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreTypeFloat Floating Point Types
##
##  @{
##
##
##  Obtain a 16-bit floating point type from a context.
##

proc LLVMHalfTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMHalfTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a 16-bit brain floating point type from a context.
##

proc LLVMBFloatTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMBFloatTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a 32-bit floating point type from a context.
##

proc LLVMFloatTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMFloatTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a 64-bit floating point type from a context.
##

proc LLVMDoubleTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMDoubleTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a 80-bit floating point type (X87) from a context.
##

proc LLVMX86FP80TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMX86FP80TypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a 128-bit floating point type (112-bit mantissa) from a
##  context.
##

proc LLVMFP128TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMFP128TypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a 128-bit floating point type (two 64-bits) from a context.
##

proc LLVMPPCFP128TypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMPPCFP128TypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain a floating point type from the global context.
##
##  These map to the functions in this group of the same name.
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMHalfType(void), "Use of the global context is deprecated, use LLVMHalfTypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMBFloatType(void), "Use of the global context is deprecated, use LLVMBFloatTypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMFloatType(void), "Use of the global context is deprecated, use LLVMFloatTypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMDoubleType(void), "Use of the global context is deprecated, use LLVMDoubleTypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMX86FP80Type(void), "Use of the global context is deprecated, use LLVMX86FP80TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMFP128Type(void), "Use of the global context is deprecated, use LLVMFP128TypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMPPCFP128Type(void), "Use of the global context is deprecated, use LLVMPPCFP128TypeInContext instead")
##
##  @}
##
##
##  @defgroup LLVMCCoreTypeFunction Function Types
##
##  @{
##
##
##  Obtain a function type consisting of a specified signature.
##
##  The function is defined as a tuple of a return Type, a list of
##  parameter types, and whether the function is variadic.
##

proc LLVMFunctionType*(ReturnType: LLVMTypeRef; ParamTypes: ptr LLVMTypeRef;
                      ParamCount: cuint; IsVarArg: LLVMBool): LLVMTypeRef {.cdecl,
    importc: "LLVMFunctionType", dynlib: libLLVM.so.23.1.}
##
##  Returns whether a function type is variadic.
##

proc LLVMIsFunctionVarArg*(FunctionTy: LLVMTypeRef): LLVMBool {.cdecl,
    importc: "LLVMIsFunctionVarArg", dynlib: libLLVM.so.23.1.}
##
##  Obtain the Type this function Type returns.
##

proc LLVMGetReturnType*(FunctionTy: LLVMTypeRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetReturnType", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of parameters this function accepts.
##

proc LLVMCountParamTypes*(FunctionTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMCountParamTypes", dynlib: libLLVM.so.23.1.}
##
##  Obtain the types of a function's parameters.
##
##  The Dest parameter should point to a pre-allocated array of
##  LLVMTypeRef at least LLVMCountParamTypes() large. On return, the
##  first LLVMCountParamTypes() entries in the array will be populated
##  with LLVMTypeRef instances.
##
##  @param FunctionTy The function type to operate on.
##  @param Dest Memory address of an array to be filled with result.
##

proc LLVMGetParamTypes*(FunctionTy: LLVMTypeRef; Dest: ptr LLVMTypeRef) {.cdecl,
    importc: "LLVMGetParamTypes", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreTypeStruct Structure Types
##
##  These functions relate to LLVMTypeRef instances.
##
##  @see llvm::StructType
##
##  @{
##
##
##  Create a new structure type in a context.
##
##  A structure is specified by a list of inner elements/types and
##  whether these can be packed together.
##
##  @see llvm::StructType::create()
##

proc LLVMStructTypeInContext*(C: LLVMContextRef; ElementTypes: ptr LLVMTypeRef;
                             ElementCount: cuint; Packed: LLVMBool): LLVMTypeRef {.
    cdecl, importc: "LLVMStructTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a new structure type in the global context.
##
##  @see llvm::StructType::create()
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMStructType(
    LLVMTypeRef * ElementTypes, unsigned, ElementCount, LLVMBool, Packed), "Use of the global context is deprecated, use LLVMStructTypeInContext instead")
##
##  Create an empty structure in a context having a specified name.
##
##  @see llvm::StructType::create()
##

proc LLVMStructCreateNamed*(C: LLVMContextRef; Name: cstring): LLVMTypeRef {.cdecl,
    importc: "LLVMStructCreateNamed", dynlib: libLLVM.so.23.1.}
##
##  Obtain the name of a structure.
##
##  @see llvm::StructType::getName()
##

proc LLVMGetStructName*(Ty: LLVMTypeRef): cstring {.cdecl,
    importc: "LLVMGetStructName", dynlib: libLLVM.so.23.1.}
##
##  Set the contents of a structure type.
##
##  @see llvm::StructType::setBody()
##

proc LLVMStructSetBody*(StructTy: LLVMTypeRef; ElementTypes: ptr LLVMTypeRef;
                       ElementCount: cuint; Packed: LLVMBool) {.cdecl,
    importc: "LLVMStructSetBody", dynlib: libLLVM.so.23.1.}
##
##  Get the number of elements defined inside the structure.
##
##  @see llvm::StructType::getNumElements()
##

proc LLVMCountStructElementTypes*(StructTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMCountStructElementTypes", dynlib: libLLVM.so.23.1.}
##
##  Get the elements within a structure.
##
##  The function is passed the address of a pre-allocated array of
##  LLVMTypeRef at least LLVMCountStructElementTypes() long. After
##  invocation, this array will be populated with the structure's
##  elements. The objects in the destination array will have a lifetime
##  of the structure type itself, which is the lifetime of the context it
##  is contained in.
##

proc LLVMGetStructElementTypes*(StructTy: LLVMTypeRef; Dest: ptr LLVMTypeRef) {.cdecl,
    importc: "LLVMGetStructElementTypes", dynlib: libLLVM.so.23.1.}
##
##  Get the type of the element at a given index in the structure.
##
##  @see llvm::StructType::getTypeAtIndex()
##

proc LLVMStructGetTypeAtIndex*(StructTy: LLVMTypeRef; i: cuint): LLVMTypeRef {.cdecl,
    importc: "LLVMStructGetTypeAtIndex", dynlib: libLLVM.so.23.1.}
##
##  Determine whether a structure is packed.
##
##  @see llvm::StructType::isPacked()
##

proc LLVMIsPackedStruct*(StructTy: LLVMTypeRef): LLVMBool {.cdecl,
    importc: "LLVMIsPackedStruct", dynlib: libLLVM.so.23.1.}
##
##  Determine whether a structure is opaque.
##
##  @see llvm::StructType::isOpaque()
##

proc LLVMIsOpaqueStruct*(StructTy: LLVMTypeRef): LLVMBool {.cdecl,
    importc: "LLVMIsOpaqueStruct", dynlib: libLLVM.so.23.1.}
##
##  Determine whether a structure is literal.
##
##  @see llvm::StructType::isLiteral()
##

proc LLVMIsLiteralStruct*(StructTy: LLVMTypeRef): LLVMBool {.cdecl,
    importc: "LLVMIsLiteralStruct", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreTypeSequential Sequential Types
##
##  Sequential types represents "arrays" of types. This is a super class
##  for array, vector, and pointer types.
##
##  @{
##
##
##  Obtain the element type of an array or vector type.
##
##  @see llvm::SequentialType::getElementType()
##

proc LLVMGetElementType*(Ty: LLVMTypeRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetElementType", dynlib: libLLVM.so.23.1.}
##
##  Returns type's subtypes
##
##  @see llvm::Type::subtypes()
##

proc LLVMGetSubtypes*(Tp: LLVMTypeRef; Arr: ptr LLVMTypeRef) {.cdecl,
    importc: "LLVMGetSubtypes", dynlib: libLLVM.so.23.1.}
##
##   Return the number of types in the derived type.
##
##  @see llvm::Type::getNumContainedTypes()
##

proc LLVMGetNumContainedTypes*(Tp: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetNumContainedTypes", dynlib: libLLVM.so.23.1.}
##
##  Create a fixed size array type that refers to a specific type.
##
##  The created type will exist in the context that its element type
##  exists in.
##
##  @deprecated LLVMArrayType is deprecated in favor of the API accurate
##  LLVMArrayType2
##  @see llvm::ArrayType::get()
##

proc LLVMArrayType*(ElementType: LLVMTypeRef; ElementCount: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMArrayType", dynlib: libLLVM.so.23.1.}
##
##  Create a fixed size array type that refers to a specific type.
##
##  The created type will exist in the context that its element type
##  exists in.
##
##  @see llvm::ArrayType::get()
##

proc LLVMArrayType2*(ElementType: LLVMTypeRef; ElementCount: uint64_t): LLVMTypeRef {.
    cdecl, importc: "LLVMArrayType2", dynlib: libLLVM.so.23.1.}
##
##  Obtain the length of an array type.
##
##  This only works on types that represent arrays.
##
##  @deprecated LLVMGetArrayLength is deprecated in favor of the API accurate
##  LLVMGetArrayLength2
##  @see llvm::ArrayType::getNumElements()
##

proc LLVMGetArrayLength*(ArrayTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetArrayLength", dynlib: libLLVM.so.23.1.}
##
##  Obtain the length of an array type.
##
##  This only works on types that represent arrays.
##
##  @see llvm::ArrayType::getNumElements()
##

proc LLVMGetArrayLength2*(ArrayTy: LLVMTypeRef): uint64_t {.cdecl,
    importc: "LLVMGetArrayLength2", dynlib: libLLVM.so.23.1.}
##
##  Create a pointer type that points to a defined type.
##
##  The created type will exist in the context that its pointee type
##  exists in.
##
##  @see llvm::PointerType::get()
##

proc LLVMPointerType*(ElementType: LLVMTypeRef; AddressSpace: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMPointerType", dynlib: libLLVM.so.23.1.}
##
##  Determine whether a pointer is opaque.
##
##  True if this is an instance of an opaque PointerType.
##
##  @see llvm::Type::isOpaquePointerTy()
##

proc LLVMPointerTypeIsOpaque*(Ty: LLVMTypeRef): LLVMBool {.cdecl,
    importc: "LLVMPointerTypeIsOpaque", dynlib: libLLVM.so.23.1.}
##
##  Create an opaque pointer type in a context.
##
##  @see llvm::PointerType::get()
##

proc LLVMPointerTypeInContext*(C: LLVMContextRef; AddressSpace: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMPointerTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain the address space of a pointer type.
##
##  This only works on types that represent pointers.
##
##  @see llvm::PointerType::getAddressSpace()
##

proc LLVMGetPointerAddressSpace*(PointerTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetPointerAddressSpace", dynlib: libLLVM.so.23.1.}
##
##  Create a vector type that contains a defined type and has a specific
##  number of elements.
##
##  The created type will exist in the context thats its element type
##  exists in.
##
##  @see llvm::VectorType::get()
##

proc LLVMVectorType*(ElementType: LLVMTypeRef; ElementCount: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMVectorType", dynlib: libLLVM.so.23.1.}
##
##  Create a vector type that contains a defined type and has a scalable
##  number of elements.
##
##  The created type will exist in the context thats its element type
##  exists in.
##
##  @see llvm::ScalableVectorType::get()
##

proc LLVMScalableVectorType*(ElementType: LLVMTypeRef; ElementCount: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMScalableVectorType", dynlib: libLLVM.so.23.1.}
##
##  Obtain the (possibly scalable) number of elements in a vector type.
##
##  This only works on types that represent vectors (fixed or scalable).
##
##  @see llvm::VectorType::getNumElements()
##

proc LLVMGetVectorSize*(VectorTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetVectorSize", dynlib: libLLVM.so.23.1.}
##
##  Get the pointer value for the associated ConstantPtrAuth constant.
##
##  @see llvm::ConstantPtrAuth::getPointer
##

proc LLVMGetConstantPtrAuthPointer*(PtrAuth: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetConstantPtrAuthPointer", dynlib: libLLVM.so.23.1.}
##
##  Get the key value for the associated ConstantPtrAuth constant.
##
##  @see llvm::ConstantPtrAuth::getKey
##

proc LLVMGetConstantPtrAuthKey*(PtrAuth: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetConstantPtrAuthKey", dynlib: libLLVM.so.23.1.}
##
##  Get the discriminator value for the associated ConstantPtrAuth constant.
##
##  @see llvm::ConstantPtrAuth::getDiscriminator
##

proc LLVMGetConstantPtrAuthDiscriminator*(PtrAuth: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMGetConstantPtrAuthDiscriminator", dynlib: libLLVM.so.23.1.}
##
##  Get the address discriminator value for the associated ConstantPtrAuth
##  constant.
##
##  @see llvm::ConstantPtrAuth::getAddrDiscriminator
##

proc LLVMGetConstantPtrAuthAddrDiscriminator*(PtrAuth: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMGetConstantPtrAuthAddrDiscriminator",
    dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreTypeOther Other Types
##
##  @{
##
##
##  Create a void type in a context.
##

proc LLVMVoidTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMVoidTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a label type in a context.
##

proc LLVMLabelTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMLabelTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a X86 AMX type in a context.
##

proc LLVMX86AMXTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMX86AMXTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a token type in a context.
##

proc LLVMTokenTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMTokenTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a metadata type in a context.
##

proc LLVMMetadataTypeInContext*(C: LLVMContextRef): LLVMTypeRef {.cdecl,
    importc: "LLVMMetadataTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  These are similar to the above functions except they operate on the
##  global context.
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMVoidType(void), "Use of the global context is deprecated, use LLVMVoidTypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMLabelType(void), "Use of the global context is deprecated, use LLVMLabelTypeInContext instead")
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMTypeRef, LLVMX86AMXType(void), "Use of the global context is deprecated, use LLVMX86AMXTypeInContext instead")
##
##  Create a target extension type in LLVM context.
##

proc LLVMTargetExtTypeInContext*(C: LLVMContextRef; Name: cstring;
                                TypeParams: ptr LLVMTypeRef; TypeParamCount: cuint;
                                IntParams: ptr cuint; IntParamCount: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMTargetExtTypeInContext", dynlib: libLLVM.so.23.1.}
##
##  Obtain the name for this target extension type.
##
##  @see llvm::TargetExtType::getName()
##

proc LLVMGetTargetExtTypeName*(TargetExtTy: LLVMTypeRef): cstring {.cdecl,
    importc: "LLVMGetTargetExtTypeName", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of type parameters for this target extension type.
##
##  @see llvm::TargetExtType::getNumTypeParameters()
##

proc LLVMGetTargetExtTypeNumTypeParams*(TargetExtTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetTargetExtTypeNumTypeParams", dynlib: libLLVM.so.23.1.}
##
##  Get the type parameter at the given index for the target extension type.
##
##  @see llvm::TargetExtType::getTypeParameter()
##

proc LLVMGetTargetExtTypeTypeParam*(TargetExtTy: LLVMTypeRef; Idx: cuint): LLVMTypeRef {.
    cdecl, importc: "LLVMGetTargetExtTypeTypeParam", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of int parameters for this target extension type.
##
##  @see llvm::TargetExtType::getNumIntParameters()
##

proc LLVMGetTargetExtTypeNumIntParams*(TargetExtTy: LLVMTypeRef): cuint {.cdecl,
    importc: "LLVMGetTargetExtTypeNumIntParams", dynlib: libLLVM.so.23.1.}
##
##  Get the int parameter at the given index for the target extension type.
##
##  @see llvm::TargetExtType::getIntParameter()
##

proc LLVMGetTargetExtTypeIntParam*(TargetExtTy: LLVMTypeRef; Idx: cuint): cuint {.
    cdecl, importc: "LLVMGetTargetExtTypeIntParam", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @}
##
##
##  @defgroup LLVMCCoreValues Values
##
##  The bulk of LLVM's object model consists of values, which comprise a very
##  rich type hierarchy.
##
##  LLVMValueRef essentially represents llvm::Value. There is a rich
##  hierarchy of classes within this type. Depending on the instance
##  obtained, not all APIs are available.
##
##  Callers can determine the type of an LLVMValueRef by calling the
##  LLVMIsA* family of functions (e.g. LLVMIsAArgument()). These
##  functions are defined by a macro, so it isn't obvious which are
##  available by looking at the Doxygen source code. Instead, look at the
##  source definition of LLVM_FOR_EACH_VALUE_SUBCLASS and note the list
##  of value names given. These value names also correspond to classes in
##  the llvm::Value hierarchy.
##
##  @{
##
##  Currently, clang-format tries to format the LLVM_FOR_EACH_VALUE_SUBCLASS
##  macro in a progressively-indented fashion, which is not desired
##  clang-format off

template LLVM_FOR_EACH_VALUE_SUBCLASS*(`macro`: untyped): untyped =
  `macro`(Argument)

## !!!Ignored construct:  macro ( BasicBlock ) macro ( InlineAsm ) macro ( User ) macro ( Constant ) macro ( BlockAddress ) macro ( ConstantAggregateZero ) macro ( ConstantArray ) macro ( ConstantDataSequential ) macro ( ConstantDataArray ) macro ( ConstantDataVector ) macro ( ConstantExpr ) macro ( ConstantFP ) macro ( ConstantInt ) macro ( ConstantByte ) macro ( ConstantPointerNull ) macro ( ConstantStruct ) macro ( ConstantTokenNone ) macro ( ConstantVector ) macro ( ConstantPtrAuth ) macro ( GlobalValue ) macro ( GlobalAlias ) macro ( GlobalObject ) macro ( Function ) macro ( GlobalVariable ) macro ( GlobalIFunc ) macro ( UndefValue ) macro ( PoisonValue ) macro ( Instruction ) macro ( UnaryOperator ) macro ( BinaryOperator ) macro ( CallInst ) macro ( IntrinsicInst ) macro ( DbgInfoIntrinsic ) macro ( DbgVariableIntrinsic ) macro ( DbgDeclareInst ) macro ( DbgLabelInst ) macro ( MemIntrinsic ) macro ( MemCpyInst ) macro ( MemMoveInst ) macro ( MemSetInst ) macro ( CmpInst ) macro ( FCmpInst ) macro ( ICmpInst ) macro ( ExtractElementInst ) macro ( GetElementPtrInst ) macro ( InsertElementInst ) macro ( InsertValueInst ) macro ( LandingPadInst ) macro ( PHINode ) macro ( SelectInst ) macro ( ShuffleVectorInst ) macro ( StoreInst ) macro ( UncondBrInst ) macro ( CondBrInst ) macro ( IndirectBrInst ) macro ( InvokeInst ) macro ( ReturnInst ) macro ( SwitchInst ) macro ( UnreachableInst ) macro ( ResumeInst ) macro ( CleanupReturnInst ) macro ( CatchReturnInst ) macro ( CatchSwitchInst ) macro ( CallBrInst ) macro ( FuncletPadInst ) macro ( CatchPadInst ) macro ( CleanupPadInst ) macro ( UnaryInstruction ) macro ( AllocaInst ) macro ( CastInst ) macro ( AddrSpaceCastInst ) macro ( BitCastInst ) macro ( FPExtInst ) macro ( FPToSIInst ) macro ( FPToUIInst ) macro ( FPTruncInst ) macro ( IntToPtrInst ) macro ( PtrToIntInst ) macro ( SExtInst ) macro ( SIToFPInst ) macro ( TruncInst ) macro ( UIToFPInst ) macro ( ZExtInst ) macro ( ExtractValueInst ) macro ( LoadInst ) macro ( VAArgInst ) macro ( FreezeInst ) macro ( AtomicCmpXchgInst ) macro ( AtomicRMWInst ) macro ( FenceInst ) [NewLine]  clang-format on
##  @defgroup LLVMCCoreValueGeneral General APIs
##
##  Functions in this section work on all LLVMValueRef instances,
##  regardless of their sub-type. They correspond to functions available
##  on llvm::Value.
##
##  @{
##
##  Obtain the type of a value.
##
##  @see llvm::Value::getType()
##  LLVMTypeRef LLVMTypeOf ( LLVMValueRef Val ) ;
## Error: expected ';'!!!

##
##  Obtain the enumerated type of a Value instance.
##
##  @see llvm::Value::getValueID()
##

proc LLVMGetValueKind*(Val: LLVMValueRef): LLVMValueKind {.cdecl,
    importc: "LLVMGetValueKind", dynlib: libLLVM.so.23.1.}
##
##  Obtain the string name of a value.
##
##  @see llvm::Value::getName()
##

proc LLVMGetValueName2*(Val: LLVMValueRef; Length: ptr csize_t): cstring {.cdecl,
    importc: "LLVMGetValueName2", dynlib: libLLVM.so.23.1.}
##
##  Set the string name of a value.
##
##  @see llvm::Value::setName()
##

proc LLVMSetValueName2*(Val: LLVMValueRef; Name: cstring; NameLen: csize_t) {.cdecl,
    importc: "LLVMSetValueName2", dynlib: libLLVM.so.23.1.}
##
##  Dump a representation of a value to stderr.
##
##  @see llvm::Value::dump()
##

proc LLVMDumpValue*(Val: LLVMValueRef) {.cdecl, importc: "LLVMDumpValue",
                                      dynlib: libLLVM.so.23.1.}
##
##  Return a string representation of the value. Use
##  LLVMDisposeMessage to free the string.
##
##  @see llvm::Value::print()
##

proc LLVMPrintValueToString*(Val: LLVMValueRef): cstring {.cdecl,
    importc: "LLVMPrintValueToString", dynlib: libLLVM.so.23.1.}
##
##  Obtain the context to which this value is associated.
##
##  @see llvm::Value::getContext()
##

proc LLVMGetValueContext*(Val: LLVMValueRef): LLVMContextRef {.cdecl,
    importc: "LLVMGetValueContext", dynlib: libLLVM.so.23.1.}
##
##  Return a string representation of the DbgRecord. Use
##  LLVMDisposeMessage to free the string.
##
##  @see llvm::DbgRecord::print()
##

proc LLVMPrintDbgRecordToString*(Record: LLVMDbgRecordRef): cstring {.cdecl,
    importc: "LLVMPrintDbgRecordToString", dynlib: libLLVM.so.23.1.}
##
##  Replace all uses of a value with another one.
##
##  @see llvm::Value::replaceAllUsesWith()
##

proc LLVMReplaceAllUsesWith*(OldVal: LLVMValueRef; NewVal: LLVMValueRef) {.cdecl,
    importc: "LLVMReplaceAllUsesWith", dynlib: libLLVM.so.23.1.}
##
##  Determine whether the specified value instance is constant.
##

proc LLVMIsConstant*(Val: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMIsConstant",
    dynlib: libLLVM.so.23.1.}
##
##  Determine whether a value instance is undefined.
##

proc LLVMIsUndef*(Val: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMIsUndef",
    dynlib: libLLVM.so.23.1.}
##
##  Determine whether a value instance is poisonous.
##

proc LLVMIsPoison*(Val: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMIsPoison",
    dynlib: libLLVM.so.23.1.}
##
##  Convert value instances between types.
##
##  Internally, an LLVMValueRef is "pinned" to a specific type. This
##  series of functions allows you to cast an instance to a specific
##  type.
##
##  If the cast is not valid for the specified type, NULL is returned.
##
##  @see llvm::dyn_cast_or_null<>
##

template LLVM_DECLARE_VALUE_CAST*(name: untyped): untyped =
  LLVMValueRef

## !!!Ignored construct:  LLVMIsA ## name ( LLVMValueRef Val ) ;
## Error: expected ';'!!!

## !!!Ignored construct:  [NewLine] LLVM_FOR_EACH_VALUE_SUBCLASS ( LLVM_DECLARE_VALUE_CAST ) LLVM_ATTRIBUTE_C_DEPRECATED ( LLVMValueRef LLVMIsABranchInst ( LLVMValueRef Val ) , Use LLVMIsAUncondBrInst/LLVMIsACondBrInst instead ) ;
## Error: did not expect [NewLine]!!!

proc LLVMIsAMDNode*(Val: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMIsAMDNode", dynlib: libLLVM.so.23.1.}
proc LLVMIsAValueAsMetadata*(Val: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMIsAValueAsMetadata", dynlib: libLLVM.so.23.1.}
proc LLVMIsAMDString*(Val: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMIsAMDString", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMGetValueName2 instead.

proc LLVMGetValueName*(Val: LLVMValueRef): cstring {.cdecl,
    importc: "LLVMGetValueName", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMSetValueName2 instead.

proc LLVMSetValueName*(Val: LLVMValueRef; Name: cstring) {.cdecl,
    importc: "LLVMSetValueName", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueUses Usage
##
##  This module defines functions that allow you to inspect the uses of a
##  LLVMValueRef.
##
##  It is possible to obtain an LLVMUseRef for any LLVMValueRef instance.
##  Each LLVMUseRef (which corresponds to a llvm::Use instance) holds a
##  llvm::User and llvm::Value.
##
##  @{
##
##
##  Obtain the first use of a value.
##
##  Uses are obtained in an iterator fashion. First, call this function
##  to obtain a reference to the first use. Then, call LLVMGetNextUse()
##  on that instance and all subsequently obtained instances until
##  LLVMGetNextUse() returns NULL.
##
##  @see llvm::Value::use_begin()
##

proc LLVMGetFirstUse*(Val: LLVMValueRef): LLVMUseRef {.cdecl,
    importc: "LLVMGetFirstUse", dynlib: libLLVM.so.23.1.}
##
##  Obtain the next use of a value.
##
##  This effectively advances the iterator. It returns NULL if you are on
##  the final use and no more are available.
##

proc LLVMGetNextUse*(U: LLVMUseRef): LLVMUseRef {.cdecl, importc: "LLVMGetNextUse",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain the user value for a user.
##
##  The returned value corresponds to a llvm::User type.
##
##  @see llvm::Use::getUser()
##

proc LLVMGetUser*(U: LLVMUseRef): LLVMValueRef {.cdecl, importc: "LLVMGetUser",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain the value this use corresponds to.
##
##  @see llvm::Use::get().
##

proc LLVMGetUsedValue*(U: LLVMUseRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetUsedValue", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueUser User value
##
##  Function in this group pertain to LLVMValueRef instances that descent
##  from llvm::User. This includes constants, instructions, and
##  operators.
##
##  @{
##
##
##  Obtain an operand at a specific index in a llvm::User value.
##
##  @see llvm::User::getOperand()
##

proc LLVMGetOperand*(Val: LLVMValueRef; Index: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetOperand", dynlib: libLLVM.so.23.1.}
##
##  Obtain the use of an operand at a specific index in a llvm::User value.
##
##  @see llvm::User::getOperandUse()
##

proc LLVMGetOperandUse*(Val: LLVMValueRef; Index: cuint): LLVMUseRef {.cdecl,
    importc: "LLVMGetOperandUse", dynlib: libLLVM.so.23.1.}
##
##  Set an operand at a specific index in a llvm::User value.
##
##  @see llvm::User::setOperand()
##

proc LLVMSetOperand*(User: LLVMValueRef; Index: cuint; Val: LLVMValueRef) {.cdecl,
    importc: "LLVMSetOperand", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of operands in a llvm::User value.
##
##  @see llvm::User::getNumOperands()
##

proc LLVMGetNumOperands*(Val: LLVMValueRef): cint {.cdecl,
    importc: "LLVMGetNumOperands", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueConstant Constants
##
##  This section contains APIs for interacting with LLVMValueRef that
##  correspond to llvm::Constant instances.
##
##  These functions will work for any LLVMValueRef in the llvm::Constant
##  class hierarchy.
##
##  @{
##
##
##  Obtain a constant value referring to the null instance of a type.
##
##  @see llvm::Constant::getNullValue()
##

proc LLVMConstNull*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl, importc: "LLVMConstNull",
    dynlib: libLLVM.so.23.1.}
##  all zeroes
##
##  Obtain a constant value referring to the instance of a type
##  consisting of all ones.
##
##  This is only valid for integer types.
##
##  @see llvm::Constant::getAllOnesValue()
##

proc LLVMConstAllOnes*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstAllOnes", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value referring to an undefined value of a type.
##
##  @see llvm::UndefValue::get()
##

proc LLVMGetUndef*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl, importc: "LLVMGetUndef",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value referring to a poison value of a type.
##
##  @see llvm::PoisonValue::get()
##

proc LLVMGetPoison*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl, importc: "LLVMGetPoison",
    dynlib: libLLVM.so.23.1.}
##
##  Determine whether a value instance is null.
##
##  @see llvm::Constant::isNullValue()
##

proc LLVMIsNull*(Val: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMIsNull",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant that is a constant pointer pointing to NULL for a
##  specified type.
##

proc LLVMConstPointerNull*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstPointerNull", dynlib: libLLVM.so.23.1.}
##
##  @defgroup LLVMCCoreValueConstantScalar Scalar constants
##
##  Functions in this group model LLVMValueRef instances that correspond
##  to constants referring to scalar types.
##
##  For integer types, the LLVMTypeRef parameter should correspond to a
##  llvm::IntegerType instance and the returned LLVMValueRef will
##  correspond to a llvm::ConstantInt.
##
##  For floating point types, the LLVMTypeRef returned corresponds to a
##  llvm::ConstantFP.
##
##  @{
##
##
##  Obtain a constant value for an integer type.
##
##  The returned value corresponds to a llvm::ConstantInt.
##
##  @see llvm::ConstantInt::get()
##
##  @param IntTy Integer type to obtain value of.
##  @param N The value the returned instance should refer to.
##  @param SignExtend Whether to sign extend the produced value.
##

proc LLVMConstInt*(IntTy: LLVMTypeRef; N: culonglong; SignExtend: LLVMBool): LLVMValueRef {.
    cdecl, importc: "LLVMConstInt", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value for an integer of arbitrary precision.
##
##  @see llvm::ConstantInt::get()
##

proc LLVMConstIntOfArbitraryPrecision*(IntTy: LLVMTypeRef; NumWords: cuint;
                                      Words: ptr uint64_t): LLVMValueRef {.cdecl,
    importc: "LLVMConstIntOfArbitraryPrecision", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value for an integer parsed from a string.
##
##  A similar API, LLVMConstIntOfStringAndSize is also available. If the
##  string's length is available, it is preferred to call that function
##  instead.
##
##  @see llvm::ConstantInt::get()
##

proc LLVMConstIntOfString*(IntTy: LLVMTypeRef; Text: cstring; Radix: uint8_t): LLVMValueRef {.
    cdecl, importc: "LLVMConstIntOfString", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value for an integer parsed from a string with
##  specified length.
##
##  @see llvm::ConstantInt::get()
##

proc LLVMConstIntOfStringAndSize*(IntTy: LLVMTypeRef; Text: cstring; SLen: cuint;
                                 Radix: uint8_t): LLVMValueRef {.cdecl,
    importc: "LLVMConstIntOfStringAndSize", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value for a byte type.
##
##  The returned value corresponds to a llvm::ConstantByte.
##
##  @see llvm::ConstantByte::get()
##
##  @param ByteTy Byte type to obtain value of.
##  @param N The value the returned instance should refer to.
##

proc LLVMConstByte*(ByteTy: LLVMTypeRef; N: culonglong): LLVMValueRef {.cdecl,
    importc: "LLVMConstByte", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value for a byte of arbitrary precision.
##
##  @see llvm::ConstantByte::get()
##

proc LLVMConstByteOfArbitraryPrecision*(ByteTy: LLVMTypeRef; NumWords: cuint;
                                       Words: ptr uint64_t): LLVMValueRef {.cdecl,
    importc: "LLVMConstByteOfArbitraryPrecision", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value for a byte parsed from a string with specified
##  length.
##  @see llvm::ConstantByte::get()
##

proc LLVMConstByteOfStringAndSize*(ByteTy: LLVMTypeRef; Text: cstring; SLen: csize_t;
                                  Radix: uint8_t): LLVMValueRef {.cdecl,
    importc: "LLVMConstByteOfStringAndSize", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant value referring to a double floating point value.
##

proc LLVMConstReal*(RealTy: LLVMTypeRef; N: cdouble): LLVMValueRef {.cdecl,
    importc: "LLVMConstReal", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant for a floating point value parsed from a string.
##
##  A similar API, LLVMConstRealOfStringAndSize is also available. It
##  should be used if the input string's length is known.
##

proc LLVMConstRealOfString*(RealTy: LLVMTypeRef; Text: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMConstRealOfString", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant for a floating point value parsed from a string.
##

proc LLVMConstRealOfStringAndSize*(RealTy: LLVMTypeRef; Text: cstring; SLen: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMConstRealOfStringAndSize", dynlib: libLLVM.so.23.1.}
##
##  Obtain a constant for a floating point value from array of 64 bit values.
##  The length of the array N must be ceildiv(bits, 64), where bits is the
##  scalar size in bits of the floating-point type.
##

proc LLVMConstFPFromBits*(Ty: LLVMTypeRef; N: ptr uint64_t): LLVMValueRef {.cdecl,
    importc: "LLVMConstFPFromBits", dynlib: libLLVM.so.23.1.}
##
##  Obtain the zero extended value for an integer constant value.
##
##  @see llvm::ConstantInt::getZExtValue()
##

proc LLVMConstIntGetZExtValue*(ConstantVal: LLVMValueRef): culonglong {.cdecl,
    importc: "LLVMConstIntGetZExtValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain the sign extended value for an integer constant value.
##
##  @see llvm::ConstantInt::getSExtValue()
##

proc LLVMConstIntGetSExtValue*(ConstantVal: LLVMValueRef): clonglong {.cdecl,
    importc: "LLVMConstIntGetSExtValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain the zero extended value for a byte constant value.
##
##  @see llvm::ConstantByte::getZExtValue()
##

proc LLVMConstByteGetZExtValue*(ConstantVal: LLVMValueRef): culonglong {.cdecl,
    importc: "LLVMConstByteGetZExtValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain the sign extended value for a byte constant value.
##
##  @see llvm::ConstantByte::getSExtValue()
##

proc LLVMConstByteGetSExtValue*(ConstantVal: LLVMValueRef): clonglong {.cdecl,
    importc: "LLVMConstByteGetSExtValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain the double value for an floating point constant value.
##  losesInfo indicates if some precision was lost in the conversion.
##
##  @see llvm::ConstantFP::getDoubleValue
##

proc LLVMConstRealGetDouble*(ConstantVal: LLVMValueRef; losesInfo: ptr LLVMBool): cdouble {.
    cdecl, importc: "LLVMConstRealGetDouble", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueConstantComposite Composite Constants
##
##  Functions in this group operate on composite constants.
##
##  @{
##
##
##  Create a ConstantDataSequential and initialize it with a string.
##
##  @deprecated LLVMConstStringInContext is deprecated in favor of the API
##  accurate LLVMConstStringInContext2
##  @see llvm::ConstantDataArray::getString()
##

proc LLVMConstStringInContext*(C: LLVMContextRef; Str: cstring; Length: cuint;
                              DontNullTerminate: LLVMBool): LLVMValueRef {.cdecl,
    importc: "LLVMConstStringInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantDataSequential and initialize it with a string.
##
##  @see llvm::ConstantDataArray::getString()
##

proc LLVMConstStringInContext2*(C: LLVMContextRef; Str: cstring; Length: csize_t;
                               DontNullTerminate: LLVMBool): LLVMValueRef {.cdecl,
    importc: "LLVMConstStringInContext2", dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantDataSequential with string content in the global context.
##
##  This is the same as LLVMConstStringInContext except it operates on the
##  global context.
##
##  @see LLVMConstStringInContext()
##  @see llvm::ConstantDataArray::getString()
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef, LLVMConstString(`const`, char * Str,
    unsigned, Length, LLVMBool, DontNullTerminate), "Use of the global context is deprecated, use LLVMConstStringInContext2 instead")
##
##  Returns true if the specified constant is an array of i8.
##
##  @see ConstantDataSequential::getAsString()
##

proc LLVMIsConstantString*(c: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsConstantString", dynlib: libLLVM.so.23.1.}
##
##  Get the given constant data sequential as a string.
##
##  @see ConstantDataSequential::getAsString()
##

proc LLVMGetAsString*(c: LLVMValueRef; Length: ptr csize_t): cstring {.cdecl,
    importc: "LLVMGetAsString", dynlib: libLLVM.so.23.1.}
##
##  Get the raw, underlying bytes of the given constant data sequential.
##
##  This is the same as LLVMGetAsString except it works for all constant data
##  sequentials, not just i8 arrays.
##
##  @see ConstantDataSequential::getRawDataValues()
##

proc LLVMGetRawDataValues*(c: LLVMValueRef; SizeInBytes: ptr csize_t): cstring {.cdecl,
    importc: "LLVMGetRawDataValues", dynlib: libLLVM.so.23.1.}
##
##  Create an anonymous ConstantStruct with the specified values.
##
##  @see llvm::ConstantStruct::getAnon()
##

proc LLVMConstStructInContext*(C: LLVMContextRef; ConstantVals: ptr LLVMValueRef;
                              Count: cuint; Packed: LLVMBool): LLVMValueRef {.cdecl,
    importc: "LLVMConstStructInContext", dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantStruct in the global Context.
##
##  This is the same as LLVMConstStructInContext except it operates on the
##  global Context.
##
##  @see LLVMConstStructInContext()
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef, LLVMConstStruct(
    LLVMValueRef * ConstantVals, unsigned, Count, LLVMBool, Packed), "Use of the global context is deprecated, use LLVMConstStructInContext instead")
##
##  Create a ConstantArray from values.
##
##  @deprecated LLVMConstArray is deprecated in favor of the API accurate
##  LLVMConstArray2
##  @see llvm::ConstantArray::get()
##

proc LLVMConstArray*(ElementTy: LLVMTypeRef; ConstantVals: ptr LLVMValueRef;
                    Length: cuint): LLVMValueRef {.cdecl, importc: "LLVMConstArray",
    dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantArray from values.
##
##  @see llvm::ConstantArray::get()
##

proc LLVMConstArray2*(ElementTy: LLVMTypeRef; ConstantVals: ptr LLVMValueRef;
                     Length: uint64_t): LLVMValueRef {.cdecl,
    importc: "LLVMConstArray2", dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantDataArray from raw values.
##
##  ElementTy must be one of i8, i16, i32, i64, half, bfloat, float, or double.
##  Data points to a contiguous buffer of raw values in the host endianness. The
##  element count is inferred from the element type and the data size in bytes.
##
##  @see llvm::ConstantDataArray::getRaw()
##

proc LLVMConstDataArray*(ElementTy: LLVMTypeRef; Data: cstring; SizeInBytes: csize_t): LLVMValueRef {.
    cdecl, importc: "LLVMConstDataArray", dynlib: libLLVM.so.23.1.}
##
##  Create a non-anonymous ConstantStruct from values.
##
##  @see llvm::ConstantStruct::get()
##

proc LLVMConstNamedStruct*(StructTy: LLVMTypeRef; ConstantVals: ptr LLVMValueRef;
                          Count: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMConstNamedStruct", dynlib: libLLVM.so.23.1.}
##
##  Get element of a constant aggregate (struct, array or vector) at the
##  specified index. Returns null if the index is out of range, or it's not
##  possible to determine the element (e.g., because the constant is a
##  constant expression.)
##
##  @see llvm::Constant::getAggregateElement()
##

proc LLVMGetAggregateElement*(C: LLVMValueRef; Idx: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetAggregateElement", dynlib: libLLVM.so.23.1.}
##
##  Get an element at specified index as a constant.
##
##  @see ConstantDataSequential::getElementAsConstant()
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef, LLVMGetElementAsConstant(LLVMValueRef,
    C, unsigned, idx), "Use LLVMGetAggregateElement instead")
##
##  Create a ConstantVector from values.
##
##  @see llvm::ConstantVector::get()
##

proc LLVMConstVector*(ScalarConstantVals: ptr LLVMValueRef; Size: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMConstVector", dynlib: libLLVM.so.23.1.}
##
##  Create a ConstantPtrAuth constant with the given values.
##
##  @see llvm::ConstantPtrAuth::get()
##

proc LLVMConstantPtrAuth*(Ptr: LLVMValueRef; Key: LLVMValueRef; Disc: LLVMValueRef;
                         AddrDisc: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstantPtrAuth", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueConstantExpressions Constant Expressions
##
##  Functions in this group correspond to APIs on llvm::ConstantExpr.
##
##  @see llvm::ConstantExpr.
##
##  @{
##

proc LLVMGetConstOpcode*(ConstantVal: LLVMValueRef): LLVMOpcode {.cdecl,
    importc: "LLVMGetConstOpcode", dynlib: libLLVM.so.23.1.}
proc LLVMAlignOf*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl, importc: "LLVMAlignOf",
    dynlib: libLLVM.so.23.1.}
proc LLVMSizeOf*(Ty: LLVMTypeRef): LLVMValueRef {.cdecl, importc: "LLVMSizeOf",
    dynlib: libLLVM.so.23.1.}
proc LLVMConstNeg*(ConstantVal: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstNeg", dynlib: libLLVM.so.23.1.}
proc LLVMConstNSWNeg*(ConstantVal: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstNSWNeg", dynlib: libLLVM.so.23.1.}
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef,
                            LLVMConstNUWNeg(LLVMValueRef, ConstantVal),
                            "Use LLVMConstNull instead.")
proc LLVMConstNot*(ConstantVal: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstNot", dynlib: libLLVM.so.23.1.}
proc LLVMConstAdd*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstAdd", dynlib: libLLVM.so.23.1.}
proc LLVMConstNSWAdd*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstNSWAdd", dynlib: libLLVM.so.23.1.}
proc LLVMConstNUWAdd*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstNUWAdd", dynlib: libLLVM.so.23.1.}
proc LLVMConstSub*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstSub", dynlib: libLLVM.so.23.1.}
proc LLVMConstNSWSub*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstNSWSub", dynlib: libLLVM.so.23.1.}
proc LLVMConstNUWSub*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstNUWSub", dynlib: libLLVM.so.23.1.}
proc LLVMConstXor*(LHSConstant: LLVMValueRef; RHSConstant: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstXor", dynlib: libLLVM.so.23.1.}
proc LLVMConstGEP2*(Ty: LLVMTypeRef; ConstantVal: LLVMValueRef;
                   ConstantIndices: ptr LLVMValueRef; NumIndices: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMConstGEP2", dynlib: libLLVM.so.23.1.}
proc LLVMConstInBoundsGEP2*(Ty: LLVMTypeRef; ConstantVal: LLVMValueRef;
                           ConstantIndices: ptr LLVMValueRef; NumIndices: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMConstInBoundsGEP2", dynlib: libLLVM.so.23.1.}
##
##  Creates a constant GetElementPtr expression. Similar to LLVMConstGEP2, but
##  allows specifying the no-wrap flags.
##
##  @see llvm::ConstantExpr::getGetElementPtr()
##

proc LLVMConstGEPWithNoWrapFlags*(Ty: LLVMTypeRef; ConstantVal: LLVMValueRef;
                                 ConstantIndices: ptr LLVMValueRef;
                                 NumIndices: cuint;
                                 NoWrapFlags: LLVMGEPNoWrapFlags): LLVMValueRef {.
    cdecl, importc: "LLVMConstGEPWithNoWrapFlags", dynlib: libLLVM.so.23.1.}
proc LLVMConstTrunc*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstTrunc", dynlib: libLLVM.so.23.1.}
proc LLVMConstPtrToInt*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstPtrToInt", dynlib: libLLVM.so.23.1.}
proc LLVMConstIntToPtr*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstIntToPtr", dynlib: libLLVM.so.23.1.}
proc LLVMConstBitCast*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstBitCast", dynlib: libLLVM.so.23.1.}
proc LLVMConstAddrSpaceCast*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstAddrSpaceCast", dynlib: libLLVM.so.23.1.}
proc LLVMConstTruncOrBitCast*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstTruncOrBitCast", dynlib: libLLVM.so.23.1.}
proc LLVMConstPointerCast*(ConstantVal: LLVMValueRef; ToType: LLVMTypeRef): LLVMValueRef {.
    cdecl, importc: "LLVMConstPointerCast", dynlib: libLLVM.so.23.1.}
proc LLVMConstExtractElement*(VectorConstant: LLVMValueRef;
                             IndexConstant: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstExtractElement", dynlib: libLLVM.so.23.1.}
proc LLVMConstInsertElement*(VectorConstant: LLVMValueRef;
                            ElementValueConstant: LLVMValueRef;
                            IndexConstant: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstInsertElement", dynlib: libLLVM.so.23.1.}
proc LLVMConstShuffleVector*(VectorAConstant: LLVMValueRef;
                            VectorBConstant: LLVMValueRef;
                            MaskConstant: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMConstShuffleVector", dynlib: libLLVM.so.23.1.}
proc LLVMBlockAddress*(F: LLVMValueRef; BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMBlockAddress", dynlib: libLLVM.so.23.1.}
##
##  Gets the function associated with a given BlockAddress constant value.
##

proc LLVMGetBlockAddressFunction*(BlockAddr: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetBlockAddressFunction", dynlib: libLLVM.so.23.1.}
##
##  Gets the basic block associated with a given BlockAddress constant value.
##

proc LLVMGetBlockAddressBasicBlock*(BlockAddr: LLVMValueRef): LLVMBasicBlockRef {.
    cdecl, importc: "LLVMGetBlockAddressBasicBlock", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMGetInlineAsm instead.

proc LLVMConstInlineAsm*(Ty: LLVMTypeRef; AsmString: cstring; Constraints: cstring;
                        HasSideEffects: LLVMBool; IsAlignStack: LLVMBool): LLVMValueRef {.
    cdecl, importc: "LLVMConstInlineAsm", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueConstantGlobals Global Values
##
##  This group contains functions that operate on global values. Functions in
##  this group relate to functions in the llvm::GlobalValue class tree.
##
##  @see llvm::GlobalValue
##
##  @{
##

proc LLVMGetGlobalParent*(Global: LLVMValueRef): LLVMModuleRef {.cdecl,
    importc: "LLVMGetGlobalParent", dynlib: libLLVM.so.23.1.}
proc LLVMIsDeclaration*(Global: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsDeclaration", dynlib: libLLVM.so.23.1.}
proc LLVMGetLinkage*(Global: LLVMValueRef): LLVMLinkage {.cdecl,
    importc: "LLVMGetLinkage", dynlib: libLLVM.so.23.1.}
proc LLVMSetLinkage*(Global: LLVMValueRef; Linkage: LLVMLinkage) {.cdecl,
    importc: "LLVMSetLinkage", dynlib: libLLVM.so.23.1.}
proc LLVMGetSection*(Global: LLVMValueRef): cstring {.cdecl,
    importc: "LLVMGetSection", dynlib: libLLVM.so.23.1.}
proc LLVMSetSection*(Global: LLVMValueRef; Section: cstring) {.cdecl,
    importc: "LLVMSetSection", dynlib: libLLVM.so.23.1.}
proc LLVMGetVisibility*(Global: LLVMValueRef): LLVMVisibility {.cdecl,
    importc: "LLVMGetVisibility", dynlib: libLLVM.so.23.1.}
proc LLVMSetVisibility*(Global: LLVMValueRef; Viz: LLVMVisibility) {.cdecl,
    importc: "LLVMSetVisibility", dynlib: libLLVM.so.23.1.}
proc LLVMGetDLLStorageClass*(Global: LLVMValueRef): LLVMDLLStorageClass {.cdecl,
    importc: "LLVMGetDLLStorageClass", dynlib: libLLVM.so.23.1.}
proc LLVMSetDLLStorageClass*(Global: LLVMValueRef; Class: LLVMDLLStorageClass) {.
    cdecl, importc: "LLVMSetDLLStorageClass", dynlib: libLLVM.so.23.1.}
proc LLVMGetUnnamedAddress*(Global: LLVMValueRef): LLVMUnnamedAddr {.cdecl,
    importc: "LLVMGetUnnamedAddress", dynlib: libLLVM.so.23.1.}
proc LLVMSetUnnamedAddress*(Global: LLVMValueRef; UnnamedAddr: LLVMUnnamedAddr) {.
    cdecl, importc: "LLVMSetUnnamedAddress", dynlib: libLLVM.so.23.1.}
##
##  Returns the "value type" of a global value.  This differs from the formal
##  type of a global value which is always a pointer type.
##
##  @see llvm::GlobalValue::getValueType()
##  @see llvm::Function::getFunctionType()
##

proc LLVMGlobalGetValueType*(Global: LLVMValueRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGlobalGetValueType", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMGetUnnamedAddress instead.

proc LLVMHasUnnamedAddr*(Global: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMHasUnnamedAddr", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMSetUnnamedAddress instead.

proc LLVMSetUnnamedAddr*(Global: LLVMValueRef; HasUnnamedAddr: LLVMBool) {.cdecl,
    importc: "LLVMSetUnnamedAddr", dynlib: libLLVM.so.23.1.}
##
##  @defgroup LLVMCCoreValueWithAlignment Values with alignment
##
##  Functions in this group only apply to values with alignment, i.e.
##  global variables, load and store instructions.
##
##
##  Obtain the preferred alignment of the value.
##  @see llvm::AllocaInst::getAlignment()
##  @see llvm::LoadInst::getAlignment()
##  @see llvm::StoreInst::getAlignment()
##  @see llvm::AtomicRMWInst::setAlignment()
##  @see llvm::AtomicCmpXchgInst::setAlignment()
##  @see llvm::GlobalValue::getAlignment()
##

proc LLVMGetAlignment*(V: LLVMValueRef): cuint {.cdecl, importc: "LLVMGetAlignment",
    dynlib: libLLVM.so.23.1.}
##
##  Set the preferred alignment of the value.
##  @see llvm::AllocaInst::setAlignment()
##  @see llvm::LoadInst::setAlignment()
##  @see llvm::StoreInst::setAlignment()
##  @see llvm::AtomicRMWInst::setAlignment()
##  @see llvm::AtomicCmpXchgInst::setAlignment()
##  @see llvm::GlobalValue::setAlignment()
##

proc LLVMSetAlignment*(V: LLVMValueRef; Bytes: cuint) {.cdecl,
    importc: "LLVMSetAlignment", dynlib: libLLVM.so.23.1.}
##
##  Sets a metadata attachment, erasing the existing metadata attachment if
##  it already exists for the given kind.
##
##  @see llvm::GlobalObject::setMetadata()
##

proc LLVMGlobalSetMetadata*(Global: LLVMValueRef; Kind: cuint; MD: LLVMMetadataRef) {.
    cdecl, importc: "LLVMGlobalSetMetadata", dynlib: libLLVM.so.23.1.}
##
##  Adds a metadata attachment.
##
##  @see llvm::GlobalObject::addMetadata()
##

proc LLVMGlobalAddMetadata*(Global: LLVMValueRef; Kind: cuint; MD: LLVMMetadataRef) {.
    cdecl, importc: "LLVMGlobalAddMetadata", dynlib: libLLVM.so.23.1.}
##
##  Erases a metadata attachment of the given kind if it exists.
##
##  @see llvm::GlobalObject::eraseMetadata()
##

proc LLVMGlobalEraseMetadata*(Global: LLVMValueRef; Kind: cuint) {.cdecl,
    importc: "LLVMGlobalEraseMetadata", dynlib: libLLVM.so.23.1.}
##
##  Removes all metadata attachments from this value.
##
##  @see llvm::GlobalObject::clearMetadata()
##

proc LLVMGlobalClearMetadata*(Global: LLVMValueRef) {.cdecl,
    importc: "LLVMGlobalClearMetadata", dynlib: libLLVM.so.23.1.}
##
##  Add debuginfo metadata to this global.
##
##  @see llvm::GlobalVariable::addDebugInfo()
##

proc LLVMGlobalAddDebugInfo*(Global: LLVMValueRef; GVE: LLVMMetadataRef) {.cdecl,
    importc: "LLVMGlobalAddDebugInfo", dynlib: libLLVM.so.23.1.}
##
##  Retrieves an array of metadata entries representing the metadata attached to
##  this value. The caller is responsible for freeing this array by calling
##  \c LLVMDisposeValueMetadataEntries.
##
##  @see llvm::GlobalObject::getAllMetadata()
##

proc LLVMGlobalCopyAllMetadata*(Value: LLVMValueRef; NumEntries: ptr csize_t): ptr LLVMValueMetadataEntry {.
    cdecl, importc: "LLVMGlobalCopyAllMetadata", dynlib: libLLVM.so.23.1.}
##
##  Destroys value metadata entries.
##

proc LLVMDisposeValueMetadataEntries*(Entries: ptr LLVMValueMetadataEntry) {.cdecl,
    importc: "LLVMDisposeValueMetadataEntries", dynlib: libLLVM.so.23.1.}
##
##  Returns the kind of a value metadata entry at a specific index.
##

proc LLVMValueMetadataEntriesGetKind*(Entries: ptr LLVMValueMetadataEntry;
                                     Index: cuint): cuint {.cdecl,
    importc: "LLVMValueMetadataEntriesGetKind", dynlib: libLLVM.so.23.1.}
##
##  Returns the underlying metadata node of a value metadata entry at a
##  specific index.
##

proc LLVMValueMetadataEntriesGetMetadata*(Entries: ptr LLVMValueMetadataEntry;
    Index: cuint): LLVMMetadataRef {.cdecl, importc: "LLVMValueMetadataEntriesGetMetadata",
                                  dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCoreValueConstantGlobalVariable Global Variables
##
##  This group contains functions that operate on global variable values.
##
##  @see llvm::GlobalVariable
##
##  @{
##

proc LLVMAddGlobal*(M: LLVMModuleRef; Ty: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMAddGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMAddGlobalInAddressSpace*(M: LLVMModuleRef; Ty: LLVMTypeRef; Name: cstring;
                                 AddressSpace: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMAddGlobalInAddressSpace", dynlib: libLLVM.so.23.1.}
proc LLVMGetNamedGlobal*(M: LLVMModuleRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMGetNamedGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMGetNamedGlobalWithLength*(M: LLVMModuleRef; Name: cstring; Length: csize_t): LLVMValueRef {.
    cdecl, importc: "LLVMGetNamedGlobalWithLength", dynlib: libLLVM.so.23.1.}
proc LLVMGetFirstGlobal*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetFirstGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMGetLastGlobal*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetLastGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMGetNextGlobal*(GlobalVar: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetNextGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMGetPreviousGlobal*(GlobalVar: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPreviousGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMDeleteGlobal*(GlobalVar: LLVMValueRef) {.cdecl,
    importc: "LLVMDeleteGlobal", dynlib: libLLVM.so.23.1.}
proc LLVMGetInitializer*(GlobalVar: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetInitializer", dynlib: libLLVM.so.23.1.}
proc LLVMSetInitializer*(GlobalVar: LLVMValueRef; ConstantVal: LLVMValueRef) {.cdecl,
    importc: "LLVMSetInitializer", dynlib: libLLVM.so.23.1.}
proc LLVMIsThreadLocal*(GlobalVar: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsThreadLocal", dynlib: libLLVM.so.23.1.}
proc LLVMSetThreadLocal*(GlobalVar: LLVMValueRef; IsThreadLocal: LLVMBool) {.cdecl,
    importc: "LLVMSetThreadLocal", dynlib: libLLVM.so.23.1.}
proc LLVMIsGlobalConstant*(GlobalVar: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsGlobalConstant", dynlib: libLLVM.so.23.1.}
proc LLVMSetGlobalConstant*(GlobalVar: LLVMValueRef; IsConstant: LLVMBool) {.cdecl,
    importc: "LLVMSetGlobalConstant", dynlib: libLLVM.so.23.1.}
proc LLVMGetThreadLocalMode*(GlobalVar: LLVMValueRef): LLVMThreadLocalMode {.cdecl,
    importc: "LLVMGetThreadLocalMode", dynlib: libLLVM.so.23.1.}
proc LLVMSetThreadLocalMode*(GlobalVar: LLVMValueRef; Mode: LLVMThreadLocalMode) {.
    cdecl, importc: "LLVMSetThreadLocalMode", dynlib: libLLVM.so.23.1.}
proc LLVMIsExternallyInitialized*(GlobalVar: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsExternallyInitialized", dynlib: libLLVM.so.23.1.}
proc LLVMSetExternallyInitialized*(GlobalVar: LLVMValueRef; IsExtInit: LLVMBool) {.
    cdecl, importc: "LLVMSetExternallyInitialized", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCoreValueConstantGlobalAlias Global Aliases
##
##  This group contains function that operate on global alias values.
##
##  @see llvm::GlobalAlias
##
##  @{
##
##
##  Add a GlobalAlias with the given value type, address space and aliasee.
##
##  @see llvm::GlobalAlias::create()
##

proc LLVMAddAlias2*(M: LLVMModuleRef; ValueTy: LLVMTypeRef; AddrSpace: cuint;
                   Aliasee: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMAddAlias2", dynlib: libLLVM.so.23.1.}
##
##  Obtain a GlobalAlias value from a Module by its name.
##
##  The returned value corresponds to a llvm::GlobalAlias value.
##
##  @see llvm::Module::getNamedAlias()
##

proc LLVMGetNamedGlobalAlias*(M: LLVMModuleRef; Name: cstring; NameLen: csize_t): LLVMValueRef {.
    cdecl, importc: "LLVMGetNamedGlobalAlias", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the first GlobalAlias in a Module.
##
##  @see llvm::Module::alias_begin()
##

proc LLVMGetFirstGlobalAlias*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetFirstGlobalAlias", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the last GlobalAlias in a Module.
##
##  @see llvm::Module::alias_end()
##

proc LLVMGetLastGlobalAlias*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetLastGlobalAlias", dynlib: libLLVM.so.23.1.}
##
##  Advance a GlobalAlias iterator to the next GlobalAlias.
##
##  Returns NULL if the iterator was already at the end and there are no more
##  global aliases.
##

proc LLVMGetNextGlobalAlias*(GA: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetNextGlobalAlias", dynlib: libLLVM.so.23.1.}
##
##  Decrement a GlobalAlias iterator to the previous GlobalAlias.
##
##  Returns NULL if the iterator was already at the beginning and there are
##  no previous global aliases.
##

proc LLVMGetPreviousGlobalAlias*(GA: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPreviousGlobalAlias", dynlib: libLLVM.so.23.1.}
##
##  Retrieve the target value of an alias.
##

proc LLVMAliasGetAliasee*(Alias: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMAliasGetAliasee", dynlib: libLLVM.so.23.1.}
##
##  Set the target value of an alias.
##

proc LLVMAliasSetAliasee*(Alias: LLVMValueRef; Aliasee: LLVMValueRef) {.cdecl,
    importc: "LLVMAliasSetAliasee", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueFunction Function values
##
##  Functions in this group operate on LLVMValueRef instances that
##  correspond to llvm::Function instances.
##
##  @see llvm::Function
##
##  @{
##
##
##  Remove a function from its containing module and deletes it.
##
##  @see llvm::Function::eraseFromParent()
##

proc LLVMDeleteFunction*(Fn: LLVMValueRef) {.cdecl, importc: "LLVMDeleteFunction",
    dynlib: libLLVM.so.23.1.}
##
##  Check whether the given function has a personality function.
##
##  @see llvm::Function::hasPersonalityFn()
##

proc LLVMHasPersonalityFn*(Fn: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMHasPersonalityFn", dynlib: libLLVM.so.23.1.}
##
##  Obtain the personality function attached to the function.
##
##  @see llvm::Function::getPersonalityFn()
##

proc LLVMGetPersonalityFn*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPersonalityFn", dynlib: libLLVM.so.23.1.}
##
##  Set the personality function attached to the function.
##
##  @see llvm::Function::setPersonalityFn()
##

proc LLVMSetPersonalityFn*(Fn: LLVMValueRef; PersonalityFn: LLVMValueRef) {.cdecl,
    importc: "LLVMSetPersonalityFn", dynlib: libLLVM.so.23.1.}
##
##  Obtain the intrinsic ID number which matches the given function name.
##
##  @see llvm::Intrinsic::lookupIntrinsicID()
##

proc LLVMLookupIntrinsicID*(Name: cstring; NameLen: csize_t): cuint {.cdecl,
    importc: "LLVMLookupIntrinsicID", dynlib: libLLVM.so.23.1.}
##
##  Obtain the ID number from a function instance.
##
##  @see llvm::Function::getIntrinsicID()
##

proc LLVMGetIntrinsicID*(Fn: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetIntrinsicID", dynlib: libLLVM.so.23.1.}
##
##  Get or insert the declaration of an intrinsic. For overloaded intrinsics,
##  overload types must be provided to uniquely identify an overload.
##
##  @see llvm::Intrinsic::getOrInsertDeclaration()
##

proc LLVMGetIntrinsicDeclaration*(Mod: LLVMModuleRef; ID: cuint;
                                 OverloadTypes: ptr LLVMTypeRef;
                                 OverloadCount: csize_t): LLVMValueRef {.cdecl,
    importc: "LLVMGetIntrinsicDeclaration", dynlib: libLLVM.so.23.1.}
##
##  Retrieves the type of an intrinsic. For overloaded intrinsics, overload
##  types must be provided to uniquely identify an overload.
##
##  @see llvm::Intrinsic::getType()
##

proc LLVMIntrinsicGetType*(Ctx: LLVMContextRef; ID: cuint;
                          OverloadTypes: ptr LLVMTypeRef; OverloadCount: csize_t): LLVMTypeRef {.
    cdecl, importc: "LLVMIntrinsicGetType", dynlib: libLLVM.so.23.1.}
##
##  Retrieves the name of an intrinsic.
##
##  @see llvm::Intrinsic::getName()
##

proc LLVMIntrinsicGetName*(ID: cuint; NameLength: ptr csize_t): cstring {.cdecl,
    importc: "LLVMIntrinsicGetName", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMIntrinsicCopyOverloadedName2 instead.

proc LLVMIntrinsicCopyOverloadedName*(ID: cuint; OverloadTypes: ptr LLVMTypeRef;
                                     OverloadCount: csize_t;
                                     NameLength: ptr csize_t): cstring {.cdecl,
    importc: "LLVMIntrinsicCopyOverloadedName", dynlib: libLLVM.so.23.1.}
##
##  Copies the name of an overloaded intrinsic identified by a given list of
##  overload types.
##
##  Unlike LLVMIntrinsicGetName, the caller is responsible for freeing the
##  returned string.
##
##  This version also supports unnamed types.
##
##  @see llvm::Intrinsic::getName()
##

proc LLVMIntrinsicCopyOverloadedName2*(Mod: LLVMModuleRef; ID: cuint;
                                      OverloadTypes: ptr LLVMTypeRef;
                                      OverloadCount: csize_t;
                                      NameLength: ptr csize_t): cstring {.cdecl,
    importc: "LLVMIntrinsicCopyOverloadedName2", dynlib: libLLVM.so.23.1.}
##
##  Obtain if the intrinsic identified by the given ID is overloaded.
##
##  @see llvm::Intrinsic::isOverloaded()
##

proc LLVMIntrinsicIsOverloaded*(ID: cuint): LLVMBool {.cdecl,
    importc: "LLVMIntrinsicIsOverloaded", dynlib: libLLVM.so.23.1.}
##
##  Obtain the calling function of a function.
##
##  The returned value corresponds to the LLVMCallConv enumeration.
##
##  @see llvm::Function::getCallingConv()
##

proc LLVMGetFunctionCallConv*(Fn: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetFunctionCallConv", dynlib: libLLVM.so.23.1.}
##
##  Set the calling convention of a function.
##
##  @see llvm::Function::setCallingConv()
##
##  @param Fn Function to operate on
##  @param CC LLVMCallConv to set calling convention to
##

proc LLVMSetFunctionCallConv*(Fn: LLVMValueRef; CC: cuint) {.cdecl,
    importc: "LLVMSetFunctionCallConv", dynlib: libLLVM.so.23.1.}
##
##  Obtain the name of the garbage collector to use during code
##  generation.
##
##  @see llvm::Function::getGC()
##

proc LLVMGetGC*(Fn: LLVMValueRef): cstring {.cdecl, importc: "LLVMGetGC",
    dynlib: libLLVM.so.23.1.}
##
##  Define the garbage collector to use during code generation.
##
##  @see llvm::Function::setGC()
##

proc LLVMSetGC*(Fn: LLVMValueRef; Name: cstring) {.cdecl, importc: "LLVMSetGC",
    dynlib: libLLVM.so.23.1.}
##
##  Gets the prefix data associated with a function. Only valid on functions, and
##  only if LLVMHasPrefixData returns true.
##  See https://llvm.org/docs/LangRef.html#prefix-data
##

proc LLVMGetPrefixData*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPrefixData", dynlib: libLLVM.so.23.1.}
##
##  Check if a given function has prefix data. Only valid on functions.
##  See https://llvm.org/docs/LangRef.html#prefix-data
##

proc LLVMHasPrefixData*(Fn: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMHasPrefixData", dynlib: libLLVM.so.23.1.}
##
##  Sets the prefix data for the function. Only valid on functions.
##  See https://llvm.org/docs/LangRef.html#prefix-data
##

proc LLVMSetPrefixData*(Fn: LLVMValueRef; prefixData: LLVMValueRef) {.cdecl,
    importc: "LLVMSetPrefixData", dynlib: libLLVM.so.23.1.}
##
##  Gets the prologue data associated with a function. Only valid on functions,
##  and only if LLVMHasPrologueData returns true.
##  See https://llvm.org/docs/LangRef.html#prologue-data
##

proc LLVMGetPrologueData*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPrologueData", dynlib: libLLVM.so.23.1.}
##
##  Check if a given function has prologue data. Only valid on functions.
##  See https://llvm.org/docs/LangRef.html#prologue-data
##

proc LLVMHasPrologueData*(Fn: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMHasPrologueData", dynlib: libLLVM.so.23.1.}
##
##  Sets the prologue data for the function. Only valid on functions.
##  See https://llvm.org/docs/LangRef.html#prologue-data
##

proc LLVMSetPrologueData*(Fn: LLVMValueRef; prologueData: LLVMValueRef) {.cdecl,
    importc: "LLVMSetPrologueData", dynlib: libLLVM.so.23.1.}
##
##  Add an attribute to a function.
##
##  @see llvm::Function::addAttribute()
##

proc LLVMAddAttributeAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex;
                             A: LLVMAttributeRef) {.cdecl,
    importc: "LLVMAddAttributeAtIndex", dynlib: libLLVM.so.23.1.}
proc LLVMGetAttributeCountAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex): cuint {.
    cdecl, importc: "LLVMGetAttributeCountAtIndex", dynlib: libLLVM.so.23.1.}
proc LLVMGetAttributesAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex;
                              Attrs: ptr LLVMAttributeRef) {.cdecl,
    importc: "LLVMGetAttributesAtIndex", dynlib: libLLVM.so.23.1.}
proc LLVMGetEnumAttributeAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex;
                                 KindID: cuint): LLVMAttributeRef {.cdecl,
    importc: "LLVMGetEnumAttributeAtIndex", dynlib: libLLVM.so.23.1.}
proc LLVMGetStringAttributeAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex;
                                   K: cstring; KLen: cuint): LLVMAttributeRef {.
    cdecl, importc: "LLVMGetStringAttributeAtIndex", dynlib: libLLVM.so.23.1.}
proc LLVMRemoveEnumAttributeAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex;
                                    KindID: cuint) {.cdecl,
    importc: "LLVMRemoveEnumAttributeAtIndex", dynlib: libLLVM.so.23.1.}
proc LLVMRemoveStringAttributeAtIndex*(F: LLVMValueRef; Idx: LLVMAttributeIndex;
                                      K: cstring; KLen: cuint) {.cdecl,
    importc: "LLVMRemoveStringAttributeAtIndex", dynlib: libLLVM.so.23.1.}
##
##  Add a target-dependent attribute to a function
##  @see llvm::AttrBuilder::addAttribute()
##

proc LLVMAddTargetDependentFunctionAttr*(Fn: LLVMValueRef; A: cstring; V: cstring) {.
    cdecl, importc: "LLVMAddTargetDependentFunctionAttr", dynlib: libLLVM.so.23.1.}
##
##  @defgroup LLVMCCoreValueFunctionParameters Function Parameters
##
##  Functions in this group relate to arguments/parameters on functions.
##
##  Functions in this group expect LLVMValueRef instances that correspond
##  to llvm::Function instances.
##
##  @{
##
##
##  Obtain the number of parameters in a function.
##
##  @see llvm::Function::arg_size()
##

proc LLVMCountParams*(Fn: LLVMValueRef): cuint {.cdecl, importc: "LLVMCountParams",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain the parameters in a function.
##
##  The takes a pointer to a pre-allocated array of LLVMValueRef that is
##  at least LLVMCountParams() long. This array will be filled with
##  LLVMValueRef instances which correspond to the parameters the
##  function receives. Each LLVMValueRef corresponds to a llvm::Argument
##  instance.
##
##  @see llvm::Function::arg_begin()
##

proc LLVMGetParams*(Fn: LLVMValueRef; Params: ptr LLVMValueRef) {.cdecl,
    importc: "LLVMGetParams", dynlib: libLLVM.so.23.1.}
##
##  Obtain the parameter at the specified index.
##
##  Parameters are indexed from 0.
##
##  @see llvm::Function::arg_begin()
##

proc LLVMGetParam*(Fn: LLVMValueRef; Index: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetParam", dynlib: libLLVM.so.23.1.}
##
##  Obtain the function to which this argument belongs.
##
##  Unlike other functions in this group, this one takes an LLVMValueRef
##  that corresponds to a llvm::Attribute.
##
##  The returned LLVMValueRef is the llvm::Function to which this
##  argument belongs.
##

proc LLVMGetParamParent*(Inst: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetParamParent", dynlib: libLLVM.so.23.1.}
##
##  Obtain the first parameter to a function.
##
##  @see llvm::Function::arg_begin()
##

proc LLVMGetFirstParam*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetFirstParam", dynlib: libLLVM.so.23.1.}
##
##  Obtain the last parameter to a function.
##
##  @see llvm::Function::arg_end()
##

proc LLVMGetLastParam*(Fn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetLastParam", dynlib: libLLVM.so.23.1.}
##
##  Obtain the next parameter to a function.
##
##  This takes an LLVMValueRef obtained from LLVMGetFirstParam() (which is
##  actually a wrapped iterator) and obtains the next parameter from the
##  underlying iterator.
##

proc LLVMGetNextParam*(Arg: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetNextParam", dynlib: libLLVM.so.23.1.}
##
##  Obtain the previous parameter to a function.
##
##  This is the opposite of LLVMGetNextParam().
##

proc LLVMGetPreviousParam*(Arg: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPreviousParam", dynlib: libLLVM.so.23.1.}
##
##  Set the alignment for a function parameter.
##
##  @see llvm::Argument::addAttr()
##  @see llvm::AttrBuilder::addAlignmentAttr()
##

proc LLVMSetParamAlignment*(Arg: LLVMValueRef; Align: cuint) {.cdecl,
    importc: "LLVMSetParamAlignment", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueGlobalIFunc IFuncs
##
##  Functions in this group relate to indirect functions.
##
##  Functions in this group expect LLVMValueRef instances that correspond
##  to llvm::GlobalIFunc instances.
##
##  @{
##
##
##  Add a global indirect function to a module under a specified name.
##
##  @see llvm::GlobalIFunc::create()
##

proc LLVMAddGlobalIFunc*(M: LLVMModuleRef; Name: cstring; NameLen: csize_t;
                        Ty: LLVMTypeRef; AddrSpace: cuint; Resolver: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMAddGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Obtain a GlobalIFunc value from a Module by its name.
##
##  The returned value corresponds to a llvm::GlobalIFunc value.
##
##  @see llvm::Module::getNamedIFunc()
##

proc LLVMGetNamedGlobalIFunc*(M: LLVMModuleRef; Name: cstring; NameLen: csize_t): LLVMValueRef {.
    cdecl, importc: "LLVMGetNamedGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the first GlobalIFunc in a Module.
##
##  @see llvm::Module::ifunc_begin()
##

proc LLVMGetFirstGlobalIFunc*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetFirstGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Obtain an iterator to the last GlobalIFunc in a Module.
##
##  @see llvm::Module::ifunc_end()
##

proc LLVMGetLastGlobalIFunc*(M: LLVMModuleRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetLastGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Advance a GlobalIFunc iterator to the next GlobalIFunc.
##
##  Returns NULL if the iterator was already at the end and there are no more
##  global aliases.
##

proc LLVMGetNextGlobalIFunc*(IFunc: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetNextGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Decrement a GlobalIFunc iterator to the previous GlobalIFunc.
##
##  Returns NULL if the iterator was already at the beginning and there are
##  no previous global aliases.
##

proc LLVMGetPreviousGlobalIFunc*(IFunc: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPreviousGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Retrieves the resolver function associated with this indirect function, or
##  NULL if it doesn't not exist.
##
##  @see llvm::GlobalIFunc::getResolver()
##

proc LLVMGetGlobalIFuncResolver*(IFunc: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetGlobalIFuncResolver", dynlib: libLLVM.so.23.1.}
##
##  Sets the resolver function associated with this indirect function.
##
##  @see llvm::GlobalIFunc::setResolver()
##

proc LLVMSetGlobalIFuncResolver*(IFunc: LLVMValueRef; Resolver: LLVMValueRef) {.
    cdecl, importc: "LLVMSetGlobalIFuncResolver", dynlib: libLLVM.so.23.1.}
##
##  Remove a global indirect function from its parent module and delete it.
##
##  @see llvm::GlobalIFunc::eraseFromParent()
##

proc LLVMEraseGlobalIFunc*(IFunc: LLVMValueRef) {.cdecl,
    importc: "LLVMEraseGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  Remove a global indirect function from its parent module.
##
##  This unlinks the global indirect function from its containing module but
##  keeps it alive.
##
##  @see llvm::GlobalIFunc::removeFromParent()
##

proc LLVMRemoveGlobalIFunc*(IFunc: LLVMValueRef) {.cdecl,
    importc: "LLVMRemoveGlobalIFunc", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @}
##
##
##  @}
##
##
##  @}
##
##
##  @defgroup LLVMCCoreValueMetadata Metadata
##
##  @{
##
##
##  Create an MDString value from a given string value.
##
##  The MDString value does not take ownership of the given string, it remains
##  the responsibility of the caller to free it.
##
##  @see llvm::MDString::get()
##

proc LLVMMDStringInContext2*(C: LLVMContextRef; Str: cstring; SLen: csize_t): LLVMMetadataRef {.
    cdecl, importc: "LLVMMDStringInContext2", dynlib: libLLVM.so.23.1.}
##
##  Create an MDNode value with the given array of operands.
##
##  @see llvm::MDNode::get()
##

proc LLVMMDNodeInContext2*(C: LLVMContextRef; MDs: ptr LLVMMetadataRef; Count: csize_t): LLVMMetadataRef {.
    cdecl, importc: "LLVMMDNodeInContext2", dynlib: libLLVM.so.23.1.}
##
##  Obtain a Metadata as a Value.
##

proc LLVMMetadataAsValue*(C: LLVMContextRef; MD: LLVMMetadataRef): LLVMValueRef {.
    cdecl, importc: "LLVMMetadataAsValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain a Value as a Metadata.
##

proc LLVMValueAsMetadata*(Val: LLVMValueRef): LLVMMetadataRef {.cdecl,
    importc: "LLVMValueAsMetadata", dynlib: libLLVM.so.23.1.}
##
##  Obtain the underlying string from a MDString value.
##
##  @param V Instance to obtain string from.
##  @param Length Memory address which will hold length of returned string.
##  @return String data in MDString.
##

proc LLVMGetMDString*(V: LLVMValueRef; Length: ptr cuint): cstring {.cdecl,
    importc: "LLVMGetMDString", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of operands from an MDNode value.
##
##  @param V MDNode to get number of operands from.
##  @return Number of operands of the MDNode.
##

proc LLVMGetMDNodeNumOperands*(V: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetMDNodeNumOperands", dynlib: libLLVM.so.23.1.}
##
##  Obtain the given MDNode's operands.
##
##  The passed LLVMValueRef pointer should point to enough memory to hold all of
##  the operands of the given MDNode (see LLVMGetMDNodeNumOperands) as
##  LLVMValueRefs. This memory will be populated with the LLVMValueRefs of the
##  MDNode's operands.
##
##  @param V MDNode to get the operands from.
##  @param Dest Destination array for operands.
##

proc LLVMGetMDNodeOperands*(V: LLVMValueRef; Dest: ptr LLVMValueRef) {.cdecl,
    importc: "LLVMGetMDNodeOperands", dynlib: libLLVM.so.23.1.}
##
##  Replace an operand at a specific index in a llvm::MDNode value.
##
##  @see llvm::MDNode::replaceOperandWith()
##

proc LLVMReplaceMDNodeOperandWith*(V: LLVMValueRef; Index: cuint;
                                  Replacement: LLVMMetadataRef) {.cdecl,
    importc: "LLVMReplaceMDNodeOperandWith", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMMDStringInContext2 instead.

proc LLVMMDStringInContext*(C: LLVMContextRef; Str: cstring; SLen: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMMDStringInContext", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMMDStringInContext2 instead.

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef,
                            LLVMMDString(`const`, char * Str, unsigned, SLen), "Use of the global context is deprecated, use LLVMMDStringInContext2 instead")
##  Deprecated: Use LLVMMDNodeInContext2 instead.

proc LLVMMDNodeInContext*(C: LLVMContextRef; Vals: ptr LLVMValueRef; Count: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMMDNodeInContext", dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMMDNodeInContext2 instead.

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef,
                            LLVMMDNode(LLVMValueRef * Vals, unsigned, Count), "Use of the global context is deprecated, use LLVMMDNodeInContext2 instead")
##
##  @}
##
##
##  @defgroup LLVMCCoreOperandBundle Operand Bundles
##
##  Functions in this group operate on LLVMOperandBundleRef instances that
##  correspond to llvm::OperandBundleDef instances.
##
##  @see llvm::OperandBundleDef
##
##  @{
##
##
##  Create a new operand bundle.
##
##  Every invocation should be paired with LLVMDisposeOperandBundle() or memory
##  will be leaked.
##
##  @param Tag Tag name of the operand bundle
##  @param TagLen Length of Tag
##  @param Args Memory address of an array of bundle operands
##  @param NumArgs Length of Args
##

proc LLVMCreateOperandBundle*(Tag: cstring; TagLen: csize_t; Args: ptr LLVMValueRef;
                             NumArgs: cuint): LLVMOperandBundleRef {.cdecl,
    importc: "LLVMCreateOperandBundle", dynlib: libLLVM.so.23.1.}
##
##  Destroy an operand bundle.
##
##  This must be called for every created operand bundle or memory will be
##  leaked.
##

proc LLVMDisposeOperandBundle*(Bundle: LLVMOperandBundleRef) {.cdecl,
    importc: "LLVMDisposeOperandBundle", dynlib: libLLVM.so.23.1.}
##
##  Obtain the tag of an operand bundle as a string.
##
##  @param Bundle Operand bundle to obtain tag of.
##  @param Len Out parameter which holds the length of the returned string.
##  @return The tag name of Bundle.
##  @see OperandBundleDef::getTag()
##

proc LLVMGetOperandBundleTag*(Bundle: LLVMOperandBundleRef; Len: ptr csize_t): cstring {.
    cdecl, importc: "LLVMGetOperandBundleTag", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of operands for an operand bundle.
##
##  @param Bundle Operand bundle to obtain operand count of.
##  @return The number of operands.
##  @see OperandBundleDef::input_size()
##

proc LLVMGetNumOperandBundleArgs*(Bundle: LLVMOperandBundleRef): cuint {.cdecl,
    importc: "LLVMGetNumOperandBundleArgs", dynlib: libLLVM.so.23.1.}
##
##  Obtain the operand for an operand bundle at the given index.
##
##  @param Bundle Operand bundle to obtain operand of.
##  @param Index An operand index, must be less than
##  LLVMGetNumOperandBundleArgs().
##  @return The operand.
##

proc LLVMGetOperandBundleArgAtIndex*(Bundle: LLVMOperandBundleRef; Index: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMGetOperandBundleArgAtIndex", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueBasicBlock Basic Block
##
##  A basic block represents a single entry single exit section of code.
##  Basic blocks contain a list of instructions which form the body of
##  the block.
##
##  Basic blocks belong to functions. They have the type of label.
##
##  Basic blocks are themselves values. However, the C API models them as
##  LLVMBasicBlockRef.
##
##  @see llvm::BasicBlock
##
##  @{
##
##
##  Convert a basic block instance to a value type.
##

proc LLVMBasicBlockAsValue*(BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMBasicBlockAsValue", dynlib: libLLVM.so.23.1.}
##
##  Determine whether an LLVMValueRef is itself a basic block.
##

proc LLVMValueIsBasicBlock*(Val: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMValueIsBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Convert an LLVMValueRef to an LLVMBasicBlockRef instance.
##

proc LLVMValueAsBasicBlock*(Val: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMValueAsBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Obtain the string name of a basic block.
##

proc LLVMGetBasicBlockName*(BB: LLVMBasicBlockRef): cstring {.cdecl,
    importc: "LLVMGetBasicBlockName", dynlib: libLLVM.so.23.1.}
##
##  Obtain the function to which a basic block belongs.
##
##  @see llvm::BasicBlock::getParent()
##

proc LLVMGetBasicBlockParent*(BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetBasicBlockParent", dynlib: libLLVM.so.23.1.}
##
##  Obtain the terminator instruction for a basic block.
##
##  If the basic block does not have a terminator (it is not well-formed
##  if it doesn't), then NULL is returned.
##
##  The returned LLVMValueRef corresponds to an llvm::Instruction.
##
##  @see llvm::BasicBlock::getTerminator()
##

proc LLVMGetBasicBlockTerminator*(BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetBasicBlockTerminator", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of basic blocks in a function.
##
##  @param Fn Function value to operate on.
##

proc LLVMCountBasicBlocks*(Fn: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMCountBasicBlocks", dynlib: libLLVM.so.23.1.}
##
##  Obtain all of the basic blocks in a function.
##
##  This operates on a function value. The BasicBlocks parameter is a
##  pointer to a pre-allocated array of LLVMBasicBlockRef of at least
##  LLVMCountBasicBlocks() in length. This array is populated with
##  LLVMBasicBlockRef instances.
##

proc LLVMGetBasicBlocks*(Fn: LLVMValueRef; BasicBlocks: ptr LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMGetBasicBlocks", dynlib: libLLVM.so.23.1.}
##
##  Obtain the first basic block in a function.
##
##  The returned basic block can be used as an iterator. You will likely
##  eventually call into LLVMGetNextBasicBlock() with it.
##
##  @see llvm::Function::begin()
##

proc LLVMGetFirstBasicBlock*(Fn: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetFirstBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Obtain the last basic block in a function.
##
##  @see llvm::Function::end()
##

proc LLVMGetLastBasicBlock*(Fn: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetLastBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Advance a basic block iterator.
##

proc LLVMGetNextBasicBlock*(BB: LLVMBasicBlockRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetNextBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Go backwards in a basic block iterator.
##

proc LLVMGetPreviousBasicBlock*(BB: LLVMBasicBlockRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetPreviousBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Obtain the basic block that corresponds to the entry point of a
##  function.
##
##  @see llvm::Function::getEntryBlock()
##

proc LLVMGetEntryBasicBlock*(Fn: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetEntryBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Insert the given basic block after the insertion point of the given builder.
##
##  The insertion point must be valid.
##
##  @see llvm::Function::BasicBlockListType::insertAfter()
##

proc LLVMInsertExistingBasicBlockAfterInsertBlock*(Builder: LLVMBuilderRef;
    BB: LLVMBasicBlockRef) {.cdecl, importc: "LLVMInsertExistingBasicBlockAfterInsertBlock",
                           dynlib: libLLVM.so.23.1.}
##
##  Append the given basic block to the basic block list of the given function.
##
##  @see llvm::Function::BasicBlockListType::push_back()
##

proc LLVMAppendExistingBasicBlock*(Fn: LLVMValueRef; BB: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMAppendExistingBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Create a new basic block without inserting it into a function.
##
##  @see llvm::BasicBlock::Create()
##

proc LLVMCreateBasicBlockInContext*(C: LLVMContextRef; Name: cstring): LLVMBasicBlockRef {.
    cdecl, importc: "LLVMCreateBasicBlockInContext", dynlib: libLLVM.so.23.1.}
##
##  Append a basic block to the end of a function.
##
##  @see llvm::BasicBlock::Create()
##

proc LLVMAppendBasicBlockInContext*(C: LLVMContextRef; Fn: LLVMValueRef;
                                   Name: cstring): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMAppendBasicBlockInContext", dynlib: libLLVM.so.23.1.}
##
##  Append a basic block to the end of a function using the global
##  context.
##
##  @see llvm::BasicBlock::Create()
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMBasicBlockRef, LLVMAppendBasicBlock(LLVMValueRef,
    Fn, `const`, char * Name), "Use of the global context is deprecated, use LLVMAppendBasicBlockInContext instead")
##
##  Insert a basic block in a function before another basic block.
##
##  The function to add to is determined by the function of the
##  passed basic block.
##
##  @see llvm::BasicBlock::Create()
##

proc LLVMInsertBasicBlockInContext*(C: LLVMContextRef; BB: LLVMBasicBlockRef;
                                   Name: cstring): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMInsertBasicBlockInContext", dynlib: libLLVM.so.23.1.}
##
##  Insert a basic block in a function using the global context.
##
##  @see llvm::BasicBlock::Create()
##

LLVM_ATTRIBUTE_C_DEPRECATED(LLVMBasicBlockRef, LLVMInsertBasicBlock(
    LLVMBasicBlockRef, InsertBeforeBB, `const`, char * Name), "Use of the global context is deprecated, use LLVMInsertBasicBlockInContext instead")
##
##  Remove a basic block from a function and delete it.
##
##  This deletes the basic block from its containing function and deletes
##  the basic block itself.
##
##  @see llvm::BasicBlock::eraseFromParent()
##

proc LLVMDeleteBasicBlock*(BB: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMDeleteBasicBlock", dynlib: libLLVM.so.23.1.}
##
##  Remove a basic block from a function.
##
##  This deletes the basic block from its containing function but keep
##  the basic block alive.
##
##  @see llvm::BasicBlock::removeFromParent()
##

proc LLVMRemoveBasicBlockFromParent*(BB: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMRemoveBasicBlockFromParent", dynlib: libLLVM.so.23.1.}
##
##  Move a basic block to before another one.
##
##  @see llvm::BasicBlock::moveBefore()
##

proc LLVMMoveBasicBlockBefore*(BB: LLVMBasicBlockRef; MovePos: LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMMoveBasicBlockBefore", dynlib: libLLVM.so.23.1.}
##
##  Move a basic block to after another one.
##
##  @see llvm::BasicBlock::moveAfter()
##

proc LLVMMoveBasicBlockAfter*(BB: LLVMBasicBlockRef; MovePos: LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMMoveBasicBlockAfter", dynlib: libLLVM.so.23.1.}
##
##  Obtain the first instruction in a basic block.
##
##  The returned LLVMValueRef corresponds to a llvm::Instruction
##  instance.
##

proc LLVMGetFirstInstruction*(BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetFirstInstruction", dynlib: libLLVM.so.23.1.}
##
##  Obtain the last instruction in a basic block.
##
##  The returned LLVMValueRef corresponds to an LLVM:Instruction.
##

proc LLVMGetLastInstruction*(BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetLastInstruction", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueInstruction Instructions
##
##  Functions in this group relate to the inspection and manipulation of
##  individual instructions.
##
##  In the C++ API, an instruction is modeled by llvm::Instruction. This
##  class has a large number of descendents. llvm::Instruction is a
##  llvm::Value and in the C API, instructions are modeled by
##  LLVMValueRef.
##
##  This group also contains sub-groups which operate on specific
##  llvm::Instruction types, e.g. llvm::CallInst.
##
##  @{
##
##
##  Determine whether an instruction has any metadata attached.
##

proc LLVMHasMetadata*(Val: LLVMValueRef): cint {.cdecl, importc: "LLVMHasMetadata",
    dynlib: libLLVM.so.23.1.}
##
##  Return metadata associated with an instruction value.
##

proc LLVMGetMetadata*(Val: LLVMValueRef; KindID: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetMetadata", dynlib: libLLVM.so.23.1.}
##
##  Set metadata associated with an instruction value.
##

proc LLVMSetMetadata*(Val: LLVMValueRef; KindID: cuint; Node: LLVMValueRef) {.cdecl,
    importc: "LLVMSetMetadata", dynlib: libLLVM.so.23.1.}
##
##  Returns the metadata associated with an instruction value, but filters out
##  all the debug locations.
##
##  @see llvm::Instruction::getAllMetadataOtherThanDebugLoc()
##

proc LLVMInstructionGetAllMetadataOtherThanDebugLoc*(Instr: LLVMValueRef;
    NumEntries: ptr csize_t): ptr LLVMValueMetadataEntry {.cdecl,
    importc: "LLVMInstructionGetAllMetadataOtherThanDebugLoc",
    dynlib: libLLVM.so.23.1.}
##
##  Obtain the basic block to which an instruction belongs.
##
##  @see llvm::Instruction::getParent()
##

proc LLVMGetInstructionParent*(Inst: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetInstructionParent", dynlib: libLLVM.so.23.1.}
##
##  Obtain the instruction that occurs after the one specified.
##
##  The next instruction will be from the same basic block.
##
##  If this is the last instruction in a basic block, NULL will be
##  returned.
##

proc LLVMGetNextInstruction*(Inst: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetNextInstruction", dynlib: libLLVM.so.23.1.}
##
##  Obtain the instruction that occurred before this one.
##
##  If the instruction is the first instruction in a basic block, NULL
##  will be returned.
##

proc LLVMGetPreviousInstruction*(Inst: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetPreviousInstruction", dynlib: libLLVM.so.23.1.}
##
##  Remove an instruction.
##
##  The instruction specified is removed from its containing building
##  block but is kept alive.
##
##  @see llvm::Instruction::removeFromParent()
##

proc LLVMInstructionRemoveFromParent*(Inst: LLVMValueRef) {.cdecl,
    importc: "LLVMInstructionRemoveFromParent", dynlib: libLLVM.so.23.1.}
##
##  Remove and delete an instruction.
##
##  The instruction specified is removed from its containing building
##  block and then deleted.
##
##  @see llvm::Instruction::eraseFromParent()
##

proc LLVMInstructionEraseFromParent*(Inst: LLVMValueRef) {.cdecl,
    importc: "LLVMInstructionEraseFromParent", dynlib: libLLVM.so.23.1.}
##
##  Delete an instruction.
##
##  The instruction specified is deleted. It must have previously been
##  removed from its containing building block.
##
##  @see llvm::Value::deleteValue()
##

proc LLVMDeleteInstruction*(Inst: LLVMValueRef) {.cdecl,
    importc: "LLVMDeleteInstruction", dynlib: libLLVM.so.23.1.}
##
##  Obtain the code opcode for an individual instruction.
##
##  @see llvm::Instruction::getOpCode()
##

proc LLVMGetInstructionOpcode*(Inst: LLVMValueRef): LLVMOpcode {.cdecl,
    importc: "LLVMGetInstructionOpcode", dynlib: libLLVM.so.23.1.}
##
##  Obtain the predicate of an instruction.
##
##  This is only valid for instructions that correspond to llvm::ICmpInst.
##
##  @see llvm::ICmpInst::getPredicate()
##

proc LLVMGetICmpPredicate*(Inst: LLVMValueRef): LLVMIntPredicate {.cdecl,
    importc: "LLVMGetICmpPredicate", dynlib: libLLVM.so.23.1.}
##
##  Get whether or not an icmp instruction has the samesign flag.
##
##  This is only valid for instructions that correspond to llvm::ICmpInst.
##
##  @see llvm::ICmpInst::hasSameSign()
##

proc LLVMGetICmpSameSign*(Inst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetICmpSameSign", dynlib: libLLVM.so.23.1.}
##
##  Set the samesign flag on an icmp instruction.
##
##  This is only valid for instructions that correspond to llvm::ICmpInst.
##
##  @see llvm::ICmpInst::setSameSign()
##

proc LLVMSetICmpSameSign*(Inst: LLVMValueRef; SameSign: LLVMBool) {.cdecl,
    importc: "LLVMSetICmpSameSign", dynlib: libLLVM.so.23.1.}
##
##  Obtain the float predicate of an instruction.
##
##  This is only valid for instructions that correspond to llvm::FCmpInst.
##
##  @see llvm::FCmpInst::getPredicate()
##

proc LLVMGetFCmpPredicate*(Inst: LLVMValueRef): LLVMRealPredicate {.cdecl,
    importc: "LLVMGetFCmpPredicate", dynlib: libLLVM.so.23.1.}
##
##  Create a copy of 'this' instruction that is identical in all ways
##  except the following:
##    * The instruction has no parent
##    * The instruction has no name
##
##  @see llvm::Instruction::clone()
##

proc LLVMInstructionClone*(Inst: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMInstructionClone", dynlib: libLLVM.so.23.1.}
##
##  Determine whether an instruction is a terminator. This routine is named to
##  be compatible with historical functions that did this by querying the
##  underlying C++ type.
##
##  @see llvm::Instruction::isTerminator()
##

proc LLVMIsATerminatorInst*(Inst: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMIsATerminatorInst", dynlib: libLLVM.so.23.1.}
##
##  Obtain the first debug record attached to an instruction.
##
##  Use LLVMGetNextDbgRecord() and LLVMGetPreviousDbgRecord() to traverse the
##  sequence of DbgRecords.
##
##  Return the first DbgRecord attached to Inst or NULL if there are none.
##
##  @see llvm::Instruction::getDbgRecordRange()
##

proc LLVMGetFirstDbgRecord*(Inst: LLVMValueRef): LLVMDbgRecordRef {.cdecl,
    importc: "LLVMGetFirstDbgRecord", dynlib: libLLVM.so.23.1.}
##
##  Obtain the last debug record attached to an instruction.
##
##  Return the last DbgRecord attached to Inst or NULL if there are none.
##
##  @see llvm::Instruction::getDbgRecordRange()
##

proc LLVMGetLastDbgRecord*(Inst: LLVMValueRef): LLVMDbgRecordRef {.cdecl,
    importc: "LLVMGetLastDbgRecord", dynlib: libLLVM.so.23.1.}
##
##  Obtain the next DbgRecord in the sequence or NULL if there are no more.
##
##  @see llvm::Instruction::getDbgRecordRange()
##

proc LLVMGetNextDbgRecord*(DbgRecord: LLVMDbgRecordRef): LLVMDbgRecordRef {.cdecl,
    importc: "LLVMGetNextDbgRecord", dynlib: libLLVM.so.23.1.}
##
##  Obtain the previous DbgRecord in the sequence or NULL if there are no more.
##
##  @see llvm::Instruction::getDbgRecordRange()
##

proc LLVMGetPreviousDbgRecord*(DbgRecord: LLVMDbgRecordRef): LLVMDbgRecordRef {.
    cdecl, importc: "LLVMGetPreviousDbgRecord", dynlib: libLLVM.so.23.1.}
##
##  Get the debug location attached to the debug record.
##
##  @see llvm::DbgRecord::getDebugLoc()
##

proc LLVMDbgRecordGetDebugLoc*(Rec: LLVMDbgRecordRef): LLVMMetadataRef {.cdecl,
    importc: "LLVMDbgRecordGetDebugLoc", dynlib: libLLVM.so.23.1.}
proc LLVMDbgRecordGetKind*(Rec: LLVMDbgRecordRef): LLVMDbgRecordKind {.cdecl,
    importc: "LLVMDbgRecordGetKind", dynlib: libLLVM.so.23.1.}
##
##  Get the value of the DbgVariableRecord.
##
##  @see llvm::DbgVariableRecord::getValue()
##

proc LLVMDbgVariableRecordGetValue*(Rec: LLVMDbgRecordRef; OpIdx: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMDbgVariableRecordGetValue", dynlib: libLLVM.so.23.1.}
##
##  Get the debug info variable of the DbgVariableRecord.
##
##  @see llvm::DbgVariableRecord::getVariable()
##

proc LLVMDbgVariableRecordGetVariable*(Rec: LLVMDbgRecordRef): LLVMMetadataRef {.
    cdecl, importc: "LLVMDbgVariableRecordGetVariable", dynlib: libLLVM.so.23.1.}
##
##  Get the debug info expression of the DbgVariableRecord.
##
##  @see llvm::DbgVariableRecord::getExpression()
##

proc LLVMDbgVariableRecordGetExpression*(Rec: LLVMDbgRecordRef): LLVMMetadataRef {.
    cdecl, importc: "LLVMDbgVariableRecordGetExpression", dynlib: libLLVM.so.23.1.}
##
##  @defgroup LLVMCCoreValueInstructionCall Call Sites and Invocations
##
##  Functions in this group apply to instructions that refer to call
##  sites and invocations. These correspond to C++ types in the
##  llvm::CallInst class tree.
##
##  @{
##
##
##  Obtain the argument count for a call instruction.
##
##  This expects an LLVMValueRef that corresponds to a llvm::CallInst,
##  llvm::InvokeInst, or llvm:FuncletPadInst.
##
##  @see llvm::CallInst::getNumArgOperands()
##  @see llvm::InvokeInst::getNumArgOperands()
##  @see llvm::FuncletPadInst::getNumArgOperands()
##

proc LLVMGetNumArgOperands*(Instr: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumArgOperands", dynlib: libLLVM.so.23.1.}
##
##  Set the calling convention for a call instruction.
##
##  This expects an LLVMValueRef that corresponds to a llvm::CallInst or
##  llvm::InvokeInst.
##
##  @see llvm::CallInst::setCallingConv()
##  @see llvm::InvokeInst::setCallingConv()
##

proc LLVMSetInstructionCallConv*(Instr: LLVMValueRef; CC: cuint) {.cdecl,
    importc: "LLVMSetInstructionCallConv", dynlib: libLLVM.so.23.1.}
##
##  Obtain the calling convention for a call instruction.
##
##  This is the opposite of LLVMSetInstructionCallConv(). Reads its
##  usage.
##
##  @see LLVMSetInstructionCallConv()
##

proc LLVMGetInstructionCallConv*(Instr: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetInstructionCallConv", dynlib: libLLVM.so.23.1.}
proc LLVMSetInstrParamAlignment*(Instr: LLVMValueRef; Idx: LLVMAttributeIndex;
                                Align: cuint) {.cdecl,
    importc: "LLVMSetInstrParamAlignment", dynlib: libLLVM.so.23.1.}
proc LLVMAddCallSiteAttribute*(C: LLVMValueRef; Idx: LLVMAttributeIndex;
                              A: LLVMAttributeRef) {.cdecl,
    importc: "LLVMAddCallSiteAttribute", dynlib: libLLVM.so.23.1.}
proc LLVMGetCallSiteAttributeCount*(C: LLVMValueRef; Idx: LLVMAttributeIndex): cuint {.
    cdecl, importc: "LLVMGetCallSiteAttributeCount", dynlib: libLLVM.so.23.1.}
proc LLVMGetCallSiteAttributes*(C: LLVMValueRef; Idx: LLVMAttributeIndex;
                               Attrs: ptr LLVMAttributeRef) {.cdecl,
    importc: "LLVMGetCallSiteAttributes", dynlib: libLLVM.so.23.1.}
proc LLVMGetCallSiteEnumAttribute*(C: LLVMValueRef; Idx: LLVMAttributeIndex;
                                  KindID: cuint): LLVMAttributeRef {.cdecl,
    importc: "LLVMGetCallSiteEnumAttribute", dynlib: libLLVM.so.23.1.}
proc LLVMGetCallSiteStringAttribute*(C: LLVMValueRef; Idx: LLVMAttributeIndex;
                                    K: cstring; KLen: cuint): LLVMAttributeRef {.
    cdecl, importc: "LLVMGetCallSiteStringAttribute", dynlib: libLLVM.so.23.1.}
proc LLVMRemoveCallSiteEnumAttribute*(C: LLVMValueRef; Idx: LLVMAttributeIndex;
                                     KindID: cuint) {.cdecl,
    importc: "LLVMRemoveCallSiteEnumAttribute", dynlib: libLLVM.so.23.1.}
proc LLVMRemoveCallSiteStringAttribute*(C: LLVMValueRef; Idx: LLVMAttributeIndex;
                                       K: cstring; KLen: cuint) {.cdecl,
    importc: "LLVMRemoveCallSiteStringAttribute", dynlib: libLLVM.so.23.1.}
##
##  Obtain the function type called by this instruction.
##
##  @see llvm::CallBase::getFunctionType()
##

proc LLVMGetCalledFunctionType*(C: LLVMValueRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetCalledFunctionType", dynlib: libLLVM.so.23.1.}
##
##  Obtain the pointer to the function invoked by this instruction.
##
##  This expects an LLVMValueRef that corresponds to a llvm::CallInst or
##  llvm::InvokeInst.
##
##  @see llvm::CallInst::getCalledOperand()
##  @see llvm::InvokeInst::getCalledOperand()
##

proc LLVMGetCalledValue*(Instr: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetCalledValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of operand bundles attached to this instruction.
##
##  This only works on llvm::CallInst and llvm::InvokeInst instructions.
##
##  @see llvm::CallBase::getNumOperandBundles()
##

proc LLVMGetNumOperandBundles*(C: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumOperandBundles", dynlib: libLLVM.so.23.1.}
##
##  Obtain the operand bundle attached to this instruction at the given index.
##  Use LLVMDisposeOperandBundle to free the operand bundle.
##
##  This only works on llvm::CallInst and llvm::InvokeInst instructions.
##

proc LLVMGetOperandBundleAtIndex*(C: LLVMValueRef; Index: cuint): LLVMOperandBundleRef {.
    cdecl, importc: "LLVMGetOperandBundleAtIndex", dynlib: libLLVM.so.23.1.}
##
##  Obtain whether a call instruction is a tail call.
##
##  This only works on llvm::CallInst instructions.
##
##  @see llvm::CallInst::isTailCall()
##

proc LLVMIsTailCall*(CallInst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsTailCall", dynlib: libLLVM.so.23.1.}
##
##  Set whether a call instruction is a tail call.
##
##  This only works on llvm::CallInst instructions.
##
##  @see llvm::CallInst::setTailCall()
##

proc LLVMSetTailCall*(CallInst: LLVMValueRef; IsTailCall: LLVMBool) {.cdecl,
    importc: "LLVMSetTailCall", dynlib: libLLVM.so.23.1.}
##
##  Obtain a tail call kind of the call instruction.
##
##  @see llvm::CallInst::setTailCallKind()
##

proc LLVMGetTailCallKind*(CallInst: LLVMValueRef): LLVMTailCallKind {.cdecl,
    importc: "LLVMGetTailCallKind", dynlib: libLLVM.so.23.1.}
##
##  Set the call kind of the call instruction.
##
##  @see llvm::CallInst::getTailCallKind()
##

proc LLVMSetTailCallKind*(CallInst: LLVMValueRef; kind: LLVMTailCallKind) {.cdecl,
    importc: "LLVMSetTailCallKind", dynlib: libLLVM.so.23.1.}
##
##  Return the normal destination basic block.
##
##  This only works on llvm::InvokeInst instructions.
##
##  @see llvm::InvokeInst::getNormalDest()
##

proc LLVMGetNormalDest*(InvokeInst: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetNormalDest", dynlib: libLLVM.so.23.1.}
##
##  Return the unwind destination basic block.
##
##  Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
##  llvm::CatchSwitchInst instructions.
##
##  @see llvm::InvokeInst::getUnwindDest()
##  @see llvm::CleanupReturnInst::getUnwindDest()
##  @see llvm::CatchSwitchInst::getUnwindDest()
##

proc LLVMGetUnwindDest*(InvokeInst: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetUnwindDest", dynlib: libLLVM.so.23.1.}
##
##  Set the normal destination basic block.
##
##  This only works on llvm::InvokeInst instructions.
##
##  @see llvm::InvokeInst::setNormalDest()
##

proc LLVMSetNormalDest*(InvokeInst: LLVMValueRef; B: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMSetNormalDest", dynlib: libLLVM.so.23.1.}
##
##  Set the unwind destination basic block.
##
##  Works on llvm::InvokeInst, llvm::CleanupReturnInst, and
##  llvm::CatchSwitchInst instructions.
##
##  @see llvm::InvokeInst::setUnwindDest()
##  @see llvm::CleanupReturnInst::setUnwindDest()
##  @see llvm::CatchSwitchInst::setUnwindDest()
##

proc LLVMSetUnwindDest*(InvokeInst: LLVMValueRef; B: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMSetUnwindDest", dynlib: libLLVM.so.23.1.}
##
##  Get the default destination of a CallBr instruction.
##
##  @see llvm::CallBrInst::getDefaultDest()
##

proc LLVMGetCallBrDefaultDest*(CallBr: LLVMValueRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetCallBrDefaultDest", dynlib: libLLVM.so.23.1.}
##
##  Get the number of indirect destinations of a CallBr instruction.
##
##  @see llvm::CallBrInst::getNumIndirectDests()
##
##

proc LLVMGetCallBrNumIndirectDests*(CallBr: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetCallBrNumIndirectDests", dynlib: libLLVM.so.23.1.}
##
##  Get the indirect destination of a CallBr instruction at the given index.
##
##  @see llvm::CallBrInst::getIndirectDest()
##

proc LLVMGetCallBrIndirectDest*(CallBr: LLVMValueRef; Idx: cuint): LLVMBasicBlockRef {.
    cdecl, importc: "LLVMGetCallBrIndirectDest", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueInstructionTerminator Terminators
##
##  Functions in this group only apply to instructions for which
##  LLVMIsATerminatorInst returns true.
##
##  @{
##
##
##  Return the number of successors that this terminator has.
##
##  @see llvm::Instruction::getNumSuccessors
##

proc LLVMGetNumSuccessors*(Term: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumSuccessors", dynlib: libLLVM.so.23.1.}
##
##  Return the specified successor.
##
##  @see llvm::Instruction::getSuccessor
##

proc LLVMGetSuccessor*(Term: LLVMValueRef; i: cuint): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetSuccessor", dynlib: libLLVM.so.23.1.}
##
##  Update the specified successor to point at the provided block.
##
##  @see llvm::Instruction::setSuccessor
##

proc LLVMSetSuccessor*(Term: LLVMValueRef; i: cuint; `block`: LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMSetSuccessor", dynlib: libLLVM.so.23.1.}
##
##  Return if an instruction is a conditional branch.
##
##  Deprecated: Use LLVMIsACondBrInst instead.
##

proc LLVMIsConditional*(Branch: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsConditional", dynlib: libLLVM.so.23.1.}
##
##  Return the condition of a branch instruction.
##
##  This only works on llvm::CondBrInst instructions.
##
##  @see llvm::CondBrInst::getCondition
##

proc LLVMGetCondition*(Branch: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetCondition", dynlib: libLLVM.so.23.1.}
##
##  Set the condition of a branch instruction.
##
##  This only works on llvm::CondBrInst instructions.
##
##  @see llvm::CondBrInst::setCondition
##

proc LLVMSetCondition*(Branch: LLVMValueRef; Cond: LLVMValueRef) {.cdecl,
    importc: "LLVMSetCondition", dynlib: libLLVM.so.23.1.}
##
##  Obtain the default destination basic block of a switch instruction.
##
##  This only works on llvm::SwitchInst instructions.
##
##  @see llvm::SwitchInst::getDefaultDest()
##

proc LLVMGetSwitchDefaultDest*(SwitchInstr: LLVMValueRef): LLVMBasicBlockRef {.
    cdecl, importc: "LLVMGetSwitchDefaultDest", dynlib: libLLVM.so.23.1.}
##
##  Obtain the case value for a successor of a switch instruction. i corresponds
##  to the successor index. The first successor is the default destination, so i
##  must be greater than zero.
##
##  This only works on llvm::SwitchInst instructions.
##
##  @see llvm::SwitchInst::CaseHandle::getCaseValue()
##

proc LLVMGetSwitchCaseValue*(SwitchInstr: LLVMValueRef; i: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMGetSwitchCaseValue", dynlib: libLLVM.so.23.1.}
##
##  Set the case value for a successor of a switch instruction. i corresponds to
##  the successor index. The first successor is the default destination, so i
##  must be greater than zero.
##
##  This only works on llvm::SwitchInst instructions.
##
##  @see llvm::SwitchInst::CaseHandle::setValue()
##

proc LLVMSetSwitchCaseValue*(SwitchInstr: LLVMValueRef; i: cuint;
                            CaseValue: LLVMValueRef) {.cdecl,
    importc: "LLVMSetSwitchCaseValue", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueInstructionAlloca Allocas
##
##  Functions in this group only apply to instructions that map to
##  llvm::AllocaInst instances.
##
##  @{
##
##
##  Obtain the type that is being allocated by the alloca instruction.
##

proc LLVMGetAllocatedType*(Alloca: LLVMValueRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetAllocatedType", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueInstructionGetElementPointer GEPs
##
##  Functions in this group only apply to instructions that map to
##  llvm::GetElementPtrInst instances.
##
##  @{
##
##
##  Check whether the given GEP operator is inbounds.
##

proc LLVMIsInBounds*(GEP: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMIsInBounds",
    dynlib: libLLVM.so.23.1.}
##
##  Set the given GEP instruction to be inbounds or not.
##

proc LLVMSetIsInBounds*(GEP: LLVMValueRef; InBounds: LLVMBool) {.cdecl,
    importc: "LLVMSetIsInBounds", dynlib: libLLVM.so.23.1.}
##
##  Get the source element type of the given GEP operator.
##

proc LLVMGetGEPSourceElementType*(GEP: LLVMValueRef): LLVMTypeRef {.cdecl,
    importc: "LLVMGetGEPSourceElementType", dynlib: libLLVM.so.23.1.}
##
##  Get the no-wrap related flags for the given GEP instruction.
##
##  @see llvm::GetElementPtrInst::getNoWrapFlags
##

proc LLVMGEPGetNoWrapFlags*(GEP: LLVMValueRef): LLVMGEPNoWrapFlags {.cdecl,
    importc: "LLVMGEPGetNoWrapFlags", dynlib: libLLVM.so.23.1.}
##
##  Set the no-wrap related flags for the given GEP instruction.
##
##  @see llvm::GetElementPtrInst::setNoWrapFlags
##

proc LLVMGEPSetNoWrapFlags*(GEP: LLVMValueRef; NoWrapFlags: LLVMGEPNoWrapFlags) {.
    cdecl, importc: "LLVMGEPSetNoWrapFlags", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueInstructionPHINode PHI Nodes
##
##  Functions in this group only apply to instructions that map to
##  llvm::PHINode instances.
##
##  @{
##
##
##  Add an incoming value to the end of a PHI list.
##

proc LLVMAddIncoming*(PhiNode: LLVMValueRef; IncomingValues: ptr LLVMValueRef;
                     IncomingBlocks: ptr LLVMBasicBlockRef; Count: cuint) {.cdecl,
    importc: "LLVMAddIncoming", dynlib: libLLVM.so.23.1.}
##
##  Obtain the number of incoming basic blocks to a PHI node.
##

proc LLVMCountIncoming*(PhiNode: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMCountIncoming", dynlib: libLLVM.so.23.1.}
##
##  Obtain an incoming value to a PHI node as an LLVMValueRef.
##

proc LLVMGetIncomingValue*(PhiNode: LLVMValueRef; Index: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetIncomingValue", dynlib: libLLVM.so.23.1.}
##
##  Obtain an incoming value to a PHI node as an LLVMBasicBlockRef.
##

proc LLVMGetIncomingBlock*(PhiNode: LLVMValueRef; Index: cuint): LLVMBasicBlockRef {.
    cdecl, importc: "LLVMGetIncomingBlock", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreValueInstructionExtractValue ExtractValue
##  @defgroup LLVMCCoreValueInstructionInsertValue InsertValue
##
##  Functions in this group only apply to instructions that map to
##  llvm::ExtractValue and llvm::InsertValue instances.
##
##  @{
##
##
##  Obtain the number of indices.
##  NB: This also works on GEP operators.
##

proc LLVMGetNumIndices*(Inst: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumIndices", dynlib: libLLVM.so.23.1.}
##
##  Obtain the indices as an array.
##

proc LLVMGetIndices*(Inst: LLVMValueRef): ptr cuint {.cdecl,
    importc: "LLVMGetIndices", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @}
##
##
##  @}
##
##
##  @defgroup LLVMCCoreInstructionBuilder Instruction Builders
##
##  An instruction builder represents a point within a basic block and is
##  the exclusive means of building instructions using the C interface.
##
##  @{
##

proc LLVMCreateBuilderInContext*(C: LLVMContextRef): LLVMBuilderRef {.cdecl,
    importc: "LLVMCreateBuilderInContext", dynlib: libLLVM.so.23.1.}
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMBuilderRef, LLVMCreateBuilder(void), "Use of the global context is deprecated, use LLVMCreateBuilderInContext instead")
##
##  Set the builder position before Instr but after any attached debug records,
##  or if Instr is null set the position to the end of Block.
##

proc LLVMPositionBuilder*(Builder: LLVMBuilderRef; Block: LLVMBasicBlockRef;
                         Instr: LLVMValueRef) {.cdecl,
    importc: "LLVMPositionBuilder", dynlib: libLLVM.so.23.1.}
##
##  Set the builder position before Instr and any attached debug records,
##  or if Instr is null set the position to the end of Block.
##

proc LLVMPositionBuilderBeforeDbgRecords*(Builder: LLVMBuilderRef;
    Block: LLVMBasicBlockRef; Inst: LLVMValueRef) {.cdecl,
    importc: "LLVMPositionBuilderBeforeDbgRecords", dynlib: libLLVM.so.23.1.}
##
##  Set the builder position before Instr but after any attached debug records.
##

proc LLVMPositionBuilderBefore*(Builder: LLVMBuilderRef; Instr: LLVMValueRef) {.
    cdecl, importc: "LLVMPositionBuilderBefore", dynlib: libLLVM.so.23.1.}
##
##  Set the builder position before Instr and any attached debug records.
##

proc LLVMPositionBuilderBeforeInstrAndDbgRecords*(Builder: LLVMBuilderRef;
    Instr: LLVMValueRef) {.cdecl, importc: "LLVMPositionBuilderBeforeInstrAndDbgRecords",
                         dynlib: libLLVM.so.23.1.}
proc LLVMPositionBuilderAtEnd*(Builder: LLVMBuilderRef; Block: LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMPositionBuilderAtEnd", dynlib: libLLVM.so.23.1.}
proc LLVMGetInsertBlock*(Builder: LLVMBuilderRef): LLVMBasicBlockRef {.cdecl,
    importc: "LLVMGetInsertBlock", dynlib: libLLVM.so.23.1.}
proc LLVMClearInsertionPosition*(Builder: LLVMBuilderRef) {.cdecl,
    importc: "LLVMClearInsertionPosition", dynlib: libLLVM.so.23.1.}
proc LLVMInsertIntoBuilder*(Builder: LLVMBuilderRef; Instr: LLVMValueRef) {.cdecl,
    importc: "LLVMInsertIntoBuilder", dynlib: libLLVM.so.23.1.}
proc LLVMInsertIntoBuilderWithName*(Builder: LLVMBuilderRef; Instr: LLVMValueRef;
                                   Name: cstring) {.cdecl,
    importc: "LLVMInsertIntoBuilderWithName", dynlib: libLLVM.so.23.1.}
proc LLVMDisposeBuilder*(Builder: LLVMBuilderRef) {.cdecl,
    importc: "LLVMDisposeBuilder", dynlib: libLLVM.so.23.1.}
##  Metadata
##
##  Get location information used by debugging information.
##
##  @see llvm::IRBuilder::getCurrentDebugLocation()
##

proc LLVMGetCurrentDebugLocation2*(Builder: LLVMBuilderRef): LLVMMetadataRef {.
    cdecl, importc: "LLVMGetCurrentDebugLocation2", dynlib: libLLVM.so.23.1.}
##
##  Set location information used by debugging information.
##
##  To clear the location metadata of the given instruction, pass NULL to \p Loc.
##
##  @see llvm::IRBuilder::SetCurrentDebugLocation()
##

proc LLVMSetCurrentDebugLocation2*(Builder: LLVMBuilderRef; Loc: LLVMMetadataRef) {.
    cdecl, importc: "LLVMSetCurrentDebugLocation2", dynlib: libLLVM.so.23.1.}
##
##  Attempts to set the debug location for the given instruction using the
##  current debug location for the given builder.  If the builder has no current
##  debug location, this function is a no-op.
##
##  @see llvm::IRBuilder::SetInstDebugLocation()
##

proc LLVMSetInstDebugLocation*(Builder: LLVMBuilderRef; Inst: LLVMValueRef) {.cdecl,
    importc: "LLVMSetInstDebugLocation", dynlib: libLLVM.so.23.1.}
##
##  Same as LLVMSetInstDebugLocation.
##
##  @deprecated Use the identical LLVMSetInstDebugLocation.
##
##  @see llvm::IRBuilder::SetInstDebugLocation()
##

proc LLVMAddMetadataToInst*(Builder: LLVMBuilderRef; Inst: LLVMValueRef) {.cdecl,
    importc: "LLVMAddMetadataToInst", dynlib: libLLVM.so.23.1.}
##
##  Get the dafult floating-point math metadata for a given builder.
##
##  @see llvm::IRBuilder::getDefaultFPMathTag()
##

proc LLVMBuilderGetDefaultFPMathTag*(Builder: LLVMBuilderRef): LLVMMetadataRef {.
    cdecl, importc: "LLVMBuilderGetDefaultFPMathTag", dynlib: libLLVM.so.23.1.}
##
##  Set the default floating-point math metadata for the given builder.
##
##  To clear the metadata, pass NULL to \p FPMathTag.
##
##  @see llvm::IRBuilder::setDefaultFPMathTag()
##

proc LLVMBuilderSetDefaultFPMathTag*(Builder: LLVMBuilderRef;
                                    FPMathTag: LLVMMetadataRef) {.cdecl,
    importc: "LLVMBuilderSetDefaultFPMathTag", dynlib: libLLVM.so.23.1.}
##
##  Obtain the context to which this builder is associated.
##
##  @see llvm::IRBuilder::getContext()
##

proc LLVMGetBuilderContext*(Builder: LLVMBuilderRef): LLVMContextRef {.cdecl,
    importc: "LLVMGetBuilderContext", dynlib: libLLVM.so.23.1.}
##
##  Deprecated: Passing the NULL location will crash.
##  Use LLVMGetCurrentDebugLocation2 instead.
##

proc LLVMSetCurrentDebugLocation*(Builder: LLVMBuilderRef; L: LLVMValueRef) {.cdecl,
    importc: "LLVMSetCurrentDebugLocation", dynlib: libLLVM.so.23.1.}
##
##  Deprecated: Returning the NULL location will crash.
##  Use LLVMGetCurrentDebugLocation2 instead.
##

proc LLVMGetCurrentDebugLocation*(Builder: LLVMBuilderRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetCurrentDebugLocation", dynlib: libLLVM.so.23.1.}
##  Terminators

proc LLVMBuildRetVoid*(a1: LLVMBuilderRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildRetVoid", dynlib: libLLVM.so.23.1.}
proc LLVMBuildRet*(a1: LLVMBuilderRef; V: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildRet", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAggregateRet*(a1: LLVMBuilderRef; RetVals: ptr LLVMValueRef; N: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMBuildAggregateRet", dynlib: libLLVM.so.23.1.}
proc LLVMBuildBr*(a1: LLVMBuilderRef; Dest: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildBr", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCondBr*(a1: LLVMBuilderRef; If: LLVMValueRef; Then: LLVMBasicBlockRef;
                     Else: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildCondBr", dynlib: libLLVM.so.23.1.}
proc LLVMBuildSwitch*(a1: LLVMBuilderRef; V: LLVMValueRef; Else: LLVMBasicBlockRef;
                     NumCases: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMBuildSwitch", dynlib: libLLVM.so.23.1.}
proc LLVMBuildIndirectBr*(B: LLVMBuilderRef; Addr: LLVMValueRef; NumDests: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMBuildIndirectBr", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCallBr*(B: LLVMBuilderRef; Ty: LLVMTypeRef; Fn: LLVMValueRef;
                     DefaultDest: LLVMBasicBlockRef;
                     IndirectDests: ptr LLVMBasicBlockRef; NumIndirectDests: cuint;
                     Args: ptr LLVMValueRef; NumArgs: cuint;
                     Bundles: ptr LLVMOperandBundleRef; NumBundles: cuint;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildCallBr", dynlib: libLLVM.so.23.1.}
proc LLVMBuildInvoke2*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; Fn: LLVMValueRef;
                      Args: ptr LLVMValueRef; NumArgs: cuint;
                      Then: LLVMBasicBlockRef; Catch: LLVMBasicBlockRef;
                      Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildInvoke2", dynlib: libLLVM.so.23.1.}
proc LLVMBuildInvokeWithOperandBundles*(a1: LLVMBuilderRef; Ty: LLVMTypeRef;
                                       Fn: LLVMValueRef; Args: ptr LLVMValueRef;
                                       NumArgs: cuint; Then: LLVMBasicBlockRef;
                                       Catch: LLVMBasicBlockRef;
                                       Bundles: ptr LLVMOperandBundleRef;
                                       NumBundles: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildInvokeWithOperandBundles", dynlib: libLLVM.so.23.1.}
proc LLVMBuildUnreachable*(a1: LLVMBuilderRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildUnreachable", dynlib: libLLVM.so.23.1.}
##  Exception Handling

proc LLVMBuildResume*(B: LLVMBuilderRef; Exn: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildResume", dynlib: libLLVM.so.23.1.}
proc LLVMBuildLandingPad*(B: LLVMBuilderRef; Ty: LLVMTypeRef; PersFn: LLVMValueRef;
                         NumClauses: cuint; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildLandingPad", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCleanupRet*(B: LLVMBuilderRef; CatchPad: LLVMValueRef;
                         BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildCleanupRet", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCatchRet*(B: LLVMBuilderRef; CatchPad: LLVMValueRef;
                       BB: LLVMBasicBlockRef): LLVMValueRef {.cdecl,
    importc: "LLVMBuildCatchRet", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCatchPad*(B: LLVMBuilderRef; ParentPad: LLVMValueRef;
                       Args: ptr LLVMValueRef; NumArgs: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildCatchPad", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCleanupPad*(B: LLVMBuilderRef; ParentPad: LLVMValueRef;
                         Args: ptr LLVMValueRef; NumArgs: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildCleanupPad", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCatchSwitch*(B: LLVMBuilderRef; ParentPad: LLVMValueRef;
                          UnwindBB: LLVMBasicBlockRef; NumHandlers: cuint;
                          Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildCatchSwitch", dynlib: libLLVM.so.23.1.}
##  Add a case to the switch instruction

proc LLVMAddCase*(Switch: LLVMValueRef; OnVal: LLVMValueRef; Dest: LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMAddCase", dynlib: libLLVM.so.23.1.}
##  Add a destination to the indirectbr instruction

proc LLVMAddDestination*(IndirectBr: LLVMValueRef; Dest: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMAddDestination", dynlib: libLLVM.so.23.1.}
##  Get the number of clauses on the landingpad instruction

proc LLVMGetNumClauses*(LandingPad: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumClauses", dynlib: libLLVM.so.23.1.}
##  Get the value of the clause at index Idx on the landingpad instruction

proc LLVMGetClause*(LandingPad: LLVMValueRef; Idx: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetClause", dynlib: libLLVM.so.23.1.}
##  Add a catch or filter clause to the landingpad instruction

proc LLVMAddClause*(LandingPad: LLVMValueRef; ClauseVal: LLVMValueRef) {.cdecl,
    importc: "LLVMAddClause", dynlib: libLLVM.so.23.1.}
##  Get the 'cleanup' flag in the landingpad instruction

proc LLVMIsCleanup*(LandingPad: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsCleanup", dynlib: libLLVM.so.23.1.}
##  Set the 'cleanup' flag in the landingpad instruction

proc LLVMSetCleanup*(LandingPad: LLVMValueRef; Val: LLVMBool) {.cdecl,
    importc: "LLVMSetCleanup", dynlib: libLLVM.so.23.1.}
##  Add a destination to the catchswitch instruction

proc LLVMAddHandler*(CatchSwitch: LLVMValueRef; Dest: LLVMBasicBlockRef) {.cdecl,
    importc: "LLVMAddHandler", dynlib: libLLVM.so.23.1.}
##  Get the number of handlers on the catchswitch instruction

proc LLVMGetNumHandlers*(CatchSwitch: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumHandlers", dynlib: libLLVM.so.23.1.}
##
##  Obtain the basic blocks acting as handlers for a catchswitch instruction.
##
##  The Handlers parameter should point to a pre-allocated array of
##  LLVMBasicBlockRefs at least LLVMGetNumHandlers() large. On return, the
##  first LLVMGetNumHandlers() entries in the array will be populated
##  with LLVMBasicBlockRef instances.
##
##  @param CatchSwitch The catchswitch instruction to operate on.
##  @param Handlers Memory address of an array to be filled with basic blocks.
##

proc LLVMGetHandlers*(CatchSwitch: LLVMValueRef; Handlers: ptr LLVMBasicBlockRef) {.
    cdecl, importc: "LLVMGetHandlers", dynlib: libLLVM.so.23.1.}
##  Funclets
##  Get the number of funcletpad arguments.

proc LLVMGetArgOperand*(Funclet: LLVMValueRef; i: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMGetArgOperand", dynlib: libLLVM.so.23.1.}
##  Set a funcletpad argument at the given index.

proc LLVMSetArgOperand*(Funclet: LLVMValueRef; i: cuint; value: LLVMValueRef) {.cdecl,
    importc: "LLVMSetArgOperand", dynlib: libLLVM.so.23.1.}
##
##  Get the parent catchswitch instruction of a catchpad instruction.
##
##  This only works on llvm::CatchPadInst instructions.
##
##  @see llvm::CatchPadInst::getCatchSwitch()
##

proc LLVMGetParentCatchSwitch*(CatchPad: LLVMValueRef): LLVMValueRef {.cdecl,
    importc: "LLVMGetParentCatchSwitch", dynlib: libLLVM.so.23.1.}
##
##  Set the parent catchswitch instruction of a catchpad instruction.
##
##  This only works on llvm::CatchPadInst instructions.
##
##  @see llvm::CatchPadInst::setCatchSwitch()
##

proc LLVMSetParentCatchSwitch*(CatchPad: LLVMValueRef; CatchSwitch: LLVMValueRef) {.
    cdecl, importc: "LLVMSetParentCatchSwitch", dynlib: libLLVM.so.23.1.}
##  Arithmetic

proc LLVMBuildAdd*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                  Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildAdd",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildNSWAdd*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildNSWAdd", dynlib: libLLVM.so.23.1.}
proc LLVMBuildNUWAdd*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildNUWAdd", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFAdd*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildFAdd",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildSub*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                  Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildSub",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildNSWSub*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildNSWSub", dynlib: libLLVM.so.23.1.}
proc LLVMBuildNUWSub*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildNUWSub", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFSub*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildFSub",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildMul*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                  Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildMul",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildNSWMul*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildNSWMul", dynlib: libLLVM.so.23.1.}
proc LLVMBuildNUWMul*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildNUWMul", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFMul*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildFMul",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildUDiv*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildUDiv",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildExactUDiv*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                        Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildExactUDiv", dynlib: libLLVM.so.23.1.}
proc LLVMBuildSDiv*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildSDiv",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildExactSDiv*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                        Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildExactSDiv", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFDiv*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildFDiv",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildURem*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildURem",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildSRem*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildSRem",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildFRem*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildFRem",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildShl*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                  Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildShl",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildLShr*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildLShr",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildAShr*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildAShr",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildAnd*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                  Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildAnd",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildOr*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                 Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildOr",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildXor*(a1: LLVMBuilderRef; LHS: LLVMValueRef; RHS: LLVMValueRef;
                  Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildXor",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildBinOp*(B: LLVMBuilderRef; Op: LLVMOpcode; LHS: LLVMValueRef;
                    RHS: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildBinOp", dynlib: libLLVM.so.23.1.}
proc LLVMBuildNeg*(a1: LLVMBuilderRef; V: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildNeg", dynlib: libLLVM.so.23.1.}
proc LLVMBuildNSWNeg*(B: LLVMBuilderRef; V: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildNSWNeg", dynlib: libLLVM.so.23.1.}
LLVM_ATTRIBUTE_C_DEPRECATED(LLVMValueRef, LLVMBuildNUWNeg(LLVMBuilderRef, B,
    LLVMValueRef, V, `const`, char * Name), "Use LLVMBuildNeg + LLVMSetNUW instead.")
proc LLVMBuildFNeg*(a1: LLVMBuilderRef; V: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildFNeg", dynlib: libLLVM.so.23.1.}
proc LLVMBuildNot*(a1: LLVMBuilderRef; V: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildNot", dynlib: libLLVM.so.23.1.}
proc LLVMGetNUW*(ArithInst: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMGetNUW",
    dynlib: libLLVM.so.23.1.}
proc LLVMSetNUW*(ArithInst: LLVMValueRef; HasNUW: LLVMBool) {.cdecl,
    importc: "LLVMSetNUW", dynlib: libLLVM.so.23.1.}
proc LLVMGetNSW*(ArithInst: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMGetNSW",
    dynlib: libLLVM.so.23.1.}
proc LLVMSetNSW*(ArithInst: LLVMValueRef; HasNSW: LLVMBool) {.cdecl,
    importc: "LLVMSetNSW", dynlib: libLLVM.so.23.1.}
proc LLVMGetExact*(DivOrShrInst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetExact", dynlib: libLLVM.so.23.1.}
proc LLVMSetExact*(DivOrShrInst: LLVMValueRef; IsExact: LLVMBool) {.cdecl,
    importc: "LLVMSetExact", dynlib: libLLVM.so.23.1.}
##
##  Gets if the instruction has the non-negative flag set.
##  Only valid for zext instructions.
##

proc LLVMGetNNeg*(NonNegInst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetNNeg", dynlib: libLLVM.so.23.1.}
##
##  Sets the non-negative flag for the instruction.
##  Only valid for zext instructions.
##

proc LLVMSetNNeg*(NonNegInst: LLVMValueRef; IsNonNeg: LLVMBool) {.cdecl,
    importc: "LLVMSetNNeg", dynlib: libLLVM.so.23.1.}
##
##  Get the flags for which fast-math-style optimizations are allowed for this
##  value.
##
##  Only valid on floating point instructions.
##  @see LLVMCanValueUseFastMathFlags
##

proc LLVMGetFastMathFlags*(FPMathInst: LLVMValueRef): LLVMFastMathFlags {.cdecl,
    importc: "LLVMGetFastMathFlags", dynlib: libLLVM.so.23.1.}
##
##  Sets the flags for which fast-math-style optimizations are allowed for this
##  value.
##
##  Only valid on floating point instructions.
##  @see LLVMCanValueUseFastMathFlags
##

proc LLVMSetFastMathFlags*(FPMathInst: LLVMValueRef; FMF: LLVMFastMathFlags) {.cdecl,
    importc: "LLVMSetFastMathFlags", dynlib: libLLVM.so.23.1.}
##
##  Check if a given value can potentially have fast math flags.
##
##  Will return true for floating point arithmetic instructions, and for select,
##  phi, and call instructions whose type is a floating point type, or a vector
##  or array thereof. See https://llvm.org/docs/LangRef.html#fast-math-flags
##

proc LLVMCanValueUseFastMathFlags*(Inst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMCanValueUseFastMathFlags", dynlib: libLLVM.so.23.1.}
##
##  Gets whether the instruction has the disjoint flag set.
##  Only valid for or instructions.
##

proc LLVMGetIsDisjoint*(Inst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetIsDisjoint", dynlib: libLLVM.so.23.1.}
##
##  Sets the disjoint flag for the instruction.
##  Only valid for or instructions.
##

proc LLVMSetIsDisjoint*(Inst: LLVMValueRef; IsDisjoint: LLVMBool) {.cdecl,
    importc: "LLVMSetIsDisjoint", dynlib: libLLVM.so.23.1.}
##  Memory

proc LLVMBuildMalloc*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildMalloc", dynlib: libLLVM.so.23.1.}
proc LLVMBuildArrayMalloc*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; Val: LLVMValueRef;
                          Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildArrayMalloc", dynlib: libLLVM.so.23.1.}
##
##  Creates and inserts a memset to the specified pointer and the
##  specified value.
##
##  @see llvm::IRRBuilder::CreateMemSet()
##

proc LLVMBuildMemSet*(B: LLVMBuilderRef; Ptr: LLVMValueRef; Val: LLVMValueRef;
                     Len: LLVMValueRef; Align: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMBuildMemSet", dynlib: libLLVM.so.23.1.}
##
##  Creates and inserts a memcpy between the specified pointers.
##
##  @see llvm::IRRBuilder::CreateMemCpy()
##

proc LLVMBuildMemCpy*(B: LLVMBuilderRef; Dst: LLVMValueRef; DstAlign: cuint;
                     Src: LLVMValueRef; SrcAlign: cuint; Size: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMBuildMemCpy", dynlib: libLLVM.so.23.1.}
##
##  Creates and inserts a memmove between the specified pointers.
##
##  @see llvm::IRRBuilder::CreateMemMove()
##

proc LLVMBuildMemMove*(B: LLVMBuilderRef; Dst: LLVMValueRef; DstAlign: cuint;
                      Src: LLVMValueRef; SrcAlign: cuint; Size: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMBuildMemMove", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAlloca*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildAlloca", dynlib: libLLVM.so.23.1.}
proc LLVMBuildArrayAlloca*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; Val: LLVMValueRef;
                          Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildArrayAlloca", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFree*(a1: LLVMBuilderRef; PointerVal: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMBuildFree", dynlib: libLLVM.so.23.1.}
proc LLVMBuildLoad2*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; PointerVal: LLVMValueRef;
                    Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildLoad2",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildStore*(a1: LLVMBuilderRef; Val: LLVMValueRef; Ptr: LLVMValueRef): LLVMValueRef {.
    cdecl, importc: "LLVMBuildStore", dynlib: libLLVM.so.23.1.}
proc LLVMBuildGEP2*(B: LLVMBuilderRef; Ty: LLVMTypeRef; Pointer: LLVMValueRef;
                   Indices: ptr LLVMValueRef; NumIndices: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildGEP2", dynlib: libLLVM.so.23.1.}
proc LLVMBuildInBoundsGEP2*(B: LLVMBuilderRef; Ty: LLVMTypeRef;
                           Pointer: LLVMValueRef; Indices: ptr LLVMValueRef;
                           NumIndices: cuint; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildInBoundsGEP2", dynlib: libLLVM.so.23.1.}
##
##  Creates a GetElementPtr instruction. Similar to LLVMBuildGEP2, but allows
##  specifying the no-wrap flags.
##
##  @see llvm::IRBuilder::CreateGEP()
##

proc LLVMBuildGEPWithNoWrapFlags*(B: LLVMBuilderRef; Ty: LLVMTypeRef;
                                 Pointer: LLVMValueRef; Indices: ptr LLVMValueRef;
                                 NumIndices: cuint; Name: cstring;
                                 NoWrapFlags: LLVMGEPNoWrapFlags): LLVMValueRef {.
    cdecl, importc: "LLVMBuildGEPWithNoWrapFlags", dynlib: libLLVM.so.23.1.}
proc LLVMBuildStructGEP2*(B: LLVMBuilderRef; Ty: LLVMTypeRef; Pointer: LLVMValueRef;
                         Idx: cuint; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildStructGEP2", dynlib: libLLVM.so.23.1.}
proc LLVMBuildGlobalString*(B: LLVMBuilderRef; Str: cstring; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildGlobalString", dynlib: libLLVM.so.23.1.}
##
##  Deprecated: Use LLVMBuildGlobalString instead, which has identical behavior.
##

proc LLVMBuildGlobalStringPtr*(B: LLVMBuilderRef; Str: cstring; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildGlobalStringPtr", dynlib: libLLVM.so.23.1.}
proc LLVMGetVolatile*(Inst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetVolatile", dynlib: libLLVM.so.23.1.}
proc LLVMSetVolatile*(MemoryAccessInst: LLVMValueRef; IsVolatile: LLVMBool) {.cdecl,
    importc: "LLVMSetVolatile", dynlib: libLLVM.so.23.1.}
proc LLVMGetWeak*(CmpXchgInst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMGetWeak", dynlib: libLLVM.so.23.1.}
proc LLVMSetWeak*(CmpXchgInst: LLVMValueRef; IsWeak: LLVMBool) {.cdecl,
    importc: "LLVMSetWeak", dynlib: libLLVM.so.23.1.}
proc LLVMGetOrdering*(MemoryAccessInst: LLVMValueRef): LLVMAtomicOrdering {.cdecl,
    importc: "LLVMGetOrdering", dynlib: libLLVM.so.23.1.}
proc LLVMSetOrdering*(MemoryAccessInst: LLVMValueRef; Ordering: LLVMAtomicOrdering) {.
    cdecl, importc: "LLVMSetOrdering", dynlib: libLLVM.so.23.1.}
proc LLVMGetAtomicRMWBinOp*(AtomicRMWInst: LLVMValueRef): LLVMAtomicRMWBinOp {.
    cdecl, importc: "LLVMGetAtomicRMWBinOp", dynlib: libLLVM.so.23.1.}
proc LLVMSetAtomicRMWBinOp*(AtomicRMWInst: LLVMValueRef; BinOp: LLVMAtomicRMWBinOp) {.
    cdecl, importc: "LLVMSetAtomicRMWBinOp", dynlib: libLLVM.so.23.1.}
##  Casts

proc LLVMBuildTrunc*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                    Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildTrunc",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildZExt*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildZExt",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildSExt*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                   Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildSExt",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildFPToUI*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFPToUI", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFPToSI*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFPToSI", dynlib: libLLVM.so.23.1.}
proc LLVMBuildUIToFP*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildUIToFP", dynlib: libLLVM.so.23.1.}
proc LLVMBuildSIToFP*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildSIToFP", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFPTrunc*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                      Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFPTrunc", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFPExt*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                    Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildFPExt",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildPtrToInt*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                       Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildPtrToInt", dynlib: libLLVM.so.23.1.}
proc LLVMBuildIntToPtr*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                       Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildIntToPtr", dynlib: libLLVM.so.23.1.}
proc LLVMBuildBitCast*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                      Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildBitCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAddrSpaceCast*(a1: LLVMBuilderRef; Val: LLVMValueRef;
                            DestTy: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildAddrSpaceCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildZExtOrBitCast*(a1: LLVMBuilderRef; Val: LLVMValueRef;
                            DestTy: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildZExtOrBitCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildSExtOrBitCast*(a1: LLVMBuilderRef; Val: LLVMValueRef;
                            DestTy: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildSExtOrBitCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildTruncOrBitCast*(a1: LLVMBuilderRef; Val: LLVMValueRef;
                             DestTy: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildTruncOrBitCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCast*(B: LLVMBuilderRef; Op: LLVMOpcode; Val: LLVMValueRef;
                   DestTy: LLVMTypeRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildPointerCast*(a1: LLVMBuilderRef; Val: LLVMValueRef;
                          DestTy: LLVMTypeRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildPointerCast", dynlib: libLLVM.so.23.1.}
proc LLVMBuildIntCast2*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                       IsSigned: LLVMBool; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildIntCast2", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFPCast*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                     Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFPCast", dynlib: libLLVM.so.23.1.}
##  Deprecated: This cast is always signed. Use LLVMBuildIntCast2 instead.

proc LLVMBuildIntCast*(a1: LLVMBuilderRef; Val: LLVMValueRef; DestTy: LLVMTypeRef;
                      Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildIntCast", dynlib: libLLVM.so.23.1.}
  ## Signed cast!
proc LLVMGetCastOpcode*(Src: LLVMValueRef; SrcIsSigned: LLVMBool;
                       DestTy: LLVMTypeRef; DestIsSigned: LLVMBool): LLVMOpcode {.
    cdecl, importc: "LLVMGetCastOpcode", dynlib: libLLVM.so.23.1.}
##  Comparisons

proc LLVMBuildICmp*(a1: LLVMBuilderRef; Op: LLVMIntPredicate; LHS: LLVMValueRef;
                   RHS: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildICmp", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFCmp*(a1: LLVMBuilderRef; Op: LLVMRealPredicate; LHS: LLVMValueRef;
                   RHS: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFCmp", dynlib: libLLVM.so.23.1.}
##  Miscellaneous instructions

proc LLVMBuildPhi*(a1: LLVMBuilderRef; Ty: LLVMTypeRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildPhi", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCall2*(a1: LLVMBuilderRef; a2: LLVMTypeRef; Fn: LLVMValueRef;
                    Args: ptr LLVMValueRef; NumArgs: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildCall2", dynlib: libLLVM.so.23.1.}
proc LLVMBuildCallWithOperandBundles*(a1: LLVMBuilderRef; a2: LLVMTypeRef;
                                     Fn: LLVMValueRef; Args: ptr LLVMValueRef;
                                     NumArgs: cuint;
                                     Bundles: ptr LLVMOperandBundleRef;
                                     NumBundles: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildCallWithOperandBundles", dynlib: libLLVM.so.23.1.}
proc LLVMBuildSelect*(a1: LLVMBuilderRef; If: LLVMValueRef; Then: LLVMValueRef;
                     Else: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildSelect", dynlib: libLLVM.so.23.1.}
proc LLVMBuildVAArg*(a1: LLVMBuilderRef; List: LLVMValueRef; Ty: LLVMTypeRef;
                    Name: cstring): LLVMValueRef {.cdecl, importc: "LLVMBuildVAArg",
    dynlib: libLLVM.so.23.1.}
proc LLVMBuildExtractElement*(a1: LLVMBuilderRef; VecVal: LLVMValueRef;
                             Index: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildExtractElement", dynlib: libLLVM.so.23.1.}
proc LLVMBuildInsertElement*(a1: LLVMBuilderRef; VecVal: LLVMValueRef;
                            EltVal: LLVMValueRef; Index: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildInsertElement", dynlib: libLLVM.so.23.1.}
proc LLVMBuildShuffleVector*(a1: LLVMBuilderRef; V1: LLVMValueRef; V2: LLVMValueRef;
                            Mask: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildShuffleVector", dynlib: libLLVM.so.23.1.}
proc LLVMBuildExtractValue*(a1: LLVMBuilderRef; AggVal: LLVMValueRef; Index: cuint;
                           Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildExtractValue", dynlib: libLLVM.so.23.1.}
proc LLVMBuildInsertValue*(a1: LLVMBuilderRef; AggVal: LLVMValueRef;
                          EltVal: LLVMValueRef; Index: cuint; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildInsertValue", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFreeze*(a1: LLVMBuilderRef; Val: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildFreeze", dynlib: libLLVM.so.23.1.}
proc LLVMBuildIsNull*(a1: LLVMBuilderRef; Val: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildIsNull", dynlib: libLLVM.so.23.1.}
proc LLVMBuildIsNotNull*(a1: LLVMBuilderRef; Val: LLVMValueRef; Name: cstring): LLVMValueRef {.
    cdecl, importc: "LLVMBuildIsNotNull", dynlib: libLLVM.so.23.1.}
proc LLVMBuildPtrDiff2*(a1: LLVMBuilderRef; ElemTy: LLVMTypeRef; LHS: LLVMValueRef;
                       RHS: LLVMValueRef; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildPtrDiff2", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFence*(B: LLVMBuilderRef; ordering: LLVMAtomicOrdering;
                    singleThread: LLVMBool; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFence", dynlib: libLLVM.so.23.1.}
proc LLVMBuildFenceSyncScope*(B: LLVMBuilderRef; ordering: LLVMAtomicOrdering;
                             SSID: cuint; Name: cstring): LLVMValueRef {.cdecl,
    importc: "LLVMBuildFenceSyncScope", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAtomicRMW*(B: LLVMBuilderRef; op: LLVMAtomicRMWBinOp;
                        PTR: LLVMValueRef; Val: LLVMValueRef;
                        ordering: LLVMAtomicOrdering; singleThread: LLVMBool): LLVMValueRef {.
    cdecl, importc: "LLVMBuildAtomicRMW", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAtomicRMWSyncScope*(B: LLVMBuilderRef; op: LLVMAtomicRMWBinOp;
                                 PTR: LLVMValueRef; Val: LLVMValueRef;
                                 ordering: LLVMAtomicOrdering; SSID: cuint): LLVMValueRef {.
    cdecl, importc: "LLVMBuildAtomicRMWSyncScope", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAtomicCmpXchg*(B: LLVMBuilderRef; Ptr: LLVMValueRef; Cmp: LLVMValueRef;
                            New: LLVMValueRef;
                            SuccessOrdering: LLVMAtomicOrdering;
                            FailureOrdering: LLVMAtomicOrdering;
                            SingleThread: LLVMBool): LLVMValueRef {.cdecl,
    importc: "LLVMBuildAtomicCmpXchg", dynlib: libLLVM.so.23.1.}
proc LLVMBuildAtomicCmpXchgSyncScope*(B: LLVMBuilderRef; Ptr: LLVMValueRef;
                                     Cmp: LLVMValueRef; New: LLVMValueRef;
                                     SuccessOrdering: LLVMAtomicOrdering;
                                     FailureOrdering: LLVMAtomicOrdering;
                                     SSID: cuint): LLVMValueRef {.cdecl,
    importc: "LLVMBuildAtomicCmpXchgSyncScope", dynlib: libLLVM.so.23.1.}
##
##  Get the number of elements in the mask of a ShuffleVector instruction.
##

proc LLVMGetNumMaskElements*(ShuffleVectorInst: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetNumMaskElements", dynlib: libLLVM.so.23.1.}
##
##  \returns a constant that specifies that the result of a \c ShuffleVectorInst
##  is undefined.
##

proc LLVMGetUndefMaskElem*(): cint {.cdecl, importc: "LLVMGetUndefMaskElem",
                                  dynlib: libLLVM.so.23.1.}
##
##  Get the mask value at position Elt in the mask of a ShuffleVector
##  instruction.
##
##  \Returns the result of \c LLVMGetUndefMaskElem() if the mask value is
##  poison at that position.
##

proc LLVMGetMaskValue*(ShuffleVectorInst: LLVMValueRef; Elt: cuint): cint {.cdecl,
    importc: "LLVMGetMaskValue", dynlib: libLLVM.so.23.1.}
proc LLVMIsAtomicSingleThread*(AtomicInst: LLVMValueRef): LLVMBool {.cdecl,
    importc: "LLVMIsAtomicSingleThread", dynlib: libLLVM.so.23.1.}
proc LLVMSetAtomicSingleThread*(AtomicInst: LLVMValueRef; SingleThread: LLVMBool) {.
    cdecl, importc: "LLVMSetAtomicSingleThread", dynlib: libLLVM.so.23.1.}
##
##  Returns whether an instruction is an atomic instruction, e.g., atomicrmw,
##  cmpxchg, fence, or loads and stores with atomic ordering.
##

proc LLVMIsAtomic*(Inst: LLVMValueRef): LLVMBool {.cdecl, importc: "LLVMIsAtomic",
    dynlib: libLLVM.so.23.1.}
##
##  Returns the synchronization scope ID of an atomic instruction.
##

proc LLVMGetAtomicSyncScopeID*(AtomicInst: LLVMValueRef): cuint {.cdecl,
    importc: "LLVMGetAtomicSyncScopeID", dynlib: libLLVM.so.23.1.}
##
##  Sets the synchronization scope ID of an atomic instruction.
##

proc LLVMSetAtomicSyncScopeID*(AtomicInst: LLVMValueRef; SSID: cuint) {.cdecl,
    importc: "LLVMSetAtomicSyncScopeID", dynlib: libLLVM.so.23.1.}
proc LLVMGetCmpXchgSuccessOrdering*(CmpXchgInst: LLVMValueRef): LLVMAtomicOrdering {.
    cdecl, importc: "LLVMGetCmpXchgSuccessOrdering", dynlib: libLLVM.so.23.1.}
proc LLVMSetCmpXchgSuccessOrdering*(CmpXchgInst: LLVMValueRef;
                                   Ordering: LLVMAtomicOrdering) {.cdecl,
    importc: "LLVMSetCmpXchgSuccessOrdering", dynlib: libLLVM.so.23.1.}
proc LLVMGetCmpXchgFailureOrdering*(CmpXchgInst: LLVMValueRef): LLVMAtomicOrdering {.
    cdecl, importc: "LLVMGetCmpXchgFailureOrdering", dynlib: libLLVM.so.23.1.}
proc LLVMSetCmpXchgFailureOrdering*(CmpXchgInst: LLVMValueRef;
                                   Ordering: LLVMAtomicOrdering) {.cdecl,
    importc: "LLVMSetCmpXchgFailureOrdering", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreModuleProvider Module Providers
##
##  @{
##
##
##  Changes the type of M so it can be passed to FunctionPassManagers and the
##  JIT.  They take ModuleProviders for historical reasons.
##

proc LLVMCreateModuleProviderForExistingModule*(M: LLVMModuleRef): LLVMModuleProviderRef {.
    cdecl, importc: "LLVMCreateModuleProviderForExistingModule",
    dynlib: libLLVM.so.23.1.}
##
##  Destroys the module M.
##

proc LLVMDisposeModuleProvider*(M: LLVMModuleProviderRef) {.cdecl,
    importc: "LLVMDisposeModuleProvider", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreMemoryBuffers Memory Buffers
##
##  @{
##

proc LLVMCreateMemoryBufferWithContentsOfFile*(Path: cstring;
    OutMemBuf: ptr LLVMMemoryBufferRef; OutMessage: cstringArray): LLVMBool {.cdecl,
    importc: "LLVMCreateMemoryBufferWithContentsOfFile", dynlib: libLLVM.so.23.1.}
proc LLVMCreateMemoryBufferWithSTDIN*(OutMemBuf: ptr LLVMMemoryBufferRef;
                                     OutMessage: cstringArray): LLVMBool {.cdecl,
    importc: "LLVMCreateMemoryBufferWithSTDIN", dynlib: libLLVM.so.23.1.}
proc LLVMCreateMemoryBufferWithMemoryRange*(InputData: cstring;
    InputDataLength: csize_t; BufferName: cstring; RequiresNullTerminator: LLVMBool): LLVMMemoryBufferRef {.
    cdecl, importc: "LLVMCreateMemoryBufferWithMemoryRange",
    dynlib: libLLVM.so.23.1.}
proc LLVMCreateMemoryBufferWithMemoryRangeCopy*(InputData: cstring;
    InputDataLength: csize_t; BufferName: cstring): LLVMMemoryBufferRef {.cdecl,
    importc: "LLVMCreateMemoryBufferWithMemoryRangeCopy", dynlib: libLLVM.so.23.1.}
proc LLVMGetBufferStart*(MemBuf: LLVMMemoryBufferRef): cstring {.cdecl,
    importc: "LLVMGetBufferStart", dynlib: libLLVM.so.23.1.}
proc LLVMGetBufferSize*(MemBuf: LLVMMemoryBufferRef): csize_t {.cdecl,
    importc: "LLVMGetBufferSize", dynlib: libLLVM.so.23.1.}
proc LLVMDisposeMemoryBuffer*(MemBuf: LLVMMemoryBufferRef) {.cdecl,
    importc: "LLVMDisposeMemoryBuffer", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCorePassManagers Pass Managers
##  @ingroup LLVMCCore
##
##  @{
##
##  Constructs a new whole-module pass pipeline. This type of pipeline is
##     suitable for link-time optimization and whole-module transformations.
##     @see llvm::PassManager::PassManager

proc LLVMCreatePassManager*(): LLVMPassManagerRef {.cdecl,
    importc: "LLVMCreatePassManager", dynlib: libLLVM.so.23.1.}
##  Constructs a new function-by-function pass pipeline over the module
##     provider. It does not take ownership of the module provider. This type of
##     pipeline is suitable for code generation and JIT compilation tasks.
##     @see llvm::FunctionPassManager::FunctionPassManager

proc LLVMCreateFunctionPassManagerForModule*(M: LLVMModuleRef): LLVMPassManagerRef {.
    cdecl, importc: "LLVMCreateFunctionPassManagerForModule",
    dynlib: libLLVM.so.23.1.}
##  Deprecated: Use LLVMCreateFunctionPassManagerForModule instead.

proc LLVMCreateFunctionPassManager*(MP: LLVMModuleProviderRef): LLVMPassManagerRef {.
    cdecl, importc: "LLVMCreateFunctionPassManager", dynlib: libLLVM.so.23.1.}
##  Initializes, executes on the provided module, and finalizes all of the
##     passes scheduled in the pass manager. Returns 1 if any of the passes
##     modified the module, 0 otherwise.
##     @see llvm::PassManager::run(Module&)

proc LLVMRunPassManager*(PM: LLVMPassManagerRef; M: LLVMModuleRef): LLVMBool {.cdecl,
    importc: "LLVMRunPassManager", dynlib: libLLVM.so.23.1.}
##  Initializes all of the function passes scheduled in the function pass
##     manager. Returns 1 if any of the passes modified the module, 0 otherwise.
##     @see llvm::FunctionPassManager::doInitialization

proc LLVMInitializeFunctionPassManager*(FPM: LLVMPassManagerRef): LLVMBool {.cdecl,
    importc: "LLVMInitializeFunctionPassManager", dynlib: libLLVM.so.23.1.}
##  Executes all of the function passes scheduled in the function pass manager
##     on the provided function. Returns 1 if any of the passes modified the
##     function, false otherwise.
##     @see llvm::FunctionPassManager::run(Function&)

proc LLVMRunFunctionPassManager*(FPM: LLVMPassManagerRef; F: LLVMValueRef): LLVMBool {.
    cdecl, importc: "LLVMRunFunctionPassManager", dynlib: libLLVM.so.23.1.}
##  Finalizes all of the function passes scheduled in the function pass
##     manager. Returns 1 if any of the passes modified the module, 0 otherwise.
##     @see llvm::FunctionPassManager::doFinalization

proc LLVMFinalizeFunctionPassManager*(FPM: LLVMPassManagerRef): LLVMBool {.cdecl,
    importc: "LLVMFinalizeFunctionPassManager", dynlib: libLLVM.so.23.1.}
##  Frees the memory of a pass pipeline. For function pipelines, does not free
##     the module provider.
##     @see llvm::PassManagerBase::~PassManagerBase.

proc LLVMDisposePassManager*(PM: LLVMPassManagerRef) {.cdecl,
    importc: "LLVMDisposePassManager", dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @defgroup LLVMCCoreThreading Threading
##
##  Handle the structures needed to make LLVM safe for multithreading.
##
##  @{
##
##  Deprecated: Multi-threading can only be enabled/disabled with the compile
##     time define LLVM_ENABLE_THREADS.  This function always returns
##     LLVMIsMultithreaded().

proc LLVMStartMultithreaded*(): LLVMBool {.cdecl, importc: "LLVMStartMultithreaded",
                                        dynlib: libLLVM.so.23.1.}
##  Deprecated: Multi-threading can only be enabled/disabled with the compile
##     time define LLVM_ENABLE_THREADS.

proc LLVMStopMultithreaded*() {.cdecl, importc: "LLVMStopMultithreaded",
                              dynlib: libLLVM.so.23.1.}
##  Check whether LLVM is executing in thread-safe mode or not.
##     @see llvm::llvm_is_multithreaded

proc LLVMIsMultithreaded*(): LLVMBool {.cdecl, importc: "LLVMIsMultithreaded",
                                     dynlib: libLLVM.so.23.1.}
##
##  @}
##
##
##  @}
##
##
##  @}
##
