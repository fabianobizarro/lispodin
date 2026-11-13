package scanner_tests

import "../../src/core"
import scanner "../../src/scanner"
import "core:sync"
import "core:testing"
import "core:thread"

// Carriage return falls through into read_string, so a Windows newline
// panics with "Unterminated string." Space, tab, and line feed are skipped.

@(test)
carriage_return_splits_names :: proc(t: ^testing.T) {
	// arrange
	program := "foo\rbar"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 3)
	testing.expect_value(t, result[0].type, .IDENTIFIER)
	testing.expect_value(t, result[0].lexeme, "foo")
	testing.expect_value(t, result[1].type, .IDENTIFIER)
	testing.expect_value(t, result[1].lexeme, "bar")
	testing.expect_value(t, result[2].type, .EOF)
}

@(test)
crlf_splits_names :: proc(t: ^testing.T) {
	// arrange
	program := "foo\r\nbar"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 3)
	testing.expect_value(t, result[0].type, .IDENTIFIER)
	testing.expect_value(t, result[0].lexeme, "foo")
	testing.expect_value(t, result[1].type, .IDENTIFIER)
	testing.expect_value(t, result[1].lexeme, "bar")
	testing.expect_value(t, result[2].type, .EOF)
}

@(test)
leading_carriage_return_is_blank :: proc(t: ^testing.T) {
	// arrange
	program := "\r"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 1)
	testing.expect_value(t, result[0].type, .EOF)
}

@(test)
crlf_before_a_form_is_blank :: proc(t: ^testing.T) {
	// arrange
	program := "\r\n(+ 1)"
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
	testing.expect_value(t, result[2].lexeme, "1")
	testing.expect_value(t, result[2].literal, 1)
	testing.expect_value(t, result[3].type, .RIGHT_PAREN)
	testing.expect_value(t, result[4].type, .EOF)
}

@(test)
trailing_carriage_return_is_blank :: proc(t: ^testing.T) {
	// arrange
	program := "(+ 1)\r"
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
	testing.expect_value(t, result[2].lexeme, "1")
	testing.expect_value(t, result[2].literal, 1)
	testing.expect_value(t, result[3].type, .RIGHT_PAREN)
	testing.expect_value(t, result[4].type, .EOF)
}

@(test)
newline_splits_names :: proc(t: ^testing.T) {
	// arrange
	program := "foo\nbar"
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 3)
	testing.expect_value(t, result[0].type, .IDENTIFIER)
	testing.expect_value(t, result[0].lexeme, "foo")
	testing.expect_value(t, result[1].type, .IDENTIFIER)
	testing.expect_value(t, result[1].lexeme, "bar")
	testing.expect_value(t, result[2].type, .EOF)
}

@(test)
carriage_return_inside_a_string_stays :: proc(t: ^testing.T) {
	// arrange
	program := "\"a\rb\""
	result: []core.Token
	defer delete(result)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 2)
	testing.expect_value(t, result[0].type, .STRING)
	testing.expect_value(t, result[0].lexeme, "a\rb")
	testing.expect_value(t, result[0].literal, "a\rb")
	testing.expect_value(t, result[1].type, .EOF)
}

// advance and peek cast one byte to a rune. match.is_alpha then classifies
// that byte, and read_number asks strings.substring for a rune range using
// the byte index. Multibyte letters come out as more than one token, and a
// number after one can panic with "Failed to retrieve literal value".

@(test)
unicode_letter_is_a_single_identifier :: proc(t: ^testing.T) {
	// arrange
	names := [?]string{"λ", "café"}
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
number_after_a_unicode_letter :: proc(t: ^testing.T) {
	// arrange
	program := "α 10"
	result: []core.Token
	defer delete(result)

	s: scanner.ScannerContext
	scanner.scanner_context_init(&s)

	// act
	result = scanner.tokenize(program)

	// assert
	testing.expect(t, result != nil)
	testing.expect(t, len(result) == 3)
	testing.expect_value(t, result[0].type, .IDENTIFIER)
	testing.expect_value(t, result[0].lexeme, "α")
	testing.expect_value(t, result[1].type, .NUMBER)
	testing.expect_value(t, result[1].lexeme, "10")
	testing.expect_value(t, result[1].literal, 10)
	testing.expect_value(t, result[2].type, .EOF)
}

// tokenize keeps its cursor and token buffer in package globals.
// make test runs with ODIN_TEST_THREADS=2, so two calls overlap and
// return each other's tokens.

Scan_Check :: struct {
	source:   string,
	lexeme:   string,
	want_len: int,
	failures: int,
}

Scan_Pair :: struct {
	started: int,
	left:    Scan_Check,
	right:   Scan_Check,
}

scan_side :: proc(pair: ^Scan_Pair, side: int) {
	check := &pair.left if side == 0 else &pair.right
	sync.atomic_add(&pair.started, 1)
	for _ in 0 ..< 1_000_000 {
		if sync.atomic_load(&pair.started) >= 2 {
			break
		}
	}
	if sync.atomic_load(&pair.started) < 2 {
		check.failures += 1
		return
	}

	// One call per round. A loop here livelocks: tokenize resets the shared cursor.
	tokens := scanner.tokenize(check.source)
	if len(tokens) != check.want_len || tokens[1].lexeme != check.lexeme {
		check.failures += 1
	}
	delete(tokens)
}

@(test)
tokenize_is_reentrant :: proc(t: ^testing.T) {
	// arrange
	pairs: [40]Scan_Pair
	for &pair in pairs {
		pair.left = {
			source   = "(+ 1)",
			lexeme   = "+",
			want_len = 5,
		}
		pair.right = {
			source   = "(def a 10)",
			lexeme   = "def",
			want_len = 6,
		}
	}
	left_failures: [len(pairs)]int
	right_failures: [len(pairs)]int

	// act
	for &pair, i in pairs {
		left := thread.create_and_start_with_poly_data2(&pair, 0, scan_side, context)
		right := thread.create_and_start_with_poly_data2(&pair, 1, scan_side, context)
		if left != nil {
			thread.join(left)
			thread.destroy(left)
		}
		if right != nil {
			thread.join(right)
			thread.destroy(right)
		}
		left_failures[i] = pair.left.failures
		right_failures[i] = pair.right.failures
		if pair.left.failures != 0 || pair.right.failures != 0 {
			break
		}
	}

	// assert
	for failures in left_failures {
		testing.expect_value(t, failures, 0)
	}
	for failures in right_failures {
		testing.expect_value(t, failures, 0)
	}
}
