package runtime_functions_test

import core "../../src/core"
import runtime "../../src/functions"
import "core:testing"

subtraction :: runtime.subtraction

@(test)
subtraction_test_0 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := subtraction(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

@(test)
subtraction_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result, err := subtraction(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

@(test)
subtraction_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result, err := subtraction(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -1)
}

@(test)
subtraction_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-1, 9, -1}

	// act
	result, err := subtraction(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -9)
}


@(test)
subtraction_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, 9}

	// act
	result, err := subtraction(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -10)
}

@(test)
subtraction_test_5 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{"hello"}

	// act
	result, err := subtraction(nil, values[:], nil)

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
subtraction_test_6 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{10, "hello", 2}

	// act
	result, err := subtraction(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}
