import std/[unittest, strutils, os]
import ../[lexer, parser, codegen, ast, jit]
import ../../../src/llvnim/[idiomatic, shim]

suite "lexer":

  test "integers and decimals":
    var col = 0
    let text = "42 3.14 1. .5"
    let expected = @[
      ("42",   tkNumber),
      ("3.14", tkNumber),
      ("1.",   tkNumber),
      (".5",   tkNumber),
    ]
    for (lex, kind) in expected:
      let tok = getTok(col, text)
      check tok.kind == kind
      check tok.lexeme == lex

  test "operators and columns":
    var col = 0
    let text = "1+2*3-4/5"
    let expected = @[
      ("1", tkNumber), ("+", tkPlus),
      ("2", tkNumber), ("*", tkStar),
      ("3", tkNumber), ("-", tkMinus),
      ("4", tkNumber), ("/", tkSlash),
      ("5", tkNumber),
    ]
    for (lex, kind) in expected:
      let tok = getTok(col, text)
      check tok.kind == kind
      check tok.lexeme == lex
    check getTok(col, text).kind == tkEOF

  test "invalid numbers raise errors":
    var c1 = 0
    expect LexerError:
      discard getTok(c1, "1.2.3")

    var c2 = 0
    expect LexerError:
      discard getTok(c2, ".")
  
  test "unexpected character raises error":
    var col = 0
    expect LexerError:
      discard getTok(col, "@ 2")

  test "identifiers":
    var col = 0
    let text = "foo _bar baz123 x_1"
    let expected = @["foo", "_bar", "baz123", "x_1"]
    for id in expected:
      let tok = getTok(col, text)
      check tok.kind == tkIdent
      check tok.lexeme == id
    check getTok(col, text).kind == tkEOF

  test "equals token":
    var col = 0
    let tok = getTok(col, "=")
    check tok.kind == tkEquals
    check tok.lexeme == "="
    check tok.pos == 0

  test "EOS token":
    var col = 0
    let tok = getTok(col, ";")
    check tok.kind == tkEOS
    check tok.lexeme == ";"
    check tok.pos == 0

  test "lexer: comma":
    var col = 0
    let tok = getTok(col, ",")
    check tok.kind == tkComma
    check tok.lexeme == ","

  test "lexer: extern keyword":
    var col = 0
    let tok = getTok(col, "extern")
    check tok.kind == tkExtern
    check tok.lexeme == "extern"

  test "lexer: extern is keyword, not ident":
    var col = 0
    let text = "extern foo"
    check getTok(col, text).kind == tkExtern
    check getTok(col, text).kind == tkIdent

  test "lexer: extern-like ident":
    var col = 0
    let text = "external"
    let tok = getTok(col, text)
    check tok.kind == tkIdent
    check tok.lexeme == "external"

  test "lexer: comparison operators":
    var col = 0
    let text = "< > <= >= == !="
    let expected = @[
      ("<",  tkLT), (">",  tkGT),
      ("<=", tkLTE), (">=", tkGTE),
      ("==", tkEQ), ("!=", tkNEQ),
    ]
    for (lex, kind) in expected:
      let tok = getTok(col, text)
      check tok.kind == kind
      check tok.lexeme == lex

  test "lexer: and or keywords":
    var col = 0
    let text = "and or"
    check getTok(col, text).kind == tkAnd
    check getTok(col, text).kind == tkOr

  test "lexer: lone equals is assignment":
    var col = 0
    check getTok(col, "=").kind == tkEquals

  test "lexer: lone bang errors":
    var col = 0
    expect LexerError:
      discard getTok(col, "!")

