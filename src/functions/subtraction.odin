package runtime_functions

import core "../core"

SUBTRACTION_FUNCTION_NAME :: "-"

create_subtraction :: proc() -> LambdaFunction {
	return {name = SUBTRACTION_FUNCTION_NAME, arity = -1, call = subtraction, closure = nil}
}

subtraction :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	assert(len(values) > 0)

	if len(values) == 1 {
		n := core.parse_f32(values[0]) or_return
		return n == 0 ? core.LiteralValue(0) : core.LiteralValue(n * -1), nil
	}

	argument_value: f32
	accum := core.parse_f32(values[0]) or_return

	for v in values[1:] {
		argument_value = core.parse_f32(v) or_return
		accum -= argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}
