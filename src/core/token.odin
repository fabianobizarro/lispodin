package core

TokenType :: enum {
	LEFT_PAREN,
	RIGHT_PAREN,

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
	IF,
	BEGIN,
	AND,
	OR,
	EOF,
}

Token :: struct {
	type:    TokenType,
	lexeme:  string,
	literal: Maybe(LiteralValue),
}
