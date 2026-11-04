ODIN := odin
SRC := src
OUT := build/lisp_odin

.PHONY: all build debug release run test clean check lint

all: build

# Debug build (used in CI for fast feedback and local development).
build:
	@mkdir -p build
	$(ODIN) build $(SRC) -out:$(OUT) -debug

# Alias for the debug build.
debug: build

# Optimized release build (used when producing release binaries).
release:
	@mkdir -p build
	$(ODIN) build $(SRC) -out:$(OUT) -o:speed

run:
	$(ODIN) run $(SRC)

# Tests live in tests/ and are pulled in through @(require) imports.
# -all-packages is required so @(test) procedures in subpackages run.
test:
	$(ODIN) test tests -all-packages

clean:
	rm -rf build/

check:
	$(ODIN) check $(SRC)

# Format check does not rewrite sources. odinfmt has no -check flag.
lint:
	@fail=0; \
	for f in $$(find $(SRC) tests -name '*.odin'); do \
		odinfmt "$$f" > "$$f.fmt"; \
		if ! diff -q "$$f" "$$f.fmt" >/dev/null; then \
			echo "not formatted: $$f"; \
			diff -u "$$f" "$$f.fmt" || true; \
			fail=1; \
		fi; \
		rm -f "$$f.fmt"; \
	done; \
	test $$fail -eq 0
	$(ODIN) check $(SRC) -vet -strict-style -warnings-as-errors -error-pos-style:unix
