# lisp_odin

A small Lisp interpreter written in [Odin](https://odin-lang.org/).

It reads a Lisp-like program, tokenizes it, parses it into an AST, and evaluates the result. The language uses prefix notation: operators and function names come first, and forms are wrapped in parentheses.

```lisp
(print (+ 10 10))
(print (+ 20 10))
```

## Status

Early prototype. The lexer, parser, and evaluator exist, and nested arithmetic plus `print` run. Variable binding (`def`), lambdas, and loading source from a file are parsed or sketched but not finished. The program currently lives as a string in `src/main.odin`.

## Todo

- [ ] `>=` operator
- [ ] `<=` operator
- [ ] `==` operator
- [ ] Variable declaration (environment)
- [ ] Variable retrieval

## Language

Forms are lists. A call is `(name arg ...)`. Numbers are `f32`. Strings use double quotes. `true` and `false` are boolean literals.

| Form | Meaning | Evaluation |
| --- | --- | --- |
| `(+ a b ...)` | Addition | Implemented |
| `(- a b ...)` | Subtraction | Implemented |
| `(* a b ...)` | Multiplication | Implemented |
| `(/ a b ...)` | Division | Implemented |
| `(print expr ...)` | Print each argument | Implemented |
| `(def name expr)` | Bind a name | Parsed, not evaluated |
| `(lambda ...)` | Function | Keyword only |

Calls nest:

```lisp
(print (+ 10 (* 2 3)))
```

`examples/sum.lisp` is a sample program. The interpreter does not load it yet.

## Layout

```
src/
  main.odin                 entry point and the hardcoded program
  interpreter.odin          walks the AST and evaluates it
  token/                    lexer: tokens, keywords, scanner
  parser/                   recursive-descent parser
  exp/                      expression AST (literals, calls, variables)
  stmt/                     statement AST (print, def, expression)
  builtin/functions/        +, -, *, /
examples/
  sum.lisp                  sample source, not wired up
```

Pipeline:

1. `token.tokenize` scans the source into tokens.
2. `parser.parse` builds statements and expressions.
3. `evaluate` runs print forms and builtin math calls.

## Build

Requires the [Odin compiler](https://odin-lang.org/docs/install/) on `PATH`.

```sh
make          # debug build -> build/lisp_odin
make run      # odin run src
make check    # type-check only
make lint     # odinfmt check, then odin check -vet
make test     # odin test tests -all-packages
make clean    # remove build/
```

## CI

[`.github/workflows/ci.yml`](.github/workflows/ci.yml) runs on pull requests and pushes to `main`:

- **Lint** — `make lint`
- **Test** — `make test`
- **Build** — `make build` on macOS (arm64), then uploads `build/lisp_odin`

The compiler is pinned to the `dev-2026-10` release, matching the local toolchain. Add another OS by extending the build matrix.

`make build` and `make debug` both compile with `-debug` into `build/lisp_odin`.

Change the `program` string in `src/main.odin`, then `make run`, to try a different snippet. The binary prints the source, the token list, the AST, and the evaluation result.

## Editor

`ols.json` configures [OLS](https://github.com/DanielGavin/ols) with a `src` collection for the language server.
