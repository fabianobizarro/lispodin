package runtime_functions

import core "../core"
import env "../environment"

Literal :: core.Atom
LiteralValue :: core.LiteralValue
LambdaExpression :: core.LambdaExpression
LambdaFunction :: core.LambdaFunction

register_runtime_global_functions :: proc(e: ^core.RuntimeEnvironment) {

	// math functions
	env.define(e, SUM_FUNCTION_NAME, create_sum())
	env.define(e, SUBTRACTION_FUNCTION_NAME, create_subtraction())
	env.define(e, MULTIPLICATION_FUNCTION_NAME, create_multiplication())
	env.define(e, DIVISION_FUNCTION_NAME, create_division())
	env.define(e, SQRT_FUNCTION_NAME, create_sqrt())

	// string functions
	env.define(e, NEWLINE_FUNCTION_NAME, create_newline())

	// comparison functions
	env.define(e, EQUAL_FUNCTION_NAME, create_comparison_function())
	env.define(e, GREATER_FUNCTION_NAME, create_greater_than_function())
	env.define(e, GREATER_EQUAL_FUNCTION_NAME, create_greater_than_equal_function())
	env.define(e, LESS_FUNCTION_NAME, create_less_than_function())
	env.define(e, LESS_EQUAL_FUNCTION_NAME, create_less_than_equal_function())
}
