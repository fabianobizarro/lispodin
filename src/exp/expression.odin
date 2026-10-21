package exp

import tk "../token"

@(private)
Token :: tk.Token

Expression :: union {
	Literal,
	^Variable,
	FunctionCall,
}

// 1 2 3 4
// "string content"
Literal :: struct {
	value: Maybe(tk.LiteralKind),
}

// (... x)
//      ˆ
Variable :: struct {
	name: string,
}

// (proc_name arg1 arg2)
// (proc_name arg1 arg2)
// (+ 1 1)
FunctionCall :: struct {
	identifier: Token,
	args:       []Expression,
}
