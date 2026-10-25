# llvnim23

## What it is

Hand-written Nim bindings for the LLVM-C API, version 23.1.x. You call LLVM directly from Nim to build IR, run the verifier, optimize with the new PassBuilder, and execute code via LLJIT or MCJIT.

## Why use it

Nim has no maintained bindings for modern LLVM-C. This package gives you the parts you need to write a compiler backend, a small language frontend, or a JIT in Nim, without leaving the language.

## Requirements

- Nim >= 2.2.10.
- LLVM 23.1.x. `checkVersion` raises `ValueError` on a different major.minor.

The library is loaded at runtime from:

| OS      | Default library      |
|---------|----------------------|
| Windows | `LLVM-C.dll`         |
| macOS   | `libLLVM.dylib`      |
| Linux   | `libLLVM.so.23.1`    |

Override with `-d:LlvmLib=<name>`.

Install LLVM:

```sh
# Ubuntu / Debian
sudo apt install llvm-23-dev

# Fedora
sudo dnf install llvm23-devel

# Arch
sudo pacman -S llvm

# macOS (Homebrew)
brew install llvm@23
```

Windows: use the official LLVM 23.1.x build from llvm.org. It ships `LLVM-C.dll`.

## Install

```sh
nimble install llvnim23
```

Package page: <https://nimble.directory/pkg/llvnim23>

Or vendor `src/llvnim23.nim` and `import llvnim23`.

## Quickstart

Build an `add` function, verify it, print the IR.

```nim
import llvnim23

checkVersion()

let ctx = LLVMContextCreate()
defer: LLVMContextDispose(ctx)

let m = LLVMModuleCreateWithNameInContext("hello", ctx)
defer: LLVMDisposeModule(m)

let i32t = LLVMInt32TypeInContext(ctx)
var params = [i32t, i32t]
let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
let fn = LLVMAddFunction(m, "add", fnTy)

let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
let b = LLVMCreateBuilderInContext(ctx)
defer: LLVMDisposeBuilder(b)
LLVMPositionBuilderAtEnd(b, bb)

let sum = LLVMBuildAdd(b, LLVMGetParam(fn, 0), LLVMGetParam(fn, 1), "sum")
discard LLVMBuildRet(b, sum)

let (ok, msg) = verifyModule(m)
doAssert ok, msg

let s = LLVMPrintModuleToString(m)
echo s
LLVMDisposeMessage(s)
```

Run it through LLJIT:

```nim
discard LLVMInitializeNativeTarget()
discard LLVMInitializeNativeAsmPrinter()

let (jit, jitErr) = createLLJIT()
doAssert jitErr.len == 0
doAssert addModule(jit, m).len == 0

let (addr, lookupErr) = lookup(jit, "add")
doAssert lookupErr.len == 0

type AddFn = proc(a, b: int64): int64 {.cdecl.}
echo cast[AddFn](addr)(20'i64, 22'i64)  # 42
```

## Idiomatic API

If you prefer a more Nim-friendly interface, import the `idiomatic` module. It automatically generates `camelCase` wrappers for all `LLVM*` functions (e.g., `contextCreate()` instead of `LLVMContextCreate()`) and provides RAII templates for safe memory management.

```nim
import llvnim23/idiomatic

withContext(ctx):
  withModule(ctx, "hello", m):
    withBuilder(ctx, b):
      let i32t = int32TypeInContext(ctx)
      var params = [i32t, i32t]
      let fnTy = functionType(i32t, addr params[0], 2, LLVMFalse)
      let fn = addFunction(m, "add", fnTy)
      
      let bb = appendBasicBlockInContext(ctx, fn, "entry")
      positionBuilderAtEnd(b, bb)
      
      let sum = buildAdd(b, getParam(fn, 0), getParam(fn, 1), "sum")
      discard buildRet(b, sum)
      
      doAssert verifyModule(m).ok
```

See `tests/` for atomics, passes, target machine emit, attributes, metadata, aliases, and MCJIT.

## What it covers

- Core refs (context, module, builder, basic block, value, type) with `==`, `isNil`, `$`, `hash`.
- Types: integers, floats, void, pointer, vector, array, struct.
- IR builders: arithmetic, `icmp`/`fcmp`, branches, `switch`, `phi`, `select`, casts, `alloca`/`load`/`store`, GEP, calls, aggregates.
- Constants and constexpr: int, real, null, undef, `allones`, `add`/`sub`/`xor`, casts, GEP, `extractelement`/`insertelement`/`shufflevector`.
- Globals, string globals (`addGlobalString`), linkage, unnamed address.
- Atomics: `atomicrmw`, `cmpxchg`, `fence`.
- Exceptions: `landingpad`, `resume`, `catchpad`, `cleanuppad`.
- `verifyModule` (frees the error message for you).
- PassBuilder (`LLVMRunPasses`, `LLVMRunPassesOnFunction`).
- TargetMachine and AOT emit (assembly, object).
- MCJIT (`createJIT`, `LLVMGetFunctionAddress`) and LLJIT (`createLLJIT`, `addModule`, `lookup`).
- Attributes (enum, string, target-dependent), metadata, aliases.
- Per-arch and `LLVMInitializeAll*` / `LLVMInitializeNative*` initializers.

## Gotchas

- Version is fixed to LLVM 23.1.x. Different major.minor fails `checkVersion`.
- `LLVMDisposeExecutionEngine` frees the module. Do not dispose it separately. `addModule` in LLJIT transfers ownership; on error it does not. Use `addModuleSafe` / `createJITSafe` to prevent double-free.
- Free strings from `LLVMPrint*ToString` with `LLVMDisposeMessage`.
- A context is not thread-safe. Use one context per thread.
- `LLVMInitializeNative*` supports amd64, i386, arm64. Other CPUs fail at compile time.
- `LLVMBuildUnwind` was removed from the C API in LLVM 23 and is not bound.

## Limitations

- Not full LLVM-C coverage. Debug info (DI*), object loaders, and most ORC layers beyond LLJIT are not bound.
- Only dynamic linking via `dynlib`. Static linking is not wired up.
- The AOT emit test writes to `/tmp` and assumes a Unix-like system.

## License

AGPL-3.0. Author: xlebore3o4ka.