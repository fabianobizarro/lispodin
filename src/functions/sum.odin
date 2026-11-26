package runtime_functions

import core "../core"

SUM_FUNCTION_NAME :: "+"

create_sum :: proc() -> LambdaFunction {
	return {name = SUM_FUNCTION_NAME, arity = -1, call = sum, closure = nil}
}

sum :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	if len(values) == 0 do return core.LiteralValue(0), nil

	argument_value: f32
	accum: f32 = 0
	for v in values {
		argument_value = core.parse_f32(v) or_return
		accum += argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}
