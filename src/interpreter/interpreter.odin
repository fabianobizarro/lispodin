package interpreter

import "core:fmt"
import "core:strconv"
import "core:strings"

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

	return nil
}

evaluate_print :: proc(print: PrintStatement, e: ^RuntimeEnvironment) -> Result {

	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	for s in print.arguments {
		exp, ok := evaluate_expression(s, e).?

		write_builder(&builder, exp)
	}

	fmt.print(strings.to_string(builder))

	return nil
}

write_builder :: proc(builder: ^strings.Builder, atom: Maybe(Atom)) {

	res, ok := atom.?
	if !ok do return

	literal := res.(LiteralValue) or_else panic("Expected a literal value to be printed.")

	switch v in literal {
	case f32:
		strings.write_f32(builder, v, 'f')
	case string:
		strings.write_string(builder, unescape(v))
	case bool:
		strings.write_string(builder, v ? "true" : "false")
	}
}


unescape :: proc(s: string, allocator := context.allocator) -> string {
	result := s
	result, _ = strings.replace_all(result, "\\n", "\n", allocator)
	result, _ = strings.replace_all(result, "\\t", "\t", allocator)
	result, _ = strings.replace_all(result, "\\r", "\r", allocator)
	result, _ = strings.replace_all(result, "\\\\", "\\", allocator)

	return result
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

	if !ok do fmt.panicf("Variable %s not found", var.name)

	return Result(val)
}

evaluate_lambda_expression :: proc(
	lambda: LambdaExpression,
	e: ^RuntimeEnvironment,
) -> LambdaFunction {

	return core.create_lambda_function(lambda, e)
}

evaluate_literal :: proc(literal: LiteralExpression) -> Result {
	return LiteralValue(literal.value.?)
}

evaluate_lamba_call :: proc(call: LambdaCallExpression, e: ^RuntimeEnvironment) -> Result {

	call_args := call.args
	func: LambdaFunction
	ok: bool
	lambda: LambdaExpression


	// check if the lambda function exists in env and the identifier is valid
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

	// -1 means the runtime function will validate the params
	if func.arity >= 0 && i8(len(call_args)) != func.arity {
		fmt.panicf(
			"%s: Expected %d arguments but got %d.",
			call.identifier,
			func.arity,
			len(call_args),
		)
	}


	args := make([dynamic]LiteralValue)
	for arg in call_args {
		a, is_literal := evaluate_expression(arg, e).?.(LiteralValue)
		if !is_literal do panic("Expected a literal value or a lambda call.")
		append(&args, a)
	}

	// call function
	return func.call(&func, args[:], evaluate)
}
