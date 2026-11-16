#+test
package builtin_functions

import "core:testing"

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
