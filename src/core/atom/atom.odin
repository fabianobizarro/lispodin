package odin

import "../builtin_functions/lambda"

LambdaFunction :: lambda.LambdaFunction

LiteralValue :: union {
	f32,
	string,
	bool,
}

/*
Represents the smallest piece of value possible in the language

A literal value (f32, string, bool) or a lambda expression
*/
Atom :: union {
	LiteralValue,
	LambdaFunction,
}
