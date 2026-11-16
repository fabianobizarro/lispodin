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
	None = 0,
}

Parser_Error :: struct {
	kind:    Parser_Error_Kind,
	line:    int,
	message: string,
}

Error :: union {
	Scanner_Error,
	Parser_Error,
}
