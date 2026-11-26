package runtime_functions_test

import core "../../src/core"
import runtime "../../src/functions"
import cmath "core:math"
import "core:testing"

sqrt :: runtime.sqrt
create_sqrt :: runtime.create_sqrt

// Unit tests for the sqrt builtin. This is the first builtin with a FIXED
// arity (1) and a NAME ("sqrt") — the call machinery enforces the arity
// before the handler runs and reports the name in arity errors. The
// handler itself no longer validates arity (by design): it reads
// values[0] directly, so it must only be called with exactly one value.
// Negative input reports the dedicated .MathError kind. Type errors use the
// shared parse_f32 message, like every other builtin.

@(test)
create_sqrt_sets_name_and_fixed_arity :: proc(t: ^testing.T) {
	// arrange
	fn := create_sqrt()

	// act/assert
	testing.expect_value(t, fn.name, "sqrt")
	testing.expect_value(t, fn.arity, 1)
	testing.expect_value(t, fn.closure, nil)
}

@(test)
create_sqrt_wires_handler :: proc(t: ^testing.T) {
	// arrange
	fn := create_sqrt()
	values := [1]LiteralValue{9}

	// act
	result, err := fn.call(&fn, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 3)
}

@(test)
sqrt_of_perfect_square_returns_root :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{4}

	// act
	result, err := sqrt(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 2)
}

@(test)
sqrt_of_zero_returns_zero :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{0}

	// act
	result, err := sqrt(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, 0)
}

@(test)
sqrt_of_two_returns_f32_sqrt :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{2}

	// act
	result, err := sqrt(nil, values[:], nil)

	// assert
	value, ok := result.?.(LiteralValue)
	testing.expect_value(t, err, nil)
	testing.expect(t, ok)
	testing.expect_value(t, value, cmath.sqrt_f32(2))
}

// Negative input reports the dedicated .MathError kind (the message is
// allocated with fmt.aprint — deleted here).

@(test)
sqrt_of_negative_reports_math_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{-1}

	// act
	result, err := sqrt(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .MathError)
	testing.expect_value(t, runtime_err.token, "sqrt")
	testing.expect_value(
		t,
		runtime_err.message,
		"Can't calculate the square root of a negative number - -1",
	)
	testing.expect(t, !has_value)
	delete(runtime_err.message)
}

// The type error uses sqrt's own message, not the shared one.

@(test)
sqrt_of_string_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{"a"}

	// act
	result, err := sqrt(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.token, "")
	testing.expect_value(t, runtime_err.message, "Argument 'a': Expected type NUMBER.")
	testing.expect(t, !has_value)
}

@(test)
sqrt_of_bool_reports_expected_number_error :: proc(t: ^testing.T) {
	// arrange
	values := [1]LiteralValue{true}

	// act
	result, err := sqrt(nil, values[:], nil)

	// assert
	runtime_err, ok := err.(core.Runtime_Error)
	_, has_value := result.?
	testing.expect(t, ok)
	testing.expect_value(t, runtime_err.kind, .Expected_LiteralValue_Type)
	testing.expect_value(t, runtime_err.token, "")
	testing.expect_value(t, runtime_err.message, "Argument 'true': Expected type NUMBER.")
	testing.expect(t, !has_value)
}
