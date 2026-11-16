package scanner

import "../core"

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
	s^ = {
		start   = 0,
		current = 0,
		line    = 1,
		source  = source,
		tokens  = make([dynamic]Token),
	}
}

@(private)
tokenize_context_source :: proc(s: ^ScannerContext, source: string) -> ([]Token, []core.Error) {
	assert(s != nil)

	errors: [dynamic]core.Error

	s.source = source
	for !is_at_end(s) {
		s.start = s.current

		err := scan_token(s)
		if err != nil do append(&errors, err)
	}

	add_token(s, {type = .EOF})

	return s.tokens[:], errors[:]
}

@(private)
tokenize_source :: proc(source: string) -> ([]Token, []core.Error) {

	s: ScannerContext
	scanner_context_init(&s, source)

	return tokenize(&s, source)
}
