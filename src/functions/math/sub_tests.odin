#+test
package builtin_functions

import "core:testing"

@(test)
subtraction_test_0 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result := subtraction(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 0)
}

@(test)
subtraction_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result := subtraction(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 0)
}

@(test)
subtraction_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result := subtraction(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -1)
}

@(test)
subtraction_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-1, 9, -1}

	// act
	result := subtraction(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -9)
}


@(test)
subtraction_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{-1, 9}

	// act
	result := subtraction(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -10)
}
