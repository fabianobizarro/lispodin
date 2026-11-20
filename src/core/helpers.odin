package core

import "base:intrinsics"
import "core:fmt"
import "core:reflect"

get_literalvalue_type_str :: proc(
	$T: typeid,
) -> string where intrinsics.type_is_variant_of(LiteralValue, T) {
	if T == f32 do return "NUMBER"
	else if T == string do return "STRING"
	else if T == bool do return "BOOLEAN"

	return ""
}

get_literalvalue_typeid :: proc(l: LiteralValue) -> typeid {
	return reflect.union_variant_typeid(l)
}

literal_to_string :: proc(literal: LiteralValue) -> (result: string = "") {

	switch v in literal {
	case f32:
		result = fmt.aprint(v)
	case string:
		result = v
	case bool:
		result = v ? "true" : "false"
	}

	return
}


parse_literalvalue :: proc(literal: LiteralValue, $T: typeid) -> (result: T, err: Error) {

	ok: bool
	result, ok = literal.(T)
	if !ok {
		err = Runtime_Error {
			kind    = .Expected_LiteralValue_Type,
			message = fmt.aprintf(
				"Argument '%s': Expected type %s.",
				literal_to_string(literal),
				get_literalvalue_type_str(T),
			),
		}
	}

	return
}

parse_f32 :: proc(literal: LiteralValue) -> (result: f32, err: Error) {
	return parse_literalvalue(literal, f32)
}
