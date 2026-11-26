package interpreter_tests

import core "../../src/core"
import env "../../src/environment"
import "core:testing"

// End-to-end tests for the "begin", "and", and "or" special forms
// (CONDITIONAL_OPERATORS.md). Uses the evaluate_source and make_global_env
// helpers from interpreter_error_tests.odin (same package).
//
// Semantics as implemented (and pinned here):
// - begin evaluates everything, returns the last value; empty begin
//   produces no value.
// - and/or are SHORT-CIRCUITING and return the VALUE of the last expression
//   evaluated — not a boolean: (and true 2) => 2, (or false 2) => 2.
// - Truthiness is C-style (like "if"): false, 0, "" are falsy, and a def
//   (which produces no value) is falsy too. NOTE: Scheme's and/or only stop
//   at #f — so (and 0 2) differs from Scheme (Scheme => 2, here => 0).
// - Empty (and)/(or) produce no value. NOTE: Scheme convention is
//   (and) => #t and (or) => #f — current behavior pinned as-is.

// ---------------------------------------------------------------------------
// begin — sequential evaluation, value of the last form
// ---------------------------------------------------------------------------

@(test)
begin_empty_returns_no_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(begin)", &global_env)

	// assert
	_, has_value := result.?
	testing.expect_value(t, err, nil)
	testing.expect(t, !has_value)
}

@(test)
begin_returns_last_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(begin 1 2 3)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 3)
}

// The begin form is the def-then-use enabler: one expression that defines
// and then uses the binding.

@(test)
begin_enables_def_then_use_in_one_expression :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(begin (def x 10) (if (> x 5) 1 2))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
begin_returns_last_of_mixed_types :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(begin (def x 5) \"done\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "done")
}

@(test)
begin_composes_with_and :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(begin (def w 2) (and (> w 1) (< w 3)))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
begin_unterminated_reports_parse_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(begin 1 2", &global_env)

	// assert
	parser_err, ok := err.(core.Parser_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)
	testing.expect_value(t, parser_err.message, "Unexpected Expression")
	testing.expect(t, !has_value)
}

// ---------------------------------------------------------------------------
// and — stops at the first falsy value, returns the last evaluated value
// ---------------------------------------------------------------------------

// NOTE: Scheme convention is (and) => #t; the implementation produces no
// value, pinned as-is.

@(test)
and_empty_returns_no_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and)", &global_env)

	// assert
	_, has_value := result.?
	testing.expect_value(t, err, nil)
	testing.expect(t, !has_value)
}

@(test)
and_single_value_returns_it :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and true)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Per CONDITIONAL_OPERATORS.md: and returns the value of the last
// expression evaluated — 2, not true.

@(test)
and_returns_last_value_not_boolean :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and true 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

@(test)
and_all_truthy_returns_last :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and 1 2 3)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 3)
}

@(test)
and_stops_at_false :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and true false 7)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Short-circuit: the type error after the falsy value never fires.

@(test)
and_is_lazy_after_falsy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and false (> 1 \"a\"))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
and_is_lazy_in_the_middle :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and true false (> 1 \"a\"))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// C-style truthiness (consistent with "if"): 0 stops the chain. NOTE:
// Scheme's and only stops at #f, so Scheme would answer 2 here.

@(test)
and_c_truthiness_zero_stops :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and 0 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

@(test)
and_c_truthiness_empty_string_stops :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and \"\" \"x\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "")
}

// Errors in EVALUATED positions still propagate — laziness only skips
// later forms.

@(test)
and_type_error_propagates :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and (> 1 \"a\") true)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

@(test)
and_unbound_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and unbound true)", &global_env)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "unbound")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// QUIRK: a def produces no value, which is falsy — so a def inside an and
// stops the chain and the whole form yields no value.

@(test)
and_with_def_stops_at_no_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and (def y 5) true)", &global_env)

	// assert
	_, has_value := result.?
	testing.expect_value(t, err, nil)
	testing.expect(t, !has_value)
}

@(test)
and_unterminated_reports_parse_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(and 1 2", &global_env)

	// assert
	parser_err, ok := err.(core.Parser_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, parser_err.kind, .Unexpected_Expression)
	testing.expect_value(t, parser_err.message, "Unexpected Expression")
	testing.expect(t, !has_value)
}

// ---------------------------------------------------------------------------
// or — stops at the first truthy value, returns the last evaluated value
// ---------------------------------------------------------------------------

// NOTE: Scheme convention is (or) => #f; the implementation produces no
// value, pinned as-is.

@(test)
or_empty_returns_no_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or)", &global_env)

	// assert
	_, has_value := result.?
	testing.expect_value(t, err, nil)
	testing.expect(t, !has_value)
}

@(test)
or_single_falsy_returns_it :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or false)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Per CONDITIONAL_OPERATORS.md: or returns the value of the last expression
// evaluated — 2, not true.

@(test)
or_returns_first_truthy_value :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or false 2)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

@(test)
or_all_falsy_returns_last :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or false false)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// C-style truthiness: 0 is skipped and evaluation continues. NOTE: Scheme
// answers 0 here (0 is truthy in Scheme).

@(test)
or_c_truthiness_zero_skipped :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or 0 5)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 5)
}

// Short-circuit: the type error after the truthy value never fires.

@(test)
or_is_lazy_after_truthy :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or true (> 1 \"a\"))", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
or_type_error_propagates :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or false (> 1 \"a\"))", &global_env)

	// assert
	// (no value assertion: alongside the error, the result keeps the value
	// of the form before the failing one — or_return returns early; the
	// error is the authoritative signal)
	runtime_err, ok := err.(core.Runtime_Error)
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type NUMBER.")
	delete(runtime_err.message)
}

@(test)
or_unbound_after_truthy_not_evaluated :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or true unbound)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
or_unbound_after_falsy_reports_error :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or false unbound)", &global_env)

	// assert
	// (no value assertion: alongside the error, the result keeps the value
	// of the form before the failing one — see the note above)
	runtime_err, ok := err.(core.Runtime_Error)
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Variable_Not_Found)
	testing.expect_value(t, runtime_err.token, "unbound")
	delete(runtime_err.message)
}

// A def inside an or is falsy (no value), so evaluation continues past it.

@(test)
or_with_def_continues :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(or (def y 5) true)", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// ---------------------------------------------------------------------------
// composition with if
// ---------------------------------------------------------------------------

@(test)
and_as_if_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (and (> 1 0) (< 1 5)) \"in\" \"out\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "in")
}

@(test)
or_as_if_condition :: proc(t: ^testing.T) {
	// arrange
	global_env: core.RuntimeEnvironment
	make_global_env(&global_env)
	defer env.destroy(&global_env)

	// act
	result, err := evaluate_source("(if (or false (= 1 2)) \"yes\" \"no\")", &global_env)

	// assert
	value, ok := result.?.(core.LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, "no")
}
