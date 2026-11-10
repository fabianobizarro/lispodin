package scanner_tests

import "../../src/core"
import "../../src/scanner"
import "core:testing"


@(test)
string_tests_1 :: proc(t: ^testing.T) {
	// arrange
	ExpectedValue :: "hello!"
	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens = scanner.tokenize(" \"hello!\" ")

	// assert
	testing.expect(t, tokens != nil)
	testing.expect_value(t, len(tokens), 2)
	testing.expect_value(t, tokens[1].type, .EOF)

	tk := tokens[0]
	testing.expect_value(t, tk.type, .STRING)
	testing.expect_value(t, tk.literal, ExpectedValue)
	testing.expect_value(t, tk.lexeme, ExpectedValue)
}


@(test)
string_tests_2 :: proc(t: ^testing.T) {
	// arrange
	ExpectedValue1 :: "hello"
	ExpectedValue2 :: "world!"

	tokens: []core.Token
	defer delete(tokens)

	// act
	tokens = scanner.tokenize(" \"hello\"   \"world!\" ")

	// assert
	testing.expect(t, tokens != nil)
	testing.expect_value(t, len(tokens), 3)
	testing.expect_value(t, tokens[2].type, .EOF)

	tk := tokens[0]
	testing.expect_value(t, tk.type, .STRING)
	testing.expect_value(t, tk.literal, ExpectedValue1)
	testing.expect_value(t, tk.lexeme, ExpectedValue1)

	tk = tokens[1]
	testing.expect_value(t, tk.type, .STRING)
	testing.expect_value(t, tk.literal, ExpectedValue2)
	testing.expect_value(t, tk.lexeme, ExpectedValue2)
}
