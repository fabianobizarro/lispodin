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
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	if len(values) == 0 do return core.LiteralValue(0), nil

	argument_value: f32
	accum: f32 = 0
	for v, i in values {

		argument_value = parse_f32(v) or_return

		accum += argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}


create_subtraction :: proc() -> LambdaFunction {
	return {arity = -1, call = subtraction, closure = nil}
}

@(private)
subtraction :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	assert(len(values) > 0)

	if len(values) == 1 {
		n := parse_f32(values[0]) or_return
		return n == 0 ? core.LiteralValue(0) : core.LiteralValue(n * -1), nil
	}

	argument_value: f32
	accum := parse_f32(values[0]) or_return

	for v, i in values[1:] {
		argument_value = parse_f32(v) or_return
		accum -= argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}


create_multiplication :: proc() -> LambdaFunction {
	return {arity = -1, call = multiplication, closure = nil}
}

@(private)
multiplication :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	if len(values) == 0 do return core.LiteralValue(1), nil

	argument_value: f32
	accum: f32 = 1
	for v, i in values {

		argument_value = parse_f32(v) or_return
		accum *= argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}

create_division :: proc() -> LambdaFunction {
	return {arity = -1, call = division, closure = nil}
}

@(private)
division :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	assert(len(values) > 0, "Required 1 or more operands")

	if len(values) == 1 {
		val := parse_f32(values[0]) or_return
		check_division_by_zero(val) or_return

		return LiteralValue(1 / val), nil
	}

	argument_value: f32
	accum: f32 = parse_f32(values[0]) or_return
	for v, i in values[1:] {
		argument_value = parse_f32(v) or_return
		check_division_by_zero(argument_value) or_return

		accum /= argument_value
	}

	result = core.LiteralValue(accum)
	err = nil
	return
}

check_division_by_zero :: proc(val: f32) -> (err: core.Error) {
	if val != 0 do return

	return core.Runtime_Error{kind = .Division_By_Zero, message = "Division by Zero Error"}
}

parse_f32 :: proc(literal: LiteralValue) -> (result: f32, err: core.Error) {


	ok: bool
	result, ok = literal.(f32)
	if !ok {
		err = core.Runtime_Error {
			kind    = .Expected_Number,
			message = fmt.aprintf(
				"Argument '%s': Expected type Number.",
				core.literal_to_string(literal),
			),
		}
	}

	return
}
