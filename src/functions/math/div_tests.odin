#+test
package builtin_functions

import "core:testing"


@(test)
division_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act, assert
	testing.expect_assert_message(t, "Required 1 or more operands")
	result := division(nil, values[:], nil).?.(LiteralValue)
}

@(test)
division_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result := division(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 1)
}

@(test)
division_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-12, 1, 2}

	// act
	result := division(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -6)
}


@(test)
division_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 0}

	// act, assert
	testing.expect_assert_message(t, "Division by Zero")
	result := division(nil, values[:], nil).?.(LiteralValue)
}

@(test)
division_test_5 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{10}

	// act
	result := division(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 0.1)
}
