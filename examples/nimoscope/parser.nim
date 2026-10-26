import lexer
import ast
import std/strutils

type
  Context* = ref object
    pos*: int
    text*: string

  ParserError* = object of CatchableError

template nextTok(ctx: Context): Token =
  getTok(ctx.pos, ctx.text)

proc peekTok(ctx: Context): Token =
  var c = ctx.pos
  getTok(c, ctx.text)

proc newError*(pos: int, msg: string) {.noreturn.} =
  raise newException(ParserError, "pos " & $pos & ": " & msg)

proc expect(ctx: Context, kind: TokenKind): Token =
  result = ctx.nextTok()
  if result.kind != kind:
    result.pos.newError("expected " & kind.mean() & ", got " & $result.mean())

proc parseExpr(ctx: Context): Node

proc parsePrimary(ctx: Context): Node =
  let tok = ctx.nextTok()

  if tok.kind == tkNumber:
    return tok.newNumberNode(parseFloat(tok.lexeme))
  elif tok.kind == tkIdent:
    return tok.newIdentNode()
  elif tok.kind == tkLParen:
    result = ctx.parseExpr()
    discard ctx.expect(tkRParen)
    return

  tok.pos.newError("Unexpected " & tok.mean())

proc parseUnary(ctx: Context): Node =
  let tok = ctx.peekTok()

  if tok.kind in {tkMinus, tkPlus}:
    return ctx.nextTok().newUnaryNode(ctx.parseUnary())
  else:
    return ctx.parsePrimary()

proc parseMulDiv(ctx: Context): Node =
  result = ctx.parseUnary()

  while ctx.peekTok().kind in {tkStar, tkSlash}:
    let tok = ctx.nextTok()
    result = tok.newBinaryNode(result, ctx.parseUnary())

proc parseAddSub(ctx: Context): Node =
  result = ctx.parseMulDiv()

  while ctx.peekTok().kind in {tkPlus, tkMinus}:
    let tok = ctx.nextTok()
    result = tok.newBinaryNode(result, ctx.parseMulDiv())

proc parseAssignment(ctx: Context): Node =
  result = ctx.parseAddSub()

  if ctx.peekTok().kind == tkEquals:
    if result.kind != nkIdent:
      newError(result.token.pos, "left side of '=' must be identifier")
    let eq = ctx.nextTok()

    result = newBinaryNode(eq, result, ctx.parseAssignment())

proc parseExpr(ctx: Context): Node =
  ctx.parseAssignment()

proc parse*(text: string): BlockNode =
  let ctx = Context(pos: 0, text: text)
  result = newBlockNode(Token(), @[])

  while ctx.peekTok().kind != tkEOF:
    result.body.add(ctx.parseExpr())
    discard ctx.expect(tkEOS)