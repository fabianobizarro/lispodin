#+ private
package interpreter

import "../core"
import env "../environment"
import "core:fmt"

Error :: core.Error
Runtime_Error :: core.Runtime_Error

evaluate_expression :: proc(
	expression: Expression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

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

	result = nil
	err = Runtime_Error {
		kind    = .Unexpected_Expression,
		message = "Unexpected Expression",
	}
	return
}


evaluate_variable :: proc(
	var: VariableExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	val, ok := env.get(e, var.name)

	if !ok {
		err = Runtime_Error {
			kind    = .Variable_Not_Found,
			token   = var.name,
			message = fmt.aprintf("Variable %s not found", var.name),
		}
		return
	}

	result = Result(val)
	err = nil
	return
}

evaluate_lambda_expression :: proc(
	lambda: LambdaExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: LambdaFunction,
	err: Error,
) {

	result = core.create_lambda_function(lambda, e)
	err = nil
	return
}

evaluate_literal :: proc(literal: LiteralExpression) -> (result: Result, err: Error) {
	return LiteralValue(literal.value.?), nil
}

evaluate_lamba_call :: proc(
	call: LambdaCallExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {
	call_args := call.args
	func: LambdaFunction
	ok: bool
	lambda: LambdaExpression

	// check if the lambda function exists in env and the identifier is valid
	if env.contains_key(e, call.identifier.lexeme) {
		raw, _ := env.get(e, call.identifier.lexeme)
		func, ok = raw.(LambdaFunction)

		if !ok {
			err = Runtime_Error {
				kind    = .Lambda_Call_Mismatch,
				token   = call.identifier.lexeme,
				message = fmt.aprintf(
					"Can only call lambda functions. %s does not seem to be a lambda.",
					call.identifier.lexeme,
				),
			}
			return
		}
	} else {
		if len(call.args) > 0 {
			lambda, ok = call.args[0].(LambdaExpression)
		}

		if ok {
			func = evaluate_lambda_expression(lambda, e) or_return
			call_args = call_args[1:] // remove the lambda definition from arguments list
		} else {
			err = Runtime_Error {
				kind    = .Lambda_Call_Mismatch,
				token   = call.identifier.lexeme,
				message = "First argument of the lambda call must be a lambda declaration.",
			}
			return
		}
	}

	// -1 means the runtime function will validate the params
	if func.arity >= 0 && i8(len(call_args)) != func.arity {
		err = Runtime_Error {
			kind    = .Lambda_Arity_Mismatch,
			token   = call.identifier.lexeme,
			message = fmt.aprintf(
				"%s: Expected %d arguments but got %d.",
				call.identifier,
				func.arity,
				len(call_args),
			),
		}
		return
	}


	args := make([dynamic]LiteralValue)
	defer delete(args)
	for arg in call_args {
		arg_result := evaluate_expression(arg, e) or_return
		a, is_literal := arg_result.?.(LiteralValue)
		if !is_literal {
			result = nil
			err = Runtime_Error {
				kind    = .Runtime_Or_Lambda_Expected,
				token   = call.identifier.lexeme,
				message = "Expected a literal value or a lambda call.",
			}
			return
		}
		append(&args, a)
	}

	result, err = func.call(&func, args[:], evaluate)
	return
}
