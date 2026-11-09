package main

import "core:fmt"

import "core"

print_environment :: proc(e: ^core.RuntimeEnvironment) {

	if len(e.variables) == 0 do fmt.println("<empty>")

	for k in e.variables {
		switch t in e.variables[k] {
		case core.LiteralValue:
			fmt.printfln("%s => %s", k, t)
		case core.LambdaFunction:
			fmt.printfln("%s => lambda function", k)
		}
	}
}
