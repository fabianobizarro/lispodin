package main

import "core"
import env "environment"
import math "functions/math"

initialize_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)

	env.define(e, "+", math.create_sum())
	env.define(e, "-", math.create_subtraction())
	env.define(e, "*", math.create_multiplication())
	env.define(e, "/", math.create_division())
}
