#+private
package scanner

read_string :: proc(s: ^ScannerContext) {

	for peek(s) != '"' && !is_at_end(s) {
		if peek(s) == '\n' do s.line += 1
		advance(s)
	}

	if is_at_end(s) {
		panic("Unterminated string.")
	}

	advance(s)

	value := s.source[s.start + 1:s.current - 1]
	add_token(s, {type = .STRING, literal = value, lexeme = value})
}
