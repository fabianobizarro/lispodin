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
IfExpression :: core.IfExpression

parse_expression :: proc(p: ^Parser) -> (exp: Expression, err: Error) {

	if match(p, .LAMBDA) do return parse_lambda_expression(p)
	else if check_next(p, .IF) do return return_parse_if_expression(p)
	else if match(p, .NUMBER, .STRING, .TRUE, .FALSE) do return parse_literal_expression(p)
	else if match(p, .IDENTIFIER) do return parse_variable_expression(p)
	else if match(p, .LEFT_PAREN) do return parse_lambda_call_expression(p)

	exp = {}
	err = Parser_Error {
		kind    = .Unexpected_Expression,
		message = "Unexpected Expression",
	}
	return
}

return_parse_if_expression :: proc(p: ^Parser) -> (exp: IfExpression, err: Error) {

	//if
	consume(p, .LEFT_PAREN, "Expected '(' at the beginning of the expression") or_return
	consume(p, .IF, "Expected 'if' keyword at the beginning of the expression") or_return

	condition := parse_expression(p) or_return
	then_branch := parse_expression(p) or_return
	else_branch: ^Expression

	if !check(p, .RIGHT_PAREN) {
		else_branch = new(Expression)
		else_branch^ = parse_expression(p) or_return
	}

	consume(
		p,
		.RIGHT_PAREN,
		fmt.aprintf("Expected ')' at the end of the `if` expression, got `%s`", peek(p).lexeme),
	) or_return


	exp.condition = new(Expression)
	exp.condition^ = condition

	exp.then_branch = new(Expression)
	exp.then_branch^ = then_branch

	exp.else_branch = else_branch

	err = nil
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

	if check(p, .RIGHT_PAREN) {
		err = Parser_Error {
			kind    = .Lambda_Body_Expected,
			message = "Lambda body expected.",
		}
		return
	}

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
