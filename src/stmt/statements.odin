package statements

import exp "../exp"
import tk "../token"

Statement :: union {
	Define,
	Print,
	Expression,
}

// variable define
// (def a 1)
Define :: struct {
	name:  tk.Token,
	value: exp.Expression,
}

// (print x)
Print :: struct {
	token:     tk.Token,
	arguments: []exp.Expression,
}

Expression :: struct {
	expression: exp.Expression,
}

// (lamba x y z)
// FunctionDefinition :: struct {
// 	identifier: Token,
// 	args:       []Expression,
// }
