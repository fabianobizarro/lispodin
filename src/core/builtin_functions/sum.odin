package builtin_functions

import tk "../../core/token"
import "core:fmt"
// Sum opreation
//
// Expects only numbers
sum :: proc(values: []LiteralValue) -> f32 {
	if len(values) == 0 do return 0

	result: f32 = 0
	for v, i in values {

		argument_value, ok := v.(f32)
		if !ok {
			fmt.panicf("Argument %d: Expected Number", i)
		}
		result += argument_value
	}

	return result
}
