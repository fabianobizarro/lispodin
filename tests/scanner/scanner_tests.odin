package scanner_tests

import "../../src/core"
import scanner "../../src/scanner"
import "core:testing"

@(test)
tokenize_test :: proc(t: ^testing.T) {
	// arrange
	program := "(+ 1)"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 5)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .IDENTIFIER)
	testing.expect_value(t, result[1].lexeme, "+")
	testing.expect_value(t, result[2].type, .NUMBER)
	testing.expect_value(t, result[3].type, .RIGHT_PAREN)
	testing.expect_value(t, result[4].type, .EOF)
}

@(test)
tokenize_test_def :: proc(t: ^testing.T) {
	// arrange
	program := "(def a 10)"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 6)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .DEF)
	testing.expect_value(t, result[1].lexeme, "def")
	testing.expect_value(t, result[2].type, .IDENTIFIER)
	testing.expect_value(t, result[3].type, .NUMBER)
	testing.expect_value(t, result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, result[5].type, .EOF)
}

@(test)
tokenize_test_lambda :: proc(t: ^testing.T) {
	// arrange
	program := "(lambda n () (10))"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .LAMBDA)
	testing.expect_value(t, result[2].type, .IDENTIFIER)
	testing.expect_value(t, result[3].type, .LEFT_PAREN)
	testing.expect_value(t, result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, result[5].type, .LEFT_PAREN)
	testing.expect_value(t, result[6].type, .NUMBER)
	testing.expect_value(t, result[7].type, .RIGHT_PAREN)
	testing.expect_value(t, result[8].type, .RIGHT_PAREN)
	testing.expect_value(t, result[9].type, .EOF)
}

@(test)
tokenize_test_lambda_with_params :: proc(t: ^testing.T) {
	// arrange
	program := "(lambda n (a b) (10))"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .LAMBDA)

	testing.expect_value(t, result[2].type, .IDENTIFIER)
	testing.expect_value(t, result[2].lexeme, "n")

	testing.expect_value(t, result[3].type, .LEFT_PAREN)

	testing.expect_value(t, result[4].type, .IDENTIFIER)
	testing.expect_value(t, result[4].lexeme, "a")

	testing.expect_value(t, result[5].type, .IDENTIFIER)
	testing.expect_value(t, result[5].lexeme, "b")

	testing.expect_value(t, result[6].type, .RIGHT_PAREN)

	testing.expect_value(t, result[7].type, .LEFT_PAREN)

	testing.expect_value(t, result[8].type, .NUMBER)
	testing.expect_value(t, result[8].literal, 10)

	testing.expect_value(t, result[9].type, .RIGHT_PAREN)
	testing.expect_value(t, result[10].type, .RIGHT_PAREN)
	testing.expect_value(t, result[11].type, .EOF)
}
