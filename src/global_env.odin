package main

import "core"
import "core:math"
import env "environment"
import func "functions"

initialize_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)

	func.register_runtime_global_functions(e)

	env.define(e, "pi", core.LiteralValue(f32(math.PI)))
}
