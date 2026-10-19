package parser

import "../exp"
import tk "../token"
import "core:fmt"
import "core:strings"

Token :: tk.Token
TokenType :: tk.TokenType

@(private)
_tokens: []tk.Token

@(private)
_current: int = 0

peek :: proc() -> Token {
	return _tokens[_current]
}

previous :: proc() -> Token {
	return _tokens[_current - 1]
}

is_at_end :: proc() -> bool {
	return peek().type == .EOF
}

check :: proc(tokenType: TokenType) -> bool {
	return is_at_end() ? false : peek().type == tokenType
}

advance :: proc() -> Token {
	if (!is_at_end()) do _current += 1
	return previous()
}

match :: proc(types: ..TokenType) -> bool {
	for t in types {
		if (check(t)) {
			advance()
			return true
		}
	}

	return false
}


consume :: proc(type: tk.TokenType, error_message: string) -> Token {
	if check(type) do return advance()

	panic(error_message)
}

parse :: proc(tokens: []Token) -> []exp.Expression {
	_tokens = tokens

	expressions := make([dynamic]exp.Expression)

	for !is_at_end() {
		append(&expressions, parse_expression())
	}

	return expressions[:]
}

parse_expression :: proc() -> exp.Expression {

	if match(.LEFT_PAREN) do return parse_list()
	// if (match(.DEF)) do return parse_define_expression()
	if match(.PLUS, .MINUS, .SLASH, .STAR, .PRINT) do return parse_procedure()
	if match(.NUMBER) do return parse_number()


	panic("calma la chefe")

}

parse_number :: proc() -> exp.Literal {
	value := previous()
	lit := value.literal.?.(f32)

	return {value = lit}
}

parse_procedure :: proc() -> exp.Procedure {
	identifier := previous()
	args := make([dynamic]exp.Expression)

	for !check(.RIGHT_PAREN) && !is_at_end() {
		append(&args, parse_expression())
	}

	return {identifier = identifier, args = args[:]}
}

parse_define_expression :: proc() -> exp.Define {
	panic("Not implemented")
}

parse_list :: proc() -> exp.List {
	exps := make([dynamic]exp.Expression)

	for !check(.RIGHT_PAREN) && !is_at_end() {
		append(&exps, parse_expression())
	}

	consume(.RIGHT_PAREN, "Expected ')' at the end of list.")

	return {expressions = exps[:]}
}
