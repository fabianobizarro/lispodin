#+feature dynamic-literals
package core

Keywords := map[string]TokenType {
	"print"  = .PRINT,
	"def"    = .DEF,
	"define" = .DEF,
	"lambda" = .LAMBDA,
	"true"   = .TRUE,
	"false"  = .FALSE,
	"if"     = .IF,
}
