package parser_tests

import "../../src/core"
import parser "../../src/parser"
import scanner "../../src/scanner"
import "core:fmt"
import "core:strings"
import "core:testing"

// Structural parser tests: the AST shapes produced for each form. The
// companion file parser_error_tests.odin covers error paths; these pin the
// happy path — operator expressions, parameter and body lists, if branch
// pointers, and the boundaries of the parameter limit.

// Tokenizes and parses a source string, asserting that scanning succeeded.

@(private)
parse_source :: proc(
	t: ^testing.T,
	source: string,
) -> (
	exps: []core.Expression,
	errs: []core.Error,
) {
	tokens, scan_errs := scanner.tokenize(source)
	defer delete(tokens)
	testing.expect_value(t, len(scan_errs), 0)

	exps, errs = parser.parse(tokens)
	return
}

// Builds "(lambda (p0 p1 ... p{n-1}) x)" with n parameters.

@(private)
lambda_with_params :: proc(n: int) -> string {
	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	strings.write_string(&builder, "(lambda (")
	for i in 0 ..< n {
		if i > 0 do strings.write_rune(&builder, ' ')
		param := fmt.aprintf("p%d", i)
		strings.write_string(&builder, param)
		delete(param)
	}
	strings.write_string(&builder, ") x)")

	view := strings.to_string(builder)
	return fmt.aprint("%s", view)
}

// ---------------------------------------------------------------------------
// empty and trivial sources
// ---------------------------------------------------------------------------

@(test)
empty_source_produces_no_expressions :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(exps), 0)
	testing.expect_value(t, len(errs), 0)
}

@(test)
comment_only_source_produces_no_expressions :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "; just a comment\n")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(exps), 0)
	testing.expect_value(t, len(errs), 0)
}

// ---------------------------------------------------------------------------
// atoms
// ---------------------------------------------------------------------------

@(test)
number_literal_parses_value :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "42")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	lit, ok := exps[0].(core.LiteralExpression)
	testing.expect(t, ok)

	value, has_value := lit.value.?
	testing.expect(t, has_value)
	testing.expect_value(t, value, 42)
}

@(test)
string_literal_parses_value :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "\"hi\"")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	lit, ok := exps[0].(core.LiteralExpression)
	testing.expect(t, ok)

	value, has_value := lit.value.?
	testing.expect(t, has_value)
	testing.expect_value(t, value, "hi")
}

@(test)
boolean_literals_parse_values :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "true")
	defer delete(exps)
	defer delete(errs)
	testing.expect_value(t, len(errs), 0)
	lit, ok := exps[0].(core.LiteralExpression)
	testing.expect(t, ok)
	value, _ := lit.value.?
	testing.expect_value(t, value, true)

	exps2, errs2 := parse_source(t, "false")
	defer delete(exps2)
	defer delete(errs2)
	testing.expect_value(t, len(errs2), 0)
	lit2, ok2 := exps2[0].(core.LiteralExpression)
	testing.expect(t, ok2)
	value2, _ := lit2.value.?
	testing.expect_value(t, value2, false)
}

@(test)
identifier_parses_variable_expression :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "my-var")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	variable, ok := exps[0].(core.VariableExpression)
	testing.expect(t, ok)
	testing.expect_value(t, variable.name, "my-var")
}

// ---------------------------------------------------------------------------
// calls
// ---------------------------------------------------------------------------

@(test)
call_with_no_arguments_parses :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(f)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	call, ok := exps[0].(core.LambdaCallExpression)
	testing.expect(t, ok)

	operator, is_var := call.operator^.(core.VariableExpression)
	testing.expect(t, is_var)
	testing.expect_value(t, operator.name, "f")
	testing.expect_value(t, len(call.args), 0)
}

// The operator position accepts any expression — here a nested call.

@(test)
call_with_nested_call_operator :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "((f) 1)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	call, ok := exps[0].(core.LambdaCallExpression)
	testing.expect(t, ok)
	testing.expect_value(t, len(call.args), 1)

	inner, is_call := call.operator^.(core.LambdaCallExpression)
	testing.expect(t, is_call)
	testing.expect_value(t, len(inner.args), 0)
}

