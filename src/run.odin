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


	if debug_flag do display_environment(e)
	if debug_flag do display_input(source)

	tokens: []core.Token
	ast: []core.Expression
	errors: []core.Error
	defer delete(errors)
	defer delete(tokens)
	defer delete(ast)

	tokens, errors = scanner.tokenize(source)

	if len(errors) > 0 {
		display_errors(errors)
		return
	}

	if debug_flag do display_tokens(tokens)

	ast, errors = parser.parse(tokens)

	if len(errors) > 0 {
		display_errors(errors)
		return
	}

	if debug_flag do display_ast(ast)

	if debug_flag do fmt.println("Evaluation: ")
	result, error := interpreter.evaluate(ast, e)
	_, ok := result.?


	if error != nil do display_error(error)
	else if ok do display_result(result.?)
}

display_result :: proc(result: core.Atom) {

	switch v in result {
	case core.LiteralValue:
		fmt.println(v)
	case core.LambdaFunction:
		fmt.printfln("<[lambda function] %s %p>", v.name, v.call)
	}
}
display_input :: proc(source: string) {
	fmt.println("Input: ", source)
	fmt.println()
}

display_environment :: proc(e: ^core.RuntimeEnvironment) {
	fmt.println("\nGlobal Env")
	print_environment(e)
	fmt.println()
}

display_tokens :: proc(tokens: []core.Token) {
	fmt.println("Tokens")
	for t in tokens {
		fmt.println(t)
	}
	fmt.println()
}

display_ast :: proc(ast: []core.Expression) {
	fmt.println("AST")
	for s in ast do fmt.printfln("%#v", s)
	fmt.println()
}

display_error :: proc(err: core.Error) {
	switch e in err {
	case core.Scanner_Error:
		fmt.printfln("[ScannerError][line %d][%s] %s", e.line, e.kind, e.message)
	case core.Parser_Error:
		fmt.printfln("[ParsingError][%s] %s", e.kind, e.message)
	case core.Runtime_Error:
		fmt.printfln("[RuntimeError][%s] %s - %s", e.kind, e.token, e.message)
	}
}

display_errors :: proc(errs: []core.Error) {
	for err in errs do display_error(err)
}
