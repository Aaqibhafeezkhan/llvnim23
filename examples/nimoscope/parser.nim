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
    if ctx.peekTok().kind == tkLParen:
      let par = ctx.nextTok()

      var args: seq[Node]

      while ctx.peekTok().kind notin {tkRParen, tkEOF}:
        args.add(ctx.parseExpr())

        if ctx.peekTok().kind == tkRParen: break
        discard ctx.expect(tkComma)

      discard ctx.expect(tkRParen)

      return par.newCallNode(tok, args)

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

proc parseComparison(ctx: Context): Node =
  result = ctx.parseAddSub()
  while ctx.peekTok().kind in {tkGT, tkLT, tkGTE, tkLTE, tkEQ, tkNEQ}:
    let tok = ctx.nextTok()
    result = tok.newBinaryNode(result, ctx.parseAddSub())

proc parseAnd(ctx: Context): Node =
  result = ctx.parseComparison()
  while ctx.peekTok().kind == tkAnd:
    let tok = ctx.nextTok()
    result = tok.newBinaryNode(result, ctx.parseComparison())

proc parseOr(ctx: Context): Node =
  result = ctx.parseAnd()
  while ctx.peekTok().kind == tkOr:
    let tok = ctx.nextTok()
    result = tok.newBinaryNode(result, ctx.parseAnd())

proc parseAssignment(ctx: Context): Node =
  result = ctx.parseOr()

  if ctx.peekTok().kind == tkEquals:
    if result.kind != nkIdent:
      newError(result.token.pos, "left side of '=' must be identifier")
    let eq = ctx.nextTok()
    
    result = newBinaryNode(eq, result, ctx.parseExpr())

proc parseExtern(ctx: Context, tok: Token): Node =
  let name = ctx.expect(tkIdent)
  discard ctx.expect(tkLParen)

  var args: seq[Token] = @[]

  while ctx.peekTok().kind == tkIdent:
    args.add(ctx.nextTok())

    if ctx.peekTok().kind == tkRParen: break
    discard ctx.expect(tkComma)

  discard ctx.expect(tkRParen)

  return tok.newExternNode(name, args)

proc parseBlock(ctx: Context, tok: Token): Node =
  var body: seq[Node]

  while ctx.peekTok().kind notin {tkRBrace, tkEOF}:
    body.add(ctx.parseExpr())

    if ctx.peekTok().kind in {tkRBrace, tkEOF}:
      break

    discard ctx.expect(tkEOS)
    
  discard ctx.expect(tkRBrace)

  tok.newBlockNode(body)

proc parseBlockOrExpr(ctx: Context): Node =
  if ctx.peekTok().kind == tkLBrace:
    result = ctx.parseBlock(ctx.nextTok())
  else:
    result = ctx.parseExpr()
    discard ctx.expect(tkEOS)

proc parseBranch(ctx: Context): (Node, Node) =
  let cond = ctx.parseExpr()
  var body: Node = ctx.parseBlockOrExpr()

  return (cond, body)

proc parseIf(ctx: Context, tok: Token): Node =
  let (ifCond, ifBody) = ctx.parseBranch()

  var elifs: seq[(Node, Node)]
  while ctx.peekTok().kind == tkElif:
    discard ctx.nextTok()
    elifs.add(ctx.parseBranch())

  var elseBody: Node
  if ctx.peekTok().kind == tkElse:
    discard ctx.nextTok()
    elseBody = ctx.parseBlockOrExpr()

  return tok.newBranchNode(ifCond, ifBody, elifs, elseBody)

proc parseSpecial(ctx: Context): Node =
  let tok = ctx.peekTok()

  if   tok.kind == tkExtern: return ctx.parseExtern(ctx.nextTok())
  elif tok.kind == tkIf:     return ctx.parseIf(ctx.nextTok())

  return ctx.parseAssignment()

proc parseExpr(ctx: Context): Node =
  ctx.parseSpecial()

proc parse*(text: string): BlockNode =
  let ctx = Context(pos: 0, text: text)
  result = newBlockNode(Token(), @[])

  while ctx.peekTok().kind != tkEOF:
    let expr = ctx.parseExpr()
    result.body.add(expr)
    
    if expr.kind != nkBranch:
      discard ctx.expect(tkEOS)