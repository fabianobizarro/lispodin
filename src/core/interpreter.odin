package core

import func "builtin_functions"
import "core:fmt"
import tk "token"

import "atom"

import lf "builtin_functions/lambda"


Result :: Maybe(atom.Atom)

@(private)
_env: Environment

get_current_env :: proc() -> Environment {
	return _env
}

evaluate :: proc(statements: []Statement) -> Result {
	assert(len(statements) > 0)

	if len(statements) == 1 {
		return evaluate_statement(statements[0])
	}

	for s in statements do evaluate_statement(s)

	return nil
}

evaluate_statement :: proc(statement: Statement) -> Result {

	switch t in statement {

	case PrintStatement:
		return evaluate_print(t)
	case ExpressionStatement:
		return evaluate_expression(t.expression)
	case DefineStatement:
		return evaluate_define(t)
	}

	return nil
}

evaluate_lambda_expression :: proc(lambda: LambdaExpression) -> lf.LambdaFunction {

	// _env[lambda.]

	return {arity = u8(len(lambda.params))}
}

evaluate_define :: proc(def: DefineStatement) -> Result {

	identifier := def.name.lexeme

	value := evaluate_expression(def.value)

	_env[identifier] = atom.Atom(value.?)

	return nil
}

evaluate_print :: proc(print: PrintStatement) -> Result {

	for s in print.arguments {
		exp := evaluate_expression(s)
		fmt.println(exp)
	}

	return nil
}

evaluate_expression :: proc(expression: Expression) -> Result {

	switch kind in expression {
	case LiteralExpression:
		return evaluate_literal(kind)
	case VariableExpression:
		return evaluate_variable(kind)
	case LambdaCallExpression:
		return evaluate_lamba_call(kind)
	case LambdaExpression:
		return evaluate_lambda_expression(kind)
	}

	return nil
}


evaluate_variable :: proc(var: VariableExpression) -> Result {

	val, ok := _env[var.name]

	if !ok do fmt.panicf("Variable %s not found", var.name)

	return Result(val)
}

evaluate_lamba_call :: proc(call: LambdaCallExpression) -> Result {

	if builtin_math_function(call.identifier.type) do return evaluate_math_operation(call)

	panic("not implemented")

	// return nil
}

builtin_math_function :: proc(t: tk.TokenType) -> bool {
	switch t {
	case .PLUS:
		return true
	case .MINUS:
		return true
	case .STAR:
		return true
	case .SLASH:
		return true
	case .LEFT_PAREN:
	case .RIGHT_PAREN:
	case .STRING:
	case .NUMBER:
	case .TRUE:
	case .FALSE:
	case .IDENTIFIER:
	case .DEF:
	case .PRINT:
	case .LAMBDA:
	case .EOF:
		return false
	}

	return false
}


evaluate_math_operation :: proc(call: LambdaCallExpression) -> Result {
	// args := make([dynamic]Maybe(LiteralKind))
	args := make([dynamic]atom.LiteralValue)
	// defer delete(args)

	for arg in call.args {
		value := evaluate_expression(arg)

		lambda, is_lambda := value.?.(atom.LambdaFunction)
		if is_lambda {
			// TODO: call the lambda
			panic("a")
		}
		append(&args, value.?.(atom.LiteralValue))

	}

	#partial switch call.identifier.type {
	case .PLUS:
		return tk.LiteralValue(func.sum(args[:]))
	case .MINUS:
		return tk.LiteralValue(func.subtract(args[:]))
	case .STAR:
		return tk.LiteralValue(func.multiply(args[:]))
	case .SLASH:
		return tk.LiteralValue(func.divide(args[:]))
	case:
		panic("Operation not supported")
	}

	return nil

}

evaluate_literal :: proc(literal: LiteralExpression) -> Result {
	return atom.LiteralValue(literal.value.?)
}
