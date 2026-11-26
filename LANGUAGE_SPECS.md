# Language Specification

This document describes the Lisp-like language implemented by the interpreter in this repository.

## 1. Overview

The language is a minimal, parenthesized, prefix-notation language inspired by Scheme and Lisp. Programs are made of **forms** (parenthesized lists) and **atoms** (literals and identifiers). The interpreter reads source text, tokenizes it, parses it into an AST, and evaluates the result.

Key characteristics:

- **Prefix notation:** `(operator arg1 arg2 ...)`
- **Everything is an expression:** there are no statements. Every form produces a value — or *no value* (see 2.5).
- **Dynamic typing:** values are one of `f32`, `string`, `bool`, or `lambda`.
- **Lexical scoping:** lambdas capture the environment where they are defined (with a current limitation for escaping closures — see 14).
- **Short-circuiting conditionals:** `if`, `and`, and `or` evaluate only the forms they need.

## 2. Data Types

| Type     | Description                   | Literal Example        |
| -------- | ----------------------------- | ---------------------- |
| `number` | 32-bit floating point (`f32`) | `42`, `3.14`, `-7`     |
| `string` | Double-quoted text            | `"hello"`              |
| `bool`   | Boolean value                 | `true`, `false`        |
| `lambda` | Function value                | `(lambda (x) (+ x 1))` |

### 2.1 Numbers

Numbers are parsed as `f32`. Integer-looking literals are still stored as floating-point values. An explicit leading `+` or `-` is accepted as part of a numeric literal.

```lisp
10      ; => 10.0
3.14    ; => 3.14
-7      ; => -7.0
+5      ; => 5.0
```

### 2.2 Strings

Strings are delimited by double quotes (`"`). They may contain spaces and span a single line. The surrounding quotes are not included in the stored value. The escape sequences `\n`, `\t`, `\r`, and `\\` are converted to their corresponding characters when printed.

```lisp
"hello world"
"line one\nline two"
```

### 2.3 Booleans

The keywords `true` and `false` evaluate to boolean values.

### 2.4 Lambda Values

A lambda value is a first-class function object that carries:

- its name (`lambda_func` for anonymous lambdas, the registered name for built-ins),
- its parameter list and arity,
- its body (a list of expressions),
- a closure (the environment where it was created).

Lambdas can be bound to names with `def`, called immediately, passed as arguments... no — arguments must be literal values, so lambdas are passed by name. They can also be **selected by conditionals and called directly** (see 6.5).

### 2.5 No Value

Some forms produce *no value* instead of a value: `def`, `print`, an `if` whose condition is falsy and has no alternative, an empty `begin`/`and`/`or`, and a lambda body with more than one form. The REPL prints nothing for these, and `and`/`or`/`if` treat "no value" as falsy.

## 3. Lexical Structure

### 3.1 Tokens

The scanner produces the following token kinds:

| Token         | Lexeme                                        |
| ------------- | --------------------------------------------- |
| `LEFT_PAREN`  | `(`                                           |
| `RIGHT_PAREN` | `)`                                           |
| `NUMBER`      | sequence of digits, optional `.` and fraction |
| `STRING`      | `"..."`                                       |
| `TRUE`        | `true`                                        |
| `FALSE`       | `false`                                       |
| `DEF`         | `def`, `define`                               |
| `PRINT`       | `print`, `display`                            |
| `LAMBDA`      | `lambda`                                      |
| `IF`          | `if`                                          |
| `BEGIN`       | `begin`                                       |
| `AND`         | `and`                                         |
| `OR`          | `or`                                          |
| `IDENTIFIER`  | identifier token                              |
| `EOF`         | end of input                                  |

The operator symbols `+`, `-`, `*`, `/`, `=`, `>`, `>=`, `<`, and `<=` are tokenized as `IDENTIFIER` tokens, not as separate operator token kinds. They resolve to built-in functions through the environment.

### 3.2 Identifiers

Identifiers are sequences of characters that are not control characters, whitespace, or delimiters. They may contain letters, digits, and many punctuation characters such as `?`, `_`, `-`, `!`, `*`, `=`, `/`, `+`, `.`, `<`, and `>`. The characters `(`, `)`, `"`, `;`, space, tab, carriage return, and newline are **not** allowed inside an identifier.

Valid identifiers: `x`, `foo`, `x1`, `foo-bar`, `_bar`, `even?`, `set!`, `*global*`, `beginner`, `android`, `orders`
Invalid identifiers: `(foo)`, `"bar"`, `foo;bar`

Keyword lookalikes with extra characters stay identifiers: `def1`, `iffy`, `begins`, `displays`, `defined`.

### 3.3 Keywords

