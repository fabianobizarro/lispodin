# Language Specification

This document describes the Lisp-like language implemented by the interpreter in this repository.

## 1. Overview

The language is a minimal, parenthesized, prefix-notation language inspired by Scheme and Lisp. Programs are made of **forms** (parenthesized lists) and **atoms** (literals and identifiers). The interpreter reads source text, tokenizes it, parses it into an AST, and evaluates the result.

Key characteristics:

- **Prefix notation:** `(operator arg1 arg2 ...)`
- **Dynamic typing:** values are one of `f32`, `string`, `bool`, or `lambda`.
- **Lexical scoping:** lambdas capture the environment where they are defined.
- **Expression-oriented:** the last expression in a sequence determines the returned value.

## 2. Data Types

| Type     | Description                   | Literal Example        |
| -------- | ----------------------------- | ---------------------- |
| `number` | 32-bit floating point (`f32`) | `42`, `3.14`, `-7`     |
| `string` | Double-quoted text            | `"hello"`              |
| `bool`   | Boolean value                 | `true`, `false`        |
| `lambda` | Anonymous function value      | `(lambda (x) (+ x 1))` |

### 2.1 Numbers

Numbers are parsed as `f32`. Integer-looking literals are still stored as floating-point values. An explicit leading `+` or `-` is also accepted as part of a numeric literal.

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

```lisp
true
false
```

### 2.4 Lambda Values

A lambda value is a first-class function object that carries:

- its parameter list,
- its body (a list of statements),
- its arity,
- a closure (the environment where it was created).

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
| `IDENTIFIER`  | identifier token                              |
| `DEF`         | `def`                                         |
| `PRINT`       | `print`                                       |
| `LAMBDA`      | `lambda`                                      |
| `EOF`         | end of input                                  |

The operator symbols `+`, `-`, `*`, and `/` are tokenized as `IDENTIFIER` tokens, not as separate operator token kinds.

### 3.2 Identifiers

Identifiers are sequences of characters that are not control characters, whitespace, or delimiters. They may contain letters, digits, and many punctuation characters such as `?`, `_`, `-`, `!`, `*`, `=`, `/`, `+`, and `.`. The characters `(`, `)`, `"`, `;`, space, tab, carriage return, and newline are **not** allowed inside an identifier.

Valid identifiers: `x`, `foo`, `x1`, `foo-bar`, `_bar`, `even?`, `set!`, `*global*`
Invalid identifiers: `(foo)`, `"bar"`, `foo;bar`

### 3.3 Keywords

The following names are reserved and cannot be used as variable names:

- `def`
- `print`
- `lambda`
- `true`
- `false`

### 3.4 Whitespace

Space (` `), tab (`\t`), and carriage return (`\r`) are treated as whitespace and skipped. Newlines (`\n`) increment the line counter for error reporting and also separate tokens.

### 3.5 Comments

A semicolon (`;`) begins a comment that runs to the end of the current line. Comments are skipped by the scanner.

```lisp
(def x 10) ; this is a comment
(+ x 5)    ; => 15.0
```

## 4. Program Structure

A program is a sequence of **statements**. Statements are evaluated in order. If a program contains more than one statement, the values of all but the last statement are discarded, and the value of the last statement is returned as the program's result.

```lisp
(def x 10)
(def y 20)
(+ x y)     ; => 30.0
```

## 5. Statements

### 5.1 Expression Statement

Any expression standing alone is an expression statement.

```lisp
(+ 1 2)
"hello"
```

### 5.2 `def` — Variable Definition

```lisp
(def name expr)
```

Binds the identifier `name` to the value of `expr` in the current environment. The right-hand side is evaluated before binding.

```lisp
(def x 10)
(def y (+ x 5))
```

### 5.3 `print` — Output

```lisp
(print expr ...)
```

Evaluates each argument in order, concatenates their string representations, and prints the result to standard output. No extra spaces or newline are appended automatically; use string literals or the `newline` built-in to add line breaks.

```lisp
(print "hello")
(print "sum is" (+ 1 2) (newline))
```

## 6. Expressions

### 6.1 Literals

A literal expression evaluates to its literal value.

```lisp
42
"hello"
true
```

### 6.2 Variables

An identifier evaluates to the value bound to that name in the current or enclosing environment. If the name is not bound, evaluation returns a runtime error.

```lisp
x
my-function
```

### 6.3 Function Calls

```lisp
(function arg1 arg2 ...)
```

The first element after the opening parenthesis is an identifier that must resolve to a `lambda` value. The remaining elements are evaluated as arguments and passed to the function.

Arguments are evaluated left-to-right in the current environment before the function body runs.

```lisp
(+ 1 2 3)
(my-func a b)
```

### 6.4 Anonymous Function Calls

A lambda expression can be called immediately by placing it in function position:

```lisp
((lambda (a b) (+ a b)) 1 2)   ; => 3.0
```

## 7. Special Forms

### 7.1 `lambda` — Anonymous Functions

```lisp
(lambda (param1 param2 ...) body ...)
```

Creates a first-class function value. Parameters are identifiers listed inside an inner parameter list. The body is a sequence of statements.

When the lambda is called, a new environment is created with the closure as its parent, each parameter is bound to the corresponding argument, and the body statements are evaluated. The value of the last body statement is returned.

```lisp
(lambda (x) (+ x 1))
(lambda (a b) (print a) (+ a b))
```

Parameter list size is limited to 100 parameters.

## 8. Built-in Functions

