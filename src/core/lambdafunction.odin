package core

import env "../environment"
import "core:fmt"
import "core:strings"

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


	fmt.println("Function environment:")
	print_env(&function_env)
	fmt.println()

	result := interpreter(lambda.expression.body, &function_env)

	return result
}


print_env :: proc(e: ^RuntimeEnvironment, enclosing_level := 0) {

	tab := strings.repeat("\t", enclosing_level)
	fmt.println(tab, "Enclosing #", enclosing_level)

	for k, v in e.variables {
		if _, ok := v.(LambdaFunction); ok do fmt.println(tab, k, " -> function")
		else do fmt.println(tab, k, " -> ", v)
	}

	if e.enclosing != nil {
		print_env(e.enclosing, enclosing_level + 1)
	}
}
