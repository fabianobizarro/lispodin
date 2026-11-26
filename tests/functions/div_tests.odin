package runtime_functions_test

import core "../../src/core"
import runtime "../../src/functions"
import "core:testing"

division :: runtime.division

@(test)
division_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act, assert
	testing.expect_assert_message(t, "Required 1 or more operands")
	_, _ = division(nil, values[:], nil)
}

@(test)
division_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result, err := division(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
division_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-12, 1, 2}

	// act
	result, err := division(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -6)
}


@(test)
division_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 0}

	// act
	result, err := division(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Division_By_Zero)
	testing.expect_value(t, runtime_err.message, "Division by Zero Error")
	testing.expect(t, !has_value)
}

@(test)
division_test_5 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{10}

	// act
	result, err := division(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0.1)
}

@(test)
division_test_6 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := division(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Division_By_Zero)
	testing.expect_value(t, runtime_err.message, "Division by Zero Error")
	testing.expect(t, !has_value)
}

@(test)
division_test_7 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{"hello", 2}

	// act
	result, err := division(nil, values[:], nil)

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
division_test_8 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{10, "hello"}

	// act
	result, err := division(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}
