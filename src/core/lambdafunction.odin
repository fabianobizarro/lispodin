package core

InterpreterInterface :: proc(_: []Statement) -> Maybe(Atom)

LambdaFunction :: struct {
	arity: u8,
	body:  []Statement,
	call:  proc(
		i: ^LambdaFunction,
		args: []LiteralValue,
		interpreter: InterpreterInterface,
	) -> Maybe(Atom),
}
