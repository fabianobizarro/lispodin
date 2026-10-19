package main

import func "builtin/functions"
import "core:fmt"
import "core:math"
import "exp"

Result :: Maybe(exp.LiteralKind)

evaluate :: proc(expressions: []exp.Expression) -> Result {

	for expression in expressions {
		evaluate_expression(expression)
	}

	return nil
}

evaluate_expression :: proc(expression: exp.Expression) -> Result {

	switch kind in expression {
	case exp.List:
		r := evaluate_list(kind)
		return r
	case exp.Literal:
		r := evaluate_literal(kind)
		return r
	case exp.Define:
		r := evaluate_define(kind)
		return r
	case exp.Procedure:
		r := evaluate_procedure(kind)
		return r
	case ^exp.Variable:
		r := evaluate_variable(kind^)
		return r
	case:
		panic("not handled")
	}
}

evaluate_list :: proc(list: exp.List) -> Result {
	for expression in list.expressions {
		evaluate_expression(expression)
	}
	return nil
}

evaluate_literal :: proc(literal: exp.Literal) -> Result {
	return literal.value
}

evaluate_procedure :: proc(procedure: exp.Procedure) -> Result {

	fmt.println("procedure ", procedure.identifier.lexeme)
	#partial switch procedure.identifier.type {

	case .PLUS:
		sum_args := make([dynamic]f32)
		for arg in procedure.args {
			value := evaluate_expression(arg).?
			switch t in value {
			case f32:
				append(&sum_args, t)
			case string:
			case:
				panic("Type not supportted for sum operation")
			}

		}

		result := func.sum(..sum_args[:])
		return result
	case .MINUS:
		sum_args := make([dynamic]f32)
		for arg in procedure.args {
			value := evaluate_expression(arg).?
			switch t in value {
			case f32:
				append(&sum_args, t)
			case string:
			case:
				panic("Type not supportted for sum operation")
			}

		}

		result := func.subtract(..sum_args[:])
		return result
	case .SLASH:
	case .STAR:
	case .PRINT:
		return evaluate_print(procedure)
	case:
		panic("Not implemented")
	}

	return nil
}

evaluate_variable :: proc(list: exp.Variable) -> Result {
	return nil
}

evaluate_define :: proc(list: exp.Define) -> Result {
	return nil
}

evaluate_print :: proc(call: exp.Procedure) -> Result {

	fmt.println(call.identifier)
	for e in call.args {
		value := evaluate_expression(e)
		fmt.println(value)
	}

	return nil
}
