package repl

import "core:fmt"
import "core:os"
import "core:strings"

HISTORY_LOGS_PATH :: "logs/history.log"
DEBUG_LOGS_PATH :: "logs/debug.log"

print_cursor :: proc() {
	fmt.printf("\x1b[32m%s\x1b[39m ", CURSOR_PREFIX)
}

print_welcome :: proc() {
	fmt.println(
		" ██╗     ██╗███████╗██████╗  ██████╗ ██████╗ ██╗███╗   ██╗",
	)
	fmt.println(
		" ██║     ██║██╔════╝██╔══██╗██╔═══██╗██╔══██╗██║████╗  ██║",
	)
	fmt.println(
		" ██║     ██║███████╗██████╔╝██║   ██║██║  ██║██║██╔██╗ ██║",
	)
	fmt.println(
		" ██║     ██║╚════██║██╔═══╝ ██║   ██║██║  ██║██║██║╚██╗██║",
	)
	fmt.println(
		" ███████╗██║███████║██║     ╚██████╔╝██████╔╝██║██║ ╚████║",
	)
	fmt.println(
		" ╚══════╝╚═╝╚══════╝╚═╝      ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═══╝",
	)
}


debug_history :: proc(h: ^BufferHistory) {
	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	file, err := os.open(HISTORY_LOGS_PATH, {.Write, .Append, .Create})
	defer os.close(file)
	if err != nil {
		fmt.eprint("Error when creating the debug file\n")
		fmt.eprintln(err)
		os.exit(1)
	}

	fmt.sbprintln(&builder, "current_pos: ", h.current)
	for record, i in h.buffer_history {
		fmt.sbprintln(&builder, i, " > ", string(record[:]))
	}
	fmt.sbprintln(&builder)
	fmt.sbprintln(&builder)

	os.write_string(file, strings.to_string(builder))
}

debug_file :: proc(buff: ^[dynamic]byte, current_pos: int) {
	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)

	file, err := os.open(DEBUG_LOGS_PATH, {.Write, .Append, .Create})
	defer os.close(file)
	if err != nil {
		fmt.eprint("Error when creating the debug file\n")
		fmt.eprintln(err)
		os.exit(1)
	}

	fmt.sbprintln(&builder, "buffer: ", string(buff[:]))
	fmt.sbprintln(&builder, "current_pos: ", current_pos)
	fmt.sbprintln(&builder)

	_, _ = os.write_string(file, strings.to_string(builder))
}

print_line :: proc(buff: ^[dynamic]byte, current_pos: int) {
	fmt.print("\r\x1b[K")
	print_cursor()
	fmt.print(string(buff[:]))

	col := CURSOR_PREFIX_OFFSET + current_pos
	fmt.printf("\x1b[%dG", col + 1)
}
