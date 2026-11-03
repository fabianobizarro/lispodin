package main

import "core"
import env "environment"
import builtin_functions "functions"

initialize_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)

	env.define(e, "+", builtin_functions.create_sum())
}
