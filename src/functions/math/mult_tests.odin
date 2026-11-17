#+test
package builtin_functions

import core "../../core"
import "core:testing"

@(test)
multiplication_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result, err := multiplication(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 1)
}

@(test)
multiplication_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{8}

	// act
	result, err := multiplication(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 8)
}

@(test)
multiplication_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-12, 1, 2}

	// act
	result, err := multiplication(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -24)
}


@(test)
multiplication_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-12}

	// act
	result, err := multiplication(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, -12)
}


@(test)
multiplication_test_5 :: proc(t: ^testing.T) {
	// arrange
	values := [7]LiteralValue{-12, 1, 5, 89, 0, 4234, -89}

	// act
	result, err := multiplication(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

@(test)
multiplication_test_6 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{2, "hello"}

	// act
	result, err := multiplication(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_Number)
	testing.expect_value(t, runtime_err.message, "Argument 'hello': Expected type Number.")
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}
