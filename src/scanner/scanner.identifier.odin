#+private
package scanner

import "../core"
import "core:slice"
import "core:text/match"
import "core:unicode"


FORBIDDEN_CHARS :: []rune{' ', '(', ')', ';'}
ALLOWED_CHARS :: []rune{'?', '_', '-', '!', '*', '=', '/', '+', '.'}

is_valid_rune :: proc(r: rune) -> bool {
	return(
		!match.is_cntrl(r) &&
		!slice.contains(FORBIDDEN_CHARS, r) &&
		(match.is_alnum(r) || slice.contains(ALLOWED_CHARS, r) || unicode.is_graphic(r)) \
	)
}


read_identifier :: proc(s: ^ScannerContext) {

	for is_valid_rune(peek(s)) do advance(s)


	text := s.source[s.start:s.current]
	token_type, ok := core.Keywords[text]
	if !ok do token_type = .IDENTIFIER

	add_token(s, {type = token_type, lexeme = text})
}
