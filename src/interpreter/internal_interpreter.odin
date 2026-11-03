#+private
package interpreter

import "../core"
import env "../environment"

Atom :: core.Atom

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
