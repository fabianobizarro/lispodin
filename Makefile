ODIN := odin
SRC := src
OUT := build/lisp_odin

.PHONY: all build debug run test clean check lint

all: build

build:
	@mkdir -p build
	$(ODIN) build $(SRC) -out:$(OUT) -debug

debug:
	@mkdir -p build
	$(ODIN) build $(SRC) -out:$(OUT) -debug

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
