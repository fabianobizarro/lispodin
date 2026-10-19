package exp

import tk "../token"

@(private)
Token :: tk.Token

Expression :: union {
	List,
	Literal,
	Define,
	Procedure,
	^Variable,
}

// (....)
List :: struct {
	expressions: []Expression,
}

LiteralKind :: union {
	f32,
	string,
}

Literal :: struct {
	value: Maybe(LiteralKind),
}

// (def age 1)
Define :: struct {
	name: string,
}

// (x)
Variable :: struct {
	name:  string,
	value: ^Expression,
}

// (proc x y z)
Procedure :: struct {
	identifier: Token,
	args:       []Expression,
}
