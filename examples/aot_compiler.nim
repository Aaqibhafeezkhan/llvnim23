import std/os
import ../src/llvnim23

proc main() =
  checkVersion()

  discard LLVMInitializeNativeTarget()
  discard LLVMInitializeNativeAsmPrinter()

  when hostCPU == "amd64" or hostCPU == "i386":
    LLVMInitializeX86Disassembler()
  elif hostCPU == "arm64":
    LLVMInitializeAArch64Disassembler()

  let ctx = LLVMContextCreate()
  defer: LLVMContextDispose(ctx)

  let m = LLVMModuleCreateWithNameInContext("aot", ctx)
  defer: LLVMDisposeModule(m)

  # Build a simple multiplication function: int64 mul64(int64 a, int64 b)
  let i64t = LLVMInt64TypeInContext(ctx)
  var params = [i64t, i64t]
  let fnTy = LLVMFunctionType(i64t, addr params[0], 2, LLVMFalse)
  let fn = LLVMAddFunction(m, "mul64", fnTy)

  let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
  let b = LLVMCreateBuilderInContext(ctx)
  defer: LLVMDisposeBuilder(b)
  LLVMPositionBuilderAtEnd(b, bb)
  let res = LLVMBuildMul(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "res")
  discard LLVMBuildRet(b, res)

  # Set target
  let tripleC = LLVMGetDefaultTargetTriple()
  let triple = $tripleC
  LLVMDisposeMessage(tripleC)
  LLVMSetTarget(m, triple.cstring)

  var target: LLVMTargetRef
  var errMsg: cstring
  if LLVMGetTargetFromTriple(triple.cstring, target, errMsg) != LLVMFalse:
    echo "Failed to get target: ", errMsg
    quit(1)

  let tm = LLVMCreateTargetMachine(target, triple.cstring, "generic", "", LLVMCodeGenLevelDefault, LLVMRelocDefault, LLVMCodeModelDefault)
  defer: LLVMDisposeTargetMachine(tm)

  # Emit to object file
  let objFile = "/tmp/llvnim23_aot_example.o"
  var emitErr: cstring
  if LLVMTargetMachineEmitToFile(tm, m, objFile.cstring, LLVMObjectFile, emitErr) != LLVMFalse:
    echo "Failed to emit object file: ", emitErr
    if not emitErr.isNil: LLVMDisposeMessage(emitErr)
    quit(1)

  echo "Successfully compiled to: ", objFile

  # Inspect the object file
  let (br, loadErr) = loadObjectFile(ctx, objFile)
  if loadErr.len > 0:
    echo "Failed to load object file: ", loadErr
    quit(1)
  defer: LLVMDisposeBinary(br)

  echo "\nSections:"
  var textPtr: cstring = nil
  var textSize: uint64 = 0
  var secIt = LLVMObjectFileCopySectionIterator(br)
  defer: LLVMDisposeSectionIterator(secIt)
  while LLVMObjectFileIsSectionIteratorAtEnd(br, secIt) == LLVMFalse:
    let name = $LLVMGetSectionName(secIt)
    let size = LLVMGetSectionSize(secIt)
    echo "  ", name, " (size: ", size, " bytes)"
    if name == ".text":
      textPtr = LLVMGetSectionContents(secIt)
      textSize = size
    LLVMMoveToNextSection(secIt)

  if not textPtr.isNil and textSize > 0:
    echo "\nDisassembly of .text:"
    var bytes = newSeq[uint8](textSize)
    copyMem(addr bytes[0], textPtr, textSize)
    
    let tripleC = LLVMGetDefaultTargetTriple()
    let triple = $tripleC
    LLVMDisposeMessage(tripleC)
    
    for ins in disassembleBytes(triple, bytes):
      echo "  ", ins

  removeFile(objFile)

when isMainModule:
  main()