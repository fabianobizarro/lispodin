#+private
package parser

import core "../"
import t "../token"
import "core:fmt"

Token :: t.Token
TokenType :: t.TokenType

Statement :: core.Statement
DefineStatement :: core.DefineStatement
PrintStatement :: core.PrintStatement
ExpressionStatement :: core.ExpressionStatement

Expression :: core.Expression
LiteralExpression :: core.LiteralExpression
VariableExpression :: core.VariableExpression
LambdaCallExpression :: core.LambdaCallExpression
LambdaExpression :: core.LambdaExpression

MAX_PARAMS_SIZE :: 100


@(private)
_tokens: []Token

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

consume :: proc(type: TokenType, error_message: string) -> Token {
	if check(type) do return advance()

	panic(error_message)
}


parse_statement :: proc() -> Statement {

	if check_next(.PRINT) do return parse_print_statement()
	else if check_next(.DEF) do return parse_define_statement()
	else do return parse_expression_statement()
}

parse_lambda_expression :: proc() -> LambdaExpression {

	consume(.LEFT_PAREN, "Expected '(' at the beginning of the list")

	lambda := advance()

	params := make([dynamic]Token)
	body := make([dynamic]Statement)

	/**
	Parsing parameters
	*/
	consume(.LEFT_PAREN, "Expected '(' at the beginning of the parameters list")

	for !check(.RIGHT_PAREN) {

		if len(params) > MAX_PARAMS_SIZE do fmt.panicf("Can't have more than %d parameters.", MAX_PARAMS_SIZE)

		append(&params, peek())
	}

	consume(.RIGHT_PAREN, "Expected ')' at the beginning of the parameters list")

	/*
	* Parsing body
	*/

	if check(.RIGHT_PAREN) do panic("Lambda body expected.")

	for !check(.RIGHT_PAREN) {
		append(&body, parse_statement())
	}

	consume(.RIGHT_PAREN, "Expected ')' at the end of the lambda definition")

	return {params = params[:], body = body[:]}
}

parse_define_statement :: proc() -> DefineStatement {
	consume(.LEFT_PAREN, "Expected '(' at the beginning of the list")

	identifier := advance()
	name := advance()
	value := parse_expression()

	consume(.RIGHT_PAREN, "Expected ')' at the end of the list")

	return {name, value}
}

parse_print_statement :: proc() -> PrintStatement {
	consume(.LEFT_PAREN, "Expected '(' at the beginning of the list")
	// print keyword
	token := advance()

	expressions := make([dynamic]Expression)


	for !check(.RIGHT_PAREN) && !is_at_end() {
		append(&expressions, parse_expression())
	}

	consume(.RIGHT_PAREN, "Expected ')' at the end of the list")

	return {token = token, arguments = expressions[:]}
}

parse_expression_statement :: proc() -> ExpressionStatement {

	expression := parse_expression()

	return {expression}
}

parse_expression :: proc() -> Expression {

	if check_next(.LAMBDA) do return parse_lambda_expression()
	else if match(.LEFT_PAREN) do return parse_function_call()
	else if match(.NUMBER, .STRING, .TRUE, .FALSE) do return parse_literal_expression()
	else if match(.IDENTIFIER) do return parse_variable_expression()

	panic("Unexpected Expression")
}

parse_variable_expression :: proc() -> VariableExpression {

	name := previous()

	return {name = name.lexeme}
}

parse_literal_expression :: proc() -> LiteralExpression {

	token := previous()

	return {value = token.literal}
}

parse_function_call :: proc() -> LambdaCallExpression {

	identifier := advance()

	args := make([dynamic]Expression)

	for !check(.RIGHT_PAREN) && !is_at_end() {
		append(&args, parse_expression())
	}

	consume(.RIGHT_PAREN, "Expected ')'")

	return {identifier, args[:]}
}
