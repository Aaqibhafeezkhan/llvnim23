import ../../llvnim

proc stringConstant*(ctx: LLVMContextRef; s: string): LLVMValueRef =
  ## Creates a null-terminated constant [N x i8] array for the string.
  LLVMConstStringInContext2(ctx, s.cstring, csize_t(s.len), LLVMFalse)

proc stringGlobal*(m: LLVMModuleRef; ctx: LLVMContextRef; s: string; name: string = ".str"): LLVMValueRef =
  ## Creates a private unnamed_addr global string constant.
  let constArr = stringConstant(ctx, s)
  let arrTy = LLVMTypeOf(constArr)
  result = LLVMAddGlobal(m, arrTy, name.cstring)
  LLVMSetInitializer(result, constArr)
  LLVMSetGlobalConstant(result, LLVMTrue)
  LLVMSetLinkage(result, LLVMPrivateLinkage)
  LLVMSetUnnamedAddress(result, LLVMGlobalUnnamedAddr)