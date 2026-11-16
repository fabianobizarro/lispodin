#+test
package builtin_functions

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
