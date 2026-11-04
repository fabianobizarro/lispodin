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

| Type | Description | Literal Example |
|------|-------------|-----------------|
| `number` | 32-bit floating point (`f32`) | `42`, `3.14`, `-7` |
| `string` | Double-quoted text | `"hello"` |
| `bool` | Boolean value | `true`, `false` |
| `lambda` | Anonymous function value | `(lambda (x) (+ x 1))` |

### 2.1 Numbers

Numbers are parsed as `f32`. Integer-looking literals are still stored as floating-point values.

```lisp
10      ; => 10.0
3.14    ; => 3.14
```

### 2.2 Strings

Strings are delimited by double quotes (`"`). They may contain spaces and span a single line.

```lisp
"hello world"
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

| Token | Lexeme |
|-------|--------|
| `LEFT_PAREN` | `(` |
| `RIGHT_PAREN` | `)` |
| `PLUS` | `+` |
| `MINUS` | `-` |
| `STAR` | `*` |
| `SLASH` | `/` |
| `NUMBER` | sequence of digits, optional `.` and fraction |
| `STRING` | `"..."` |
| `TRUE` | `true` |
| `FALSE` | `false` |
| `IDENTIFIER` | alphabetic identifier |
| `DEF` | `def` |
| `PRINT` | `print` |
| `LAMBDA` | `lambda` |
| `EOF` | end of input |

### 3.2 Identifiers

Identifiers consist of alphabetic characters only. Digits, underscores, hyphens, and other characters are **not** allowed in identifiers.

Valid identifiers: `x`, `foo`, `bar`
Invalid identifiers: `x1`, `foo-bar`, `_bar`

### 3.3 Keywords

The following names are reserved and cannot be used as variable names:

- `def`
- `print`
- `lambda`
- `true`
- `false`

### 3.4 Whitespace

Whitespace characters (` `, `\t`, `\r`) and newlines (`\n`) separate tokens. Newlines are counted for line tracking but have no syntactic meaning.

### 3.5 Comments

There is no comment syntax in this language.

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

Evaluates each argument in order and prints each result to standard output, followed by a newline.

```lisp
(print "hello")
(print "sum is" (+ 1 2))
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

An identifier evaluates to the value bound to that name in the current or enclosing environment. If the name is not bound, the interpreter panics.

```lisp
x
my-function
```

### 6.3 Function Calls

```lisp
(function arg1 arg2 ...)
```

The first element after the opening parenthesis is evaluated as a function position. It must resolve to a `lambda` value. The remaining elements are evaluated as arguments and passed to the function.

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

Built-in functions are variadic (`arity = -1`) and are stored in the global environment under their operator symbols.

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

**Current implementation bug:** The built-in subtraction function is registered but its `call` handler points to the addition implementation, so `(- a b ...)` currently behaves like `(+ a b ...)`.

### 8.3 `*` — Multiplication

```lisp
(* number ...)
```

**Current implementation bug:** The built-in multiplication function is registered but its `call` handler points to the addition implementation, so `(* a b ...)` currently behaves like `(+ a b ...)`.

### 8.4 `/` — Division

```lisp
(/ number ...)
```

**Current implementation bug:** The built-in division function is registered but its `call` handler points to the addition implementation, so `(/ a b ...)` currently behaves like `(+ a b ...)`.

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

- The global environment is created at startup and contains the built-in math functions.
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

The interpreter uses panics for error conditions. There is no exception-catching mechanism.

Errors that cause panics include:

- Unknown characters during tokenization
- Unterminated string literals
- Unexpected tokens during parsing
- Use of an unbound variable
- Calling a non-function value
- Wrong number of arguments for a lambda
- Passing a non-number argument to a math function
- Division by zero (in the intended division implementation)
- Type mismatches during evaluation

## 12. EBNF Grammar

```ebnf
program        ::= statement* EOF

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

IDENTIFIER     ::= ALPHA+
NUMBER         ::= DIGIT+ ("." DIGIT+)?
STRING         ::= "\"" ANY* "\""
ALPHA          ::= "a".."z" | "A".."Z"
DIGIT          ::= "0".."9"
```

## 13. Examples

### Arithmetic

```lisp
(+ 10 10)                 ; => 20.0
(+ 10 (* 2 3))            ; => 16.0 (intended; current * bug affects result)
```

### Variables

```lisp
(def r 10)
(def pi 3.14)
(print (* pi (* r r)))    ; prints intended area (current * bug affects result)
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

1. **Broken built-in operators:** `-`, `*`, and `/` are registered but their call handlers incorrectly point to the addition implementation.
   - [ ] **TASK:** Fix `create_subtraction`, `create_multiplication`, and `create_division` in `src/functions/math/math.odin` to use their own `call` handlers.
2. **No comparison operators:** `==`, `<`, `>`, `<=`, `>=` are not implemented.
   - [ ] **TASK:** Add comparison operators to the scanner, parser, global environment, and built-in functions.
3. **No conditionals:** `if`, `cond`, and logical operators are not implemented.
   - [ ] **TASK:** Add `if`/`cond` special forms and logical operators (`and`, `or`, `not`).
4. **No lists or pairs:** There are no cons cells, lists, or sequence data structures beyond function argument lists.
   - Known limitation. We won't touch lists for now.
5. **No comments:** The language has no comment syntax.
   - [ ] **TASK:** Add comment syntax (e.g., `;` to end of line) to the scanner.
6. **Limited identifiers:** Identifiers may contain only alphabetic characters.
   - [ ] **TASK:** Expand identifier scanning to support digits, hyphens, underscores, and other common identifier characters, and add tests.
7. **No REPL:** The REPL is not implemented.
   - [ ] **TASK:** Implement the REPL in `src/repl/repl.odin` and wire it into `src/main.odin`.
8. **String literal bug:** String literals include the surrounding quote characters in the stored value.
   - [ ] **TASK:** Fix `read_string` in `src/scanner/internal_scanner.odin` to strip surrounding quotes.
9. **No error recovery:** Most errors panic and terminate the interpreter.
   - [ ] **TASK:** Introduce a structured error-handling mechanism so the interpreter can report errors without panicking.
10. **Negative numbers not supported:** A leading `-` is always treated as the subtraction operator, so literals like `-5` cannot be parsed.
    - [ ] **TASK:** Add support for negative numeric literals in the scanner and parser.
11. **No I/O beyond `print`:** There are no file, network, or input operations.
    - Known limitation. We won't touch I/O for now.
