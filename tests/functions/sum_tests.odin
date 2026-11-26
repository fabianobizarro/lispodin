package runtime_functions_test

import core "../../src/core"
import runtime "../../src/functions"
import "core:testing"

sum :: runtime.sum

@(test)
sum_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result, err := sum(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

@(test)
sum_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result, err := sum(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
sum_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-12, 1, 2}

	// act
	result, err := sum(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -9)
}


@(test)
sum_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result, err := sum(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

@(test)
sum_test_5 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, "hello"}

	// act
	result, err := sum(nil, values[:], nil)

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
sum_test_6 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, true}

	// act
	result, err := sum(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}
