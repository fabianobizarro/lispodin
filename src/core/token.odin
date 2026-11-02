package core

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
	TRUE,
	FALSE,
	IDENTIFIER,

	// KEYWORDS
	DEF,
	PRINT,
	LAMBDA,
	EOF,
}

Token :: struct {
	type:    TokenType,
	lexeme:  string,
	literal: Maybe(LiteralValue),
}
