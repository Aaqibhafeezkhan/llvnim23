# Developer Experience (DX) Helpers

`llvnim` provides a 1:1 binding to the LLVM-C API. It is powerful and fully matches the official C headers, but sometimes writing pure LLVM-C code in Nim feels a bit verbose due to manual pointer management and arrays.

The `llvnim/dx` module contains high-level abstractions to make writing IR generators in Nim more ergonomic. Import it via `import llvnim/dx`.

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
Pass a Nim sequence or array directly. It also automatically creates the first basic block (usually named "entry").

```nim
import llvnim/dx

let i32t = i32(ctx) # Type shorthand
let (fn, entryBB) = createFunction(m, ctx, "add", i32t, [i32t, i32t])
```

## Type Shorthands

Instead of `LLVMInt32TypeInContext(ctx)`, use concise helpers:

```nim
let t1 = i32(ctx)     # 32-bit integer
let t2 = f64(ctx)     # 64-bit float
let p  = ptrTy(ctx)   # opaque pointer (address space 0)
let v  = vector(ctx, i32(ctx), 4) # <4 x i32>
let s  = struct(ctx, [i32(ctx), f64(ctx)]) # { i32, double }
```

## Iterators

Traverse modules, functions, and basic blocks using standard Nim `for` loops. Both forward and reverse iteration are supported.

```nim
for fn in m.functions:
  echo "Function: ", fn.getName
  for bb in fn.basicBlocks:
    echo "  Block: ", bb.getName
    for inst in bb.instructions:
      echo "    ", inst.printValueToString
```

Counting elements is also simplified:

```nim
echo "Total functions: ", fn.countParams
echo "Total basic blocks: ", fn.countBasicBlocks
```

## Control Flow

Building `if/else` in SSA form usually requires creating blocks, branching, and manually positioning the builder. The DX helpers reduce this to a block-like syntax.

```nim
let cond = LLVMBuildICmp(b, LLVMIntSGT, a, c, "cmp")
let iface = createIfElse(b, ctx, fn, cond)

iface.thenBlock:
  discard LLVMBuildRet(b, a)

iface.elseBlock:
  discard LLVMBuildRet(b, c)
```

If you need to merge the control flow back (e.g., using a `phi` node), you can create a `merge` block:

```nim
let iface = createIfElse(b, ctx, fn, cond)

var valFromThen, valFromElse: LLVMValueRef

iface.thenBlock:
  valFromThen = LLVMBuildAdd(b, a, c, "sum")
  iface.brToMerge()

iface.elseBlock:
  valFromElse = LLVMBuildSub(b, a, c, "diff")
  iface.brToMerge()

iface.mergeBlock:
  let phi = LLVMBuildPhi(b, i32t, "result")
  var vals = [valFromThen, valFromElse]
  var blocks = [iface.thenBB, iface.elseBB]
  LLVMAddIncoming(phi, addr vals[0], addr blocks[0], 2)
  discard LLVMBuildRet(b, phi)
```

## Builder Helpers

Common instructions are wrapped to avoid passing arrays and types manually:

```nim
# Allocate memory on the stack
let slot = b.alloca(i32(ctx), "slot")

# Store and load (load infers the type from the alloca)
b.store(slot, LLVMConstInt(i32(ctx), 42, LLVMFalse))
let val = b.load(slot, "val")

# Call a function (infers the function type)
let res = b.call(fn, [val, LLVMConstInt(i32(ctx), 10, LLVMFalse)], "res")
```

## String Constants

Creating null-terminated string globals is simplified:

```nim
let strConst = stringConstant(ctx, "hello")
let strGlobal = stringGlobal(m, ctx, "world", "my_str")
```