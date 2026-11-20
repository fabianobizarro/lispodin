package comparison_functions

import core "../../core"

create_less_than_function :: proc() -> LambdaFunction {
	return {arity = -1, call = less_than, closure = nil}
}

less_than :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	if len(values) == 0 do return LiteralValue(true), nil

	accum := true
	target: f32
	comp := core.parse_literalvalue(values[0], f32) or_return

	for val in values[1:] {
		target = core.parse_literalvalue(val, f32) or_return

		accum = accum && (comp < target)
		comp = target
	}

	result = core.LiteralValue(accum)
	return
}
