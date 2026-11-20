package comparison_functions_test

import core "../../../src/core"
import comparison "../../../src/functions/comp"
import "core:math"
import "core:testing"

create_less_than_function :: comparison.create_less_than_function
less_than :: comparison.less_than

// Unit tests for the "<" (less than) builtin. Scheme-style strictly
// increasing chain: every argument must be < the next one. Numbers only:
// any string or boolean argument is a type error.

// ---------------------------------------------------------------------------
// create_less_than_function
// ---------------------------------------------------------------------------

@(test)
create_less_than_function_sets_variadic_arity :: proc(t: ^testing.T) {
	// arrange
	fn := create_less_than_function()

	// act/assert
	testing.expect_value(t, fn.arity, -1)
	testing.expect_value(t, fn.closure, nil)
}

@(test)
create_less_than_function_wires_handler :: proc(t: ^testing.T) {
	// arrange
	fn := create_less_than_function()
	ascending := [2]LiteralValue{1, 2}

	// act
	result, err := fn.call(&fn, ascending[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)

	// act
	descending := [2]LiteralValue{2, 1}
	result, err = fn.call(&fn, descending[:], nil)

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
less_no_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_nil_arguments_slice_returns_true :: proc(t: ^testing.T) {
	// arrange
	values: []LiteralValue = nil

	// act
	result, err := less_than(nil, values, nil)

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
// Like ">" and ">=", the single-argument branch type-checks its argument —
// a lone string or boolean is an error, a lone number is true.

@(test)
less_single_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_single_negative_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-3.5}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_single_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_single_nan_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{math.QNAN_F32}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_single_string_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{"hello"}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_single_true_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{true}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_single_false_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{false}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_second_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 2}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_first_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{2, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// "<" is strict: equal values do not count as less.

@(test)
less_equal_values_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_negative_than_positive_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_positive_than_negative_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, -1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_smaller_negative_than_greater_negative_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-5, -2}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_fractional_values_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1.5, 2.5}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Type errors from both argument positions.

@(test)
less_string_first_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", 1}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_string_second_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "a"}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_bool_first_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, 1}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_bool_second_argument_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, true}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_string_and_bool_arguments_report_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", true}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_bool_and_string_arguments_report_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, "a"}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_numeric_string_is_not_coerced :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "1"}

	// act
	result, err := less_than(nil, values[:], nil)

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
// Strictly increasing chain: every argument must be < the next one. Equal
// values anywhere in the chain break it.

@(test)
less_strictly_increasing_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{1, 2, 3, 4}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Strictness pin: the 2 < 2 pair breaks the chain even though the rest
// increases.

@(test)
less_equal_pair_breaks_strict_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{1, 2, 2, 3}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Mirror of the (> 1 0 0 4) rule: the chain holds until the equal pair, and
// the last value also fails.

@(test)
less_last_breaks_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{1, 2, 2, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Chain pin: 1 < 3 holds, but 3 < 2 fails. Under a "first less than all"
// reading this would be true.

@(test)
less_chain_break_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 3, 2}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_equal_pair_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, 2}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_all_equal_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{3, 3, 3}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// A full monotone trip from -inf to +inf.

@(test)
less_monotone_through_infinities_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{math.NEG_INF_F32, 0, math.INF_F32}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// Validation is eager: arguments after a failed comparison are still
// type-checked, so (< 2 1 "hello") reports the type error.

@(test)
less_string_after_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{2, 1, "hello"}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_string_after_valid_prefix_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, "hello"}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_bool_after_mismatch_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{2, 1, true}

	// act
	result, err := less_than(nil, values[:], nil)

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
less_many_increasing_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := make([]LiteralValue, 100)
	defer delete(values)
	for i in 0 ..< len(values) {
		values[i] = f32(i + 1)
	}

	// act
	result, err := less_than(nil, values, nil)

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
less_nan_not_less_than_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_nan_not_less_than_nan_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, math.QNAN_F32}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_number_less_than_infinity_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, math.INF_F32}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_infinity_not_less_than_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.INF_F32, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_negative_infinity_less_than_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.NEG_INF_F32, 1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_number_not_less_than_negative_infinity_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, math.NEG_INF_F32}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Strictness with infinities: inf < inf fails, breaking the chain.

@(test)
less_infinity_chain_breaks_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, math.INF_F32, math.INF_F32}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// -0.0 and +0.0 are equal values, so < fails in both directions.

@(test)
less_zero_not_less_than_negative_zero_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0, -0.0}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_negative_zero_not_less_than_zero_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-0.0, 0}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_minus_one_less_than_negative_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, -0.0}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_close_values_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.1, 0.10000001}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_close_values_reversed_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.10000001, 0.1}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
less_large_number_less_than_max_f32_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1e38, 3.4028235e38}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
less_zero_less_than_tiny_value_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0, 1e-38}

	// act
	result, err := less_than(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}
