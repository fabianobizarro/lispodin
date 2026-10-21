#+feature dynamic-literals
package token

Keywords := map[string]TokenType {
	"print"  = .PRINT,
	"def"    = .DEF,
	"lambda" = .LAMBDA,
	"true"   = .TRUE,
	"false"  = .FALSE,
}
