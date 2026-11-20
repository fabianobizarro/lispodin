package comparison_functions_test

import core "../../../src/core"
import comparison "../../../src/functions/comp"
import "core:math"
import "core:testing"

LiteralValue :: core.LiteralValue
create_comparison_function :: comparison.create_comparison_function
equal :: comparison.equal

// ---------------------------------------------------------------------------
// create_comparison_function
// ---------------------------------------------------------------------------

@(test)
create_comparison_function_sets_variadic_arity :: proc(t: ^testing.T) {
	// arrange
	fn := create_comparison_function()

	// act/assert
	testing.expect_value(t, fn.arity, -1)
	testing.expect_value(t, fn.closure, nil)
}

@(test)
create_comparison_function_wires_equal_handler :: proc(t: ^testing.T) {
	// arrange
	fn := create_comparison_function()
	same := [2]LiteralValue{7, 7}

	// act
	result, err := fn.call(&fn, same[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)

	// act
	different := [2]LiteralValue{7, 8}
	result, err = fn.call(&fn, different[:], nil)

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
no_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
nil_arguments_slice_returns_true :: proc(t: ^testing.T) {
	// arrange
	values: []LiteralValue = nil

	// act
	result, err := equal(nil, values, nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// ---------------------------------------------------------------------------
// arity: single argument
// ---------------------------------------------------------------------------

@(test)
single_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{42}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
single_negative_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-3.5}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
single_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// EDGE CASE: the single-argument branch performs no type check at all, so
// any lone value (including NaN) returns true. Compare with
// nan_never_equals_itself.

@(test)
single_nan_number_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{math.QNAN_F32}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// The single-argument branch no longer type-checks: a lone string is
// accepted and returns true.

@(test)
single_string_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{"hello"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
single_true_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
single_false_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{false}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// ---------------------------------------------------------------------------
// arity: two arguments
// ---------------------------------------------------------------------------

@(test)
two_equal_numbers_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
two_different_numbers_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 2}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
equal_negative_numbers_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-7, -7}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
negative_number_differs_from_positive_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, 1}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Type errors are driven by the FIRST argument's type: a string first means
// every other argument must be a string. All type mismatches report kind
// .Expected_LiteralValue_Type, with the expected type named in the message.

@(test)
mixed_string_and_number_reports_expected_string_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", 1}

	// act
	result, err := equal(nil, values[:], nil)

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
second_argument_string_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "a"}

	// act
	result, err := equal(nil, values[:], nil)

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
second_argument_bool_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// The remaining mixed-type combinations. Note that (= 1 true) above reports
// NUMBER because the first argument is an f32; here the first argument is a
// string or bool, so the expected type flips accordingly.

@(test)
mixed_string_and_bool_reports_expected_string_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", true}

	// act
	result, err := equal(nil, values[:], nil)

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
mixed_bool_and_number_reports_expected_boolean_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, 1}

	// act
	result, err := equal(nil, values[:], nil)

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
mixed_bool_and_string_reports_expected_boolean_error :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, "a"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type BOOLEAN.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Strings compare by content; booleans compare by value.

@(test)
equal_strings_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", "a"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
different_strings_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"a", "b"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
equal_bools_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{true, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
different_bools_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{false, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// EDGE CASE: no cross-type coercion — the first argument's type decides.
// A numeric-looking string is still a string, not an f32.

@(test)
numeric_string_is_not_coerced_to_number :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "1"}

	// act
	result, err := equal(nil, values[:], nil)

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

@(test)
all_arguments_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{2, 2, 2, 2}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
mismatch_at_second_position_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, 2}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
mismatch_in_middle_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{1, 1, 2, 1}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// REGRESSION GUARD: calculate_equal overwrites its accumulator on every
// iteration (`accum = comp == target`), so with 3+ arguments the result only
// reflects the FIRST vs LAST comparison — a mismatch in the middle is
// forgotten and (= 1 2 1) returns true. These tests assert the intended "all
// arguments are equal" semantics and FAIL against the current
// implementation (EQUAL_FINDINGS.md, item 10). The fix must keep eager
// validation: compare all arguments AND type-check all of them.

