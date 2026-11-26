package core

Expression :: union {
	LiteralExpression,
	VariableExpression,
	LambdaCallExpression,
	LambdaExpression,
	IfExpression,
	PrintExpression,
	DefineExpression,
	BeginExpression,
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
	operator: ^Expression,
	// identifier: Token,
	args:     []Expression,
}


// (lamba x y z)
LambdaExpression :: struct {
	name:   string,
	params: []Token,
	body:   []Expression,
}

// BeginExpression :: struct {
// 	statements: []Statement,
// }

IfExpression :: struct {
	condition:   ^Expression,
	then_branch: ^Expression,
	else_branch: ^Expression,
}

// (print x)
PrintExpression :: struct {
	token:     Token,
	arguments: []Expression,
}

// variable define
// (def a 1)
DefineExpression :: struct {
	name:  Token,
	value: ^Expression,
}


BeginExpression :: struct {
	expressions: []Expression,
}
