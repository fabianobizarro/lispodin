#+ private
package interpreter

import "../core"
import env "../environment"
import "core:fmt"
import "core:strings"

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
	case:
		result = nil
		err = Runtime_Error {
			kind    = .Unexpected_Expression,
			message = "Unexpected Expression",
		}
		return
	case core.LiteralExpression:
		return evaluate_literal(kind)
	case core.VariableExpression:
		return evaluate_variable(kind, e)
	case core.LambdaCallExpression:
		return evaluate_lamba_call(kind, e)
	case core.LambdaExpression:
		return evaluate_lambda_expression(kind, e)
	case core.IfExpression:
		return evaluate_if_expression(kind, e)
	case core.PrintExpression:
		return evaluate_print(kind, e)
	case core.DefineExpression:
		return evaluate_define(kind, e)
	case core.BeginExpression:
		return evaluate_begin_expression(kind, e)
	case core.AndExpression:
		return evaluate_and_expression(kind, e)
	case core.OrExpression:
		return evaluate_or_expression(kind, e)
	}
}

evaluate_or_expression :: proc(
	exp: core.OrExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	for expression in exp.expressions {
		result = evaluate_expression(expression, e) or_return
		if truthy(result) do return
	}

	return
}

evaluate_and_expression :: proc(
	exp: core.AndExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	for expression in exp.expressions {
		result = evaluate_expression(expression, e) or_return
		if falsy(result) do return
	}

	return
}

evaluate_begin_expression :: proc(
	exp: core.BeginExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	for expression in exp.expressions {
		result = evaluate_expression(expression, e) or_return
	}

	return
}

evaluate_if_expression :: proc(
	exp: core.IfExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {
	condition_eval := evaluate_expression(exp.condition^, e) or_return

	if truthy(condition_eval) {
		return evaluate_expression(exp.then_branch^, e)
	} else if exp.else_branch != nil {
		return evaluate_expression(exp.else_branch^, e)
	}

	return nil, nil
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

	operator := evaluate_expression(call.operator^, e) or_return
	if _, ok := operator.?; !ok {
		result = nil
		err = Runtime_Error {
			kind    = .Runtime_Or_Lambda_Expected,
			message = "Expected a variable or lambda definition as the call operator",
		}
		return
	}


	atom, ok := operator.?
	if !ok {
		err = Runtime_Error {
			kind    = .Unexpected_Expression,
			message = "Expected a Lambda function. Got nil",
		}
		return
	}

	func, is_lambda := atom.(LambdaFunction)
	if !is_lambda {
		err = Runtime_Error {
			kind    = .Runtime_Or_Lambda_Expected,
			message = "Unknown Lambda declaration",
		}
		return
	}

	// -1 means the runtime function will validate the params
	if func.arity >= 0 && i8(len(call_args)) != func.arity {
		err = Runtime_Error {
			kind    = .Lambda_Arity_Mismatch,
			token   = func.name,
			message = fmt.aprintf(
				"Expected %d argument(s) but got %d.",
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
				token   = core.literal_to_string(a),
				message = "Expected a literal value or a lambda call.",
			}
			return
		}
		append(&args, a)
	}

	result, err = func.call(&func, args[:], evaluate)
	return
}

evaluate_define :: proc(
	def: core.DefineExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	identifier := def.name.lexeme

	value := evaluate_expression(def.value^, e) or_return

	if func, is_func := value.?.(LambdaFunction); is_func {
		if func.name == core.ANONYMOUS_LAMBDA_NAME {
			func.name = identifier
		}
	}

	env.define(e, identifier, Atom(value.?))

	result = nil
	return
}

evaluate_print :: proc(
	print: core.PrintExpression,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	for s in print.arguments {
		exp := evaluate_expression(s, e) or_return
		atom, _ := exp.?

		write_builder(&builder, atom) or_return
	}

	fmt.print(strings.to_string(builder))

	result = nil
	return
}

write_builder :: proc(builder: ^strings.Builder, atom: Maybe(Atom)) -> (err: Error) {

	raw: Atom
	ok: bool
	literal: LiteralValue

	raw, ok = atom.?
	if !ok do return

	literal, ok = raw.(LiteralValue)
	if !ok {
		return Runtime_Error {
			kind = .LiteralValue_Parsing_Error,
			message = fmt.aprint("Unable to parse literal value for ", atom),
		}
	}

	switch v in literal {
	case f32:
		strings.write_f32(builder, v, 'f')
	case string:
		strings.write_string(builder, unescape(v))
	case bool:
		strings.write_string(builder, v ? "true" : "false")
	}

	return nil
}


unescape :: proc(s: string, allocator := context.allocator) -> string {
	result := s
	result, _ = strings.replace_all(result, "\\n", "\n", allocator)
	result, _ = strings.replace_all(result, "\\t", "\t", allocator)
	result, _ = strings.replace_all(result, "\\r", "\r", allocator)
	result, _ = strings.replace_all(result, "\\\\", "\\", allocator)

	return result
}
