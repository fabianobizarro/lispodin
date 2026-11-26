package parser_tests

import "../../src/core"
import parser "../../src/parser"
import scanner "../../src/scanner"
import "core:testing"

// A stray ')' reports one parser error and the parser terminates.
// Before the recovery fix this input made the parse loop retry the same
// token forever.

@(test)
stray_right_paren_reports_one_error :: proc(t: ^testing.T) {
	// arrange
	scan_errors: []core.Error
	program := ")"
	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens, scan_errors = scanner.tokenize(program)
	testing.expect_value(t, len(scan_errors), 0)

	expressions, parse_errors := parser.parse(tokens)
	defer delete(expressions)
	defer delete(parse_errors)

	// assert
	testing.expect_value(t, len(expressions), 0)
	testing.expect_value(t, len(parse_errors), 1)

	parser_err, ok := parse_errors[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)
	testing.expect_value(t, parser_err.message, "Unexpected Expression")
}

// A call left open at the end of the input reports an unexpected token error.

@(test)
unterminated_call_reports_error :: proc(t: ^testing.T) {
	// arrange
	scan_errors: []core.Error
	program := "(+ 1"
	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens, scan_errors = scanner.tokenize(program)
	testing.expect_value(t, len(scan_errors), 0)

	expressions, parse_errors := parser.parse(tokens)
	defer delete(expressions)
	defer delete(parse_errors)

	// assert
	testing.expect_value(t, len(expressions), 0)
	testing.expect_value(t, len(parse_errors), 1)

	parser_err, ok := parse_errors[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Token)
	testing.expect_value(t, parser_err.message, "Expected ')'")
}

// A lambda without a body reports Lambda_Body_Expected. The token-level
// recovery may add a follow-up error for the leftover tokens; the first
// error is the meaningful one (see issue #19 for the recovery work).

@(test)
lambda_without_body_reports_error :: proc(t: ^testing.T) {
	// arrange
	scan_errors: []core.Error
	program := "((lambda (x)) 1)"
	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens, scan_errors = scanner.tokenize(program)
	testing.expect_value(t, len(scan_errors), 0)

	expressions, parse_errors := parser.parse(tokens)
	defer delete(expressions)
	defer delete(parse_errors)

	// assert
	testing.expect(t, len(parse_errors) > 0)

	parser_err, ok := parse_errors[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Lambda_Body_Expected)
	testing.expect_value(t, parser_err.message, "Lambda body expected.")
}

// (def x) with no value reports an unexpected expression error.

@(test)
define_missing_value_reports_error :: proc(t: ^testing.T) {
	// arrange
	scan_errors: []core.Error
	program := "(def x)"
	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens, scan_errors = scanner.tokenize(program)
	testing.expect_value(t, len(scan_errors), 0)

	expressions, parse_errors := parser.parse(tokens)
	defer delete(expressions)
	defer delete(parse_errors)

	// assert
	testing.expect_value(t, len(expressions), 0)
	testing.expect_value(t, len(parse_errors), 1)

	parser_err, ok := parse_errors[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)
	testing.expect_value(t, parser_err.message, "Unexpected Expression")
}

// After an error the parser recovers and still parses the next valid
// expression.

@(test)
recovery_parses_expression_after_error :: proc(t: ^testing.T) {
	// arrange
	scan_errors: []core.Error
	program := ")\n(+ 1 2)"
	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens, scan_errors = scanner.tokenize(program)
	testing.expect_value(t, len(scan_errors), 0)

	expressions, parse_errors := parser.parse(tokens)
	defer delete(expressions)
	defer delete(parse_errors)

	// assert
	testing.expect_value(t, len(parse_errors), 1)
	testing.expect_value(t, len(expressions), 1)

	parser_err, ok := parse_errors[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)

	call, is_call := expressions[0].(core.LambdaCallExpression)
	testing.expect(t, is_call)

	operator, is_var := call.operator^.(core.VariableExpression)
	testing.expect(t, is_var)
	testing.expect_value(t, operator.name, "+")
	testing.expect_value(t, len(call.args), 2)
}
