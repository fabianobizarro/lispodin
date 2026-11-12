#+private
package scanner

import "../core"
import "core:text/match"

read_identifier :: proc() {
	for match.is_alpha(peek()) do advance()

	text := _source[_start:_current]
	token_type, ok := core.Keywords[text]
	if !ok do token_type = .IDENTIFIER

	add_token({type = token_type, lexeme = text})
}
