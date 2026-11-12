#+private
package scanner

read_string :: proc() {

	for peek() != '"' && !is_at_end() {
		if peek() == '\n' do _line += 1
		advance()
	}

	if is_at_end() {
		panic("Unterminated string.")
	}

	advance()

	value := _source[_start + 1:_current - 1]
	add_token({type = .STRING, literal = value, lexeme = value})
}
