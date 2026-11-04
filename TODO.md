# TODO

This file tracks pending tasks for the Lisp interpreter. Items map to the limitations and bugs listed in `LANGUAGE_SPECS.md`.

## Built-in Operators

- [ ] **Fix broken `-`, `*`, `/` operators** — Issue #1
  - File: `src/functions/math/math.odin`
  - Problem: `create_subtraction`, `create_multiplication`, and `create_division` set `call = sum` instead of their own handlers.
  - Action: Wire each function to its own `subtraction`, `multiplication`, and `division` implementation.
  - Acceptance: `(- 5 2)` => `3.0`, `(* 2 3)` => `6.0`, `(/ 6 2)` => `3.0`.

## Language Features

- [ ] **Add comparison operators** — Issue #2
  - Files: `src/core/token.odin`, `src/core/keywords.odin`, `src/scanner/internal_scanner.odin`, `src/parser/internal_parser.odin`, `src/functions/math/math.odin`, `src/global_env.odin`
  - Operators: `==`, `<`, `>`, `<=`, `>=`
  - Acceptance: Expressions like `(< 1 2)`, `(== 3 3)`, `(>= 5 4)` evaluate to booleans.

- [ ] **Add conditionals and logical operators** — Issue #3
  - Files: `src/core/token.odin`, `src/core/keywords.odin`, `src/core/statements.odin`, `src/scanner/internal_scanner.odin`, `src/parser/internal_parser.odin`, `src/interpreter/interpreter.odin`
  - Forms: `if`, `cond` (optional), `and`, `or`, `not`
  - Acceptance: `(if (< 1 2) "yes" "no")` => `"yes"`.

- [ ] **Add support for negative number literals** — Issue #4
  - Files: `src/scanner/internal_scanner.odin`, `src/parser/internal_parser.odin`
  - Problem: A leading `-` is always tokenized as the subtraction operator, so `-5` cannot be parsed as a single number.
  - Acceptance: `(- 5)` => `-5.0` or `(+ -5 10)` => `5.0`.

- [ ] **Add comment syntax** — Issue #5
  - File: `src/scanner/internal_scanner.odin`
  - Syntax: `;` to end of line.
  - Acceptance: `(+ 1 2) ; this is a comment` evaluates to `3.0`.

## Lexer / Parser Improvements

- [ ] **Fix string literal bug** — Issue #6
  - File: `src/scanner/internal_scanner.odin`
  - Problem: `read_string` stores the surrounding quote characters as part of the string value.
  - Action: Strip the first and last quote characters from the captured literal.
  - Acceptance: `"hello"` evaluates to `hello` (without quotes).

- [ ] **Expand identifier characters** — Issue #7
  - File: `src/scanner/internal_scanner.odin`
  - Problem: Identifiers are currently restricted to alphabetic characters only.
  - Action: Allow digits, hyphens, underscores, and question marks after the first character (e.g., `x1`, `foo-bar`, `even?`).
  - Acceptance: Add scanner tests for valid and invalid identifiers.

## Runtime / UX

- [ ] **Implement the REPL** — Issue #8
  - Files: `src/repl/repl.odin`, `src/main.odin`
  - Action: Read input line by line, tokenize, parse, evaluate, print result, and loop.
  - Acceptance: Running the binary with no arguments starts an interactive REPL.

- [ ] **Introduce structured error handling** — Issue #9
  - Files: `src/scanner/internal_scanner.odin`, `src/parser/internal_parser.odin`, `src/interpreter/interpreter.odin`
  - Problem: Most failures panic and terminate the interpreter.
  - Action: Return error values or use a result/union type so errors can be reported gracefully.
  - Acceptance: Syntax errors print a friendly message instead of crashing.

## Tests

- [ ] **Add interpreter end-to-end tests** — Issue #10
  - Files: `tests/interpreter/`
  - Coverage: `def`, `print`, lambdas, built-in math, variable resolution, closures.

- [ ] **Add parser tests** — Issue #11
  - Files: `tests/parser/`
  - Coverage: `def`, `print`, `lambda`, function calls, literals, nested expressions.

- [ ] **Expand scanner tests** — Issue #12
  - Files: `tests/token/scanner_tests.odin`
  - Coverage: numbers, strings, identifiers, keywords, operators, whitespace, newlines.

## Infrastructure

- [x] **Set up CI/CD pipeline with release binaries**
  - Files: `.github/workflows/ci.yml`, `Makefile`, `README.md`
  - Done: every push/PR now runs lint, tests, and cross-platform builds; tags matching `vN.N.N` create GitHub Releases with attached binaries.

## Known Limitations (No Tasks)

- **No lists or pairs:** Cons cells and list data structures are out of scope for now.
- **No I/O beyond `print`:** File, network, and input operations are out of scope for now.
