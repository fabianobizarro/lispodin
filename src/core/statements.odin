package core

import t "token"

Statement :: union {
	DefineStatement,
	PrintStatement,
	ExpressionStatement,
}

// variable define
// (def a 1)
DefineStatement :: struct {
	name:  t.Token,
	value: Expression,
}

// (print x)
PrintStatement :: struct {
	token:     t.Token,
	arguments: []Expression,
}

ExpressionStatement :: struct {
	expression: Expression,
}
