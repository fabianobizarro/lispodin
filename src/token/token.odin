package token

TokenType :: enum {
	LEFT_PAREN,
	RIGHT_PAREN,
	PLUS,
	MINUS,
	SLASH,
	STAR,

	// LITERALS
	STRING,
	NUMBER,
	IDENTIFIER,

	// KEYWORDS
	// DEF,
	PRINT,
	EOF,
}


Token :: struct {
	type:    TokenType,
	lexeme:  string,
	literal: Maybe(LiteralType),
}


LiteralType :: union {
	f32,
	string,
}
