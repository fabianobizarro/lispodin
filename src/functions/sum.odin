package builtin_functions

import core "../core"
import "core:fmt"


create_sum :: proc() -> LambdaFunction {

	return {arity = -1, call = sum, closure = nil}
}

@(private)
sum :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> Maybe(core.Atom) {
	if len(values) == 0 do return core.LiteralValue(0)

	result: f32 = 0
	for v, i in values {

		argument_value, ok := v.(f32)
		if !ok do fmt.panicf("Argument %d: Expected Number", i)

		result += argument_value
	}

	return core.LiteralValue(result)
}
