#+private
package scanner

import "../core"
import "core:fmt"
import "core:strconv"
import "core:text/match"

is_digit :: match.is_digit

read_number :: proc(s: ^ScannerContext) -> (err: core.Error) {
	for is_digit(peek(s)) do advance(s)

	if peek(s) == '.' && is_digit(peek_next(s)) {
		advance(s) // skip the dot
		for is_digit(peek(s)) do advance(s)
	}

	literal_text := s.source[s.start:s.current]
	literal, ok := strconv.parse_f32(literal_text)
	if !ok {
		return core.Scanner_Error {
			kind = .Literal_Number_Parse,
			line = s.line,
			message = fmt.aprintf("Failed to parse '%s' as a number.", literal_text),
		}
	}

	add_token(s, Token{type = .NUMBER, lexeme = literal_text, literal = literal})

	return nil
}
