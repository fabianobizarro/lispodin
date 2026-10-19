package statements


Statement :: union {
	List,
	Def,
}

List :: struct {
	statements: []Statement,
}

Def :: struct {}

Print :: struct {}
