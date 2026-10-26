import std/[unittest, strutils]
import ../[lexer, parser, codegen, ast, jit]
import ../../../src/llvnim/[idiomatic]

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
    check "alloca double" in s
    check "store double" in s

  test "ident load":
    let s = ir("x = 1; x;")
    check "load double" in s

  test "chain assignment":
    let s = ir("x = y = 1;")
    check "alloca double" in s

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
    check "ret double 0.000000e+00" in ir("")

proc run(src: string): float =
  let ctx = codegen.newContext()
  discard codegenFunction(ctx, "entry", parse(src))
  let jctx = jit.newContext()
  jctx.evalFunction("entry", ctx.module)

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