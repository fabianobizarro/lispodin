package main

import "core:fmt"
import "core:os"

import "core"
import env "environment"
import interpreter "interpreter"
import parser "parser"
import "repl"
import scanner "scanner"


run_repl :: proc() {

	global_env: core.RuntimeEnvironment
	defer env.destroy(&global_env)

	initialize_global_env(&global_env)

	history: repl.BufferHistory

	repl.print_welcome()
	content: string
	defer delete(content)
	for {
		content, _ = repl.read_console(&history)
		if len(content) > 0 do run(content, &global_env)
	}
}

run_file :: proc(file: ^os.File) {

	global_env: core.RuntimeEnvironment
	defer env.destroy(&global_env)

	initialize_global_env(&global_env)

	data, err := os.read_entire_file(file, context.allocator)
	if err != nil {
		fmt.println(err)
		return
	}

	defer delete(data, context.allocator)

	run(string(data), &global_env)
}

run :: proc(source: string, e: ^core.RuntimeEnvironment) {


	if debug_flag {
		fmt.println("\nGlobal Env")
		print_environment(e)
		fmt.println()
	}

	if debug_flag {

		fmt.println("Input: ", source)
		fmt.println()
	}

	tokens := scanner.tokenize(source)
	defer delete(tokens)

	if debug_flag {
		fmt.println("Tokens")
		for t in tokens {
			fmt.println(t)
		}
		fmt.println()
	}

	ast := parser.parse(tokens)

	if debug_flag {

		fmt.println("AST")
		for s in ast do fmt.printfln("%#v", s)
		fmt.println()

	}

	result, ok := interpreter.evaluate(ast, e).?

	if debug_flag do fmt.println("Evaluation: ")
	if ok do fmt.println(result)


	if debug_flag {
		fmt.println("\n Environment after execution:")
		print_environment(e)
	}
}
