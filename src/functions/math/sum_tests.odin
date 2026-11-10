#+test
package builtin_functions

import "core:testing"

@(test)
sum_test_1 :: proc(t: ^testing.T) {
	// arrange
	values := []LiteralValue{}

	// act
	result := sum(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 0)
}

@(test)
sum_test_2 :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{1}

	// act
	result := sum(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 1)
}

@(test)
sum_test_3 :: proc(t: ^testing.T) {
	// arrange
	values := [3]LiteralValue{-12, 1, 2}

	// act
	result := sum(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, -9)
}


@(test)
sum_test_4 :: proc(t: ^testing.T) {
	// arrange
	values := [2]LiteralValue{1, 1}

	// act
	result := sum(nil, values[:], nil).?.(LiteralValue)

	// assert
	testing.expect_value(t, result, 2)
}
