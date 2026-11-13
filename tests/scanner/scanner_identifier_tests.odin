package scanner_tests

import "../../src/core"
import scanner "../../src/scanner"
import "core:testing"

// Names continue through letters, digits, '-', '_', and '?'.
// They stop at ( ) " ; and whitespace. ';' starts a comment.
//
// A leading digit is a number. '-' followed by a digit is a negative
// number. Later in a name those characters stay in the name: x-1 is one
// identifier, -1 is a number.
//
// def, print, lambda, true, and false are keywords only when the whole
// lexeme is that word.
//
// +, -, *, / and other symbols are their own identifiers. They are not
// glued onto a name, so foo+bar is foo and +bar. A digit after that
// symbol does stick, so +1 is one identifier. Only '-' starts a number.

@(test)
letter_number_identifier :: proc(t: ^testing.T) {
	// arrange
	program := "x1"
	results: []core.Token
	defer delete(results)

	// act
	results = scanner.tokenize(program)

	// assert
	testing.expect_value(t, len(results), 2)
	testing.expect_value(t, results[0].type, .IDENTIFIER)
	testing.expect_value(t, results[0].lexeme, "x1")
	testing.expect_value(t, results[0].literal, nil)
}

@(test)
hifen_identifier :: proc(t: ^testing.T) {
	// arrange
	program := "my-name"
	results: []core.Token
	defer delete(results)

	// act
	results = scanner.tokenize(program)

	// assert
	testing.expect_value(t, len(results), 2)
	testing.expect_value(t, results[0].type, .IDENTIFIER)
	testing.expect_value(t, results[0].lexeme, "my-name")
	testing.expect_value(t, results[0].literal, nil)
}

@(test)
question_mark_identifier :: proc(t: ^testing.T) {
	// arrange
	program := "even?"
	results: []core.Token
	defer delete(results)

	// act
	results = scanner.tokenize(program)

	// assert
	testing.expect_value(t, len(results), 2)
	testing.expect_value(t, results[0].type, .IDENTIFIER)
	testing.expect_value(t, results[0].lexeme, "even?")
	testing.expect_value(t, results[0].literal, nil)
}

@(test)
underscore_identifier :: proc(t: ^testing.T) {
	// arrange
	program := "(print _int)"
	results: []core.Token
	defer delete(results)

	// act
	results = scanner.tokenize(program)

	// assert
	testing.expect_value(t, len(results), 5)
	testing.expect_value(t, results[2].type, .IDENTIFIER)
	testing.expect_value(t, results[2].lexeme, "_int")
	testing.expect_value(t, results[2].literal, nil)
}


@(test)
identifier_letters :: proc(t: ^testing.T) {
	// arrange
	names := [?]string{"a", "A", "x", "n", "T", "foo", "bar", "Fabiano", "myname", "AbC"}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_digits :: proc(t: ^testing.T) {
	// arrange
	names := [?]string {
		"x1",
		"X1",
		"x10",
		"a0",
		"a1b2",
		"x1y",
		"a123",
		"name2",
		"a0b1c2",
		"_1",
		"?1",
	}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	stuck_program := "a+1"
	stuck_result: []core.Token
	defer delete(stuck_result)

	split_program := "1x1"
	split_result: []core.Token
	defer delete(split_result)

	exponent_program := "1e10"
	exponent_result: []core.Token
	defer delete(exponent_result)

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}
	stuck_result = scanner.tokenize(stuck_program)
	split_result = scanner.tokenize(split_program)
	exponent_result = scanner.tokenize(exponent_program)

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}

	testing.expect(t, split_result != nil)
	testing.expect(t, len(split_result) == 3)
	testing.expect_value(t, split_result[0].type, .NUMBER)
	testing.expect_value(t, split_result[0].lexeme, "1")
	testing.expect_value(t, split_result[0].literal, 1)
	testing.expect_value(t, split_result[1].type, .IDENTIFIER)
	testing.expect_value(t, split_result[1].lexeme, "x1")
	testing.expect_value(t, split_result[2].type, .EOF)

	testing.expect(t, exponent_result != nil)
	testing.expect(t, len(exponent_result) == 3)
	testing.expect_value(t, exponent_result[0].type, .NUMBER)
	testing.expect_value(t, exponent_result[0].lexeme, "1")
	testing.expect_value(t, exponent_result[0].literal, 1)
	testing.expect_value(t, exponent_result[1].type, .IDENTIFIER)
	testing.expect_value(t, exponent_result[1].lexeme, "e10")
	testing.expect_value(t, exponent_result[2].type, .EOF)
}

