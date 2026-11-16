# TODO

This file tracks pending tasks for the Lisp interpreter. Items map to the limitations and bugs listed in `LANGUAGE_SPECS.md`.

## Language Features

- [ ] **Add comparison operators** — Issue #1
  - Files: `src/core/token.odin`, `src/core/keywords.odin`, `src/scanner/scanner.token.odin`, `src/parser/parser.expressions.odin`, `src/functions/math/math.odin`, `src/global_env.odin`
  - Operators: `==`, `<`, `>`, `<=`, `>=`
  - Acceptance: Expressions like `(< 1 2)`, `(== 3 3)`, `(>= 5 4)` evaluate to booleans.

- [ ] **Add conditionals and logical operators** — Issue #2
  - Files: `src/core/token.odin`, `src/core/keywords.odin`, `src/core/statements.odin`, `src/scanner/scanner.token.odin`, `src/parser/parser.statements.odin`, `src/interpreter/interpreter.statements.odin`
  - Forms: `if`, `cond` (optional), `and`, `or`, `not`
  - Acceptance: `(if (< 1 2) "yes" "no")` => `"yes"`.

## Tests

- [ ] **Fix and expand scanner tests** — Issue #3
  - Files: `tests/scanner/`
  - Coverage: numbers, strings, identifiers, keywords, operators, whitespace, newlines, comments, carriage-return edge cases.
  - Note: existing scanner tests need to be updated to match the current `tokenize` return signature (`([]Token, []Error)`).

- [ ] **Fix math function tests** — Issue #4
  - Files: `src/functions/math/*_tests.odin`
  - Note: existing tests need to be updated to match the current handler return signature (`(Maybe(core.Atom), core.Error)`).

- [ ] **Add parser tests** — Issue #5
  - Files: `tests/parser/`
  - Coverage: `def`, `print`, `lambda`, function calls, literals, nested expressions.

- [ ] **Add interpreter end-to-end tests** — Issue #6
  - Files: `tests/interpreter/`
  - Coverage: `def`, `print`, lambdas, built-in math, variable resolution, closures.

## Infrastructure

- [x] **Set up CI/CD pipeline with release binaries**
  - Files: `.github/workflows/ci.yml`, `Makefile`, `README.md`
  - Done: every push/PR now runs lint, tests, and cross-platform builds; tags matching `vN.N.N` create GitHub Releases with attached binaries.

## Completed Tasks

- [x] **Fix broken `-`, `*`, `/` operators**
  - File: `src/functions/math/math.odin`
  - Done: each operator is wired to its own `subtraction`, `multiplication`, and `division` handler.

- [x] **Add support for negative (and explicit positive) number literals**
  - Files: `src/scanner/scanner.token.odin`, `src/scanner/scanner.number.odin`
  - Done: a leading `-` or `+` followed by a digit is tokenized as a single `NUMBER` token.

- [x] **Add comment syntax**
  - File: `src/scanner/scanner.token.odin`
  - Done: `;` starts a comment that runs to the end of the line.

- [x] **Fix string literal bug**
  - File: `src/scanner/scanner.string.odin`
  - Done: surrounding quotes are stripped from the stored literal value.

- [x] **Expand identifier characters**
  - File: `src/scanner/scanner.identifier.odin`
  - Done: identifiers support digits, hyphens, underscores, question marks, and other common symbol characters.

- [x] **Implement the REPL**
  - Files: `src/repl/repl.odin`, `src/main.odin`, `src/run.odin`
  - Done: running the binary with no arguments starts an interactive REPL.

- [x] **Introduce structured error handling**
  - Files: `src/core/errors.odin`, `src/scanner/`, `src/parser/`, `src/interpreter/`, `src/run.odin`
  - Done: scanner/parser/runtime errors are returned as `core.Error` values and reported gracefully. Some internal invariants still use assertions.

## Known Limitations (No Tasks)

- **No lists or pairs:** Cons cells and list data structures are out of scope for now.
- **No I/O beyond `print` and the REPL:** File, network, and input operations are out of scope for now.
