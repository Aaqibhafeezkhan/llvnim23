# Copyright (c) 2026 https://github.com/xlebore3o4ka

import std/os
import ../src/llvnim

proc main() =
  checkVersion()

  discard LLVMInitializeNativeTarget()
  discard LLVMInitializeNativeAsmPrinter()

  let ctx = LLVMContextCreate()
  defer: LLVMContextDispose(ctx)

  let m = LLVMModuleCreateWithNameInContext("di_example", ctx)
  defer: LLVMDisposeModule(m)

  let i64t = LLVMInt64TypeInContext(ctx)
  var params = [i64t]
  let fnTy = LLVMFunctionType(i64t, addr params[0], 1, LLVMFalse)
  let fn = LLVMAddFunction(m, "square", fnTy)
  
  let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
  let b = LLVMCreateBuilderInContext(ctx)
  defer: LLVMDisposeBuilder(b)
  LLVMPositionBuilderAtEnd(b, bb)

  let diBuilder = LLVMCreateDIBuilder(m)
  defer: LLVMDisposeDIBuilder(diBuilder)

  let file = LLVMDIBuilderCreateFile(diBuilder, "example.nim", csize_t(11), ".", csize_t(1))
  let cu = LLVMDIBuilderCreateCompileUnit(diBuilder, LLVMDWARFSourceLanguageC, file, "llvnim", csize_t(8), LLVMFalse, "", csize_t(0), 0, "", csize_t(0), LLVMDWARFEmissionFull, 0, LLVMFalse, LLVMFalse, "", csize_t(0), "", csize_t(0))
  
  let intTy = LLVMDIBuilderCreateBasicType(diBuilder, "long", csize_t(4), 64, 0x05, 0)
  var paramTypes = [intTy]
  let subTy = LLVMDIBuilderCreateSubroutineType(diBuilder, file, addr paramTypes[0], 1, 0)
  
  let sp = LLVMDIBuilderCreateFunction(diBuilder, cu, "square", csize_t(6), "square", csize_t(6), file, 1, subTy, LLVMFalse, LLVMTrue, 1, 0, LLVMFalse)
  LLVMSetSubprogram(fn, sp)

  let varX = LLVMDIBuilderCreateParameterVariable(diBuilder, sp, "x", csize_t(1), 1, file, 1, intTy, LLVMTrue, 0)
  let emptyExpr = LLVMDIBuilderCreateExpression(diBuilder, nil, csize_t(0))
  let loc = LLVMDIBuilderCreateDebugLocation(ctx, 1, 1, sp, LLVMMetadataRef(nil))

  discard LLVMDIBuilderInsertDeclareRecordAtEnd(diBuilder, LLVMGetParam(fn, 0), varX, emptyExpr, loc, bb)

  let x = LLVMGetParam(fn, 0)
  let res = LLVMBuildMul(b, x, x, "res")
  discard LLVMBuildRet(b, res)
  
  LLVMDIBuilderFinalize(diBuilder)

  let (ok, msg) = verifyModule(m)
  doAssert ok, msg

  let irText = LLVMPrintModuleToString(m)
  echo "Generated IR with Debug Info:\n"
  echo irText
  LLVMDisposeMessage(irText)

  let tripleC = LLVMGetDefaultTargetTriple()
  let triple = $tripleC
  LLVMDisposeMessage(tripleC)
  LLVMSetTarget(m, triple.cstring)

  var target: LLVMTargetRef
  var errMsg: cstring
  if LLVMGetTargetFromTriple(triple.cstring, target, errMsg) != LLVMFalse:
    echo "Failed to get target"
    quit(1)

  let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault)
  defer: LLVMDisposeTargetMachine(tm)

  let objFile = "/tmp/llvnim_di_example.o"
  var emitErr: cstring
  if LLVMTargetMachineEmitToFile(tm, m, objFile.cstring, LLVMObjectFile, emitErr) == LLVMFalse:
    echo "Successfully compiled with debug info to: ", objFile
    removeFile(objFile)
  else:
    echo "Failed to emit object file"

when isMainModule:
  main()