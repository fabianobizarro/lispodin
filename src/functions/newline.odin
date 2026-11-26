package runtime_functions

import core "../core"

NEWLINE_FUNCTION_NAME :: "newline"

create_newline :: proc() -> core.LambdaFunction {
	return {name = NEWLINE_FUNCTION_NAME, arity = -1, closure = nil, call = new_line}
}

@(private)
new_line :: proc(
	_: ^core.LambdaFunction,
	_: []core.LiteralValue,
	_: core.InterpreterCaller,
) -> (
	Maybe(core.Atom),
	core.Error,
) {

	return core.LiteralValue("\n"), nil
}
