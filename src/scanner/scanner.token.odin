#+private
package scanner

import core "../core"

import "core:text/match"

Token :: core.Token


is_at_end :: proc(s: ^ScannerContext) -> bool {
	return s.current >= len(s.source)
}

advance :: proc(s: ^ScannerContext) -> rune {
	c := s.source[s.current]
	s.current += 1

	return rune(c)
}

peek :: proc(s: ^ScannerContext) -> rune {
	return 0 if is_at_end(s) else rune(s.source[s.current])
}

peek_next :: proc(s: ^ScannerContext) -> rune {
	return 0 if s.current + 1 >= len(s.source) else rune(s.source[s.current + 1])
}

add_token :: proc(s: ^ScannerContext, token: Token) {
	append(&s.tokens, token)
}


scan_token :: proc(s: ^ScannerContext) {
	assert(len(s.source) > 0)

	char := advance(s)
	switch char {
	case '(':
		add_token(s, {type = .LEFT_PAREN, lexeme = "("})
	case ')':
		add_token(s, {type = .RIGHT_PAREN, lexeme = ")"})
	case '\n':
		s.line += 1
		break
	case '\t':
		fallthrough
	case ' ':
		fallthrough
	case '\r':
		break
	case '"':
		read_string(s)
	case ';':
		for peek(s) != '\n' && !is_at_end(s) do advance(s)
	case:
		if match.is_digit(char) do read_number(s)
		else if (char == '-' || char == '+') && match.is_digit(peek(s)) do read_number(s)
		else do read_identifier(s)
	}
}
