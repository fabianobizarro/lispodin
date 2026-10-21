package main

import func "builtin/functions"
import "core:fmt"
import "exp"
import stmt "stmt"
import tk "token"

Result :: Maybe(tk.LiteralKind)

evaluate :: proc(statements: []stmt.Statement) -> Result {
	assert(len(statements) > 0)

	if len(statements) == 1 {
		return evaluate_statement(statements[0])
	}

	for s in statements do evaluate_statement(s)

	return nil
}

evaluate_statement :: proc(statement: stmt.Statement) -> Result {

	switch t in statement {

	case stmt.Print:
		return evaluate_print(t)
	case stmt.Expression:
		return evaluate_expression(t.expression)
	case stmt.Define:
	case:
	}

	return nil
}

evaluate_print :: proc(print: stmt.Print) -> Result {

	for s in print.arguments {
		exp := evaluate_expression(s)
		fmt.println(exp)
	}

	return nil
}

evaluate_expression :: proc(expression: exp.Expression) -> Result {

	switch kind in expression {
	case exp.Literal:
		return evaluate_literal(kind)
	case ^exp.Variable:
	case exp.FunctionCall:
		return evaluate_function_call(kind)
	case:
		panic("not implemented")
	}

	return nil
}

evaluate_function_call :: proc(call: exp.FunctionCall) -> Result {

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


evaluate_math_operation :: proc(call: exp.FunctionCall) -> Result {
	args := make([dynamic]Maybe(tk.LiteralKind))

	for arg in call.args {
		value := evaluate_expression(arg).?
		append(&args, value)
	}

	#partial switch call.identifier.type {
	case .PLUS:
		return func.sum(args[:])
	case .MINUS:
		return func.subtract(args[:])
	case .STAR:
		return func.multiply(args[:])
	case .SLASH:
		return func.divide(args[:])
	case:
		panic("Operation not supported")
	}

	return nil

}


//
// evaluate_list :: proc(list: exp.List) -> Result {
// 	for expression in list.expressions {
// 		evaluate_expression(expression)
// 	}
// 	return nil
// }
//
evaluate_literal :: proc(literal: exp.Literal) -> Result {
	return literal.value
}
//
// evaluate_procedure :: proc(procedure: exp.Procedure) -> Result {
//
// 	fmt.println("procedure ", procedure.identifier.lexeme)
// 	#partial switch procedure.identifier.type {
//
// 	case .PLUS:
// 		sum_args := make([dynamic]f32)
// 		for arg in procedure.args {
// 			value := evaluate_expression(arg).?
// 			switch t in value {
// 			case f32:
// 				append(&sum_args, t)
// 			case string:
// 			case:
// 				panic("Type not supportted for sum operation")
// 			}
//
// 		}
//
// 		result := func.sum(..sum_args[:])
// 		return result
// 	case .MINUS:
// 		sum_args := make([dynamic]f32)
// 		for arg in procedure.args {
// 			value := evaluate_expression(arg).?
// 			switch t in value {
// 			case f32:
// 				append(&sum_args, t)
// 			case string:
// 			case:
// 				panic("Type not supportted for sum operation")
// 			}
//
// 		}
//
// 		result := func.subtract(..sum_args[:])
// 		return result
// 	case .SLASH:
// 	case .STAR:
// 	case .PRINT:
// 		return evaluate_print(procedure)
// 	case:
// 		panic("Not implemented")
// 	}
//
// 	return nil
// }
//
// evaluate_variable :: proc(list: exp.Variable) -> Result {
// 	return nil
// }
//
// evaluate_define :: proc(list: exp.Define) -> Result {
// 	return nil
// }
//
// evaluate_print :: proc(call: exp.Procedure) -> Result {
//
// 	fmt.println(call.identifier)
// 	for e in call.args {
// 		value := evaluate_expression(e)
// 		fmt.println(value)
// 	}
//
// 	return nil
// }
