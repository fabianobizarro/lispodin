package builtin_functions

import core "../../core"
import "core:fmt"

Literal :: core.Atom
LiteralValue :: core.LiteralValue
LambdaExpression :: core.LambdaExpression
LambdaFunction :: core.LambdaFunction

create_sum :: proc() -> LambdaFunction {
	return {arity = -1, call = sum, closure = nil}
}

@(private)
sum :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> Maybe(core.Atom) {
	if len(values) == 0 do return core.LiteralValue(0)

	result: f32 = 0
	for v, i in values {

		argument_value, ok := v.(f32)
		if !ok do fmt.panicf("Argument %d: Expected Number", i)

		result += argument_value
	}

	return core.LiteralValue(result)
}


create_subtraction :: proc() -> LambdaFunction {
	return {arity = -1, call = subtraction, closure = nil}
}

@(private)
subtraction :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> Maybe(core.Atom) {
	assert(len(values) > 0)

	if len(values) == 1 {
		n := values[0].(f32)
		return n == 0 ? core.LiteralValue(0) : core.LiteralValue(n * -1)
	}

	argument_value: f32
	ok: bool

	argument_value, ok = values[0].(f32)
	if !ok do fmt.panicf("Argument %d: Expected Number", 0)

	result: f32 = values[0].(f32)
	for v, i in values[1:] {

		argument_value, ok := v.(f32)
		if !ok do fmt.panicf("Argument %d: Expected Number", i)

		result -= argument_value
	}

	return core.LiteralValue(result)
}


create_multiplication :: proc() -> LambdaFunction {
	return {arity = -1, call = multiplication, closure = nil}
}

@(private)
multiplication :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> Maybe(core.Atom) {
	if len(values) == 0 do return core.LiteralValue(1)

	result: f32 = 1
	for v, i in values {

		argument_value, ok := v.(f32)
		if !ok {
			fmt.panicf("Argument %d: Expected Number", i)
		}
		result *= argument_value
	}

	return core.LiteralValue(result)
}

create_division :: proc() -> LambdaFunction {
	return {arity = -1, call = division, closure = nil}
}

@(private)
division :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> Maybe(core.Atom) {
	assert(len(values) > 0, "Required 1 or more operands")

	if len(values) == 1 {
		val := values[0].(f32)
		if val == 0 do panic("Division by Zero")

		return LiteralValue(1 / val)
	}

	result: f32 = values[0].(f32)
	for v, i in values[1:] {

		argument_value, ok := v.(f32)
		if !ok do fmt.panicf("Argument %d: Expected Number", i)

		if argument_value == 0 do panic("Division by Zero")

		result /= argument_value
	}

	return core.LiteralValue(result)
}
