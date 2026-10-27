import lexer
import std/[strutils, sequtils]

type
  NodeKind* = enum
    nkNumber, nkUnary, nkBinary, nkIdent, nkBlock
    nkExtern, nkCall, nkBranch

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

  ExternNode* = ref object of Node
    name*: Token
    args*: seq[Token]

  CallNode* = ref object of Node
    name*: Token
    args*: seq[Node]

  BranchNode* = ref object of Node
    cond*: Node
    body*: Node
    elifs*: seq[(Node, Node)]
    elseBody*: Node

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
  of nkExtern:
    let e = ExternNode(n)
    "extern " & $e.name.lexeme & "(" & e.args.mapIt(it.lexeme).join(", ") & ")"
  of nkCall: 
    let c = CallNode(n)
    var parts: seq[string]
    for s in c.args: parts.add $s
    c.name.lexeme & "(" & parts.join(", ") & ")"
  of nkBranch:
    let br = BranchNode(n)
    result = "if " & $br.cond & " " & $br.body
    for (c, b) in br.elifs:
      result.add " elif " & $c & " " & $b
    if br.elseBody != nil:
      result.add " else " & $br.elseBody
    return

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

proc newExternNode*(token: Token, name: Token, args: seq[Token]): ExternNode =
  ExternNode(kind: nkExtern, token: token, name: name, args: args)

proc newCallNode*(token: Token, name: Token, args: seq[Node]): CallNode =
  CallNode(kind: nkCall, token: token, name: name, args: args)

proc newBranchNode*(token: Token, cond: Node, body: Node, elifs: seq[(Node, Node)], elseBody: Node): BranchNode =
  BranchNode(kind: nkBranch, token: token, cond: cond, body: body, elifs: elifs, elseBody: elseBody)