suite "parser":

  test "number literal":
    let b = parse("42;")
    check b.body.len == 1
    check b.body[0].kind == nkNumber
    check NumberNode(b.body[0]).value == 42.0

  test "ident":
    let b = parse("foo;")
    check b.body[0].kind == nkIdent
    check IdentNode(b.body[0]).token.lexeme == "foo"

  test "binary precedence":
    let b = parse("1 + 2 * 3;")
    check $b.body[0] == "(1.0 + (2.0 * 3.0))"

  test "binary left assoc":
    let b = parse("1 - 2 - 3;")
    check $b.body[0] == "((1.0 - 2.0) - 3.0)"

  test "unary":
    let b = parse("-x;")
    check $b.body[0] == "-(x)"

  test "parens override":
    let b = parse("(1 + 2) * 3;")
    check $b.body[0] == "((1.0 + 2.0) * 3.0)"

  test "assignment right assoc":
    let b = parse("a = b = 1;")
    check $b.body[0] == "(a = (b = 1.0))"

  test "assignment to non-ident fails":
    expect ParserError:
      discard parse("1 + 2 = 3;")

  test "multiple statements":
    let b = parse("x = 1 + 2; y = x * 2;")
    check b.body.len == 2
    check $b.body[0] == "(x = (1.0 + 2.0))"
    check $b.body[1] == "(y = (x * 2.0))"

  test "missing semicolon":
    expect ParserError:
      discard parse("1 + 2")

  test "unclosed paren":
    expect ParserError:
      discard parse("(1 + 2;")

  test "unexpected token":
    expect ParserError:
      discard parse(";")

  test "empty program":
    let b = parse("")
    check b.body.len == 0

  test "parse extern no args":
    let b = parse("extern foo();")
    check b.body[0].kind == nkExtern
    check ExternNode(b.body[0]).name.lexeme == "foo"
    check ExternNode(b.body[0]).args.len == 0

  test "parse extern one arg":
    let b = parse("extern foo(a);")
    let e = ExternNode(b.body[0])
    check e.args.len == 1
    check e.args[0].lexeme == "a"

  test "parse extern multiple args":
    let b = parse("extern foo(a, b, c);")
    check ExternNode(b.body[0]).args.len == 3

  test "parse call no args":
    let b = parse("foo();")
    check b.body[0].kind == nkCall
    check CallNode(b.body[0]).args.len == 0

  test "parse call one arg":
    let b = parse("foo(1);")
    check CallNode(b.body[0]).args.len == 1

  test "parse call nested":
    let b = parse("foo(bar(1));")
    let c = CallNode(b.body[0])
    check c.args[0].kind == nkCall

  test "parse call in expression":
    let b = parse("1 + foo(2);")
    check b.body[0].kind == nkBinary

  test "parse extern in expression":
    let b = parse("x = extern foo(a);")
    check b.body[0].kind == nkBinary
    check BinaryNode(b.body[0]).rvalue.kind == nkExtern

  test "call name is ident":
    let b = parse("foo(1);")
    check CallNode(b.body[0]).name.lexeme == "foo"

  test "parse call missing rparen":
    expect ParserError:
      discard parse("foo(1;")

  test "parse extern missing name":
    expect ParserError:
      discard parse("extern ();")

  test "parse if":
    let b = parse("if (1) 2;")
    check b.body[0].kind == nkBranch
    let n = BranchNode(b.body[0])
    check n.elifs.len == 0
    check n.elseBody.isNil

  test "parse if-else":
    let b = parse("if (1) 2; else 3;")
    let n = BranchNode(b.body[0])
    check not n.elseBody.isNil

  test "parse if-elif-else":
    let b = parse("if (1) 2; elif (3) 4; else 5;")
    let n = BranchNode(b.body[0])
    check n.elifs.len == 1
    check not n.elseBody.isNil

  test "parse if with block":
    let b = parse("if (1) { x = 1; x; }")
    let n = BranchNode(b.body[0])
    check n.body.kind == nkBlock

  test "parse else missing if":
    expect ParserError:
      discard parse("else 1;")

  test "parse comparison":
    let b = parse("1 < 2;")
    check b.body[0].kind == nkBinary
    check BinaryNode(b.body[0]).token.kind == tkLT

  test "parse comparison chain":
    let b = parse("1 < 2 == 3;")
    check b.body[0].kind == nkBinary

  test "parse and precedence over or":
    let b = parse("1 or 2 and 3;")
    let top = BinaryNode(b.body[0])
    check top.token.kind == tkOr
    check BinaryNode(top.rvalue).token.kind == tkAnd

  test "parse comparison binds tighter than and":
    let b = parse("1 < 2 and 3 > 4;")
    let top = BinaryNode(b.body[0])
    check top.token.kind == tkAnd

  test "parse arith binds tighter than comparison":
    let b = parse("1 + 2 < 3 * 4;")
    let top = BinaryNode(b.body[0])
    check top.token.kind == tkLT

  test "parse for full":
    let b = parse("for i = 0; i < 10; i = i + 1; print(i);")
    check b.body[0].kind == nkFor
    let f = ForNode(b.body[0])
    check not f.init.isNil
    check not f.cond.isNil
    check not f.step.isNil

  test "parse for empty init":
    let b = parse("for ; i < 10; i = i + 1; print(i);")
    check ForNode(b.body[0]).init.isNil

  test "parse for empty cond":
    let b = parse("for i = 0; ; i = i + 1; print(i);")
    check ForNode(b.body[0]).cond.isNil

  test "parse for empty step":
    let b = parse("for i = 0; i < 10;; print(i);")
    check ForNode(b.body[0]).step.isNil

  test "parse for with block":
    let b = parse("for i = 0; i < 3; i = i + 1; { print(i); }")
    check ForNode(b.body[0]).body.kind == nkBlock

  test "parse def":
    let b = parse("def foo(a) a;")
    check b.body[0].kind == nkDef
    let d = DefNode(b.body[0])
    check d.name.lexeme == "foo"
    check d.args.len == 1
    check d.args[0].lexeme == "a"

  test "parse def no args":
    let b = parse("def foo() 1;")
    check DefNode(b.body[0]).args.len == 0

  test "parse return":
    let b = parse("def foo() return 1;")
    check ReturnNode(DefNode(b.body[0]).body).kind == nkReturn

  test "parse def with block":
    let b = parse("def foo(a) { return a; }")
    check DefNode(b.body[0]).body.kind == nkBlock

  test "parse return no value":
    let b = parse("def f() return;")
    let r = ReturnNode(DefNode(b.body[0]).body)
    check r.value.isNil

  test "parse return with value":
    let b = parse("def f() return 1;")
    let r = ReturnNode(DefNode(b.body[0]).body)
    check not r.value.isNil

