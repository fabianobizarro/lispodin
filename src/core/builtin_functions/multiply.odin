package builtin_functions

import "core:fmt"


multiply :: proc(values: []LiteralValue) -> f32 {
	if len(values) == 0 do return 1

	result: f32 = 1
	for v, i in values {

		argument_value, ok := v.(f32)
		if !ok {
			fmt.panicf("Argument %d: Expected Number", i)
		}
		result *= argument_value
	}

	return result
}
