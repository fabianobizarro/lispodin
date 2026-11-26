#+private
package interpreter

import "../core"

Atom :: core.Atom

Token :: core.Token
TokenType :: core.TokenType
LiteralValue :: core.LiteralValue

Expression :: core.Expression
LiteralExpression :: core.LiteralExpression
VariableExpression :: core.VariableExpression
LambdaCallExpression :: core.LambdaCallExpression
LambdaExpression :: core.LambdaExpression
IfExpression :: core.IfExpression

LambdaFunction :: core.LambdaFunction


truthy :: proc(val: Result) -> bool {

	if _, ok := val.?; !ok do return false

	switch lit in val.? {
	case core.LiteralValue:
		switch t in lit {
		case f32:
			return t != 0
		case string:
			return len(t) > 0
		case bool:
			return t
		}
	case core.LambdaFunction:
		return true
	}

	return false
}
