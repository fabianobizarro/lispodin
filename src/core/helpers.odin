package core

import "core:fmt"

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