Built-in functions are variadic (`arity = -1`) and are stored in the global environment under their operator symbols or names.

### 8.1 `+` — Addition

```lisp
(+ number ...)
```

Returns the sum of all arguments. With zero arguments, returns `0.0`. All arguments must be numbers.

```lisp
(+)             ; => 0.0
(+ 1 2)         ; => 3.0
(+ 1 2 3 4)     ; => 10.0
```

### 8.2 `-` — Subtraction

```lisp
(- number ...)
```

Subtracts the remaining arguments from the first. With one argument, returns its negation. All arguments must be numbers.

### 8.3 `*` — Multiplication

```lisp
(* number ...)
```

Returns the product of all arguments. With zero arguments, returns `1.0`. All arguments must be numbers.

```lisp
(*)             ; => 1.0
(* 2 3)         ; => 6.0
(* 2 3 4)       ; => 24.0
```

### 8.4 `/` — Division

```lisp
(/ number ...)
```

Divides the first argument by the remaining arguments in order. With one argument, returns its reciprocal (`1 / x`). All arguments must be numbers. Division by zero produces a runtime error.

```lisp
(/ 10 2)        ; => 5.0
(/ 1 4)         ; => 0.25
(/ 2)           ; => 0.5
```

### 8.5 `newline` — Newline String

```lisp
(newline)
```

Returns the string `"\n"`. It is typically used with `print` to produce line breaks.

```lisp
(print "hello" (newline))
```

## 9. Evaluation Rules

1. **Statements** are evaluated in order.
2. **Expression statements** evaluate the expression and return its value.
3. **`def`** evaluates the right-hand side, then binds it in the current environment.
4. **`print`** evaluates each argument and prints the result.
5. **Function calls** evaluate the function expression, evaluate each argument, then invoke the function with the arguments.
6. **Lambdas** capture the current environment as their closure.
7. **Variable lookup** searches the current environment, then each enclosing environment in order.

## 10. Scoping

The language uses lexical scoping with closures.

- The global environment is created at startup and contains the built-in math functions and `newline`.
- `def` binds names in the current environment.
- Lambda bodies run in a new environment whose parent is the lambda's closure.
- A lambda can access variables from its enclosing scopes through its closure.

```lisp
(def make-adder
  (lambda (n)
    (lambda (x) (+ x n))))

(def add5 (make-adder 5))
(add5 10)   ; => 15.0
```

## 11. Error Handling

The interpreter uses a structured error type (`core.Error`) for scanner, parser, and runtime errors. These errors are returned through the evaluation pipeline and reported to the user. There is no exception-catching mechanism.

Errors reported through this mechanism include:

- Unterminated string literals
- Failed number literal parsing
- Unexpected tokens during parsing
- Use of an unbound variable
- Calling a non-function value
- Wrong number of arguments for a lambda
- Passing a non-number argument to a math function
- Division by zero
- Type mismatches during evaluation

Some internal invariants are still enforced with assertions, which panic if violated.

## 12. EBNF Grammar

```ebnf
program        ::= (statement | comment)* EOF

comment        ::= ";" ANY* (NEWLINE | EOF)

statement      ::= def-statement
                |  print-statement
                |  expression-statement

def-statement  ::= "(" "def" IDENTIFIER expression ")"

print-statement::= "(" "print" expression* ")"

expression-statement ::= expression

expression     ::= literal
                |  IDENTIFIER
                |  lambda-expression
                |  function-call

literal        ::= NUMBER | STRING | "true" | "false"

lambda-expression ::= "(" "lambda" "(" IDENTIFIER* ")" statement* ")"

function-call  ::= "(" IDENTIFIER expression* ")"
                |  "(" lambda-expression expression* ")"

IDENTIFIER     ::= (ALPHA | SYMBOL) (ALPHA | DIGIT | SYMBOL)*
NUMBER         ::= ("+" | "-")? DIGIT+ ("." DIGIT+)?
STRING         ::= "\"" ANY* "\""
ALPHA          ::= "a".."z" | "A".."Z"
DIGIT          ::= "0".."9"
NEWLINE        ::= "\n"
SYMBOL         ::= "?" | "_" | "-" | "!" | "*" | "=" | "/" | "+" | "." | graphic-character
```

## 13. Examples

### Arithmetic

```lisp
(+ 10 10)                 ; => 20.0
(+ 10 (* 2 3))            ; => 16.0
```

### Variables

```lisp
(def r 10)
(def pi 3.14)
(print (* pi (* r r)) (newline))    ; prints area
```

### Lambdas

```lisp
(def add
  (lambda (a b) (+ a b)))

(print (add 1 2))         ; => 3.0
```

### Anonymous lambda call

```lisp
((lambda (a b) (+ a b)) 1 2)   ; => 3.0
```

## 14. Known Limitations and Bugs

1. **No comparison operators:** `==`, `<`, `>`, `<=`, `>=` are not implemented.
   - [ ] **TASK:** Add comparison operators to the scanner, parser, global environment, and built-in functions.
2. **No conditionals:** `if`, `cond`, and logical operators are not implemented.
   - [ ] **TASK:** Add `if`/`cond` special forms and logical operators (`and`, `or`, `not`).
3. **No lists or pairs:** There are no cons cells, lists, or sequence data structures beyond function argument lists.
   - Known limitation. We won't touch lists for now.
4. **No I/O beyond `print` and the REPL:** There are no file, network, or input operations.
   - Known limitation. We won't touch I/O for now.