@(test)
mismatch_then_matching_value_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, 1}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
bool_mismatch_then_matching_value_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{true, false, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
string_mismatch_then_matching_value_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{"a", "b", "a"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
mismatch_at_last_position_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [4]LiteralValue{1, 1, 1, 2}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Strings and booleans work variadically, compared against the first
// argument like numbers.

@(test)
all_equal_strings_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{"a", "a", "a"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
string_mismatch_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{"a", "a", "b"}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
all_equal_bools_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{true, true, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
bool_mismatch_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{true, true, false}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// Validation is now eager: even after a value mismatch, every remaining
// argument is still type-checked, so (= 1 2 "hello") reports that "hello"
// is not a number instead of quietly returning false.

@(test)
string_after_mismatch_reports_type_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, "hello"}

	// act
	result, err := equal(nil, values[:], nil)

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
bool_after_mismatch_reports_type_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 2, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Eager validation on the string path too: the number 1 after the ("a" vs
// "b") mismatch is still type-checked and reported.

@(test)
number_after_string_mismatch_reports_type_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{"a", "b", 1}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument '1': Expected type STRING.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// Type errors are reported even when all earlier comparisons passed.

@(test)
string_after_equal_prefix_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 1, "hello"}

	// act
	result, err := equal(nil, values[:], nil)

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
bool_after_equal_prefix_reports_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{1, 1, true}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// A number after a string first argument is a type error, reported before
// any comparison succeeds.

@(test)
number_after_string_first_reports_expected_string_error :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{"a", 1, 1}

	// act
	result, err := equal(nil, values[:], nil)

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
many_equal_arguments_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := make([]LiteralValue, 100)
	defer delete(values)
	for &v in values {
		v = 3.25
	}

	// act
	result, err := equal(nil, values, nil)

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
integer_and_decimal_representations_are_equal :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1.0}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// EDGE CASE (IEEE 754): -0.0 and +0.0 have different sign bits but compare
// equal, so (= -0.0 0) is true.

@(test)
negative_zero_equals_positive_zero_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-0.0, 0}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

// EDGE CASE (IEEE 754): NaN never compares equal, not even to itself, so two
// NaN values compare false. The language cannot produce a NaN literal: via
// the parser, `nan` is an unbound identifier and errors before "=" is ever
// called (pinned at interpreter level). These tests pin the raw f32
// contract of the comparison function itself.

@(test)
nan_never_equals_itself_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, math.QNAN_F32}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
nan_mixed_with_number_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.QNAN_F32, 1}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
infinity_equals_infinity_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.INF_F32, math.INF_F32}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
negative_infinity_differs_from_infinity_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{math.NEG_INF_F32, math.INF_F32}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// EDGE CASE: equal is IEEE 754 f32 equality, not mathematical equality.
// Summing 0.1 ten times accumulates rounding error and differs from 1.

@(test)
accumulated_rounding_differs_from_exact_value_returns_false :: proc(t: ^testing.T) {
	// arrange
	accum: f32 = 0
	for _ in 0 ..< 10 {
		accum += 0.1
	}
	values := [2]LiteralValue{accum, 1.0}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

// EDGE CASE: rounding can also work the other way. In f32, 0.1 + 0.2 and 0.3
// round to the same bits, so they compare equal (in f64 they would not).

@(test)
f32_rounding_can_make_different_expressions_equal :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{f32(0.1) + f32(0.2), 0.3}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
close_but_distinct_numbers_returns_false :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{0.1, 0.10000001}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, false)
}

@(test)
largest_f32_values_are_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{3.4028235e38, 3.4028235e38}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}

@(test)
tiny_values_are_equal_returns_true :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1e-38, 1e-38}

	// act
	result, err := equal(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, true)
}
