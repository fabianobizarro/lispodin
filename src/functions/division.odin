package runtime_functions

import core "../core"

DIVISION_FUNCTION_NAME :: "/"

create_division :: proc() -> LambdaFunction {
	return {name = DIVISION_FUNCTION_NAME, arity = -1, call = division, closure = nil}
}

division :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	assert(len(values) > 0, "Required 1 or more operands")

	if len(values) == 1 {
		val := core.parse_f32(values[0]) or_return
		check_division_by_zero(val) or_return

		return LiteralValue(1 / val), nil
	}

	argument_value: f32
	accum: f32 = core.parse_f32(values[0]) or_return
	for v in values[1:] {
		argument_value = core.parse_f32(v) or_return
		check_division_by_zero(argument_value) or_return

		accum /= argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}

check_division_by_zero :: proc(val: f32) -> (err: core.Error) {
	if val != 0 do return

	return core.Runtime_Error{kind = .Division_By_Zero, message = "Division by Zero Error"}
}
