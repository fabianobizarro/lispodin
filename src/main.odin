package main

import "core:fmt"
import parser "parser"
import token "token"

// program :: "(begin (define r 10) (* pi (* r r)))"
// program :: "(+ 10 10)"
// program :: "(print (+ 10 10))\n(print (+ 20 10))"
program :: "(print (+ 10 (* 2 3)))"


main :: proc() {

	fmt.println("Input: ", program)

	tokens := token.tokenize(program)
	defer delete(tokens)

	fmt.println("Tokens")
	for t in tokens {
		fmt.println(t)
	}
	fmt.println()

	ast := parser.parse(tokens)

	fmt.println("AST")
	for s in ast do fmt.println(s)
	fmt.println()

	fmt.println("Evaluation: ")

	result, ok := evaluate(ast).?
	if ok do fmt.println(result)


}
