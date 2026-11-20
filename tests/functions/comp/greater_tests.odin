package comparison_functions_test

import core "../../../src/core"
import comparison "../../../src/functions/comp"
import "core:math"
import "core:testing"

create_greater_than_function :: comparison.create_greater_than_function
greater_than :: comparison.greater_than

// Unit tests for the ">" (greater than) builtin. Numbers only: any string or
// boolean argument is a type error.

// ---------------------------------------------------------------------------
// create_greater_than_function
// ---------------------------------------------------------------------------

@(test)
create_greater_than_function_sets_variadic_arity :: proc(t: ^testing.T) {
	// arrange
	fn := create_greater_than_function()

	// act/assert
	testing.expect_value(t, fn.arity, -1)
	testing.expect_value(t, fn.closure, nil)
}

@(test)
create_greater_than_function_wires_greater_handler :: proc(t: ^testing.T) {
	// arrange
	fn := create_greater_than_function()
	descending := [2]LiteralValue{2, 1}

	// act
	result, err := fn.call(&fn, descending[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)

	// act
	ascending := [2]LiteralValue{1, 2}
	result, err = fn.call(&fn, ascending[:], nil)

	// assert
	value, ok = result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// ---------------------------------------------------------------------------
// arity: no arguments
// ---------------------------------------------------------------------------

@(test)
greater_no_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_nil_arguments_slice_returns_true :: proc(t: ^testing.T) {
	// arrange
	values: []LiteralValue = nil

	// act
	result, err := greater_than(nil, values, nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// ---------------------------------------------------------------------------
// arity: single argument
// ---------------------------------------------------------------------------
//
// NOTE: unlike "=", the single-argument branch of ">" type-checks its
// argument — a lone string or boolean is an error, a lone number is true.

@(test)
greater_single_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_single_negative_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-3.5}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_single_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// A lone NaN parses as a number and has nothing to compare against.

@(test)
greater_single_nan_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{math.QNAN_F32}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_single_string_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{"hello"}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_single_true_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{true}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_single_false_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{false}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'false': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// ---------------------------------------------------------------------------
// arity: two arguments
// ---------------------------------------------------------------------------

@(test)
greater_first_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{2, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// (> 1 2) — the user-specified rule.

@(test)
greater_second_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 2}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// ">" is strict: equal values do not count as greater.

@(test)
greater_equal_values_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_positive_than_negative_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, -1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_negative_than_positive_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_negative_than_smaller_negative_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-2, -5}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_fractional_values_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{2.5, 1.5}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Type errors from both argument positions.

@(test)
greater_string_first_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", 1}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_string_second_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "a"}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_bool_first_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_bool_second_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, true}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_string_and_bool_arguments_report_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", true}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_bool_and_string_arguments_report_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, "a"}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// A numeric-looking string is still a string, not an f32.

@(test)
greater_numeric_string_is_not_coerced :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "1"}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument '1': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// ---------------------------------------------------------------------------
// arity: three or more arguments
// ---------------------------------------------------------------------------
//
// Scheme-style semantics: a strictly decreasing chain — every argument
// must be greater than the NEXT one, and the comparison window slides
// (`comp = target`). The pins below distinguish the chain reading from
// "first greater than all": under first>all both would be true.

@(test)
greater_chain_break_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{3, 1, 2}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_chain_equal_pair_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{3, 1, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_chain_equal_pair_four_args_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{5, 4, 4, 2}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_strictly_decreasing_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{4, 3, 2, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// (> 1 0 0 4) — the user-specified rule: 1 is not greater than 4, so false.

@(test)
greater_first_not_greater_than_last_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{1, 0, 0, 4}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// REGRESSION GUARD: greater_than overwrites its accumulator on every
// iteration (`accum = comp > target`), so the result only reflects the
// FIRST vs LAST comparison — a failure in the middle is forgotten. These
// tests assert the intended "every comparison holds" semantics and FAIL
// against the current implementation (EQUAL_FINDINGS.md, item 11). This is
// the same bug "=" had before its fix (`accum = accum && (...)`).

@(test)
greater_mismatch_then_greater_value_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{5, 6, 4}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_mismatch_in_middle_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{3, 5, 1, 2}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_pair_then_smaller_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{2, 2, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Validation is eager: arguments after a failed comparison are still
// type-checked, so (> 1 2 "hello") reports the type error.

@(test)
greater_string_after_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, "hello"}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_string_after_valid_prefix_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{4, 3, "hello"}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_bool_after_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, true}

	// act
	result, err := greater_than(nil, values[:], nil)

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
greater_many_decreasing_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := make([]LiteralValue, 100)
	defer delete(values)
	for i in 0 ..< len(values) {
		values[i] = f32(100 - i)
	}

	// act
	result, err := greater_than(nil, values, nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// ---------------------------------------------------------------------------
// f32 / IEEE 754 edge cases
// ---------------------------------------------------------------------------

@(test)
greater_nan_not_greater_than_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_nan_not_greater_than_nan_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, math.QNAN_F32}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_infinity_greater_than_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.INF_F32, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_number_not_greater_than_infinity_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, math.INF_F32}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_number_greater_than_negative_infinity_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, math.NEG_INF_F32}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_negative_infinity_smallest_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.NEG_INF_F32, 1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// -0.0 and +0.0 are equal values, so neither is greater.

@(test)
greater_zero_not_greater_than_negative_zero_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0, -0.0}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_negative_zero_not_greater_than_zero_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-0.0, 0}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_negative_zero_greater_than_minus_one_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-0.0, -1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_close_values_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.1, 0.10000001}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_close_values_reversed_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.10000001, 0.1}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_max_f32_greater_than_large_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{3.4028235e38, 1e38}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_tiny_value_greater_than_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1e-38, 0}

	// act
	result, err := greater_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}
