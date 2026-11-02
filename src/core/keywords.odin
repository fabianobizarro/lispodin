#+feature dynamic-literals
package core

Keywords := map[string]TokenType {
	"print"  = .PRINT,
	"def"    = .DEF,
	"lambda" = .LAMBDA,
	"true"   = .TRUE,
	"false"  = .FALSE,
}