The following names are reserved and cannot be used as variable names:

`def`, `define`, `print`, `display`, `lambda`, `true`, `false`, `if`, `begin`, `and`, `or`

### 3.4 Whitespace

Space (` `), tab (`\t`), and carriage return (`\r`) are treated as whitespace and skipped. Newlines (`\n`) increment the line counter for error reporting and also separate forms.

### 3.5 Comments

A semicolon (`;`) begins a comment that runs to the end of the current line.

```lisp
(def x 10) ; this is a comment
(+ x 5)    ; => 15.0
```

## 4. Program Structure

A program is a sequence of **expressions**, evaluated in order. A program made of a single expression yields that expression's value; in a multi-expression program the values of all but the last expression are discarded. To sequence expressions and keep a value, wrap them in `begin`:

```lisp
(begin (def x 10) (def y 20) (+ x y))   ; => 30.0
```

Programs run from a file (`lisp_odin file.scm` prints the final value) or interactively in the REPL (`lisp_odin` with no arguments; the REPL requires an interactive terminal).

## 5. Core Forms

### 5.1 `def` / `define` — Variable Definition

```lisp
(def name expr)
(define name expr)
```

Evaluates `expr` and binds the identifier `name` to the result in the current environment. Produces no value. `define` is an alias for `def`.

```lisp
(def x 10)
(def y (+ x 5))
(def f (lambda (a b) (+ a b)))
```

### 5.2 `print` / `display` — Output

```lisp
(print expr ...)
(display expr ...)
```

Evaluates each argument in order, concatenates their string representations, and prints the result to standard output. No extra spaces or newline are appended automatically; use the `newline` built-in to add line breaks. Produces no value. `display` is an alias for `print`.

```lisp
(print "sum is" (+ 1 2) (newline))   ; prints: sum is3.00000000
```

### 5.3 `lambda` — Function Values

```lisp
(lambda (param1 param2 ...) body ...)
```

Creates a first-class function value. Parameters are identifiers listed inside an inner parameter list; at most 100 parameters are allowed. When the lambda is called, a new environment is created with the closure as its parent, each parameter is bound to the corresponding argument, and the body is evaluated. Note: a **single-form body** returns its value; multi-form bodies currently yield no value (wrap the body in `begin` to return a value from a sequence).

```lisp
(lambda (x) (+ x 1))
(lambda (a b) (begin (print a) (+ a b)))
```

## 6. Control Flow

### 6.1 Truthiness

The language uses **C-style truthiness** (a deliberate deviation from Scheme, where only `#f` is falsy):

| Value                     | Truthy? |
| ------------------------- | ------- |
| `false`                   | no      |
| `0` / `0.0`               | no      |
| `""` (empty string)       | no      |
| no value (e.g. a `def`)   | no      |
| everything else           | yes     |

### 6.2 `if` — Conditional

```lisp
(if condition consequent alternative?)
```

Evaluates `condition`; if truthy, evaluates and returns `consequent`; otherwise evaluates and returns `alternative` (if present). **Only the taken branch is evaluated** — errors in the untaken branch never fire. Without an alternative and a falsy condition, `if` produces no value.

```lisp
(if (> 3 2) "yes" "no")        ; => "yes"
(if true 1 (/ 1 0))            ; => 1  (division never evaluated)
(if false 1)                   ; => no value
```

### 6.3 `begin` — Sequencing

```lisp
(begin expr ...)
```

Evaluates every expression from left to right and returns the value of the last one. An empty `begin` produces no value.

```lisp
(begin (def n -4) (if (< n 0) (- 0 n) n))   ; => 4
```

### 6.4 `and` / `or` — Short-Circuit Logic

```lisp
(and expr ...)
(or expr ...)
```

`and` evaluates left to right and stops at the first **falsy** value, returning it; if all values are truthy it returns the last one. `or` stops at the first **truthy** value, returning it; if all are falsy it returns the last one. Both return the **value** of the last expression evaluated — not a boolean — and skip everything after the stopping point. Empty `and`/`or` produce no value.

```lisp
(and (>= -4 -10) (<= -4 10) (* -4 -4))   ; => 16.0
(and (> -4 0) (sqrt -4))                 ; => false  (sqrt never called)
(or (< -4 0) (sqrt -4))                  ; => true   (sqrt never called)
```

### 6.5 Calls with Computed Operators

The operator position of a call is a full expression. Any expression evaluating to a lambda can be called directly:

```lisp
((lambda (a b) (+ a b)) 1 2)                        ; => 3.0
((if true (lambda (x) (* x 2)) (lambda (x) 0)) 21)  ; => 42.0
```

## 7. Built-in Functions

