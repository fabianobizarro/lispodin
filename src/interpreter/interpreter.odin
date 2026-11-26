package interpreter

import core "../core"

RuntimeEnvironment :: core.RuntimeEnvironment
Result :: Maybe(Atom)

evaluate :: proc(
	expressions: []core.Expression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {
	assert(len(expressions) > 0)

	if len(expressions) == 1 {
		return evaluate_expression(expressions[0], e)
	}

	for exp in expressions do evaluate_expression(exp, e) or_return

	return
}
