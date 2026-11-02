package core

Expression :: union {
	LiteralExpression,
	VariableExpression,
	LambdaCallExpression,
	LambdaExpression,
}

// 1 2 3 4
// "string content"
LiteralExpression :: struct {
	value: Maybe(LiteralValue),
}

// (... x)
//      ˆ
VariableExpression :: struct {
	name: string,
}

// (proc_name arg1 arg2)
// (proc_name arg1 arg2)
// (+ 1 1)
LambdaCallExpression :: struct {
	identifier: Token,
	args:       []Expression,
}


// (lamba x y z)
LambdaExpression :: struct {
	params: []Token,
	body:   []Statement,
}