Built-ins live in the global environment. Variadic built-ins accept any number of arguments; `sqrt` is the first fixed-arity built-in (exactly 1).

### 7.1 Arithmetic

| Form         | Behavior                                               |
| ------------ | ------------------------------------------------------ |
| `(+ n ...)`  | sum; `(+)` => `0.0`                                    |
| `(- n ...)`  | left fold of subtraction; one arg => negation          |
| `(* n ...)`  | product; `(*)` => `1.0`                               |
| `(/ n ...)`  | left fold of division; one arg => reciprocal `1/x`     |

All arithmetic arguments must be numbers; anything else reports
`Argument 'x': Expected type NUMBER.` Division by zero reports a dedicated error.

```lisp
(+ 10 (* 2 3))   ; => 16.0
(/ 10 2)         ; => 5.0
(/ 2)            ; => 0.5
```

### 7.2 Comparisons — Monotonic Chains

The five comparison built-ins follow Scheme chain semantics: every argument is compared against the **next** one, and all pairs must hold.

| Form             | Chain                       | Mixed types |
| ---------------- | --------------------------- | ----------- |
| `(= a b ...)`    | all values equal            | numbers **or** strings **or** bools (first argument's type decides; a mismatch reports `Expected type STRING.` / `BOOLEAN.` / `NUMBER.`) |
| `(> a b ...)`    | strictly decreasing         | numbers only |
| `(>= a b ...)`   | non-increasing              | numbers only |
| `(< a b ...)`    | strictly increasing         | numbers only |
| `(<= a b ...)`   | non-decreasing              | numbers only |

Empty comparisons are true; a single argument is true (after its type is checked for the numeric operators).

```lisp
(= 1 1)          ; => true
(= "a" "a")      ; => true
(> 4 3 2 1)      ; => true  (strictly decreasing chain)
(> 1 0 0 4)      ; => false (0 > 0 fails)
(>= 3 1 1)       ; => true  (equal values allowed)
(< 1 2 2 3)      ; => false (strict)
(<= 1 2 2 3)     ; => true
```

IEEE notes: `-0.0` equals `0.0`; `inf` chains hold under `<=`/`>=` but break strict `<`/`>`; NaN fails every comparison, including `=`.

### 7.3 `sqrt` — Square Root

```lisp
(sqrt x)
```

Fixed arity 1, numbers only. Returns the square root of `x`. A negative argument reports a `.MathError`:

```lisp
(sqrt 9)     ; => 3.0
(sqrt 2)     ; => 1.4142135
(sqrt -1)    ; MathError: Can't calculate the square root of a negative number - -1
```

### 7.4 `newline` — Newline String

```lisp
(newline)
```

Returns the string `"\n"`; used with `print` for line breaks.

### 7.5 `pi` — Constant

The global environment binds `pi` to `3.1415927` (`f32(math.PI)`).

```lisp
(begin (def r 10) (* pi (* r r)))   ; => 314.15927
```

## 8. Evaluation Rules

1. Every form is an expression; forms are evaluated in order.
2. **`def`** evaluates the right-hand side, binds it, produces no value.
3. **`print`** evaluates each argument, prints, produces no value.
4. **`if`/`and`/`or`** evaluate lazily and return the last evaluated value (or no value).
5. **`begin`** evaluates everything, returns the last value.
6. **Calls** evaluate the operator expression first, then each argument left-to-right, then invoke the function.
7. **Lambdas** capture the current environment as their closure.
8. **Variable lookup** searches the current environment, then each enclosing environment in order.

## 9. Scoping

The language uses lexical scoping with closures.

- The global environment is created at startup via the shared registration proc and contains the arithmetic, comparison, `sqrt`, and `newline` built-ins, plus the `pi` constant.
- `def` binds names in the current environment.
- Lambda bodies run in a new environment whose parent is the lambda's closure.
- A lambda can access variables from its enclosing scopes through its closure.

> **Known bug — escaping closures:** a lambda *returned from* a call currently captures a destroyed stack environment, so the classic `(def make-adder (lambda (n) (lambda (x) (+ x n))))` pattern crashes when the returned function is invoked. See 14.

## 10. Error Handling

The interpreter uses a structured error type (`core.Error`) covering scanner, parser, and runtime errors. There is no exception-catching mechanism. Representative messages:

| Situation                              | Kind                          | Message example |
| -------------------------------------- | ----------------------------- | --------------- |
| Unbound name                           | `Variable_Not_Found`          | `Variable foo not found` |
| Non-number argument to a numeric fn   | `Expected_LiteralValue_Type`  | `Argument 'hello': Expected type NUMBER.` |
| Mixed-type comparison                  | `Expected_LiteralValue_Type`   | `Argument '1': Expected type STRING.` |
| Division by zero                       | `Division_By_Zero`             | `Division by Zero Error` |
| Wrong argument count                   | `Lambda_Arity_Mismatch`        | `Expected 1 argument(s) but got 2.` (token carries the function's name) |
| Negative `sqrt`                        | `MathError`                   | `Can't calculate the square root of a negative number - -1` |
| Calling a non-lambda value             | `Runtime_Or_Lambda_Expected`   | `Unknown Lambda declaration` |
| No-value call operator                 | `Runtime_Or_Lambda_Expected`   | `Expected a variable or lambda definition as the call operator` |
| Parse failures                         | (parser kinds)                 | `Unexpected Expression`, `Expected ')' ...`, `Lambda body expected.` |

Some internal invariants are still enforced with assertions, which panic if violated (see 14).

## 11. EBNF Grammar

```ebnf
program        ::= expression* EOF

comment        ::= ";" ANY* (NEWLINE | EOF)

expression     ::= literal
                |  IDENTIFIER
                |  def-expression
                |  print-expression
                |  lambda-expression
                |  if-expression
                |  begin-expression
                |  and-expression
                |  or-expression
                |  call-expression

literal        ::= NUMBER | STRING | "true" | "false"

def-expression  ::= "(" ("def" | "define") IDENTIFIER expression ")"

print-expression ::= "(" ("print" | "display") expression* ")"

lambda-expression ::= "(" "lambda" "(" IDENTIFIER* ")" expression* ")"

if-expression  ::= "(" "if" expression expression expression? ")"

begin-expression ::= "(" "begin" expression* ")"

and-expression ::= "(" "and" expression* ")"

or-expression  ::= "(" "or" expression* ")"

call-expression ::= "(" expression expression* ")"

IDENTIFIER     ::= (ALPHA | SYMBOL) (ALPHA | DIGIT | SYMBOL)*
NUMBER         ::= ("+" | "-")? DIGIT+ ("." DIGIT+)?
STRING         ::= "\"" ANY* "\""
ALPHA          ::= "a".."z" | "A".."Z"
DIGIT          ::= "0".."9"
NEWLINE        ::= "\n"
SYMBOL         ::= "?" | "_" | "-" | "!" | "*" | "=" | "/" | "+" | "." | "<" | ">" | graphic-character
```

## 12. Examples

### Arithmetic and variables

```lisp
(+ 10 (* 2 3))                      ; => 16.0
(begin (def x 10) (def y 20) (+ x y))   ; => 30.0
```

### Conditionals

```lisp
(if (> 5 3) "big" "small")          ; => "big"
(if (and (> 1 0) (< 1 5)) "in" "out")   ; => "in"
```

### The sign-of pattern

```lisp
(begin (def n -4)
  (if (< n 0) (- 0 n) n))            ; => 4
```

### Functions

```lisp
(begin (def add (lambda (a b) (+ a b)))
  (add 1 2))                          ; => 3.0
((lambda (a b) (+ a b)) 1 2)          ; => 3.0
```

### Geometry with the `pi` constant

```lisp
(begin (def r 10) (* pi (* r r)))    ; => 314.15927
```

## 13. REPL and File Mode

- `lisp_odin` with no arguments starts an interactive REPL (requires an interactive terminal).
- `lisp_odin file.scm` evaluates the file and prints the final value; forms producing no value print nothing.

## 14. Known Limitations and Bugs

1. **Escaping closures crash (bug):** a lambda returned from a call captures a destroyed stack environment. Reproduction:
   ```lisp
   (begin (def make-adder (lambda (n) (lambda (x) (+ x n))))
     (def add5 (make-adder 5))
     (add5 10))   ;; runtime assertion: e.variables != nil
   ```
   Fixing this requires heap-allocated (or otherwise escaping) call environments.
2. **No lists or pairs:** there are no cons cells, lists, or sequence data structures beyond function argument lists. Known limitation; out of scope for now.
3. **No I/O beyond `print` and the REPL:** no file, network, or input operations. Known limitation; out of scope for now.
4. **No `not` / `cond`:** `if`, `and`, and `or` cover the current needs; `not` can be expressed as `(if x false true)`.
5. **Multi-form lambda bodies yield no value:** wrap the body in `begin` to return a value from a sequence (see 5.3).
6. **NaN/Infinity are not literals:** `nan`/`inf` are unbound identifiers; the IEEE edge cases only matter for values produced by future arithmetic.
7. Some internal invariants use assertions that abort the process instead of reporting errors (e.g. an internal call of a built-in handler with a wrong argument count).
