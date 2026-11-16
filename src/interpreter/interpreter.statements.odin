#+ private
package interpreter

import env "../environment"
import "core:fmt"
import "core:strings"

evaluate_statement :: proc(
	statement: Statement,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	switch t in statement {

	case PrintStatement:
		return evaluate_print(t, e)
	case ExpressionStatement:
		return evaluate_expression(t.expression, e)
	case DefineStatement:
		return evaluate_define(t, e)
	}

	result = nil
	err = Runtime_Error {
		kind    = .Unexpected_Statement,
		message = "Unexpected Statement",
	}
	return
}


evaluate_define :: proc(
	def: DefineStatement,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	identifier := def.name.lexeme

	value := evaluate_expression(def.value, e) or_return

	env.define(e, identifier, Atom(value.?))

	result = nil
	return
}

evaluate_print :: proc(
	print: PrintStatement,
	e: ^RuntimeEnvironment,
) -> (
	result: Result,
	err: Error,
) {

	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	for s in print.arguments {
		exp := evaluate_expression(s, e) or_return
		atom, _ := exp.?

		write_builder(&builder, atom)
	}

	// todo:  is there a better way to write to stdout?
	fmt.print(strings.to_string(builder))

	result = nil
	return
}

write_builder :: proc(builder: ^strings.Builder, atom: Maybe(Atom)) {

	res, ok := atom.?
	if !ok do return

	literal := res.(LiteralValue) or_else panic("Expected a literal value to be printed.")

	switch v in literal {
	case f32:
		strings.write_f32(builder, v, 'f')
	case string:
		strings.write_string(builder, unescape(v))
	case bool:
		strings.write_string(builder, v ? "true" : "false")
	}
}


unescape :: proc(s: string, allocator := context.allocator) -> string {
	result := s
	result, _ = strings.replace_all(result, "\\n", "\n", allocator)
	result, _ = strings.replace_all(result, "\\t", "\t", allocator)
	result, _ = strings.replace_all(result, "\\r", "\r", allocator)
	result, _ = strings.replace_all(result, "\\\\", "\\", allocator)

	return result
}
