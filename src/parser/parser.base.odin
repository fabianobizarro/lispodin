#+private
package parser

import core "../core"

peek :: proc(p: ^Parser) -> Token {
	return p.tokens[p.current]
}

peek_next :: proc(p: ^Parser) -> Token {
	if p.current + 1 >= len(p.tokens) do return {type = .EOF}
	else do return p.tokens[p.current + 1]
}

previous :: proc(p: ^Parser) -> Token {
	return p.tokens[p.current - 1]
}

is_at_end :: proc(p: ^Parser) -> bool {
	return peek(p).type == .EOF
}

check :: proc(p: ^Parser, tokenType: TokenType) -> bool {
	return is_at_end(p) ? false : peek(p).type == tokenType
}

check_next :: proc(p: ^Parser, types: ..TokenType) -> bool {
	for t in types {
		if !is_at_end(p) && peek_next(p).type == t {
			return true
		}
	}

	return false
}

advance :: proc(p: ^Parser) -> Token {
	if (!is_at_end(p)) do p.current += 1
	return previous(p)
}

match :: proc(p: ^Parser, types: ..TokenType) -> bool {
	for t in types {
		if (check(p, t)) {
			advance(p)
			return true
		}
	}

	return false
}

consume :: proc(
	p: ^Parser,
	type: TokenType,
	error_message: string,
) -> (
	token: Token,
	err: core.Error,
) {
	if check(p, type) do return advance(p), nil

	return {}, core.Parser_Error{kind = .Unexpected_Token, message = error_message}
}
