package main

import "base:runtime"
import "core:debug/trace"
import "core:flags"
import "core:fmt"
import "core:os"

import core "core"
import env "environment"
import interpreter "interpreter"
import parser "parser"
import scanner "scanner"

import "repl"

// program :: "(begin (define r 10) (* pi (* r r)))"
// program :: "(+ 10 10)"
// program :: "(print (+ 10 10))\n(print (+ 20 10))"
// program :: "(print (+ 10 (* 2 3)))"
// program :: "(def n 10)(def b 20)(print (+ n b))"
// program :: "(lambda () (+ 10 10))"
// program :: "(def myfunc (lambda (a b) (+ a b)))\n(print (myfunc 1 1))"
program :: "((lambda (a b) (+ a b)) 1 1)"


@(private)
debug_flag: bool = false


main :: proc() {
	//
	// 	track: trace.Tracking_Allocator
	// 	trace.tracking_allocator_init(&track, context.allocator)
	// 	defer trace.tracking_allocator_destroy(&track)
	//
	// 	context.assertion_failure_proc = trace.assertion_failure_proc

	_main()
}


CliOptions :: struct {
	file:  ^os.File `args:"pos=0, requried" usage: "Input file"`,
	debug: bool `args:"pos=1" usage: "Enable debuging logs"`,
}


my_custom_type_setter :: proc(
	data: rawptr,
	data_type: typeid,
	unparsed_value: string,
	args_tag: string,
) -> (
	error: string,
	handled: bool,
	alloc_error: runtime.Allocator_Error,
) {

	return
}

my_custom_flag_checker :: proc(
	model: rawptr,
	name: string,
	value: any,
	args_tag: string,
) -> (
	error: string,
) {
	return
}

_main :: proc() {

	options: CliOptions
	style: flags.Parsing_Style = .Unix

	flags.register_flag_checker(my_custom_flag_checker)
	flags.register_type_setter(my_custom_type_setter)
	flags.parse_or_exit(&options, os.args, style)

	// fmt.printfln("%#v", options)

	debug_flag = options.debug

	if options.file != nil do run_file(options.file)
	else do run_repl()
}

run_repl :: proc() {

	repl.print_welcome()
	content: string
	for {
		content, _ = repl.read_console()
		defer delete(content)
		// fmt.println("content:_", content)
		if len(content) > 0 do run(content)
	}

	os.exit(1)
}

run_file :: proc(file: ^os.File) {

	data, err := os.read_entire_file(file, context.allocator)
	if err != nil {
		fmt.println(err)
		return
	}

	defer delete(data, context.allocator)

	run(string(data))
}

run :: proc(source: string) {

	global_env: core.RuntimeEnvironment
	defer env.destroy(&global_env)

	initialize_global_env(&global_env)

	if debug_flag {
		fmt.println("\nGlobal Env")
		print_environment(&global_env)
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

	result, ok := interpreter.evaluate(ast, &global_env).?

	if debug_flag do fmt.println("Evaluation: ")
	if ok do fmt.println(result)


	if debug_flag {
		fmt.println("\n Environment after execution:")
		print_environment(&global_env)
	}
}


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
