# llvnim23

Nim bindings for the LLVM-C API, version 23.1.x.

A comprehensive, hand-written wrapper covering contexts, modules, types, IR building, constant expressions, verification, and both JIT engines (LLJIT/ORC and MCJIT).

## Features

- **IR Generation**: Full builder support for memory (GEP, alloca, load/store), integer and float arithmetic, type casts, control flow (branches, switch, phi, select, exceptions), and aggregates (structs, vectors).
- **Constants & Atomics**: Constant expressions, global strings, and atomic operations (`atomicrmw`, `cmpxchg`, `fence`).
- **JIT Engines**: Bindings for the modern ORC LLJIT API and the legacy MCJIT execution engine.
- **Targets**: Helpers to initialize all standard targets or just the native one.

## Requirements

LLVM 23.1.x shared library:

- Windows: `LLVM-C.dll`
- macOS: `libLLVM.dylib` (Homebrew `llvm`)
- Linux: `libLLVM.so.23.1`

Override the library name with `-d:LlvmLib=...` if your system uses a different path.

## Usage

```nim
import llvnim23

checkVersion() # Raises if the loaded library is not 23.1.x compatible

let ctx = LLVMContextCreate()
defer: LLVMContextDispose(ctx)

let m = LLVMModuleCreateWithNameInContext("m", ctx)
# ... build IR ...

echo verifyModule(m) # (ok: bool, msg: string)
```

### JIT (LLJIT)

For the ORC JIT, initialize the native target and use the `LLJIT` wrappers. Note that `addModule` transfers ownership of the module to the JIT.

```nim
discard LLVMInitializeNativeTarget()
discard LLVMInitializeNativeAsmPrinter()

let (jit, err) = createLLJIT()
if err.len > 0:
  quit("Failed to create JIT: " & err)

# Build IR...
let addErr = addModule(jit, m) # JIT now owns 'm'
if addErr.len > 0:
  quit("Failed to add module: " & addErr)

let (addr, lookupErr) = lookup(jit, "my_func")
if lookupErr.len == 0:
  echo "Function address: ", addr
```

### JIT (MCJIT)

Older engines are also supported:

```nim
discard LLVMInitializeNativeTarget()
discard LLVMInitializeNativeAsmPrinter()

let (ee, err) = createJIT(m, 0)
defer: LLVMDisposeExecutionEngine(ee) # Also frees the module
let addr = LLVMGetFunctionAddress(ee, "my_func")
```

## Notes

- One context per thread; LLVM contexts are not thread-safe.
- `addModule` (LLJIT) and `createJIT` (MCJIT) take ownership of the module on success. Do not dispose it separately.
- `verifyModule` safely frees the internal LLVM error message.
- `LLVMInitializeAll*` and `LLVMInitializeNative*` helpers are reimplemented in Nim because the C inline versions are not exported from the shared library.

See `tests/` for extensive examples covering all API layers.