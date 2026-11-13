package scanner

import "vendor:vulkan"
tokenize :: proc {
	tokenize_context_source,
	tokenize_source,
}

ScannerContext :: struct {
	start:   int,
	current: int,
	line:    int,
	source:  string,
	tokens:  [dynamic]Token,
}

scanner_context_init :: proc(s: ^ScannerContext, source: string = "") {
	s: ScannerContext = {
		start   = 0,
		current = 0,
		line    = 1,
		source  = source,
		tokens  = make([dynamic]Token),
	}
}

@(private)
tokenize_context_source :: proc(s: ^ScannerContext, source: string) -> []Token {
	assert(s != nil)

	s.source = source
	for !is_at_end(s) {
		s.start = s.current
		scan_token(s)
	}

	add_token(s, {type = .EOF})

	return s.tokens[:]
}

@(private)
tokenize_source :: proc(source: string) -> []Token {

	// s: ScannerContext = {
	// 	start   = 0,
	// 	current = 0,
	// 	line    = 1,
	// 	source  = source,
	// 	tokens  = make([dynamic]Token),
	// }
	s: ScannerContext

	scanner_context_init(&s, source)

	return tokenize(&s, source)
}