proc ir(src: string): string =
  let ctx = codegen.newContext()
  discard codegenFunction(ctx, "entry", parse(src))
  let cstr = printModuleToString(ctx.module)
  result = $cstr
  disposeMessage(cstr)

suite "codegen":

  test "number":
    check "double 4.200000e+01" in ir("42;")

  test "assignment":
    let s = ir("x = 1;")
    check "@x = global double" in s
    check "store double" in s

  test "ident load":
    let s = ir("x = 1; x;")
    check "load double" in s

  test "chain assignment":
    let s = ir("x = y = 1;")
    check "@x = global double" in s
    check "@y = global double" in s

  test "binary add":
    check "fadd double" in ir("x = 1; y = 2; x + y;")

  test "binary mul precedence":
    let s = ir("x = 1; y = 2; z = 3; x + y * z;")
    check "fmul double" in s
    check "fadd double" in s

  test "unary minus":
    check "fneg double" in ir("x = 5; -x;")

  test "unary plus is noop":
    let s = ir("+5;")
    check "fneg" notin s

  test "undefined ident":
    expect CodegenError:
      discard ir("foo;")

  test "empty block":
    check "ret double +qnan" in ir("")

  test "extern declaration":
    check "declare double @foo" in ir("extern foo();")

  test "extern with params":
    let s = ir("extern foo(a, b);")
    check "declare double @foo(double, double)" in s

  test "extern twice is idempotent":
    let s = ir("extern foo(); extern foo();")
    check s.count("declare double @foo") == 1

  test "call no args":
    let s = ir("extern foo(); foo();")
    check "call double @foo()" in s

  test "call with args":
    let s = ir("extern foo(a); foo(1);")
    check "call double @foo(double 1.000000e+00)" in s

  test "call undefined function":
    expect CodegenError:
      discard ir("bar();")

  test "if emits cond branch":
    let s = ir("if (1) 2;")
    check "br i1" in s

  test "if-else emits phi":
    let s = ir("if (1) 2; else 3;")
    check "phi double" in s

  test "if-elif-else emits nested phi":
    let s = ir("if (1) 2; elif (3) 4; else 5;")
    check "phi double" in s
    check s.count("phi double") >= 2

  test "comparison emits fcmp":
    let s = ir("x = 1; y = 2; x < y;")
    check "fcmp" in s

  test "and emits phi":
    let s = ir("x = 1; y = 2; x and y;")
    check "phi double" in s

  test "or emits phi":
    let s = ir("x = 1; y = 2; x or y;")
    check "phi double" in s

  test "for emits loop blocks":
    let s = ir("for i = 0; i < 3; i = i + 1; print(i);")
    check "forcond" in s
    check "forbody" in s
    check "forexit" in s

  test "for emits condbr":
    let s = ir("for i = 0; i < 3; i = i + 1; print(i);")
    check "br i1" in s

  test "def emits function":
    let s = ir("def foo(a) a;")
    check "define double @foo(double" in s

  test "def with params":
    let s = ir("def add(a, b) a + b;")
    check "define double @add(double" in s

  test "return emits ret":
    let s = ir("def foo(a) return a;")
    check "ret double" in s

  test "redefinition of extern":
    expect CodegenError:
      discard ir("extern foo(a); def foo(a) a;")

  test "redefinition of def":
    expect CodegenError:
      discard ir("def foo() 1; def foo() 2;")

  test "def shadows variable":
    expect CodegenError:
      discard ir("x = 1; def x() 2;")

  test "return outside def":
    expect CodegenError:
      discard ir("return 1;")

  test "call undefined":
    expect CodegenError:
      discard ir("nope();")

  test "return no value emits nan":
    let s = ir("def f() return;")
    check "ret double" in s
    check "qnan" in s

  test "def rollback on error":
    let ctx = codegen.newContext()
    expect CodegenError:
      discard codegenFunction(ctx, "entry_a", parse("def bad() { undefined_var; }"))
    discard codegenFunction(ctx, "entry_b", parse("def bad() 1; bad();"))

