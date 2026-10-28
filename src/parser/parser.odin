package parser

import "../exp"
import stmt "../stmt"
import tk "../token"

Token :: tk.Token
TokenType :: tk.TokenType

@(private)
_tokens: []tk.Token

@(private)
_current: int = 0

peek :: proc() -> Token {
	return _tokens[_current]
}

peek_next :: proc() -> Token {
	if _current + 1 >= len(_tokens) do return {type = .EOF}
	else do return _tokens[_current + 1]
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

check_next :: proc(types: ..TokenType) -> bool {
	for t in types {
		if !is_at_end() && peek_next().type == t {
			return true
		}
	}

	return false
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

parse :: proc(tokens: []Token) -> []stmt.Statement {
	_tokens = tokens

	statements := make([dynamic]stmt.Statement)

	for !is_at_end() {
		append(&statements, parse_statement())
	}

	return statements[:]
}


parse_statement :: proc() -> stmt.Statement {

	if check_next(.PRINT) do return parse_print_statement()
	if check_next(.DEF) do return parse_define_statement()

	return parse_expression_statement()
}


parse_define_statement :: proc() -> stmt.Define {
	consume(.LEFT_PAREN, "Expected '(' at the beginning of the list")

	identifier := advance()
	name := advance()
	value := parse_expression()

	consume(.RIGHT_PAREN, "Expected ')' at the end of the list")

	return {name, value}
}

parse_print_statement :: proc() -> stmt.Print {
	consume(.LEFT_PAREN, "Expected '(' at the beginning of the list")
	// print keyword
	token := advance()

	expressions := make([dynamic]exp.Expression)


	for !check(.RIGHT_PAREN) && !is_at_end() {
		append(&expressions, parse_expression())
	}

	consume(.RIGHT_PAREN, "Expected ')' at the end of the list")

	return {token = token, arguments = expressions[:]}
}

parse_expression_statement :: proc() -> stmt.Expression {

	// consume(.LEFT_PAREN, "Expected '('")

	expression := parse_expression()

	// consume(.RIGHT_PAREN, "Expected ')'")

	return {expression}
}


parse_expression :: proc() -> exp.Expression {

	if match(.LEFT_PAREN) do return parse_function_call()
	else if match(.NUMBER, .STRING, .TRUE, .FALSE) do return parse_literal_expression()
	else if match(.IDENTIFIER) do return parse_variable_expression()

	panic("Unexpected Expression")
}


parse_variable_expression :: proc() -> exp.Variable {

	name := previous()

	return {name = name.lexeme}
}

parse_literal_expression :: proc() -> exp.Literal {

	token := previous()

	return {value = token.literal}
}

parse_function_call :: proc() -> exp.FunctionCall {

	identifier := advance()

	args := make([dynamic]exp.Expression)

	for !check(.RIGHT_PAREN) && !is_at_end() {
		append(&args, parse_expression())
	}

	consume(.RIGHT_PAREN, "Expected ')'")

	return {identifier, args[:]}
}
//
// parse_builtin_operations :: proc() -> exp.FunctionCall {
//
// 	consume(.LEFT_PAREN, "Expected '('")
// 	operator := advance()
// 	args := make([dynamic]exp.Expression)
//
// 	for !check(.RIGHT_PAREN) && !is_at_end() {
// 		append(&args, parse_expression())
// 	}
//
// 	consume(.RIGHT_PAREN, "Expected ')'")
//
// 	return {identifier = operator, args = args[:]}
// }
