#+test
package builtin_functions

import "core:testing"

@(test)
multiplication_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result := multiplication(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 1)
}

@(test)
multiplication_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{8}

	// act
	result := multiplication(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 8)
}

@(test)
multiplication_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-12, 1, 2}

	// act
	result := multiplication(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -24)
}


@(test)
multiplication_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-12}

	// act
	result := multiplication(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -12)
}


@(test)
multiplication_test_5 :: proc(t: ^testing.T) {
	// arrange
	values := [7]LiteralValue{-12, 1, 5, 89, 0, 4234, -89}

	// act
	result := multiplication(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 0)
}
