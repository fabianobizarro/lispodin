package interpreter

import "core:fmt"

import core "../core"
import env "../environment"

RuntimeEnvironment :: core.RuntimeEnvironment
Result :: Maybe(Atom)

evaluate :: proc(statements: []Statement, e: ^RuntimeEnvironment) -> Result {
	assert(len(statements) > 0)

	if len(statements) == 1 {
		return evaluate_statement(statements[0], e)
	}

	for s in statements do evaluate_statement(s, e)

	return nil
}

evaluate_statement :: proc(statement: Statement, e: ^RuntimeEnvironment) -> Result {

	switch t in statement {

	case PrintStatement:
		return evaluate_print(t, e)
	case ExpressionStatement:
		return evaluate_expression(t.expression, e)
	case DefineStatement:
		return evaluate_define(t, e)
	}

	return nil
}


evaluate_define :: proc(def: DefineStatement, e: ^RuntimeEnvironment) -> Result {

	identifier := def.name.lexeme

	value := evaluate_expression(def.value, e)

	env.define(e, identifier, Atom(value.?))
	// _env[identifier] = Atom(value.?)

	return nil
}

evaluate_print :: proc(print: PrintStatement, e: ^RuntimeEnvironment) -> Result {

	for s in print.arguments {
		exp := evaluate_expression(s, e)
		fmt.println(exp)
	}

	return nil
}

evaluate_expression :: proc(expression: Expression, e: ^RuntimeEnvironment) -> Result {

	switch kind in expression {
	case LiteralExpression:
		return evaluate_literal(kind)
	case VariableExpression:
		return evaluate_variable(kind, e)
	case LambdaCallExpression:
		return evaluate_lamba_call(kind, e)
	case LambdaExpression:
		return evaluate_lambda_expression(kind, e)
	}

	return nil
}


evaluate_variable :: proc(var: VariableExpression, e: ^RuntimeEnvironment) -> Result {

	val, ok := env.get(e, var.name)
	// val, ok := _env[var.name]

	if !ok do fmt.panicf("Variable %s not found", var.name)

	return Result(val)
}

evaluate_lambda_expression :: proc(
	lambda: LambdaExpression,
	e: ^RuntimeEnvironment,
) -> LambdaFunction {

	return core.create_lambda_function(lambda, e)
}

evaluate_lamba_call :: proc(call: LambdaCallExpression, e: ^RuntimeEnvironment) -> Result {

	call_args := call.args
	func: LambdaFunction
	ok: bool
	lambda: LambdaExpression


	// check if the lambda function exists in env and the identifier is valid
	// if call.identifier.type == .IDENTIFIER && env.contains_key(e, call.identifier.lexeme) {
	if env.contains_key(e, call.identifier.lexeme) {
		raw, _ := env.get(e, call.identifier.lexeme)
		func, ok = raw.(LambdaFunction)

		if !ok {
			fmt.panicf(
				"Can only call lambda functions. %s does not seem to be a lambda.",
				call.identifier.lexeme,
			)
		}
	} else if lambda, ok = call.args[0].(LambdaExpression); ok {
		func = evaluate_lambda_expression(lambda, e)
		call_args = call_args[1:] // remove the lambda definition from arguments list
	} else {
		fmt.panicf(
			"First argument of the lambda call must be a lambda declaration.",
			call.identifier.lexeme,
		)
	}


	if func.arity >= 0 { 	// 0 means the runtime will validate the params
		if i8(len(call_args)) != func.arity {
			fmt.panicf(
				"%s: Expected %d arguments but got %d.",
				call.identifier,
				func.arity,
				len(call_args),
			)
		}
	}

	args := make([dynamic]LiteralValue)
	for arg in call_args {
		a, ok := evaluate_expression(arg, e).?.(LiteralValue)
		if !ok do panic("Expected a literal value or a lambda call.")
		append(&args, a)
	}

	// call function
	return func.call(&func, args[:], evaluate)
}


// deprecated
// builtin_math_function :: proc(t: TokenType) -> bool {
// 	switch t {
// 	case .PLUS:
// 		return false
// 	case .MINUS:
// 		return true
// 	case .STAR:
// 		return true
// 	case .SLASH:
// 		return true
// 	case .LEFT_PAREN:
// 	case .RIGHT_PAREN:
// 	case .STRING:
// 	case .NUMBER:
// 	case .TRUE:
// 	case .FALSE:
// 	case .IDENTIFIER:
// 	case .DEF:
// 	case .PRINT:
// 	case .LAMBDA:
// 	case .EOF:
// 		return false
// 	}
//
// 	return false
// }

// @deprecate
// evaluate_math_operation :: proc(call: LambdaCallExpression, e: ^RuntimeEnvironment) -> Result {
// 	// args := make([dynamic]Maybe(LiteralKind))
// 	args := make([dynamic]LiteralValue)
// 	// defer delete(args)
//
// 	for arg in call.args {
// 		value := evaluate_expression(arg, e)
//
// 		lambda, is_lambda := value.?.(LambdaFunction)
// 		if is_lambda {
// 			// TODO: call the lambda
// 			panic("?????????????")
// 		}
// 		append(&args, value.?.(LiteralValue))
//
// 	}
//
// 	#partial switch call.identifier.type {
// 	case .PLUS:
// 		return LiteralValue(func.sum(args[:]))
// 	case .MINUS:
// 		return LiteralValue(func.subtract(args[:]))
// 	case .STAR:
// 		return LiteralValue(func.multiply(args[:]))
// 	case .SLASH:
// 		return LiteralValue(func.divide(args[:]))
// 	case:
// 		panic("Operation not supported")
// 	}
//
// 	return nil
//
// }

evaluate_literal :: proc(literal: LiteralExpression) -> Result {
	return LiteralValue(literal.value.?)
}
