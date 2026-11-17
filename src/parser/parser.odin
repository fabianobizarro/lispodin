package parser

import "../core"

Token :: core.Token
TokenType :: core.TokenType

Parser :: struct {
	tokens:  []Token,
	current: int,
}


parse :: proc(tokens: []Token) -> (stmts: []Statement, errs: []core.Error) {

	p: Parser = {
		current = 0,
		tokens  = tokens,
	}

	errors := make([dynamic]core.Error)
	statements := make([dynamic]Statement)

	for !is_at_end(&p) {
		stmt, err := parse_statement(&p)

		if err != nil {
			append(&errors, err)
			advance(&p)
		} else do append(&statements, stmt)

	}

	return statements[:], errors[:]
}
