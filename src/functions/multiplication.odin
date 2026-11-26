package runtime_functions

import core "../core"

MULTIPLICATION_FUNCTION_NAME :: "*"

create_multiplication :: proc() -> LambdaFunction {
	return {name = MULTIPLICATION_FUNCTION_NAME, arity = -1, call = multiplication, closure = nil}
}

multiplication :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	if len(values) == 0 do return core.LiteralValue(1), nil

	argument_value: f32
	accum: f32 = 1
	for v in values {

		argument_value = core.parse_f32(v) or_return
		accum *= argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}
