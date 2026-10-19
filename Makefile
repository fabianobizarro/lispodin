ODIN := odin
SRC := src
OUT := build/lisp_odin

.PHONY: all build debug run test clean check

all: build

build:
	@mkdir -p build
	$(ODIN) build $(SRC) -out:$(OUT) -debug

debug:
	@mkdir -p build
	$(ODIN) build $(SRC) -out:$(OUT) -debug

run:
	$(ODIN) run $(SRC)

test:
	$(ODIN) test $(SRC)

clean:
	rm -rf build/

check:
	$(ODIN) check $(SRC)
