import ../../llvnim

proc i1*(ctx: LLVMContextRef): LLVMTypeRef = LLVMInt1TypeInContext(ctx)
proc i8*(ctx: LLVMContextRef): LLVMTypeRef = LLVMInt8TypeInContext(ctx)
proc i16*(ctx: LLVMContextRef): LLVMTypeRef = LLVMInt16TypeInContext(ctx)
proc i32*(ctx: LLVMContextRef): LLVMTypeRef = LLVMInt32TypeInContext(ctx)
proc i64*(ctx: LLVMContextRef): LLVMTypeRef = LLVMInt64TypeInContext(ctx)
proc i128*(ctx: LLVMContextRef): LLVMTypeRef = LLVMInt128TypeInContext(ctx)

proc f32*(ctx: LLVMContextRef): LLVMTypeRef = LLVMFloatTypeInContext(ctx)
proc f64*(ctx: LLVMContextRef): LLVMTypeRef = LLVMDoubleTypeInContext(ctx)
proc voidTy*(ctx: LLVMContextRef): LLVMTypeRef = LLVMVoidTypeInContext(ctx)

proc ptrTy*(ctx: LLVMContextRef; addressSpace: cuint = 0): LLVMTypeRef =
  LLVMPointerTypeInContext(ctx, addressSpace)

proc array*(ctx: LLVMContextRef; elemTy: LLVMTypeRef; count: uint64): LLVMTypeRef =
  ## Creates an array type.
  LLVMArrayType2(elemTy, count)

proc vector*(ctx: LLVMContextRef; elemTy: LLVMTypeRef; count: cuint): LLVMTypeRef =
  ## Creates a fixed-width vector type.
  LLVMVectorType(elemTy, count)

proc struct*(ctx: LLVMContextRef; elems: openArray[LLVMTypeRef]; packed: bool = false): LLVMTypeRef =
  ## Creates a literal struct type from a Nim openArray.
  let packedBool = if packed: LLVMTrue else: LLVMFalse
  let elemsPtr = if elems.len > 0: cast[ptr LLVMTypeRef](unsafeAddr elems[0]) else: nil
  LLVMStructTypeInContext(ctx, elemsPtr, cuint(elems.len), packedBool)

proc constInt*(ty: LLVMTypeRef; val: SomeInteger; signExtend: bool = true): LLVMValueRef =
  ## Creates an integer constant. Safely handles negative values without manual casts.
  let ext = if signExtend: LLVMTrue else: LLVMFalse
  LLVMConstInt(ty, cast[culonglong](val), ext)