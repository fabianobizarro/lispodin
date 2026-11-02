package parser


parse :: proc(tokens: []Token) -> []Statement {
	_tokens = tokens

	statements := make([dynamic]Statement)

	for !is_at_end() {
		append(&statements, parse_statement())
	}

	return statements[:]
}

parse_teste :: proc() {}
