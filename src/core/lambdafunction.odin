package core

import env "../environment"
import "core:fmt"

InterpreterCaller :: proc(_: []Statement, e: ^RuntimeEnvironment) -> Maybe(Atom)

FunctionCreator :: proc(exp: LambdaExpression) -> LambdaFunction

LambdaCallHandler :: proc(
	i: ^LambdaFunction,
	args: []LiteralValue,
	interpreter: InterpreterCaller,
) -> Maybe(Atom)

LambdaFunction :: struct {
	arity:      i8,
	expression: LambdaExpression,
	call:       LambdaCallHandler,
	closure:    ^RuntimeEnvironment,
}

create_lambda_function :: proc(
	exp: LambdaExpression,
	closure: ^RuntimeEnvironment,
) -> LambdaFunction {

	return LambdaFunction {
		arity = i8(len(exp.params)),
		expression = exp,
		call = call,
		closure = closure,
	}
}

@(private)
call :: proc(
	lambda: ^LambdaFunction,
	args: []LiteralValue,
	interpreter: InterpreterCaller,
) -> Maybe(Atom) {

	function_env: RuntimeEnvironment
	defer env.destroy(&function_env)

	env.init(&function_env, lambda.closure)
	for param, i in lambda.expression.params {
		env.define(&function_env, param.lexeme, args[i])
	}

	fmt.println("ATÉ AQUI DEU BOM")


	print_env(&function_env)

	result := interpreter(lambda.expression.body, &function_env)

	fmt.println("SERÁ?...")

	return result
}


print_env :: proc(e: ^RuntimeEnvironment) {

	for k, v in e.variables {
		fmt.println(k, " -> ", v)
	}

	if e.enclosing != nil {
		fmt.printfln("\t========")
		print_env(e.enclosing)
	}
}
