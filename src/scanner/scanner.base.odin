#+private
package scanner

import core "../core"

import "core:text/match"

Token :: core.Token

is_digit :: match.is_digit

/*
internal variables
*/
_start: int = 0
_current: int = 0
_line: int = 1

_source: string
tokens: [dynamic]Token

is_at_end :: proc() -> bool {
	return _current >= len(_source)
}

advance :: proc() -> rune {
	c := _source[_current]
	_current += 1

	return rune(c)
}

peek :: proc() -> rune {
	return 0 if is_at_end() else rune(_source[_current])
}

peek_next :: proc() -> rune {
	return 0 if _current + 1 >= len(_source) else rune(_source[_current + 1])
}

add_token :: proc(token: Token) {
	append(&tokens, token)
}


scan_token :: proc() {
	assert(len(_source) > 0)

	char := advance()
	switch char {
	case '(':
		add_token({type = .LEFT_PAREN, lexeme = "("})
	case ')':
		add_token({type = .RIGHT_PAREN, lexeme = ")"})
	case '\n':
		_line += 1
		break
	case '\t':
	case ' ':
	case '\r':
		fallthrough
	case '"':
		read_string()
	case ';':
		for peek() != '\n' && !is_at_end() do advance()
	case:
		if match.is_digit(char) do read_number()
		else if char == '-' && match.is_digit(peek()) do read_number()
		else do read_identifier()
	}
}
