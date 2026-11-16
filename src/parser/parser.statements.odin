#+ private
package parser


import "../core"

Statement :: core.Statement
DefineStatement :: core.DefineStatement
PrintStatement :: core.PrintStatement
ExpressionStatement :: core.ExpressionStatement

Error :: core.Error
Parser_Error :: core.Parser_Error

parse_statement :: proc(p: ^Parser) -> (stmt: Statement, err: Error) {

	if check_next(p, .PRINT) do return parse_print_statement(p)
	else if check_next(p, .DEF) do return parse_define_statement(p)
	else do return parse_expression_statement(p)
}

parse_print_statement :: proc(p: ^Parser) -> (stmt: PrintStatement, err: Error) {
	consume(p, .LEFT_PAREN, "Expected '(' at the beginning of the list") or_return

	print_token := advance(p)

	expressions := make([dynamic]Expression)


	for !check(p, .RIGHT_PAREN) && !is_at_end(p) {
		append(&expressions, parse_expression(p) or_return)
	}

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	err = nil
	stmt = {
		token     = print_token,
		arguments = expressions[:],
	}
	return
}


parse_define_statement :: proc(p: ^Parser) -> (stmt: DefineStatement, err: Error) {
	consume(p, .LEFT_PAREN, "Expected '(' at the beginning of the list") or_return

	_ = advance(p)
	name := advance(p)
	value := parse_expression(p) or_return

	consume(p, .RIGHT_PAREN, "Expected ')' at the end of the list") or_return

	err = nil
	stmt = {name, value}
	return
}

parse_expression_statement :: proc(p: ^Parser) -> (stmt: ExpressionStatement, err: Error) {

	expression := parse_expression(p) or_return

	return {expression}, nil
}
