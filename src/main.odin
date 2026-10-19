package main

import "core:fmt"
import exp "exp"
import parser "parser"
import token "token"

// program :: "(begin (define r 10) (* pi (* r r)))"
program :: "(print (+ 10 10))"


main :: proc() {

	fmt.println("Input: ", program)

	tokens := token.tokenize(program)
	defer delete(tokens)

	// fmt.println("Tokens")
	// for t in tokens {
	// 	fmt.println(t)
	// }

	ast := parser.parse(tokens)


	// fmt.println("AST")
	// for exp in ast {
	// 	// fmt.println(exp)
	// 	print_expression(exp)
	// }
	// fmt.println()

	evaluate(ast)


}

print_expression :: proc(e: exp.Expression) {
	switch v in e {
	case exp.List:
		fmt.print("LIST_EXPRESSION=(")
		for child, i in v.expressions {
			if i > 0 do fmt.print(" ")
			print_expression(child)
		}
		fmt.print(")")
	case exp.Literal:
		fmt.print(v.value)
	case exp.Define:
		fmt.print("def ", v.name)
	case exp.Procedure:
		fmt.print("PROCEDURE CALL ")
		fmt.print(v.identifier.lexeme)
		for arg in v.args {
			fmt.print(" ")
			print_expression(arg)
		}
	case ^exp.Variable:
		fmt.print(v.name)
	case:
		fmt.print("<nil>")
	}
}
