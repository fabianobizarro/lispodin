package repl

import "core:fmt"
import "core:io"
import "core:os"
import "core:text/match"
import "core:unicode/utf8"

CURSOR_PREFIX :: ">>>"
CURSOR_PREFIX_OFFSET :: 4 // >>> + space

Line :: [dynamic]byte

BufferHistory :: struct {
	buffer_history: [dynamic]Line,
	current:        int,
}


print_buffer :: proc(b: ^[dynamic]byte, curr: int) {
	fmt.print("buff: ", b, " currpos: ", curr)
}

read_console :: proc(history: ^BufferHistory) -> (string, bool) {

	set_utf8_terminal()
	enable_raw_mode()
	defer disable_raw_mode()

	print_cursor()

	buffer := make(Line)
	current_pos := 0

	in_stream := os.to_stream(os.stdin)

	for {
		ch, size, err := io.read_rune(in_stream)

		switch {
		case err != nil:
			fmt.eprintfln("\nError: %v", err)
			os.exit(1)

		// new line / Enter
		case ch == '\n':
			fallthrough
		case ch == '\r':
			fmt.println()

			if len(buffer) > 0 do append(&history.buffer_history, buffer)

			history.current = 0

			debug_history(history)
			return string(buffer[:]), true

		// clear screen
		case ch == '\f':
			clear(&buffer)
			current_pos = 0
			fmt.print("\x1b[2J\x1b[H")
			print_cursor()
			debug_file(&buffer, current_pos)


		// backspace
		case ch == '\u007f':
			fallthrough
		case ch == '\b':
			_, bs_sz := utf8.decode_last_rune(buffer[:])
			if bs_sz > 0 && current_pos > 0 {

				new := make([dynamic]byte)
				defer delete(new)

				append(&new, ..buffer[:current_pos - 1])
				append(&new, ..buffer[current_pos:])

				resize(&buffer, len(buffer) - bs_sz)
				copy(buffer[:], new[:])

				current_pos -= 1
				debug_file(&buffer, current_pos)
				print_line(&buffer, current_pos)
			}

		// escape codes
		case match.is_cntrl(ch):
			seq := read_escape_sequence(in_stream)
			defer delete(seq)

			switch seq {
			case "\x1b[D":
				if current_pos == 0 do break

				fmt.print("\x1b[D") // move cursor left
				current_pos -= 1
				debug_file(&buffer, current_pos)

			case "\x1b[C":
				if current_pos >= len(buffer) do break

				fmt.print("\x1b[C") // move cursor right
				current_pos += 1
				debug_file(&buffer, current_pos)

			// up
			case "\x1b[A":
				if history.current + 1 > len(history.buffer_history) do break

				history.current += 1

				target := history.buffer_history[len(history.buffer_history) - history.current]

				clear(&buffer)
				append(&buffer, ..target[:])

				current_pos = len(buffer)

				debug_history(history)
				print_line(&buffer, current_pos)

			// down
			case "\x1b[B":
				if history.current <= 0 do break

				history.current -= 1

				if history.current == 0 {
					clear(&buffer)
				} else {
					target := history.buffer_history[len(history.buffer_history) - history.current]
					clear(&buffer)
					append(&buffer, ..target[:])
				}
				current_pos = len(buffer)

				debug_history(history)
				print_line(&buffer, current_pos)
			}


		case:
			bytes, _ := utf8.encode_rune(ch)
			inject_at_elems(&buffer, current_pos, ..bytes[:size])
			current_pos += 1

			print_line(&buffer, current_pos)
			debug_file(&buffer, current_pos)
		}
	}
}

read_escape_sequence :: proc(in_stream: io.Reader) -> string {
	seq := make([dynamic]byte)

	append(&seq, '\x1b')

	ch, _, _ := io.read_rune(in_stream)
	append(&seq, byte(ch))

	if ch == '[' {
		// Read final command letter
		cmd, _, _ := io.read_rune(in_stream)
		append(&seq, byte(cmd))
	}

	return string(seq[:])
}

enable_raw_mode :: proc() {
	_enable_raw_mode()
}

disable_raw_mode :: proc "c" () {
	_disable_raw_mode()
}

set_utf8_terminal :: proc() {
	_set_utf8_terminal()
}
