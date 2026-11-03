package main

import "base:runtime"
import "core:fmt"
import "core:os"

import core "core"
import interpreter "interpreter"
import parser "parser"
import scanner "scanner"


// program :: "(begin (define r 10) (* pi (* r r)))"
// program :: "(+ 10 10)"
// program :: "(print (+ 10 10))\n(print (+ 20 10))"
// program :: "(print (+ 10 (* 2 3)))"
// program :: "(def n 10)(def b 20)(print (+ n b))"
// program :: "(lambda () (+ 10 10))"
// program :: "(def myfunc (lambda (a b) (+ a b)))\n(print (myfunc 1 1))"
program :: "((lambda (a b) (+ a b)) 1 1)"


@(private)
debug_flag: bool = true


main :: proc() {
	length := len(os.args[1:])

	if length > 1 {
		fmt.print("Usage: ", os.args[0], "[script]")
		os.exit(64)
	} else if length == 1 {
		run_file(os.args[1])
	} else {
		run(program)
		// repl()
	}
}

repl :: proc() {
	fmt.println("Not implemented")
	os.exit(1)
}


run_file :: proc(file_path: string) {
	data, err := os.read_entire_file(file_path, context.allocator)
	if err != nil {
		fmt.println(err)
		return
	}

	defer delete(data, context.allocator)

	run(string(data))
}

run :: proc(source: string) {
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
		for s in ast do fmt.println(s)
		fmt.println()

	}

	result, ok := interpreter.evaluate(ast).?

	if debug_flag do fmt.println("Evaluation: ")
	if ok do fmt.println(result)


	if debug_flag {
		print_environment(interpreter.get_current_env())
	}
}


print_environment :: proc(env: core.Environment) {

	fmt.println("\nEnvironment:")
	if len(env) == 0 do fmt.println("<empty>")

	for k in env {
		switch t in env[k] {
		case core.LiteralValue:
			fmt.printfln("%s => %s", k, t)
		case core.LambdaFunction:
			fmt.printfln("%s => lambda function", k)
		}
	}
	// for k, v in env do fmt.printfln(k, v)
}
