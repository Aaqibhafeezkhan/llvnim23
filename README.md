# llvnim23

Nim bindings for the LLVM-C API, version 23.1.1.

Minimal, hand-written wrapper covering contexts, modules, types, IR building, verification, and the MCJIT execution engine.

## Requirements

LLVM 23.1.1 shared library:

- Windows: `LLVM-C.dll`
- macOS: `libLLVM.dylib` (Homebrew `llvm`)
- Linux: `libLLVM.so.23.1`

Override the library name with `-d:LlvmLib=...`.

## Usage

```nim
import llvnim23

checkVersion()  # raises if the loaded library is not 23.1.1

let ctx = LLVMContextCreate()
defer: LLVMContextDispose(ctx)

let m = LLVMModuleCreateWithNameInContext("m", ctx)
# ... build IR ...
echo verifyModule(m)  # (ok: bool, msg: string)
```

For JIT, initialize the native target first, then create an engine:

```nim
discard LLVMInitializeNativeTarget()
discard LLVMInitializeNativeAsmPrinter()
let (ee, err) = createJIT(m, 0)
defer: LLVMDisposeExecutionEngine(ee)  # also frees the module
let addr = LLVMGetFunctionAddress(ee, "myfunc")
```

## Notes

- One context per thread; contexts are not thread-safe.
- `createJIT` takes ownership of the module on success — do not dispose it separately.
- `verifyModule` frees the LLVM error message for you.
- `LLVMInitializeAll*` helpers are reimplemented in Nim because the C inline versions are not exported from the shared library.

See `tests/` for examples.
