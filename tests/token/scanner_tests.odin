package token_tests

import scanner "../../src/scanner"
import "core:testing"

@(test)
tokenize_test :: proc(t: ^testing.T) {
	// arrange
	program := "(+ 1)"

	// act
	result := scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 5)
}
