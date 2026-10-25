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

type
  Context* = object
    raw*: LLVMContextRef
  Module* = object
    raw*: LLVMModuleRef
  Builder* = object
    raw*: LLVMBuilderRef

converter toRaw*(c: Context): LLVMContextRef = c.raw
converter toRaw*(m: Module): LLVMModuleRef = m.raw
converter toRaw*(b: Builder): LLVMBuilderRef = b.raw

proc `=destroy`*(c: Context) =
  if not c.raw.isNil:
    LLVMContextDispose(c.raw)

proc `=destroy`*(m: Module) =
  if not m.raw.isNil:
    LLVMDisposeModule(m.raw)

proc `=destroy`*(b: Builder) =
  if not b.raw.isNil:
    LLVMDisposeBuilder(b.raw)

proc newContext*(): Context =
  Context(raw: LLVMContextCreate())

proc newModule*(ctx: Context; name: string): Module =
  Module(raw: LLVMModuleCreateWithNameInContext(name.cstring, ctx.raw))

proc newBuilder*(ctx: Context): Builder =
  Builder(raw: LLVMCreateBuilderInContext(ctx.raw))

proc release*(m: var Module): LLVMModuleRef =
  ## Transfers ownership to the caller, preventing auto-dispose on destruction.
  result = m.raw
  m.raw = LLVMModuleRef(nil)

proc addModuleSafe*(jit: LLVMOrcLLJITRef, m: var Module): string =
  let raw = release(m)
  result = addModule(jit, raw)

proc createJITSafe*(m: var Module, OptLevel: cuint = 0): tuple[ee: LLVMExecutionEngineRef, err: string] =
  let raw = release(m)
  result = createJIT(raw, OptLevel)
