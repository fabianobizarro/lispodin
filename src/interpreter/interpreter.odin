package interpreter

import core "../core"

RuntimeEnvironment :: core.RuntimeEnvironment
Result :: Maybe(Atom)

evaluate :: proc(statements: []Statement, e: ^RuntimeEnvironment) -> (result: Result, err: Error) {
	assert(len(statements) > 0)

	if len(statements) == 1 {
		return evaluate_statement(statements[0], e)
	}

	for s in statements do evaluate_statement(s, e) or_return

	return
}
