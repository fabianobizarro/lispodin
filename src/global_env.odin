package main

import "core"
import env "environment"
import math "functions/math"
import str "functions/str"

initialize_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)

	env.define(e, "+", math.create_sum())
	env.define(e, "-", math.create_subtraction())
	env.define(e, "*", math.create_multiplication())
	env.define(e, "/", math.create_division())
	env.define(e, "newline", str.create_newline())
}
