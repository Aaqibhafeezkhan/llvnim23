type
  TokenKind* = enum
    tkEOF

    tkNumber
    tkIdent

    tkPlus
    tkMinus
    tkStar
    tkSlash

    tkEquals

    tkLParen
    tkRParen

    tkEOS

  Token* = object
    kind*: TokenKind
    lexeme*: string
    pos*: int

  LexerError* = object of CatchableError

proc newError(msg: string, pos: int) {.noreturn.} =
  raise newException(LexerError, "pos " & $pos & ": " & msg)

proc getch(col: var int, text: string): char =
  if col < text.len:
    result = text[col]
    inc col
  else:
    result = '\0'

proc getTok*(col: var int, text: string): Token =
  while col < text.len and text[col] in {' ', '\t', '\n', '\r'}:
    inc col

  if col >= text.len:
    return Token(kind: tkEOF, lexeme: "", pos: col)

  let start = col
  let c = getch(col, text)

  case c
  of '+': result = Token(kind: tkPlus,   lexeme: "+", pos: start)
  of '-': result = Token(kind: tkMinus,  lexeme: "-", pos: start)
  of '*': result = Token(kind: tkStar,   lexeme: "*", pos: start)
  of '/': result = Token(kind: tkSlash,  lexeme: "/", pos: start)
  of '=': result = Token(kind: tkEquals, lexeme: "=", pos: start)
  of ';': result = Token(kind: tkEOS,    lexeme: ";", pos: start)
  of '(': 
    result = Token(kind: tkLParen, lexeme: "(", pos: start)
  of ')': 
    result = Token(kind: tkRParen, lexeme: ")", pos: start)
  of '0'..'9', '.':
    var dots = 0
    var digits = 0

    if c == '.': inc dots
    else: inc digits

    while col < text.len and text[col] in {'0'..'9', '.'}:
      if text[col] == '.':
        inc dots
      else:
        inc digits
      inc col

    let lexeme = text[start ..< col]

    if dots > 1:
      newError("invalid number: multiple '.' in '" & lexeme & "'", start)
    if digits == 0:
      newError("invalid number: '" & lexeme & "'", start)

    result = Token(kind: tkNumber, lexeme: lexeme, pos: start)
  of 'a'..'z', 'A'..'Z', '_':
    while col < text.len and text[col] in {'a'..'z', 'A'..'Z', '0'..'9', '_'}:
      inc col

    result = Token(kind: tkIdent, lexeme: text[start ..< col], pos: start)
  else:
    newError("Unknown character: " & $c, start)

proc mean*(k: TokenKind): string =
  case k
  of tkEOF:    "end of file"
  of tkNumber: "number"
  of tkIdent:  "identifier"
  of tkPlus:   "plus operator '+'"
  of tkMinus:  "minus operator '-'"
  of tkStar:   "star operator '*'"
  of tkSlash:  "slash operator '/'"
  of tkEquals: "equals operator '='"
  of tkLParen: "left parenthesis '('"
  of tkRParen: "right parenthesis ')'"
  of tkEOS:    "end of statement ';'"

proc mean*(t: Token): string =
  case t.kind
  of tkNumber: "number(" & t.lexeme & ")"
  of tkIdent:  "identifier(" & t.lexeme & ")"
  else:        t.kind.mean()