package repl

import "core:fmt"
import "core:io"
import "core:os"
import "core:text/match"
import "core:unicode/utf8"

print_cursor :: proc() {
	fmt.print("\x1b[32m>>>\x1b[39m ")
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

read_console :: proc() -> (string, bool) {
	set_utf8_terminal()

	enable_raw_mode()
	defer disable_raw_mode()

	print_cursor()

	buffer := make([dynamic]byte)
	in_stream := os.to_stream(os.stdin)

	for {
		// fmt.println(len(buffer))
		ch, size, err := io.read_rune(in_stream)

		// fmt.println("==>", ch, match.is_alnum(ch), match.is_cntrl(ch), match.is_xdigit(ch))

		// fmt.printf(
		// 	"Char: %q is alpha? %t is_control?: %t\n",
		// 	ch,
		// 	match.is_alpha(ch),
		// 	match.is_cntrl(ch),
		// 	match.is_alnum(),
		// )

		switch {
		case err != nil:
			fmt.eprintfln("\nError: %v", err)
			os.exit(1)

		// new line / Enter
		case ch == '\n':
			fallthrough
		case ch == '\r':
			fmt.println()
			return string(buffer[:]), true

		// clear screen
		case ch == '\f':
			fmt.print("\x1b[2J\x1b[H")
			clear(&buffer)
			print_cursor()

		// backspace
		case ch == '\u007f':
			fallthrough
		case ch == '\b':
			_, bs_sz := utf8.decode_last_rune(buffer[:])
			if bs_sz > 0 {
				resize(&buffer, len(buffer) - bs_sz)
				// Replace last star with a space.
				fmt.print("\b \b")
			}

		// escape codes
		case match.is_cntrl(ch):
			seq := read_escape_sequence(in_stream)
			defer delete(seq)

			// fmt.println("escape ctrl ", seq)
			switch seq {
			case "\x1b[D":
				fmt.print("\x1b[D") // move cursor left
			case "\x1b[C":
				fmt.print("\x1b[C") // move cursor right
			case "\x1b[A":
			// reserved for prompt history
			// fmt.print("up") // up arrow
			case "\x1b[B":
			// reserved for prompt history
			// fmt.print("down") // down arrow
			}


		case:
			// case match.is_alnum(ch):
			bytes, s := utf8.encode_rune(ch)
			append(&buffer, ..bytes[:size])
			fmt.print(string(bytes[:]))
		}

	}

	// n, err := os.read(os.stdin, buffer[:])
	// if err != nil {
	// 	fmt.eprintln("Error when reading from stdin: ", err)
	// 	return "", false
	// }

	return "", false
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