@(test)
nested_call_arguments_parse :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(+ (* 1 2) (- 3 4))")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	call, ok := exps[0].(core.LambdaCallExpression)
	testing.expect(t, ok)

	operator, is_var := call.operator^.(core.VariableExpression)
	testing.expect(t, is_var)
	testing.expect_value(t, operator.name, "+")
	testing.expect_value(t, len(call.args), 2)

	mul, mul_ok := call.args[0].(core.LambdaCallExpression)
	testing.expect(t, mul_ok)
	mul_op, _ := mul.operator^.(core.VariableExpression)
	testing.expect_value(t, mul_op.name, "*")

	sub, sub_ok := call.args[1].(core.LambdaCallExpression)
	testing.expect(t, sub_ok)
	sub_op, _ := sub.operator^.(core.VariableExpression)
	testing.expect_value(t, sub_op.name, "-")
}

// ---------------------------------------------------------------------------
// lambdas
// ---------------------------------------------------------------------------

@(test)
lambda_zero_params_single_body_parses :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(lambda () 1)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	lambda, ok := exps[0].(core.LambdaExpression)
	testing.expect(t, ok)
	testing.expect_value(t, len(lambda.params), 0)
	testing.expect_value(t, len(lambda.body), 1)
}

@(test)
lambda_params_and_multi_body_parse :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(lambda (a b) a b)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	lambda, ok := exps[0].(core.LambdaExpression)
	testing.expect(t, ok)
	testing.expect_value(t, len(lambda.params), 2)
	testing.expect_value(t, lambda.params[0].lexeme, "a")
	testing.expect_value(t, lambda.params[1].lexeme, "b")
	testing.expect_value(t, len(lambda.body), 2)
}

// REGRESSION GUARD: the parameter limit is MAX_PARAMS_SIZE = 100 ("at most
// 100 parameters", LANGUAGE_SPECS.md section 5.3), but the check in the
// parser is off by one — it fires only from 102 parameters on, so a lambda
// with exactly 101 parameters is silently accepted. This test asserts the
// intended limit and FAILS against the current implementation; the fix is
// `len(params) >= MAX_PARAMS_SIZE` (checked before appending).

@(test)
lambda_with_101_params_reports_max_params_error :: proc(t: ^testing.T) {
	// arrange
	source := lambda_with_params(101)

	// act
	exps, errs := parse_source(t, source)
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 1)
	if len(errs) == 0 do return

	parser_err, ok := errs[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Max_Parameters_Length)
	testing.expect_value(t, parser_err.message, "Can't have more than 100 parameters.")
	delete(parser_err.message)
}

// The boundary from above: 102 parameters already report the error today.
// The first error is the limit; the exact total count also depends on the
// naive recovery tracked in issue #19, so only the first error is pinned.

@(test)
lambda_with_102_params_reports_max_params_error :: proc(t: ^testing.T) {
	// arrange
	source := lambda_with_params(102)

	// act
	exps, errs := parse_source(t, source)
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect(t, len(errs) >= 1)
	if len(errs) == 0 do return

	parser_err, ok := errs[0].(core.Parser_Error)
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Max_Parameters_Length)
	testing.expect_value(t, parser_err.message, "Can't have more than 100 parameters.")
	delete(parser_err.message)
}

// ---------------------------------------------------------------------------
// if
// ---------------------------------------------------------------------------

@(test)
if_without_else_has_nil_else_branch :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(if c t)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	if_exp, ok := exps[0].(core.IfExpression)
	testing.expect(t, ok)
	testing.expect(t, if_exp.else_branch == nil)

	condition, cond_is_var := if_exp.condition^.(core.VariableExpression)
	testing.expect(t, cond_is_var)
	testing.expect_value(t, condition.name, "c")

	then_branch, then_is_var := if_exp.then_branch^.(core.VariableExpression)
	testing.expect(t, then_is_var)
	testing.expect_value(t, then_branch.name, "t")
}

@(test)
if_with_else_parses_all_three :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(if c t e)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	if_exp, ok := exps[0].(core.IfExpression)
	testing.expect(t, ok)
	testing.expect(t, if_exp.else_branch != nil)

	else_branch, else_is_var := if_exp.else_branch^.(core.VariableExpression)
	testing.expect(t, else_is_var)
	testing.expect_value(t, else_branch.name, "e")
}

