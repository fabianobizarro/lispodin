package builtin_functions

import "core:fmt"

subtract :: proc(values: []LiteralValue) -> f32 {
	assert(len(values) > 0)

	result: f32 = 0
	for v, i in values {

		argument_value, ok := v.(f32)
		if !ok {
			fmt.panicf("Argument %d: Expected Number", i)
		}
		result -= argument_value
	}

	return result
}
