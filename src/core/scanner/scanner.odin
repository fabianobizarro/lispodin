package scanner

tokenize :: proc(source: string) -> []Token {
	_current = 0
	_line = 1
	_source = source

	tokens = make([dynamic]Token)
	for !is_at_end() {
		_start = _current
		scan_token()
	}

	add_token({type = .EOF})

	return tokens[:]
}
