package main

import "base:runtime"
import "core:debug/trace"
import "core:flags"
import "core:os"

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

	track: trace.Tracking_Allocator
	trace.tracking_allocator_init(&track, context.allocator)
	defer trace.tracking_allocator_destroy(&track)

	context.assertion_failure_proc = trace.assertion_failure_proc

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
