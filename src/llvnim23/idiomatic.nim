import std/macros
import std/strutils
import ../llvnim23
export llvnim23

macro generateIdiomatic*(file: static string): untyped =
  ## Parses the raw bindings file and generates inline forwarders without the LLVM prefix.
  let ast = parseStmt(staticRead(file))
  result = newStmtList()

  for node in ast:
    if node.kind == nnkProcDef:
      # Only process exported procs (those with a '*')
      if node[0].kind != nnkPostfix:
        continue
        
      let origName = $node[0][1]
      if origName.startsWith("LLVM"):
        var newName = origName[4..^1]
        newName[0] = toLowerAscii(newName[0])
        
        let newIdent = postfix(ident(newName), "*")
        let origIdent = ident(origName)
        
        let newParamsNode = copyNimTree(node[3])
        
        var args = newSeq[NimNode]()
        for i in 1..<newParamsNode.len:
          let defs = newParamsNode[i]
          if defs.kind == nnkIdentDefs:
            for j in 0..<defs.len-2:
              args.add(defs[j])

        let call = newCall(origIdent)
        for a in args:
          call.add(a)

        let pragma = newNimNode(nnkPragma)
        pragma.add(ident("inline"))

        var paramsSeq = newSeq[NimNode]()
        for p in newParamsNode:
          paramsSeq.add(p)

        let procDef = newProc(
          name = newIdent,
          params = paramsSeq,
          body = newStmtList(call),
          pragmas = pragma
        )
        result.add(procDef)

generateIdiomatic("../llvnim23.nim")

# RAII wrappers

template withContext*(ctx: untyped; body: untyped) =
  ## Creates an LLVMContext, executes the body, and disposes it automatically.
  let ctx = contextCreate()
  try:
    body
  finally:
    contextDispose(ctx)

template withModule*(ctx: LLVMContextRef; name: string; modIdent: untyped; body: untyped) =
  ## Creates an LLVMModule, executes the body, and disposes it automatically.
  let modIdent = moduleCreateWithNameInContext(name.cstring, ctx)
  try:
    body
  finally:
    disposeModule(modIdent)

template withBuilder*(ctx: LLVMContextRef; bIdent: untyped; body: untyped) =
  ## Creates an LLVMBuilder, executes the body, and disposes it automatically.
  let bIdent = createBuilderInContext(ctx)
  try:
    body
  finally:
    disposeBuilder(bIdent)