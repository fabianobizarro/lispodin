package comparison_functions_test

import core "../../../src/core"
import comparison "../../../src/functions/comp"
import "core:math"
import "core:testing"

create_greater_than_equal_function :: comparison.create_greater_than_equal_function
greater_than_equal :: comparison.greater_than_equal

// Unit tests for the ">=" (greater than or equal) builtin. Scheme-style
// non-increasing chain: every argument must be >= the next one. Numbers only:
// any string or boolean argument is a type error.

// ---------------------------------------------------------------------------
// create_greater_than_equal_function
// ---------------------------------------------------------------------------

@(test)
create_greater_than_equal_function_sets_variadic_arity :: proc(t: ^testing.T) {
	// arrange
	fn := create_greater_than_equal_function()

	// act/assert
	testing.expect_value(t, fn.arity, -1)
	testing.expect_value(t, fn.closure, nil)
}

@(test)
create_greater_than_equal_function_wires_handler :: proc(t: ^testing.T) {
	// arrange
	fn := create_greater_than_equal_function()
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
greater_equal_no_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_nil_arguments_slice_returns_true :: proc(t: ^testing.T) {
	// arrange
	values: []LiteralValue = nil

	// act
	result, err := greater_than_equal(nil, values, nil)

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
// Like ">", the single-argument branch type-checks its argument — a lone
// string or boolean is an error, a lone number is true.

@(test)
greater_equal_single_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_single_negative_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-3.5}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_single_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_single_nan_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{math.QNAN_F32}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_single_string_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{"hello"}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_single_true_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{true}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_single_false_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{false}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_first_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{2, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_second_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 2}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// ">=" is non-strict: equal values count. This is the key difference from ">".

@(test)
greater_equal_equal_values_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_positive_than_negative_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, -1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_negative_than_positive_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_negative_than_smaller_negative_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-2, -5}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_fractional_values_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{2.5, 1.5}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Type errors from both argument positions.

@(test)
greater_equal_string_first_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_string_second_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "a"}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_bool_first_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_bool_second_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, true}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_string_and_bool_arguments_report_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", true}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_bool_and_string_arguments_report_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, "a"}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_numeric_string_is_not_coerced :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "1"}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
// Non-increasing chain: every argument must be >= the next, equal values are
// allowed anywhere in the chain.

@(test)
greater_equal_strictly_decreasing_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{4, 3, 2, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_non_increasing_with_equal_pair_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{4, 4, 2, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Mirror of the (> 1 0 0 4) rule: the chain holds until the last argument.

@(test)
greater_equal_last_breaks_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{5, 4, 4, 5}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Chain pin: 3 >= 1 holds, but 1 >= 2 fails. Under a "first >= all" reading
// this would be true.

@(test)
greater_equal_chain_break_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{3, 1, 2}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_chain_equal_pair_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{3, 1, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_chain_equal_pair_four_args_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{5, 4, 4, 2}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_all_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{3, 3, 3}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Validation is eager: arguments after a failed comparison are still
// type-checked, so (>= 1 2 "hello") reports the type error.

@(test)
greater_equal_string_after_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, "hello"}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_string_after_valid_prefix_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{4, 3, "hello"}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_bool_after_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, true}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

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
greater_equal_many_decreasing_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := make([]LiteralValue, 100)
	defer delete(values)
	for i in 0 ..< len(values) {
		values[i] = f32(100 - i)
	}

	// act
	result, err := greater_than_equal(nil, values, nil)

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
greater_equal_nan_not_geq_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_nan_not_geq_nan_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, math.QNAN_F32}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_infinity_geq_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.INF_F32, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_number_not_geq_infinity_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, math.INF_F32}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_number_geq_negative_infinity_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, math.NEG_INF_F32}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_negative_infinity_smallest_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.NEG_INF_F32, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Non-strict with infinities: inf >= inf holds, so the chain continues.

@(test)
greater_equal_infinity_chain_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{math.INF_F32, math.INF_F32, 1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// -0.0 and +0.0 are equal values, so >= holds in both directions.

@(test)
greater_equal_zero_geq_negative_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0, -0.0}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_negative_zero_geq_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-0.0, 0}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_negative_zero_geq_minus_one_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-0.0, -1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_close_values_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.1, 0.10000001}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
greater_equal_close_values_reversed_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.10000001, 0.1}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_max_f32_geq_large_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{3.4028235e38, 1e38}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
greater_equal_tiny_value_geq_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1e-38, 0}

	// act
	result, err := greater_than_equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}