var jdCounter = 0

proc run(src: string): float =
  let ctx = codegen.newContext()
  discard codegenFunction(ctx, "entry", parse(src))
  let jctx = jit.newContext(currentSourcePath().parentDir.parentDir / "libruntime.so")
  inc jdCounter
  jctx.evalFunction("entry", "test_" & $jdCounter, ctx.module)

suite "jit":

  test "number":
    check run("42;") == 42.0

  test "add":
    check run("1 + 2;") == 3.0

  test "precedence":
    check run("1 + 2 * 3;") == 7.0

  test "parens":
    check run("(1 + 2) * 3;") == 9.0

  test "unary":
    check run("-5;") == -5.0

  test "assign and read":
    check run("x = 5; x;") == 5.0

  test "chain assign":
    check run("x = y = 3; x + y;") == 6.0

  test "div":
    check run("10 / 4;") == 2.5

  test "extern cos via libm":
    when defined(linux):
      const libm = "libm.so.6"
    elif defined(macosx):
      const libm = "libm.dylib"
    else:
      const libm = "libm.so"
    let ctx = codegen.newContext()
    discard codegenFunction(ctx, "entry", parse("extern cos(a); cos(0);"))
    let jctx = jit.newContext()
    let (ok, err) = jitLoadPlatformDynamicLibrary(jctx.jit, libm)
    check ok
    check err == ""
    check jctx.evalFunction("entry", "test_" & $jdCounter, ctx.module) == 1.0

  test "print via runtime.so":
    let ctx = codegen.newContext()
    discard codegenFunction(ctx, "entry", parse("print(42);"))
    let jctx = jit.newContext(currentSourcePath().parentDir.parentDir / "libruntime.so")
    discard jctx.evalFunction("entry", "test_" & $jdCounter, ctx.module)

  test "if true branch":
    check run("if (1) 42; else 0;") == 42.0

  test "if false branch":
    check run("if (0) 42; else 7;") == 7.0

  test "if elif":
    check run("if (0) 1; elif (1) 2; else 3;") == 2.0

  test "if elif else":
    check run("if (0) 1; elif (0) 2; else 3;") == 3.0

  test "if with variable":
    check run("x = 5; if (x) 1; else 0;") == 1.0

  test "if nested":
    check run("if (1) { if (0) 1; else 2; } else 3;") == 2.0

  test "lt true":
    check run("1 < 2;") == 1.0

  test "lt false":
    check run("2 < 1;") == 0.0

  test "eq":
    check run("2 == 2;") == 1.0

  test "neq":
    check run("2 != 2;") == 0.0

  test "gte":
    check run("2 >= 2;") == 1.0

  test "lte":
    check run("3 <= 2;") == 0.0

  test "and truthy returns rhs":
    check run("1 and 2;") == 2.0

  test "and falsy returns lhs":
    check run("0 and 2;") == 0.0

  test "or truthy returns lhs":
    check run("1 or 2;") == 1.0

  test "or falsy returns rhs":
    check run("0 or 2;") == 2.0

  test "and short-circuits":
    check run("0 and print(9);") == 0.0

  test "or short-circuits":
    check run("1 or print(9);") == 1.0

  test "combined expression":
    check run("x = 10; if (x > 5 and x < 20) 1; else 0;") == 1.0

  test "for sums via global":
    check run("s = 0; for i = 0; i < 5; i = i + 1; s = s + i; s;") == 10.0

  test "for with block":
    check run("s = 0; for i = 0; i < 5; i = i + 1; { s = s + i; } s;") == 10.0

  test "for zero iterations":
    check run("s = 0; for i = 0; i < 0; i = i + 1; s = s + 1; s;") == 0.0

  test "break exits loop":
    check run("s = 0; for i = 0; i < 10; i = i + 1; { if i == 3 break; s = s + 1; } s;") == 3.0

  test "continue skips body":
    check run("s = 0; for i = 0; i < 5; i = i + 1; { if i == 2 continue; s = s + i; } s;") == 8.0

  test "break at start":
    check run("s = 0; for i = 0; i < 10; i = i + 1; { break; s = s + 1; } s;") == 0.0

  test "continue all iterations":
    check run("s = 0; for i = 0; i < 5; i = i + 1; { continue; s = s + 1; } s;") == 0.0

  test "break in nested loop exits inner":
    check run("""
s = 0;
for i = 0; i < 3; i = i + 1; {
  for j = 0; j < 3; j = j + 1; {
    if j == 1 break;
    s = s + 1;
  }
}
s;
""") == 3.0

  test "continue in nested loop":
    check run("""
s = 0;
for i = 0; i < 3; i = i + 1; {
  for j = 0; j < 3; j = j + 1; {
    if j == 1 continue;
    s = s + 1;
  }
}
s;
""") == 6.0

  test "break inside if only":
    check run("s = 0; for i = 0; i < 5; i = i + 1; { if i == 2 break; s = s + 1; } s;") == 2.0

  test "break outside loop errors":
    expect CodegenError:
      discard run("break;")

  test "continue outside loop errors":
    expect CodegenError:
      discard run("continue;")

  test "def simple":
    check run("def foo(a) a * 2; foo(21);") == 42.0

  test "def no args":
    check run("def foo() 42; foo();") == 42.0

  test "def with return":
    check run("def foo(a) return a + 1; foo(41);") == 42.0

  test "def early return":
    check run("def foo(a) { if a < 0 return 0; a; } foo(-5);") == 0.0

  test "def fib recursive":
    check run("def fib(a) if (a < 2) return a; else fib(a-1)+fib(a-2); fib(10);") == 55.0

  test "def fact recursive":
    check run("def fact(n) if (n <= 1) return 1; else n * fact(n - 1); fact(5);") == 120.0

  test "def multiple":
    check run("def add(a, b) a + b; def mul(a, b) a * b; add(mul(2, 3), 4);") == 10.0

  test "return no value gives NaN":
    let v = run("def f(a) { if a < 0 return; a; } f(-1);")
    check v != v

  test "return value":
    check run("def f(a) { if a < 0 return 0; a; } f(-1);") == 0.0

  test "return early":
    check run("def f(a) { return a * 2; a + 100; } f(5);") == 10.0

  test "return inside loop":
    check run("""
def find(n) {
  for i = 0; i < 10; i = i + 1; {
    if i * i == n return i;
  }
  return -1;
}
find(9);
""") == 3.0

  test "return inside nested if":
    check run("def f(a) { if a > 0 { if a > 10 return 100; return 10; } 0; } f(50);") == 100.0

  test "return outside function":
    expect CodegenError:
      discard run("return 1;")

  test "return no value outside function":
    expect CodegenError:
      discard run("return;")