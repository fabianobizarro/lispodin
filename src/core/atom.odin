package core

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
