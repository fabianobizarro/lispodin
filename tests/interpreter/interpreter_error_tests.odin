package interpreter_tests

import core "../../src/core"
import env "../../src/environment"
import math "../../src/functions/math"
import interpreter "../../src/interpreter"
import parser "../../src/parser"
import scanner "../../src/scanner"
import "core:testing"

// Evaluates a source string end to end: tokenize, parse, then evaluate
// against the given environment. Scanner and parser errors are returned
// as errors, mirroring how run.odin bails on them.

@(private)
evaluate_source :: proc(
	source: string,
	e: ^core.RuntimeEnvironment,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	tokens, scan_errors := scanner.tokenize(source)
	defer delete(tokens)

	if len(scan_errors) > 0 {
		return nil, scan_errors[0]
	}

	statements, parse_errors := parser.parse(tokens)
	defer delete(statements)
	defer delete(parse_errors)

	if len(parse_errors) > 0 {
		return nil, parse_errors[0]
	}

	return interpreter.evaluate(statements, e)
}

// Creates a global environment with the built-in math functions bound,
// the same way initialize_global_env does in src/global_env.odin.

@(private)
make_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)
	env.define(e, "+", math.create_sum())
	env.define(e, "-", math.create_subtraction())
	env.define(e, "*", math.create_multiplication())
	env.define(e, "/", math.create_division())
}

// An unbound name reports Variable_Not_Found.

@(test)
unbound_variable_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("foo", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "foo")
	testing.expect_value(t, runtime_err.message, "Variable foo not found")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// An unbound name in a call argument reports the error instead of
// returning the value of the earlier arguments.

@(test)
unbound_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(+ 1 undefined)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "undefined")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// A non-number argument to a math function reports Expected_Number.

@(test)
non_number_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(+ 1 \"hello\")", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_Number)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type Number.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Division by zero reports Division_By_Zero.

@(test)
division_by_zero_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(/ 1 0)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Division_By_Zero)
	testing.expect_value(t, runtime_err.message, "Division by Zero Error")
	testing.expect(t, !has_value)
}

// A single zero operand reports Division_By_Zero on the reciprocal path.

@(test)
division_by_zero_single_operand_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(/ 0)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Division_By_Zero)
	testing.expect_value(t, runtime_err.message, "Division by Zero Error")
	testing.expect(t, !has_value)
}

// An inline lambda called with the wrong number of arguments reports
// Lambda_Arity_Mismatch.

@(test)
inline_lambda_arity_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("((lambda (x) x) 1 2)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Lambda_Arity_Mismatch)
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// A call with no arguments and no bound name reports Lambda_Call_Mismatch
// instead of indexing an empty argument list.

@(test)
empty_call_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(x)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Lambda_Call_Mismatch)
	testing.expect_value(t, runtime_err.token, "x")
	testing.expect_value(
		t,
		runtime_err.message,
		"First argument of the lambda call must be a lambda declaration.",
	)
	testing.expect(t, !has_value)
}

// Calling a name bound to a non-lambda value reports Lambda_Call_Mismatch.

@(test)
calling_a_non_lambda_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(def x 10)\n(x 1)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Lambda_Call_Mismatch)
	testing.expect_value(t, runtime_err.token, "x")
	testing.expect_value(
		t,
		runtime_err.message,
		"Can only call lambda functions. x does not seem to be a lambda.",
	)
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Control: a valid expression returns the result and no error.

@(test)
valid_expression_returns_result :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(+ 1 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 3)
}

// Control: an inline lambda call with matching arity returns its result.

@(test)
inline_lambda_call_returns_result :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("((lambda (x) x) 1)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}
