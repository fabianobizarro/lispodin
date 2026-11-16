#+private
package scanner

import core "../core"

read_string :: proc(s: ^ScannerContext) -> (err: core.Error) {

	for peek(s) != '"' && !is_at_end(s) {
		if peek(s) == '\n' do s.line += 1
		advance(s)
	}

	if is_at_end(s) {
		return core.Scanner_Error {
			kind = .Unexpected_EOF,
			line = s.line,
			message = "Unexpected EOF",
		}
	}

	advance(s)

	value := s.source[s.start + 1:s.current - 1]
	add_token(s, {type = .STRING, literal = value, lexeme = value})

	return nil
}
