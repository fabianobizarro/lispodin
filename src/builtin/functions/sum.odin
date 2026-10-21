package functions

import tk "../../token"
import "core:fmt"
import "core:strings"

Literal :: tk.LiteralKind

// Sum opreation
//
// Expects only numbers
sum :: proc(values: []Maybe(Literal)) -> f32 {
	if len(values) == 0 do return 0

	message: strings.Builder
	strings.builder_init(&message)
	defer strings.builder_destroy(&message)

	result: f32 = 0
	for v, i in values {

		argument_value, ok := v.?.(f32)
		if !ok {
			fmt.sbprint(&message, "Argument ", i, ": Expected Number")
			panic(strings.to_string(message))
		}
		result += argument_value
	}

	return result
}

subtract :: proc(values: []Maybe(Literal)) -> f32 {
	assert(len(values) > 0)


	message: strings.Builder
	strings.builder_init(&message)
	defer strings.builder_destroy(&message)

	result: f32 = 0
	for v, i in values {

		argument_value, ok := v.?.(f32)
		if !ok {
			fmt.sbprint(&message, "Argument ", i, ": Expected Number")
			panic(strings.to_string(message))
		}
		result -= argument_value
	}

	return result
}

multiply :: proc(values: []Maybe(Literal)) -> f32 {
	if len(values) == 0 do return 1

	message: strings.Builder
	strings.builder_init(&message)
	defer strings.builder_destroy(&message)

	result: f32 = 1
	for v, i in values {

		argument_value, ok := v.?.(f32)
		if !ok {
			fmt.sbprint(&message, "Argument ", i, ": Expected Number")
			panic(strings.to_string(message))
		}
		result *= argument_value
	}

	return result
}

divide :: proc(values: []Maybe(Literal)) -> f32 {
	if len(values) == 0 do return 1

	message: strings.Builder
	strings.builder_init(&message)
	defer strings.builder_destroy(&message)

	result: f32 = 1
	for v, i in values {

		argument_value, ok := v.?.(f32)
		if !ok {
			fmt.sbprint(&message, "Argument ", i, ": Expected Number")
			panic(strings.to_string(message))
		}

		if argument_value == 0 do panic("Division by Zero")

		result /= argument_value
	}

	return result
}
