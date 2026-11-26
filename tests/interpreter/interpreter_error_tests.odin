package interpreter_tests

import core "../../src/core"
import env "../../src/environment"
import runtime "../../src/functions"
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

	expressions, parse_errors := parser.parse(tokens)
	defer delete(expressions)
	defer delete(parse_errors)

	if len(parse_errors) > 0 {
		return nil, parse_errors[0]
	}

	return interpreter.evaluate(expressions, e)
}

// Creates a global environment with the runtime functions bound via the
// shared registration proc, the same way initialize_global_env does in
// src/global_env.odin.

@(private)
make_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)
	runtime.register_runtime_global_functions(e)
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

// A non-number argument to a math function reports Expected_LiteralValue_Type.

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
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type NUMBER.")
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
// Lambda_Arity_Mismatch, tagged "lambda_func" in the token field.

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
	testing.expect_value(t, runtime_err.token, "lambda_func")
	testing.expect_value(t, runtime_err.message, "Expected 1 argument(s) but got 2.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// A call with an unbound operator name reports Variable_Not_Found: the
// operator is evaluated before any call machinery runs.

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
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "x")
	testing.expect_value(t, runtime_err.message, "Variable x not found")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Calling a name bound to a non-lambda value reports
// Runtime_Or_Lambda_Expected. The operator's value is no longer echoed in
// the token (empty string pinned as-is).

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
	testing.expect_value(t, runtime_err.kind, .Runtime_Or_Lambda_Expected)
	testing.expect_value(t, runtime_err.token, "")
	testing.expect_value(t, runtime_err.message, "Unknown Lambda declaration")
	testing.expect(t, !has_value)
}

// A call whose operator evaluates to no value (here: a two-argument if
// with a falsy condition) reports a graceful error instead of crashing.
// Regression pin: this used to panic before the missing control flow was
// fixed in evaluate_lamba_call.

@(test)
call_operator_with_no_value_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("((if false 1) 2)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Runtime_Or_Lambda_Expected)
	testing.expect_value(
		t,
		runtime_err.message,
		"Expected a variable or lambda definition as the call operator",
	)
	testing.expect(t, !has_value)
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

// The primary named-lambda flow: bind a lambda with def, then call it by
// name. Two evaluations against the same environment (REPL-style), since a
// multi-expression source still discards intermediate values.

@(test)
named_lambda_def_then_call_returns_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	_, def_err := evaluate_source("(def f (lambda (x) (* x x)))", &global_env)
	testing.expect_value(t, def_err, nil)

	result, err := evaluate_source("(f 7)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 49)
}

// Arity mismatch on a named lambda. The token is the uniform "lambda_func"
// tag for both named and anonymous lambdas (pinned as-is).

@(test)
named_lambda_arity_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	_, def_err := evaluate_source("(def f (lambda (x) x))", &global_env)
	testing.expect_value(t, def_err, nil)

	result, err := evaluate_source("(f 1 2)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Lambda_Arity_Mismatch)
	testing.expect_value(t, runtime_err.token, "lambda_func")
	testing.expect_value(t, runtime_err.message, "Expected 1 argument(s) but got 2.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// ---------------------------------------------------------------------------
// sqrt — the first fixed-arity builtin
// ---------------------------------------------------------------------------

// Arity is enforced by the call machinery (not the handler). NOTE: the
// token is empty because the builtin was created without a name — the
// arity error carries func.name.

@(test)
sqrt_returns_root :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(sqrt 9)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 3)
}

@(test)
sqrt_of_nested_call :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(sqrt (sqrt 16))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

// sqrt's own hand-rolled type error (differs from the shared
// parse_literalvalue message used by the other builtins).

@(test)
sqrt_string_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(sqrt \"a\")", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.token, "")
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type NUMBER.")
	testing.expect(t, !has_value)
}

@(test)
sqrt_arity_enforced_by_caller :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(sqrt 4 9)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Lambda_Arity_Mismatch)
	testing.expect_value(t, runtime_err.token, "sqrt")
	testing.expect_value(t, runtime_err.message, "Expected 1 argument(s) but got 2.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Negative input reports the dedicated .MathError kind end to end.

@(test)
sqrt_negative_argument_reports_math_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(sqrt -1)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .MathError)
	testing.expect_value(t, runtime_err.token, "sqrt")
	testing.expect_value(
		t,
		runtime_err.message,
		"Can't calculate the square root of a negative number - -1",
	)
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// A def whose value is a bodyless lambda reports the parse error from the
// lambda body check.

@(test)
def_of_bodyless_lambda_reports_parse_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(def f (lambda (x)))", &global_env)

	// assert
	parser_err, ok := err.(core.Parser_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Lambda_Body_Expected)
	testing.expect_value(t, parser_err.message, "Lambda body expected.")
	testing.expect(t, !has_value)
}
