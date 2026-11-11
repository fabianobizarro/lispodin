package str_functions

import core "../../core"

create_newline :: proc() -> core.LambdaFunction {
	return {arity = -1, closure = nil, call = new_line}
}

@(private)
new_line :: proc(
	_: ^core.LambdaFunction,
	_: []core.LiteralValue,
	_: core.InterpreterCaller,
) -> Maybe(core.Atom) {

	return core.LiteralValue("\n")
}
