package core

Scanner_Error_Kind :: enum i32 {
	Unexpected_EOF,
	Literal_Number_Parse,
}

Scanner_Error :: struct {
	kind:    Scanner_Error_Kind,
	line:    int,
	message: string,
}

Parser_Error_Kind :: enum u32 {
	Unexpected_Token,
	Max_Parameters_Length,
	Unexpected_Expression,
	Lambda_Body_Expected,
}

Parser_Error :: struct {
	kind:    Parser_Error_Kind,
	// line:    int,
	message: string,
}

Runtime_Error_Kind :: enum u32 {
	Lambda_Call_Mismatch,
	Lambda_Arity_Mismatch,
	Unexpected_Expression,
	Unexpected_Statement,
	Runtime_Or_Lambda_Expected,
	Variable_Not_Found,
	Expected_Number,
	Division_By_Zero,
	LiteralValue_Parsing_Error,
}

Runtime_Error :: struct {
	kind:    Runtime_Error_Kind,
	token:   string,
	message: string,
}


Error :: union {
	Scanner_Error,
	Parser_Error,
	Runtime_Error,
}
