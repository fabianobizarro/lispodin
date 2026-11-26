# lisp_odin

A small Lisp interpreter written in [Odin](https://odin-lang.org/).

It reads a Lisp-like program, tokenizes it, parses it into an AST, and evaluates the result. The language is expression-oriented — everything is an expression — with Scheme-style chain comparisons, lazy `if`/`and`/`or`, closures, and a REPL.

```lisp
(begin (def r 10)
  (print "area: " (* pi (* r r)) (newline)))
```

## Status

Working prototype. Scanner, parser, and evaluator are implemented, along with:

- **Arithmetic:** `+ - * /` (variadic), `sqrt` (with a `.MathError` for negatives), `pi` constant
- **Comparisons:** `= > >= < <=` with Scheme monotonic-chain semantics; `=` supports numbers, strings, and booleans (type-homogeneous lists)
- **Special forms:** `def`/`define`, `print`/`display`, `lambda`, `if` (lazy, optional else), `begin`, `and`/`or` (short-circuiting, value-returning)
- **Functions:** named and anonymous lambdas, immediate calls, and computed operators (`((if c f g) x)`)

496 unit and end-to-end tests cover every builtin and special form (see `make test`).

Known bugs (all with regression guards or ready-to-add pins): escaping closures crash (#23), `def` of a no-value form panics (#24), the lambda parameter limit is off by one (#25), and `def` names are not validated (#26). See `LANGUAGE_SPECS.md` §14.

## Language

Forms are lists. Numbers are `f32`. Strings use double quotes. `true`/`false` are booleans. Truthiness is C-style: `false`, `0`, `""` are falsy, everything else is truthy.

| Form | Meaning |
| --- | --- |
| `(+ a b ...)` | sum (variadic) |
| `(- a b ...)` | subtraction fold; one arg negates |
| `(* a b ...)` | product (variadic) |
| `(/ a b ...)` | division fold; one arg reciprocates |
| `(sqrt x)` | square root; negative input is a `.MathError` |
| `(= a b ...)` | all equal — numbers, strings, or bools (first arg's type) |
| `(> a b ...)` / `(>= ...)` | strictly / non-strictly decreasing chain |
| `(< a b ...)` / `(<= ...)` | strictly / non-strictly increasing chain |
| `(newline)` | the string `"\n"` |
| `pi` | 3.1415927 |
| `(def name expr)` / `(define ...)` | bind a name; produces no value |
| `(print expr ...)` / `(display ...)` | print concatenation; produces no value |
| `(lambda (params) body)` | function value |
| `(if c t e?)` | lazy conditional; optional else |
| `(begin e ...)` | sequence; value of the last form |
| `(and e ...)` / `(or e ...)` | short-circuit; value of the last evaluated form |
| `(op arg ...)` | call — the operator can be any expression evaluating to a lambda |

Calls nest, and control flow composes with everything:

```lisp
(+ 1 (if true 2 3))                                      ; => 3.0
(and (>= -4 -10) (<= -4 10) (* -4 -4))                    ; => 16.0
((if true (lambda (x) (* x 2)) (lambda (x) 0)) 21)        ; => 42.0
```

## Running

```sh
make run                      # runs src/main.odin's `program` constant
odin run src -- examples/sum.scm   # evaluates a file and prints the result
make && ./build/lisp_odin     # file mode + REPL
```

`examples/*.scm` are runnable sample programs.

## Layout

```
src/
  main.odin              entry point: CLI flags, file mode / REPL dispatch
  run.odin               file runner and REPL loop
  repl/                  line editing and raw terminal handling
  scanner/               lexer: tokens, keywords, identifier/number/string scanning
  parser/                recursive-descent parser producing []Expression
  interpreter/           evaluator (expressions only — no statement layer)
  core/                  shared AST types, tokens, errors, helpers
  environment/           lexical environments
  functions/             flat runtime_functions package: one file per builtin,
                         base.odin registers them all via register_runtime_global_functions
  global_env.odin        global environment setup (+ pi)
tests/
  scanner/ parser/       per-phase suites
  interpreter/           end-to-end suites: comparisons, if, begin/and/or,
                         call machinery, sqrt
  functions/             builtin unit suites (runtime_functions_test package)
examples/                 sample .scm programs
```

Pipeline:

1. `scanner.tokenize` scans the source into tokens.
2. `parser.parse` builds a flat list of expressions.
3. `interpreter.evaluate` walks the AST; special forms dispatch in the parser, builtins are lambdas in the global environment.

## Build

Requires the [Odin compiler](https://odin-lang.org/docs/install/) on `PATH`.

```sh
make          # debug build -> build/lisp_odin
make release  # optimized build -> build/lisp_odin
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
- **Build** — `make release` on macOS (arm64), Linux (x64), and Windows (x64), then uploads the binaries as artifacts

The compiler is pinned to the `dev-2026-10` release, matching the local toolchain.

`make build` compiles with `-debug` into `build/lisp_odin`; `make release` builds with `-o:speed`.

## Releases

Pushing a tag matching `vN.N.N` (for example, `v0.1.0`) triggers the same lint/test/build pipeline and then creates a GitHub Release with the compiled binaries attached:

- `lisp_odin-macos-arm64`
- `lisp_odin-linux-x64`
- `lisp_odin-windows-x64.exe`

## Editor

`ols.json` configures [OLS](https://github.com/DanielGavin/ols) with a `src` collection for the language server.

## Specification

See [`LANGUAGE_SPECS.md`](LANGUAGE_SPECS.md) for the full language specification — grammar, evaluation rules, error kinds, and known limitations.
