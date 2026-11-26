package interpreter_tests

import core "../../src/core"
import env "../../src/environment"
import "core:testing"

// End-to-end tests for the "if" special form: source string through
// scanner, parser, and interpreter, against a global environment set up the
// same way as src/global_env.odin. Uses the evaluate_source and
// make_global_env helpers from interpreter_error_tests.odin (same package).
//
// Semantics as implemented (and pinned here):
// - Only the taken branch is evaluated (lazy) — dead branches can contain
//   errors that never fire.
// - The condition is always evaluated — its errors propagate.
// - Truthiness is C-style: false, 0, and "" are falsy; everything else is
//   truthy.
// - The else branch is optional: with no alternative and a falsy
//   condition, `if` produces no value.
// - Arity is enforced by the parser: exactly one condition + one
//   consequent + at most one alternative.

// ---------------------------------------------------------------------------
// basic branch selection
// ---------------------------------------------------------------------------

@(test)
if_true_takes_then_branch :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_false_takes_else_branch :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if false 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

// Each literal type can be a branch value.

@(test)
if_branches_return_booleans :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true true false)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
if_else_branch_returns_string :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if false 1 \"a\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "a")
}

// ---------------------------------------------------------------------------
// comparison operators as conditions
// ---------------------------------------------------------------------------

@(test)
if_with_equal_true_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (= 1 1) \"yes\" \"no\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "yes")
}

@(test)
if_with_equal_false_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (= 1 2) \"yes\" \"no\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "no")
}

@(test)
if_with_greater_true_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (> 3 2) 1 0)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_with_greater_equal_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (>= 2 2) 1 0)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_with_less_true_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (< 1 2) 1 0)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_with_less_equal_false_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (<= 2 1) 1 0)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

// ---------------------------------------------------------------------------
// truthiness (C-style: false, 0, "" are falsy)
// ---------------------------------------------------------------------------

@(test)
if_zero_is_falsy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if 0 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

@(test)
if_nonzero_is_truthy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if 1 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_negative_number_is_truthy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if -1 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_empty_string_is_falsy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if \"\" 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

@(test)
if_nonempty_string_is_truthy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if \"a\" 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

// ---------------------------------------------------------------------------
// laziness — only the taken branch is evaluated
// ---------------------------------------------------------------------------

// The untaken branch never runs, so its errors never fire. This is what
// makes `if` a special form and not a builtin function.

@(test)
if_dead_division_by_zero_never_fires :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true 1 (/ 1 0))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_dead_division_in_condition_position_never_fires :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if false (/ 1 0) 1)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_dead_type_error_never_fires :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true 1 (+ 1 \"x\"))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
if_dead_comparison_type_error_never_fires :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if false (> \"a\" 1) \"a\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "a")
}

// The condition is NOT lazy: its errors always propagate.

@(test)
if_condition_unbound_variable_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if unbound 1 2)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "unbound")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
if_condition_type_error_propagates :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (= 1 \"a\") 1 2)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// ---------------------------------------------------------------------------
// optional else branch — the two-argument form
// ---------------------------------------------------------------------------

@(test)
if_without_else_true_returns_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true 1)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

// No alternative and a falsy condition: `if` produces no value (the "nil"
// semantics of the expression world — def and print behave the same way).

@(test)
if_without_else_false_returns_no_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if false 1)", &global_env)

	// assert
	_, has_value := result.?
	testing.expect_value(t, err, nil)
	testing.expect(t, !has_value)
}

// ---------------------------------------------------------------------------
// arity errors — enforced by the parser
// ---------------------------------------------------------------------------

@(test)
if_with_no_operands_reports_parse_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if)", &global_env)

	// assert
	parser_err, ok := err.(core.Parser_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)
	testing.expect_value(t, parser_err.message, "Unexpected Expression")
	testing.expect(t, !has_value)
}

@(test)
if_missing_consequent_reports_parse_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true)", &global_env)

	// assert
	parser_err, ok := err.(core.Parser_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)
	testing.expect_value(t, parser_err.message, "Unexpected Expression")
	testing.expect(t, !has_value)
}

@(test)
if_too_many_operands_reports_parse_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if true 1 2 3)", &global_env)

	// assert
	parser_err, ok := err.(core.Parser_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Token)
	testing.expect_value(
		t,
		parser_err.message,
		"Expected ')' at the end of the `if` expression, got `3`",
	)
	testing.expect(t, !has_value)
}

// ---------------------------------------------------------------------------
// nesting — if is an expression and composes everywhere
// ---------------------------------------------------------------------------

@(test)
if_in_condition_position :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (if true false true) 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

// if inside a call argument — expression position.

@(test)
if_inside_call_argument :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(+ 1 (if true 2 3))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 3)
}

// The classic elif-chain pattern.

@(test)
if_else_if_chain :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (> 1 2) \"x\" (if (< 1 2) \"y\" \"z\"))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "y")
}

// Nested ifs in both branches.

@(test)
if_nested_in_both_branches :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (= 1 1) (if (> 2 1) \"a\" \"b\") \"c\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "a")
}

// An if result used directly as the call operator — first-class selection
// of the function to run.

@(test)
if_result_called_as_operator :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source(
		"((if true (lambda (x) (* x 2)) (lambda (x) 0)) 21)",
		&global_env,
	)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 42)
}

// An if inside a lambda body — the lambda-wrapped scenario from the
// IF_EXPRESSIONS.md catalog (section H), unblocked now that anonymous
// lambda calls parse again.

@(test)
if_inside_lambda_body :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("((lambda (x) (if (> x 5) \"big\" \"small\")) 10)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "big")
}
