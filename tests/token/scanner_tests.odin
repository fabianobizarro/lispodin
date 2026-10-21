package token_tests

import scan "../../src/token"
import "core:testing"

@(test)
tokenize_test :: proc(t: ^testing.T) {
	// arrange
	program := "(+ 1)"

	// act
	result := scan.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 5)

}
