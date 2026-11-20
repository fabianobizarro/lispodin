package interpreter_tests

import core "../../src/core"
import env "../../src/environment"
import "core:testing"

// End-to-end tests for the "=" comparison builtin: source string through
// scanner, parser, and interpreter, against a global environment set up the
// same way as src/global_env.odin. Uses the evaluate_source and
// make_global_env helpers from interpreter_error_tests.odin (same package).

// ---------------------------------------------------------------------------
// real scenarios: results
// ---------------------------------------------------------------------------

// (=) compares nothing, so everything "agrees" by definition.

@(test)
empty_call_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(=)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// The single-argument branch performs no type check at all: a lone value of
// any type returns true, with nothing to compare it against.

@(test)
single_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
single_string_argument_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"hello\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
single_bool_argument_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= true)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
two_equal_numbers_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 1)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
two_different_numbers_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 4 5)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Variadic use: every argument is compared against the first one.

@(test)
all_arguments_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 1 1)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
mismatch_at_last_argument_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
negative_numbers_compare_equal :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= -7 -7)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
fractional_numbers_compare_equal :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1.5 1.5)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Computed arguments are compared by value: (+ 1 1) and (* 1 2) both yield 2.

@(test)
computed_arguments_are_compared_by_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= (+ 1 1) (* 1 2))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
computed_arguments_mismatch_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= (+ 1 1) 3)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Arguments bound by a lambda are compared like any other value. (A def-based
// scenario is not possible here: evaluate only returns the value of the last
// statement when the source has exactly one statement.)

@(test)
lambda_argument_binding_compares_equal :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("((lambda (x) (= x x)) 5)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
lambda_argument_differs_from_literal_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("((lambda (x) (= x 10)) 5)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Strings and booleans compare within their own type, driven by the first
// argument.

@(test)
identical_strings_compare_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"a\" \"a\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
different_strings_return_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"a\" \"b\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
identical_bools_compare_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= true true)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
different_bools_return_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= false true)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
all_equal_strings_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"a\" \"a\" \"a\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
string_mismatch_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"a\" \"a\" \"b\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
all_equal_bools_returns_true :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= true true true)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
bool_mismatch_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= true true false)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// ---------------------------------------------------------------------------
// error conditions: mixed types
// ---------------------------------------------------------------------------
//
// The first argument's type decides what every other argument must be. All
// type mismatches report kind .Expected_LiteralValue_Type, with the expected
// type named in the message.

@(test)
mixed_string_and_number_reports_expected_string_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"hello\" 1)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument '1': Expected type STRING.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
string_second_argument_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 \"hello\")", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
mixed_number_and_bool_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 true)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
mixed_bool_and_number_reports_expected_boolean_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= true 1)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument '1': Expected type BOOLEAN.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
bool_last_argument_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 1 false)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'false': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
mixed_string_and_bool_reports_expected_string_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"a\" true)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type STRING.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
mixed_bool_and_string_reports_expected_boolean_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= true \"a\")", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type BOOLEAN.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// REGRESSION GUARD (EQUAL_FINDINGS.md, item 10): calculate_equal overwrites
// its accumulator per iteration, so (= 1 2 1) currently returns true — the
// 2-vs-1 mismatch is forgotten. This test asserts the intended "all
// arguments are equal" semantics and FAILS against the current
// implementation.

@(test)
mismatch_then_match_returns_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 2 1)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// NaN cannot reach "=" through the normal path: the language has no nan
// literal, so `nan` is an unbound identifier and the interpreter reports
// Variable_Not_Found before the comparison is ever called. The raw f32 NaN
// semantics remain pinned at unit level (EQUAL_FINDINGS.md, item 3).

@(test)
nan_identifier_reports_variable_not_found :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= nan nan)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "nan")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Validation is eager at interpreter level too: (= 1 2 "hello") reports the
// type error instead of quietly returning false.

@(test)
string_after_mismatch_reports_type_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= 1 2 \"hello\")", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Eager validation on the string path as well.

@(test)
number_after_string_mismatch_reports_type_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(= \"a\" \"b\" 1)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument '1': Expected type STRING.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}
