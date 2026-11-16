#+ private
package parser

import "../core"
import "core:fmt"

MAX_PARAMS_SIZE :: 100

Expression :: core.Expression
LiteralExpression :: core.LiteralExpression
VariableExpression :: core.VariableExpression
LambdaCallExpression :: core.LambdaCallExpression
LambdaExpression :: core.LambdaExpression

parse_expression :: proc(p: ^Parser) -> (exp: Expression, err: Error) {

	if match(p, .LAMBDA) do return parse_lambda_expression(p)
	else if match(p, .LEFT_PAREN) do return parse_lambda_call_expression(p)
	else if match(p, .NUMBER, .STRING, .TRUE, .FALSE) do return parse_literal_expression(p)
	else if match(p, .IDENTIFIER) do return parse_variable_expression(p)

	exp = {}
	err = Parser_Error {
		kind    = .Unexpected_Expression,
		message = "Unexpected Expression",
	}
	return
}


parse_lambda_expression :: proc(p: ^Parser) -> (exp: LambdaExpression, err: Error) {

	params := make([dynamic]Token)
	body := make([dynamic]Statement)

	/**
	Parsing parameters
	*/
	consume(p, .LEFT_PAREN, "Expected '(' at the beginning of the parameters list") or_return

	for !check(p, .RIGHT_PAREN) {

		if len(params) > MAX_PARAMS_SIZE {
			// fmt.panicf("Can't have more than %d parameters.", MAX_PARAMS_SIZE)
			exp = {}
			err = Parser_Error {
				kind    = .Max_Parameters_Length,
				message = fmt.aprintf("Can't have more than %d parameters.", MAX_PARAMS_SIZE),
			}
			return
		}

		append(&params, advance(p))
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the beginning of the parameters list") or_return

	/*
	* Parsing body
	*/

	if check(p, .RIGHT_PAREN) do panic("Lambda body expected.")

	for !check(p, .RIGHT_PAREN) {
		append(&body, parse_statement(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the lambda definition") or_return

	return {params = params[:], body = body[:]}, nil
}

parse_variable_expression :: proc(p: ^Parser) -> (exp: VariableExpression, err: Error) {

	name := previous(p)

	return {name = name.lexeme}, nil
}

parse_literal_expression :: proc(p: ^Parser) -> (exp: LiteralExpression, err: Error) {

	token := previous(p)


	if token.type == .TRUE do exp.value = true
	else if token.type == .FALSE do exp.value = false
	else do exp.value = token.literal

	return exp, nil
}


parse_lambda_call_expression :: proc(p: ^Parser) -> (exp: LambdaCallExpression, err: Error) {

	identifier := advance(p)

	args := make([dynamic]Expression)

	for !check(p, .RIGHT_PAREN) && !is_at_end(p) {
		append(&args, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')'") or_return

	exp = {identifier, args[:]}
	err = nil
	return
}
