package environment

Environment :: struct($T: typeid) {
	variables: map[string]T,
	enclosing: ^Environment(T),
}

init :: proc(e: ^$E/Environment($T), enclosing: ^E = nil) {
	e.variables = make(map[string]T)
	e.enclosing = enclosing
}

destroy :: proc(e: ^$E/Environment($T), recurring := false) {
	if e.variables != nil {
		delete(e.variables)
	}

	if e.enclosing != nil && recurring {
		destroy(e.enclosing)
	}
}

get :: proc(e: ^$E/Environment($T), name: string) -> (T, bool) {
	assert(e != nil)
	assert(e.variables != nil)

	if value, ok := e.variables[name]; ok do return value, true
	if e.enclosing != nil do return get(e.enclosing, name)

	return nil, false
}

contains_key :: proc(e: ^$E/Environment($T), key: string) -> bool {

	if key in e.variables do return true
	if e.enclosing != nil do return contains_key(e.enclosing, key)

	return false
}

define :: proc(e: ^$E/Environment($T), key: string, value: T) {
	e.variables[key] = value
}
