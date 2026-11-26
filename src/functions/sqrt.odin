package runtime_functions

import core "../core"
import "core:fmt"
import "core:math"

SQRT_FUNCTION_NAME :: "sqrt"

create_sqrt :: proc() -> LambdaFunction {
	return {name = SQRT_FUNCTION_NAME, arity = 1, call = sqrt, closure = nil}
}

sqrt :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	value := core.parse_f32(values[0]) or_return

	if value < 0 {
		err = core.Runtime_Error {
			kind    = .MathError,
			token   = SQRT_FUNCTION_NAME,
			message = fmt.aprint("Can't calculate the square root of a negative number -", value),
		}
		result = nil
		return
	}

	result = core.LiteralValue(math.sqrt(value))
	err = nil

	return
}
