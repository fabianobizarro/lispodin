#+private
package scanner

import core "../core"

import "core:strconv"
import "core:strings"
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
		else do read_identifier()
	}
}

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

	literal := strconv.parse_f32(literal_text) or_else panic("Failed to case literal value.")

	add_token(Token{type = .NUMBER, lexeme = literal_text, literal = literal})

}

read_identifier :: proc() {
	for match.is_alpha(peek()) do advance()

	text := _source[_start:_current]
	token_type, ok := core.Keywords[text]
	if !ok do token_type = .IDENTIFIER

	add_token({type = token_type, lexeme = text})
}


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
