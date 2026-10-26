import lexer
import std/strutils

type
  NodeKind* = enum
    nkNumber, nkUnary, nkBinary, nkIdent, nkBlock

  Node* = ref object of RootObj
    kind*: NodeKind
    token*: Token

  NumberNode* = ref object of Node
    value*: float

  UnaryNode* = ref object of Node
    # op - token
    value*: Node

  BinaryNode* = ref object of Node
    # op - token
    lvalue*: Node
    rvalue*: Node

  IdentNode* = ref object of Node
    # ident - token

  BlockNode* = ref object of Node
    body*: seq[Node]

proc `$`*(n: Node): string =
  case n.kind
  of nkNumber: $NumberNode(n).value
  of nkIdent:  IdentNode(n).token.lexeme
  of nkUnary:  UnaryNode(n).token.lexeme & "(" & $UnaryNode(n).value & ")"
  of nkBinary:
    let b = BinaryNode(n)
    "(" & $b.lvalue & " " & b.token.lexeme & " " & $b.rvalue & ")"
  of nkBlock:
    var parts: seq[string]
    for s in BlockNode(n).body: parts.add $s
    "{" & parts.join("; ") & "}"

proc newNumberNode*(token: Token, value: float): NumberNode =
  NumberNode(kind: nkNumber, token: token, value: value)

proc newUnaryNode*(token: Token, value: Node): UnaryNode =
  UnaryNode(kind: nkUnary, token: token, value: value)

proc newBinaryNode*(token: Token, lvalue: Node, rvalue: Node): BinaryNode =
  BinaryNode(kind: nkBinary, token: token, lvalue: lvalue, rvalue: rvalue)

proc newIdentNode*(token: Token): IdentNode =
  IdentNode(kind: nkIdent, token: token)

proc newBlockNode*(token: Token, body: seq[Node]): BlockNode =
  BlockNode(kind: nkBlock, token: token, body: body)