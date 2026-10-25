# Developer Experience (DX) Helpers

`llvnim` provides a 1:1 binding to the LLVM-C API. It is powerful and fully matches the official C headers, but sometimes writing pure LLVM-C code in Nim feels a bit verbose due to manual pointer management and arrays.

The `llvnim/dx` directory contains high-level abstractions to make writing IR generators in Nim more ergonomic.

## Function Creation

**Vanilla LLVM-C approach:**
To create a function with two `i32` parameters and an entry block, you need to manually construct a C-array of types and pass its pointer, along with its length.

```nim
let i32t = LLVMInt32TypeInContext(ctx)
var params = [i32t, i32t]
let fnTy = LLVMFunctionType(i32t, addr params[0], 2, LLVMFalse)
let fn = LLVMAddFunction(m, "add", fnTy)
let bb = LLVMAppendBasicBlockInContext(ctx, fn, "entry")
```

**With DX helpers:**
By importing `llvnim/dx/funcs`, you can pass a Nim sequence or array directly. It also automatically creates the first basic block (usually named "entry").

```nim
import llvnim
import llvnim/dx

let i32t = LLVMInt32TypeInContext(ctx)
let (fn, entryBB) = createFunction(m, ctx, "add", i32t, @[i32t, i32t])
```

*Why it's better:* You avoid temporary C-arrays, manual `addr` calls, and explicit `cuint` length counts. The helper returns both the function and the entry block ready for you to position the builder.