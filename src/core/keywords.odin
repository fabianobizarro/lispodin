#+feature dynamic-literals
package core

import t "token"

Keywords := map[string]t.TokenType {
	"print"  = .PRINT,
	"def"    = .DEF,
	"lambda" = .LAMBDA,
	"true"   = .TRUE,
	"false"  = .FALSE,
}
