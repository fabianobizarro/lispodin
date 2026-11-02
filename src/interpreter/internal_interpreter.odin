#+private
package interpreter

import "../core"

Atom :: core.Atom

Environment :: core.Environment

Token :: core.Token
TokenType :: core.TokenType
LiteralValue :: core.LiteralValue
Statement :: core.Statement
DefineStatement :: core.DefineStatement
PrintStatement :: core.PrintStatement
ExpressionStatement :: core.ExpressionStatement

Expression :: core.Expression
LiteralExpression :: core.LiteralExpression
VariableExpression :: core.VariableExpression
LambdaCallExpression :: core.LambdaCallExpression
LambdaExpression :: core.LambdaExpression

LambdaFunction :: core.LambdaFunction

_env: Environment
