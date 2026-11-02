package core

Statement :: union {
	DefineStatement,
	PrintStatement,
	ExpressionStatement,
}

// variable define
// (def a 1)
DefineStatement :: struct {
	name:  Token,
	value: Expression,
}

// (print x)
PrintStatement :: struct {
	token:     Token,
	arguments: []Expression,
}

ExpressionStatement :: struct {
	expression: Expression,
}
