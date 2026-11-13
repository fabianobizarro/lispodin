package scanner_tests

import "../../src/core"
import scanner "../../src/scanner"
import "core:testing"

@(test)
number_zero :: proc(t: ^testing.T) {
	// arrange
	program := "0"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "0")
	testing.expect_value(t, result[0].literal, f32(0))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_positive_integer :: proc(t: ^testing.T) {
	// arrange
	program := "10"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "10")
	testing.expect_value(t, result[0].literal, f32(10))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_explicit_positive_integer :: proc(t: ^testing.T) {
	// arrange
	program := "+10"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "+10")
	testing.expect_value(t, result[0].literal, f32(10))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_negative_integer :: proc(t: ^testing.T) {
	// arrange
	program := "-10"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "-10")
	testing.expect_value(t, result[0].literal, f32(-10))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_explicit_positive_decimal :: proc(t: ^testing.T) {
	// arrange
	program := "+10.234"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "+10.234")
	testing.expect_value(t, result[0].literal, f32(10.234))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_negative_decimal :: proc(t: ^testing.T) {
	// arrange
	program := "-4532.423"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "-4532.423")
	testing.expect_value(t, result[0].literal, f32(-4532.423))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_zero_point_decimal :: proc(t: ^testing.T) {
	// arrange
	program := "0.978"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "0.978")
	testing.expect_value(t, result[0].literal, f32(0.978))
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_multiple_numbers :: proc(t: ^testing.T) {
	// arrange
	program := "0 10 +10 -10 +10.234 -4532.423 0.978"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 8)
	testing.expect_value(t, result[0].type, .NUMBER)
	testing.expect_value(t, result[0].lexeme, "0")
	testing.expect_value(t, result[0].literal, f32(0))
	testing.expect_value(t, result[1].type, .NUMBER)
	testing.expect_value(t, result[1].lexeme, "10")
	testing.expect_value(t, result[1].literal, f32(10))
	testing.expect_value(t, result[2].type, .NUMBER)
	testing.expect_value(t, result[2].lexeme, "+10")
	testing.expect_value(t, result[2].literal, f32(10))
	testing.expect_value(t, result[3].type, .NUMBER)
	testing.expect_value(t, result[3].lexeme, "-10")
	testing.expect_value(t, result[3].literal, f32(-10))
	testing.expect_value(t, result[4].type, .NUMBER)
	testing.expect_value(t, result[4].lexeme, "+10.234")
	testing.expect_value(t, result[4].literal, f32(10.234))
	testing.expect_value(t, result[5].type, .NUMBER)
	testing.expect_value(t, result[5].lexeme, "-4532.423")
	testing.expect_value(t, result[5].literal, f32(-4532.423))
	testing.expect_value(t, result[6].type, .NUMBER)
	testing.expect_value(t, result[6].lexeme, "0.978")
	testing.expect_value(t, result[6].literal, f32(0.978))
	testing.expect_value(t, result[7].type, .EOF)
}

@(test)
number_plus_alone_is_identifier :: proc(t: ^testing.T) {
	// arrange
	program := "+"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .IDENTIFIER)
	testing.expect_value(t, result[0].lexeme, "+")
	testing.expect_value(t, result[1].type, .EOF)
}

@(test)
number_plus_prefix_inside_expression :: proc(t: ^testing.T) {
	// arrange
	program := "(+ +10 -90)"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 6)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .IDENTIFIER)
	testing.expect_value(t, result[1].lexeme, "+")
	testing.expect_value(t, result[2].type, .NUMBER)
	testing.expect_value(t, result[2].lexeme, "+10")
	testing.expect_value(t, result[2].literal, f32(10))
	testing.expect_value(t, result[3].type, .NUMBER)
	testing.expect_value(t, result[3].lexeme, "-90")
	testing.expect_value(t, result[3].literal, f32(-90))
	testing.expect_value(t, result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, result[5].type, .EOF)
}
