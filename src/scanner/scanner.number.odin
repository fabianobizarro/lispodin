#+private
package scanner

import "core:strconv"
import "core:strings"

read_number :: proc() {
	for is_digit(peek()) do advance()

	if peek() == '.' && is_digit(peek_next()) {
		advance() // pula o ponto
		for is_digit(peek()) do advance()
	}

	literal_text :=
		strings.substring(_source, _start, _current) or_else panic(
			"Failed to retrieve literal value",
		)

	literal := strconv.parse_f32(literal_text) or_else panic("Failed to parse literal value.")

	add_token(Token{type = .NUMBER, lexeme = literal_text, literal = literal})

}
