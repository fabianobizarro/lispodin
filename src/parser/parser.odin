package parser

import "../core"

Token :: core.Token
TokenType :: core.TokenType

Parser :: struct {
	tokens:  []Token,
	current: int,
}


parse :: proc(tokens: []Token) -> (exps: []Expression, errs: []core.Error) {

	p: Parser = {
		current = 0,
		tokens  = tokens,
	}

	errors := make([dynamic]core.Error)
	expressions := make([dynamic]Expression)

	for !is_at_end(&p) {
		exp, err := parse_expression(&p)

		if err != nil {
			append(&errors, err)
			advance(&p)
		} else do append(&expressions, exp)

	}

	return expressions[:], errors[:]
}