// ---------------------------------------------------------------------------
// begin / and / or / print / display
// ---------------------------------------------------------------------------

@(test)
begin_parses_expression_list :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(begin)")
	defer delete(exps)
	defer delete(errs)
	testing.expect_value(t, len(errs), 0)
	begin, ok := exps[0].(core.BeginExpression)
	testing.expect(t, ok)
	testing.expect_value(t, len(begin.expressions), 0)

	exps2, errs2 := parse_source(t, "(begin 1 2 3)")
	defer delete(exps2)
	defer delete(errs2)
	testing.expect_value(t, len(errs2), 0)
	begin2, ok2 := exps2[0].(core.BeginExpression)
	testing.expect(t, ok2)
	testing.expect_value(t, len(begin2.expressions), 3)
}

@(test)
and_or_parse_expression_lists :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(and 1 2)")
	defer delete(exps)
	defer delete(errs)
	testing.expect_value(t, len(errs), 0)
	and_exp, ok := exps[0].(core.AndExpression)
	testing.expect(t, ok)
	testing.expect_value(t, len(and_exp.expressions), 2)

	exps2, errs2 := parse_source(t, "(or)")
	defer delete(exps2)
	defer delete(errs2)
	testing.expect_value(t, len(errs2), 0)
	or_exp, ok2 := exps2[0].(core.OrExpression)
	testing.expect(t, ok2)
	testing.expect_value(t, len(or_exp.expressions), 0)
}

// display is an alias for print: both parse into the same node kind.

@(test)
print_and_display_parse_same_node :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(print)")
	defer delete(exps)
	defer delete(errs)
	testing.expect_value(t, len(errs), 0)
	print_exp, ok := exps[0].(core.PrintExpression)
	testing.expect(t, ok)
	testing.expect_value(t, len(print_exp.arguments), 0)

	exps2, errs2 := parse_source(t, "(display 1 2)")
	defer delete(exps2)
	defer delete(errs2)
	testing.expect_value(t, len(errs2), 0)
	display_exp, ok2 := exps2[0].(core.PrintExpression)
	testing.expect(t, ok2)
	testing.expect_value(t, len(display_exp.arguments), 2)
}

// ---------------------------------------------------------------------------
// def
// ---------------------------------------------------------------------------

@(test)
def_parses_name_and_value :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(def x (+ 1 2))")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	def, ok := exps[0].(core.DefineExpression)
	testing.expect(t, ok)
	testing.expect_value(t, def.name.lexeme, "x")

	value, is_call := def.value^.(core.LambdaCallExpression)
	testing.expect(t, is_call)
	testing.expect_value(t, len(value.args), 2)
}

// QUIRK: the parser does not validate that a def name is an IDENTIFIER —
// keywords, numbers, and strings are all accepted and silently bound to
// names that can never be looked up. Pinned as-is; flagged for a decision
// (validate `def.name` in parse_define_expression and report a parse error).

@(test)
def_name_is_not_validated :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(def if 1)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect_value(t, len(errs), 0)
	def, ok := exps[0].(core.DefineExpression)
	testing.expect(t, ok)
	testing.expect_value(t, def.name.lexeme, "if")
}

// ---------------------------------------------------------------------------
// keywords in expression position
// ---------------------------------------------------------------------------

// A bare keyword is not an expression, so using one as an argument reports
// parse errors. Pinned loosely (at least one Unexpected_Expression error)
// because the exact error count depends on the recovery behavior tracked
// in issue #19.

@(test)
keyword_in_argument_position_reports_error :: proc(t: ^testing.T) {
	// act
	exps, errs := parse_source(t, "(+ if 1)")
	defer delete(exps)
	defer delete(errs)

	// assert
	testing.expect(t, len(errs) >= 1)
	found := false
	for err in errs {
		parser_err, ok := err.(core.Parser_Error)
		if ok && parser_err.kind == .Unexpected_Expression {
			found = true
		}
	}
	testing.expect(t, found)
}
