


package functions


sum :: proc(values: ..f32) -> f32 {
	assert(len(values) > 0)

	result: f32 = 0
	for v in values do result += v

	return result
}


subtract :: proc(values: ..f32) -> f32 {
	assert(len(values) > 0)

	if len(values) == 1 do return 0 - values[0]


	result := values[0]
	for v in values[1:] do result -= v

	return result
}
