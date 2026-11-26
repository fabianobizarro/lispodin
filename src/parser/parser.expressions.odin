#+ private
package parser

import "../core"
import "core:fmt"
import "core:math"

MAX_PARAMS_SIZE :: 100

Error :: core.Error
Parser_Error :: core.Parser_Error

Expression :: core.Expression
LiteralExpression :: core.LiteralExpression
VariableExpression :: core.VariableExpression
LambdaCallExpression :: core.LambdaCallExpression
LambdaExpression :: core.LambdaExpression
IfExpression :: core.IfExpression
PrintExpression :: core.PrintExpression
DefineExpression :: core.DefineExpression
BeginExpression :: core.BeginExpression

parse_expression :: proc(p: ^Parser) -> (exp: Expression, err: Error) {

	if match(p, .LEFT_PAREN) do return parse_block(p)
	else if match(p, .IDENTIFIER) do return parse_variable_expression(p)
	else if match(p, .NUMBER, .STRING, .TRUE, .FALSE) do return parse_literal_expression(p)

	exp = {}
	err = Parser_Error {
		kind    = .Unexpected_Expression,
		message = "Unexpected Expression",
	}
	return
}

// block expression -> any epxression embraced by ( )
parse_block :: proc(p: ^Parser) -> (exp: Expression, err: Error) {

	if match(p, .PRINT) do return parse_print_expression(p)
	else if match(p, .DEF) do return parse_define_expression(p)
	else if match(p, .LAMBDA) do return parse_lambda_expression(p)
	else if match(p, .IF) do return return_parse_if_expression(p)
	else if match(p, .BEGIN) do return parse_begin_expression(p)
	else if match(p, .AND) do return parse_and_expression(p)
	else if match(p, .OR) do return parse_or_expression(p)
	else do return parse_lambda_call_expression(p)
}

parse_or_expression :: proc(p: ^Parser) -> (exp: core.OrExpression, err: Error) {

	exps := make([dynamic]Expression)

	for !check(p, .RIGHT_PAREN) {
		append(&exps, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	exp.expressions = exps[:]
	err = nil

	return
}

parse_and_expression :: proc(p: ^Parser) -> (exp: core.AndExpression, err: Error) {

	exps := make([dynamic]Expression)

	for !check(p, .RIGHT_PAREN) {
		append(&exps, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	exp.expressions = exps[:]
	err = nil

	return
}

parse_begin_expression :: proc(p: ^Parser) -> (exp: BeginExpression, err: Error) {

	exps := make([dynamic]Expression)

	for !check(p, .RIGHT_PAREN) {
		append(&exps, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	exp.expressions = exps[:]
	err = nil
	return
}

parse_define_expression :: proc(p: ^Parser) -> (exp: DefineExpression, err: Error) {
	_ = previous(p)
	name := advance(p)
	value := parse_expression(p) or_return

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	err = nil
	exp.name = name
	exp.value = new(Expression)
	exp.value^ = value

	return
}

parse_print_expression :: proc(p: ^Parser) -> (exp: PrintExpression, err: Error) {

	print_token := previous(p)
	expressions := make([dynamic]Expression)

	for !check(p, .RIGHT_PAREN) && !is_at_end(p) {
		append(&expressions, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	err = nil
	exp = {
		token     = print_token,
		arguments = expressions[:],
	}
	return
}

return_parse_if_expression :: proc(p: ^Parser) -> (exp: IfExpression, err: Error) {

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
	body := make([dynamic]Expression)

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
		append(&body, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the lambda definition") or_return

	exp = {
		params = params[:],
		body   = body[:],
	}
	err = nil
	return
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

	op := parse_expression(p) or_return

	// check if operator is not a literal value
	args := make([dynamic]Expression)

	for !check(p, .RIGHT_PAREN) && !is_at_end(p) {
		append(&args, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')'") or_return

	// exp = {identifier, args[:]}
	exp.operator = new(Expression)
	exp.operator^ = op
	exp.args = args[:]
	err = nil
	return
}