@(test)
identifier_hyphens :: proc(t: ^testing.T) {
	// arrange
	names := [?]string {
		"my-name",
		"foo-bar",
		"foo-bar-baz",
		"make-adder",
		"My-Name",
		"a-",
		"name-",
		"foo--bar",
		"a--b",
		"-a",
		"-name",
		"--",
		"--1",
		"x-1",
	}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_underscores :: proc(t: ^testing.T) {
	// arrange
	names := [?]string{"_", "_bar", "_a", "foo_bar", "foo_", "__", "a__b", "a_b_c", "__init__"}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_question_marks :: proc(t: ^testing.T) {
	// arrange
	names := [?]string {
		"?",
		"?even",
		"even?",
		"empty?",
		"Even?",
		"even??",
		"a?b",
		"??",
		"?x?",
		"a??b",
	}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_mixed_characters :: proc(t: ^testing.T) {
	// arrange
	names := [?]string {
		"is-even?",
		"my_name-2?",
		"n-1?",
		"x_1",
		"a1_b-c?",
		"my-name?",
		"_private-1?",
	}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_keywords_with_extra_characters :: proc(t: ^testing.T) {
	// arrange
	names := [?]string {
		"define",
		"printer",
		"Def",
		"TRUE",
		"False",
		"Lambda",
		"Print",
		"def1",
		"def-name",
		"def_name",
		"def?",
		"lambda1",
		"true?",
		"true-value",
		"false?",
		"false_flag",
	}
	results: [len(names)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for name, i in names {
		results[i] = scanner.tokenize(name)
	}

	// assert
	for name, i in names {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, .IDENTIFIER)
		testing.expect_value(t, result[0].lexeme, name)
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_keywords_and_numbers_stay_exact :: proc(t: ^testing.T) {
	// arrange
	cases := [?]struct {
		program:       string,
		kind:          core.TokenType,
		lexeme:        string,
		literal:       Maybe(core.LiteralValue),
		check_literal: bool,
	} {
		{"def", .DEF, "def", nil, false},
		{"print", .PRINT, "print", nil, false},
		{"lambda", .LAMBDA, "lambda", nil, false},
		{"true", .TRUE, "true", nil, false},
		{"false", .FALSE, "false", nil, false},
		{"-1", .NUMBER, "-1", -1, true},
		{"-7", .NUMBER, "-7", -7, true},
		{"-0.5", .NUMBER, "-0.5", -0.5, true},
		{"0", .NUMBER, "0", 0, true},
		{"100", .NUMBER, "100", 100, true},
		{"007", .NUMBER, "007", 7, true},
		{"10.5", .NUMBER, "10.5", 10.5, true},
		{"3.14", .NUMBER, "3.14", nil, false},
		{"+", .IDENTIFIER, "+", nil, false},
		{"-", .IDENTIFIER, "-", nil, false},
		{"*", .IDENTIFIER, "*", nil, false},
		{"/", .IDENTIFIER, "/", nil, false},
		{"+name", .IDENTIFIER, "+name", nil, false},
		{"-name", .IDENTIFIER, "-name", nil, false},
		{"*name", .IDENTIFIER, "*name", nil, false},
		{"?even", .IDENTIFIER, "?even", nil, false},
		{"_bar", .IDENTIFIER, "_bar", nil, false},
	}
	results: [len(cases)][]core.Token
	defer for result in results {
		delete(result)
	}

	// act
	for item, i in cases {
		results[i] = scanner.tokenize(item.program)
	}

	// assert
	for item, i in cases {
		result := results[i]
		testing.expect(t, result != nil)
		testing.expect(t, len(result) == 2)
		testing.expect_value(t, result[0].type, item.kind)
		testing.expect_value(t, result[0].lexeme, item.lexeme)
		if item.check_literal {
			testing.expect_value(t, result[0].literal, item.literal)
		}
		testing.expect_value(t, result[1].type, .EOF)
	}
}

@(test)
identifier_stops_at_other_symbols :: proc(t: ^testing.T) {
	// arrange
	plus_program := "foo+bar"
	plus_result: []core.Token
	defer delete(plus_result)

	star_program := "foo*bar"
	star_result: []core.Token
	defer delete(star_result)

	slash_program := "foo/bar"
	slash_result: []core.Token
	defer delete(slash_result)

	bang_program := "set!"
	bang_result: []core.Token
	defer delete(bang_result)

	bang_name_program := "!set"
	bang_name_result: []core.Token
	defer delete(bang_name_result)

	dot_program := "foo.bar"
	dot_result: []core.Token
	defer delete(dot_result)

	eq_program := "a=b"
	eq_result: []core.Token
	defer delete(eq_result)

	global_program := "*global*"
	global_result: []core.Token
	defer delete(global_result)

	// act
	plus_result = scanner.tokenize(plus_program)
	star_result = scanner.tokenize(star_program)
	slash_result = scanner.tokenize(slash_program)
	bang_result = scanner.tokenize(bang_program)
	bang_name_result = scanner.tokenize(bang_name_program)
	dot_result = scanner.tokenize(dot_program)
	eq_result = scanner.tokenize(eq_program)
	global_result = scanner.tokenize(global_program)

	// assert
	testing.expect(t, plus_result != nil)
	testing.expect(t, len(plus_result) == 2)
	testing.expect_value(t, plus_result[0].type, .IDENTIFIER)
	testing.expect_value(t, plus_result[0].lexeme, "foo+bar")
	testing.expect_value(t, plus_result[1].type, .EOF)

	testing.expect(t, star_result != nil)
	testing.expect(t, len(star_result) == 2)
	testing.expect_value(t, star_result[0].type, .IDENTIFIER)
	testing.expect_value(t, star_result[0].lexeme, "foo*bar")
	testing.expect_value(t, star_result[1].type, .EOF)

	testing.expect(t, slash_result != nil)
	testing.expect(t, len(slash_result) == 2)
	testing.expect_value(t, slash_result[0].type, .IDENTIFIER)
	testing.expect_value(t, slash_result[0].lexeme, "foo/bar")
	testing.expect_value(t, slash_result[1].type, .EOF)

	testing.expect(t, bang_result != nil)
	testing.expect(t, len(bang_result) == 2)
	testing.expect_value(t, bang_result[0].type, .IDENTIFIER)
	testing.expect_value(t, bang_result[0].lexeme, "set!")
	testing.expect_value(t, bang_result[1].type, .EOF)

	testing.expect(t, bang_name_result != nil)
	testing.expect(t, len(bang_name_result) == 2)
	testing.expect_value(t, bang_name_result[0].type, .IDENTIFIER)
	testing.expect_value(t, bang_name_result[0].lexeme, "!set")
	testing.expect_value(t, bang_name_result[1].type, .EOF)

	testing.expect(t, dot_result != nil)
	testing.expect(t, len(dot_result) == 2)
	testing.expect_value(t, dot_result[0].type, .IDENTIFIER)
	testing.expect_value(t, dot_result[0].lexeme, "foo.bar")
	testing.expect_value(t, dot_result[1].type, .EOF)

	testing.expect(t, eq_result != nil)
	testing.expect(t, len(eq_result) == 2)
	testing.expect_value(t, eq_result[0].type, .IDENTIFIER)
	testing.expect_value(t, eq_result[0].lexeme, "a=b")
	testing.expect_value(t, eq_result[1].type, .EOF)

	testing.expect(t, global_result != nil)
	testing.expect(t, len(global_result) == 2)
	testing.expect_value(t, global_result[0].type, .IDENTIFIER)
	testing.expect_value(t, global_result[0].lexeme, "*global*")
	testing.expect_value(t, global_result[1].type, .EOF)
}

@(test)
identifier_leading_digit_is_a_number :: proc(t: ^testing.T) {
	// arrange
	one_program := "1x"
	one_result: []core.Token
	defer delete(one_result)

	name_program := "2name"
	name_result: []core.Token
	defer delete(name_result)

	spaced_program := "x 1"
	spaced_result: []core.Token
	defer delete(spaced_result)

	// act
	one_result = scanner.tokenize(one_program)
	name_result = scanner.tokenize(name_program)
	spaced_result = scanner.tokenize(spaced_program)

	// assert
	testing.expect(t, one_result != nil)
	testing.expect(t, len(one_result) == 3)
	testing.expect_value(t, one_result[0].type, .NUMBER)
	testing.expect_value(t, one_result[0].lexeme, "1")
	testing.expect_value(t, one_result[0].literal, 1)
	testing.expect_value(t, one_result[1].type, .IDENTIFIER)
	testing.expect_value(t, one_result[1].lexeme, "x")
	testing.expect_value(t, one_result[2].type, .EOF)

	testing.expect(t, name_result != nil)
	testing.expect(t, len(name_result) == 3)
	testing.expect_value(t, name_result[0].type, .NUMBER)
	testing.expect_value(t, name_result[0].lexeme, "2")
	testing.expect_value(t, name_result[0].literal, 2)
	testing.expect_value(t, name_result[1].type, .IDENTIFIER)
	testing.expect_value(t, name_result[1].lexeme, "name")
	testing.expect_value(t, name_result[2].type, .EOF)

	testing.expect(t, spaced_result != nil)
	testing.expect(t, len(spaced_result) == 3)
	testing.expect_value(t, spaced_result[0].type, .IDENTIFIER)
	testing.expect_value(t, spaced_result[0].lexeme, "x")
	testing.expect_value(t, spaced_result[1].type, .NUMBER)
	testing.expect_value(t, spaced_result[1].lexeme, "1")
	testing.expect_value(t, spaced_result[1].literal, 1)
	testing.expect_value(t, spaced_result[2].type, .EOF)
}

@(test)
identifier_user_forms :: proc(t: ^testing.T) {
	// arrange
	x1_program := "(def x1 100)"
	x1_result: []core.Token
	defer delete(x1_result)

	name_program := "(def my-name \"fabiano\")"
	name_result: []core.Token
	defer delete(name_result)

	even_program := "(def even? false)"
	even_result: []core.Token
	defer delete(even_result)

	print_x1_program := "(print x1 \"\\n\")"
	print_x1_result: []core.Token
	defer delete(print_x1_result)

	print_name_program := "(print my-name \"\\n\")"
	print_name_result: []core.Token
	defer delete(print_name_result)

	print_even_program := "(print even? \"\\n\")"
	print_even_result: []core.Token
	defer delete(print_even_result)

	// act
	x1_result = scanner.tokenize(x1_program)
	name_result = scanner.tokenize(name_program)
	even_result = scanner.tokenize(even_program)
	print_x1_result = scanner.tokenize(print_x1_program)
	print_name_result = scanner.tokenize(print_name_program)
	print_even_result = scanner.tokenize(print_even_program)

	// assert
	testing.expect(t, x1_result != nil)
	testing.expect(t, len(x1_result) == 6)
	testing.expect_value(t, x1_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, x1_result[1].type, .DEF)
	testing.expect_value(t, x1_result[1].lexeme, "def")
	testing.expect_value(t, x1_result[2].type, .IDENTIFIER)
	testing.expect_value(t, x1_result[2].lexeme, "x1")
	testing.expect_value(t, x1_result[3].type, .NUMBER)
	testing.expect_value(t, x1_result[3].lexeme, "100")
	testing.expect_value(t, x1_result[3].literal, 100)
	testing.expect_value(t, x1_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, x1_result[5].type, .EOF)

	testing.expect(t, name_result != nil)
	testing.expect(t, len(name_result) == 6)
	testing.expect_value(t, name_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, name_result[1].type, .DEF)
	testing.expect_value(t, name_result[1].lexeme, "def")
	testing.expect_value(t, name_result[2].type, .IDENTIFIER)
	testing.expect_value(t, name_result[2].lexeme, "my-name")
	testing.expect_value(t, name_result[3].type, .STRING)
	testing.expect_value(t, name_result[3].lexeme, "fabiano")
	testing.expect_value(t, name_result[3].literal, "fabiano")
	testing.expect_value(t, name_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, name_result[5].type, .EOF)

	testing.expect(t, even_result != nil)
	testing.expect(t, len(even_result) == 6)
	testing.expect_value(t, even_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, even_result[1].type, .DEF)
	testing.expect_value(t, even_result[1].lexeme, "def")
	testing.expect_value(t, even_result[2].type, .IDENTIFIER)
	testing.expect_value(t, even_result[2].lexeme, "even?")
	testing.expect_value(t, even_result[3].type, .FALSE)
	testing.expect_value(t, even_result[3].lexeme, "false")
	testing.expect_value(t, even_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, even_result[5].type, .EOF)

	testing.expect(t, print_x1_result != nil)
	testing.expect(t, len(print_x1_result) == 6)
	testing.expect_value(t, print_x1_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, print_x1_result[1].type, .PRINT)
	testing.expect_value(t, print_x1_result[1].lexeme, "print")
	testing.expect_value(t, print_x1_result[2].type, .IDENTIFIER)
	testing.expect_value(t, print_x1_result[2].lexeme, "x1")
	testing.expect_value(t, print_x1_result[3].type, .STRING)
	testing.expect_value(t, print_x1_result[3].lexeme, "\\n")
	testing.expect_value(t, print_x1_result[3].literal, "\\n")
	testing.expect_value(t, print_x1_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, print_x1_result[5].type, .EOF)

	testing.expect(t, print_name_result != nil)
	testing.expect(t, len(print_name_result) == 6)
	testing.expect_value(t, print_name_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, print_name_result[1].type, .PRINT)
	testing.expect_value(t, print_name_result[1].lexeme, "print")
	testing.expect_value(t, print_name_result[2].type, .IDENTIFIER)
	testing.expect_value(t, print_name_result[2].lexeme, "my-name")
	testing.expect_value(t, print_name_result[3].type, .STRING)
	testing.expect_value(t, print_name_result[3].lexeme, "\\n")
	testing.expect_value(t, print_name_result[3].literal, "\\n")
	testing.expect_value(t, print_name_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, print_name_result[5].type, .EOF)

	testing.expect(t, print_even_result != nil)
	testing.expect(t, len(print_even_result) == 6)
	testing.expect_value(t, print_even_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, print_even_result[1].type, .PRINT)
	testing.expect_value(t, print_even_result[1].lexeme, "print")
	testing.expect_value(t, print_even_result[2].type, .IDENTIFIER)
	testing.expect_value(t, print_even_result[2].lexeme, "even?")
	testing.expect_value(t, print_even_result[3].type, .STRING)
	testing.expect_value(t, print_even_result[3].lexeme, "\\n")
	testing.expect_value(t, print_even_result[3].literal, "\\n")
	testing.expect_value(t, print_even_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, print_even_result[5].type, .EOF)
}

@(test)
identifier_lambda_parameters :: proc(t: ^testing.T) {
	// arrange
	program := "(lambda (x1 my-name even?) (my-name))"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 12)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .LAMBDA)
	testing.expect_value(t, result[1].lexeme, "lambda")
	testing.expect_value(t, result[2].type, .LEFT_PAREN)
	testing.expect_value(t, result[3].type, .IDENTIFIER)
	testing.expect_value(t, result[3].lexeme, "x1")
	testing.expect_value(t, result[4].type, .IDENTIFIER)
	testing.expect_value(t, result[4].lexeme, "my-name")
	testing.expect_value(t, result[5].type, .IDENTIFIER)
	testing.expect_value(t, result[5].lexeme, "even?")
	testing.expect_value(t, result[6].type, .RIGHT_PAREN)
	testing.expect_value(t, result[7].type, .LEFT_PAREN)
	testing.expect_value(t, result[8].type, .IDENTIFIER)
	testing.expect_value(t, result[8].lexeme, "my-name")
	testing.expect_value(t, result[9].type, .RIGHT_PAREN)
	testing.expect_value(t, result[10].type, .RIGHT_PAREN)
	testing.expect_value(t, result[11].type, .EOF)
}

@(test)
identifier_full_program :: proc(t: ^testing.T) {
	// arrange
	program := `(def x1 100)
(def my-name "fabiano")
(def even? false)

(print x1 "\n")
(print my-name "\n")
(print even? "\n")`
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 31)
	testing.expect_value(t, result[0].type, .LEFT_PAREN)
	testing.expect_value(t, result[1].type, .DEF)
	testing.expect_value(t, result[1].lexeme, "def")
	testing.expect_value(t, result[2].type, .IDENTIFIER)
	testing.expect_value(t, result[2].lexeme, "x1")
	testing.expect_value(t, result[3].type, .NUMBER)
	testing.expect_value(t, result[3].lexeme, "100")
	testing.expect_value(t, result[3].literal, 100)
	testing.expect_value(t, result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, result[5].type, .LEFT_PAREN)
	testing.expect_value(t, result[6].type, .DEF)
	testing.expect_value(t, result[6].lexeme, "def")
	testing.expect_value(t, result[7].type, .IDENTIFIER)
	testing.expect_value(t, result[7].lexeme, "my-name")
	testing.expect_value(t, result[8].type, .STRING)
	testing.expect_value(t, result[8].lexeme, "fabiano")
	testing.expect_value(t, result[8].literal, "fabiano")
	testing.expect_value(t, result[9].type, .RIGHT_PAREN)
	testing.expect_value(t, result[10].type, .LEFT_PAREN)
	testing.expect_value(t, result[11].type, .DEF)
	testing.expect_value(t, result[11].lexeme, "def")
	testing.expect_value(t, result[12].type, .IDENTIFIER)
	testing.expect_value(t, result[12].lexeme, "even?")
	testing.expect_value(t, result[13].type, .FALSE)
	testing.expect_value(t, result[13].lexeme, "false")
	testing.expect_value(t, result[14].type, .RIGHT_PAREN)
	testing.expect_value(t, result[15].type, .LEFT_PAREN)
	testing.expect_value(t, result[16].type, .PRINT)
	testing.expect_value(t, result[16].lexeme, "print")
	testing.expect_value(t, result[17].type, .IDENTIFIER)
	testing.expect_value(t, result[17].lexeme, "x1")
	testing.expect_value(t, result[18].type, .STRING)
	testing.expect_value(t, result[18].lexeme, "\\n")
	testing.expect_value(t, result[18].literal, "\\n")
	testing.expect_value(t, result[19].type, .RIGHT_PAREN)
	testing.expect_value(t, result[20].type, .LEFT_PAREN)
	testing.expect_value(t, result[21].type, .PRINT)
	testing.expect_value(t, result[21].lexeme, "print")
	testing.expect_value(t, result[22].type, .IDENTIFIER)
	testing.expect_value(t, result[22].lexeme, "my-name")
	testing.expect_value(t, result[23].type, .STRING)
	testing.expect_value(t, result[23].lexeme, "\\n")
	testing.expect_value(t, result[23].literal, "\\n")
	testing.expect_value(t, result[24].type, .RIGHT_PAREN)
	testing.expect_value(t, result[25].type, .LEFT_PAREN)
	testing.expect_value(t, result[26].type, .PRINT)
	testing.expect_value(t, result[26].lexeme, "print")
	testing.expect_value(t, result[27].type, .IDENTIFIER)
	testing.expect_value(t, result[27].lexeme, "even?")
	testing.expect_value(t, result[28].type, .STRING)
	testing.expect_value(t, result[28].lexeme, "\\n")
	testing.expect_value(t, result[28].literal, "\\n")
	testing.expect_value(t, result[29].type, .RIGHT_PAREN)
	testing.expect_value(t, result[30].type, .EOF)
}

@(test)
identifier_between_delimiters :: proc(t: ^testing.T) {
	// arrange
	parens_digit_program := "(x1)"
	parens_digit_result: []core.Token
	defer delete(parens_digit_result)

	parens_hyphen_program := "(my-name)"
	parens_hyphen_result: []core.Token
	defer delete(parens_hyphen_result)

	parens_pred_program := "(even?)"
	parens_pred_result: []core.Token
	defer delete(parens_pred_result)

	padded_program := "  x1  "
	padded_result: []core.Token
	defer delete(padded_result)

	tabbed_program := "x1\tmy-name"
	tabbed_result: []core.Token
	defer delete(tabbed_result)

	lines_program := "x1\nmy-name"
	lines_result: []core.Token
	defer delete(lines_result)

	comment_program := "x1;comment"
	comment_result: []core.Token
	defer delete(comment_result)

	comment_line_program := "my-name;rest\neven?"
	comment_line_result: []core.Token
	defer delete(comment_line_result)

	string_x1_program := "\"x1\""
	string_x1_result: []core.Token
	defer delete(string_x1_result)

	string_name_program := "\"my-name\""
	string_name_result: []core.Token
	defer delete(string_name_result)

	string_even_program := "\"even?\""
	string_even_result: []core.Token
	defer delete(string_even_result)

	call_program := "(- x1 1)"
	call_result: []core.Token
	defer delete(call_result)

	pred_call_program := "(+ my-name even?)"
	pred_call_result: []core.Token
	defer delete(pred_call_result)

	// act
	parens_digit_result = scanner.tokenize(parens_digit_program)
	parens_hyphen_result = scanner.tokenize(parens_hyphen_program)
	parens_pred_result = scanner.tokenize(parens_pred_program)
	padded_result = scanner.tokenize(padded_program)
	tabbed_result = scanner.tokenize(tabbed_program)
	lines_result = scanner.tokenize(lines_program)
	comment_result = scanner.tokenize(comment_program)
	comment_line_result = scanner.tokenize(comment_line_program)
	string_x1_result = scanner.tokenize(string_x1_program)
	string_name_result = scanner.tokenize(string_name_program)
	string_even_result = scanner.tokenize(string_even_program)
	call_result = scanner.tokenize(call_program)
	pred_call_result = scanner.tokenize(pred_call_program)

	// assert
	testing.expect(t, parens_digit_result != nil)
	testing.expect(t, len(parens_digit_result) == 4)
	testing.expect_value(t, parens_digit_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, parens_digit_result[1].type, .IDENTIFIER)
	testing.expect_value(t, parens_digit_result[1].lexeme, "x1")
	testing.expect_value(t, parens_digit_result[2].type, .RIGHT_PAREN)
	testing.expect_value(t, parens_digit_result[3].type, .EOF)

	testing.expect(t, parens_hyphen_result != nil)
	testing.expect(t, len(parens_hyphen_result) == 4)
	testing.expect_value(t, parens_hyphen_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, parens_hyphen_result[1].type, .IDENTIFIER)
	testing.expect_value(t, parens_hyphen_result[1].lexeme, "my-name")
	testing.expect_value(t, parens_hyphen_result[2].type, .RIGHT_PAREN)
	testing.expect_value(t, parens_hyphen_result[3].type, .EOF)

	testing.expect(t, parens_pred_result != nil)
	testing.expect(t, len(parens_pred_result) == 4)
	testing.expect_value(t, parens_pred_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, parens_pred_result[1].type, .IDENTIFIER)
	testing.expect_value(t, parens_pred_result[1].lexeme, "even?")
	testing.expect_value(t, parens_pred_result[2].type, .RIGHT_PAREN)
	testing.expect_value(t, parens_pred_result[3].type, .EOF)

	testing.expect(t, padded_result != nil)
	testing.expect(t, len(padded_result) == 2)
	testing.expect_value(t, padded_result[0].type, .IDENTIFIER)
	testing.expect_value(t, padded_result[0].lexeme, "x1")
	testing.expect_value(t, padded_result[1].type, .EOF)

	testing.expect(t, tabbed_result != nil)
	testing.expect(t, len(tabbed_result) == 3)
	testing.expect_value(t, tabbed_result[0].type, .IDENTIFIER)
	testing.expect_value(t, tabbed_result[0].lexeme, "x1")
	testing.expect_value(t, tabbed_result[1].type, .IDENTIFIER)
	testing.expect_value(t, tabbed_result[1].lexeme, "my-name")
	testing.expect_value(t, tabbed_result[2].type, .EOF)

	testing.expect(t, lines_result != nil)
	testing.expect(t, len(lines_result) == 3)
	testing.expect_value(t, lines_result[0].type, .IDENTIFIER)
	testing.expect_value(t, lines_result[0].lexeme, "x1")
	testing.expect_value(t, lines_result[1].type, .IDENTIFIER)
	testing.expect_value(t, lines_result[1].lexeme, "my-name")
	testing.expect_value(t, lines_result[2].type, .EOF)

	testing.expect(t, comment_result != nil)
	testing.expect(t, len(comment_result) == 2)
	testing.expect_value(t, comment_result[0].type, .IDENTIFIER)
	testing.expect_value(t, comment_result[0].lexeme, "x1")
	testing.expect_value(t, comment_result[1].type, .EOF)

	testing.expect(t, comment_line_result != nil)
	testing.expect(t, len(comment_line_result) == 3)
	testing.expect_value(t, comment_line_result[0].type, .IDENTIFIER)
	testing.expect_value(t, comment_line_result[0].lexeme, "my-name")
	testing.expect_value(t, comment_line_result[1].type, .IDENTIFIER)
	testing.expect_value(t, comment_line_result[1].lexeme, "even?")
	testing.expect_value(t, comment_line_result[2].type, .EOF)

	testing.expect(t, string_x1_result != nil)
	testing.expect(t, len(string_x1_result) == 2)
	testing.expect_value(t, string_x1_result[0].type, .STRING)
	testing.expect_value(t, string_x1_result[0].lexeme, "x1")
	testing.expect_value(t, string_x1_result[0].literal, "x1")
	testing.expect_value(t, string_x1_result[1].type, .EOF)

	testing.expect(t, string_name_result != nil)
	testing.expect(t, len(string_name_result) == 2)
	testing.expect_value(t, string_name_result[0].type, .STRING)
	testing.expect_value(t, string_name_result[0].lexeme, "my-name")
	testing.expect_value(t, string_name_result[0].literal, "my-name")
	testing.expect_value(t, string_name_result[1].type, .EOF)

	testing.expect(t, string_even_result != nil)
	testing.expect(t, len(string_even_result) == 2)
	testing.expect_value(t, string_even_result[0].type, .STRING)
	testing.expect_value(t, string_even_result[0].lexeme, "even?")
	testing.expect_value(t, string_even_result[0].literal, "even?")
	testing.expect_value(t, string_even_result[1].type, .EOF)

	testing.expect(t, call_result != nil)
	testing.expect(t, len(call_result) == 6)
	testing.expect_value(t, call_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, call_result[1].type, .IDENTIFIER)
	testing.expect_value(t, call_result[1].lexeme, "-")
	testing.expect_value(t, call_result[2].type, .IDENTIFIER)
	testing.expect_value(t, call_result[2].lexeme, "x1")
	testing.expect_value(t, call_result[3].type, .NUMBER)
	testing.expect_value(t, call_result[3].lexeme, "1")
	testing.expect_value(t, call_result[3].literal, 1)
	testing.expect_value(t, call_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, call_result[5].type, .EOF)

	testing.expect(t, pred_call_result != nil)
	testing.expect(t, len(pred_call_result) == 6)
	testing.expect_value(t, pred_call_result[0].type, .LEFT_PAREN)
	testing.expect_value(t, pred_call_result[1].type, .IDENTIFIER)
	testing.expect_value(t, pred_call_result[1].lexeme, "+")
	testing.expect_value(t, pred_call_result[2].type, .IDENTIFIER)
	testing.expect_value(t, pred_call_result[2].lexeme, "my-name")
	testing.expect_value(t, pred_call_result[3].type, .IDENTIFIER)
	testing.expect_value(t, pred_call_result[3].lexeme, "even?")
	testing.expect_value(t, pred_call_result[4].type, .RIGHT_PAREN)
	testing.expect_value(t, pred_call_result[5].type, .EOF)
}
