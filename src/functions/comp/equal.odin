package comparison_functions

import core "../../core"

Literal :: core.Atom
LiteralValue :: core.LiteralValue
LambdaExpression :: core.LambdaExpression
LambdaFunction :: core.LambdaFunction

create_comparison_function :: proc() -> LambdaFunction {
	return {arity = -1, call = equal, closure = nil}
}

equal :: proc(
	_: ^LambdaFunction,
	values: []LiteralValue,
	_: core.InterpreterCaller,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {
	if len(values) == 0 do return LiteralValue(true), nil
	if len(values) == 1 do return LiteralValue(true), nil

	first_elem_type := core.get_literalvalue_typeid(values[0])

	if first_elem_type == f32 do return calculate_equal(values, f32)
	else if first_elem_type == bool do return calculate_equal(values, bool)
	else if first_elem_type == string do return calculate_equal(values, string)
	else {
		err = core.Runtime_Error {
			kind    = .LiteralValue_Parsing_Error,
			message = "Unexpected type for LiteralValue",
		}
		result = nil
		return
	}
}

@(private)
calculate_equal :: proc(
	values: []LiteralValue,
	$T: typeid,
) -> (
	result: Maybe(core.Atom),
	err: core.Error,
) {

	accum := true
	err = nil
	comp := core.parse_literalvalue(values[0], T) or_return
	for v in values[1:] {

		target := core.parse_literalvalue(v, T) or_return
		accum = accum && (comp == target)
	}

	result = LiteralValue(accum)
	return
}
