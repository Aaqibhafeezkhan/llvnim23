import codegen, parser, jit

let ctx = newContext()
let modd = codegenFunction(ctx, "entry", parse("x = 5; y = x * 2;"))
let jctx = newJit()
echo jctx.evalFunction("entry", ctx.module)