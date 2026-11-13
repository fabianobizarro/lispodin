#+private
package scanner

import "core:strconv"
import "core:text/match"

is_digit :: match.is_digit

read_number :: proc(s: ^ScannerContext) {
	for is_digit(peek(s)) do advance(s)

	if peek(s) == '.' && is_digit(peek_next(s)) {
		advance(s) // pula o ponto
		for is_digit(peek(s)) do advance(s)
	}

	literal_text := s.source[s.start:s.current]
	literal := strconv.parse_f32(literal_text) or_else panic("Failed to parse literal value.")

	add_token(s, Token{type = .NUMBER, lexeme = literal_text, literal = literal})

}
