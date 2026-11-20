package main

import "core"
import env "environment"
import comp "functions/comp"
import math "functions/math"
import str "functions/str"

initialize_global_env :: proc(e: ^core.RuntimeEnvironment) {
	env.init(e)

	// math functions
	env.define(e, "+", math.create_sum())
	env.define(e, "-", math.create_subtraction())
	env.define(e, "*", math.create_multiplication())
	env.define(e, "/", math.create_division())

	// string functions
	env.define(e, "newline", str.create_newline())

	// comparison functions
	env.define(e, "=", comp.create_comparison_function())
	env.define(e, ">", comp.create_greater_than_function())
	env.define(e, ">=", comp.create_greater_than_equal_function())
	env.define(e, "<", comp.create_less_than_function())
	env.define(e, "<=", comp.create_less_than_equal_function())
}
