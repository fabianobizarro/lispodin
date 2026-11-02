package lambda

import core "../core"
import "core:fmt"


create_lambda_function :: proc(exp: core.LambdaExpression) -> core.LambdaFunction {

	instance: core.LambdaFunction = {
		arity = u8(len(exp.params)),
		body  = exp.body,
		call  = call,
	}

	return instance
}

// TBD
call :: proc(
	lambda: ^core.LambdaFunction,
	args: []core.LiteralValue,
	interpreter: core.InterpreterInterface,
) -> Maybe(core.Atom) {

	fmt.println("ATÉ AQUI DEU BOM")
	result := interpreter(lambda.body)

	fmt.println("SERÁ?...")

	return result
}
