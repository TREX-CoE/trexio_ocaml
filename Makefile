PREFIX ?= $(CURDIR)/_prefix
.PHONY: all codegen bootstrap build test install clean cleanall

all: codegen build
codegen:
	./setup.sh codegen
bootstrap:                                  # install the C library locally
	./setup.sh install-c-library $(PREFIX)
build:
	dune build
test:
	dune build @runtest
install:
	opam install .
clean:
	rm -f lib/trexio.ml lib/trexio.mli lib/trexio_stubs.c trex.json
	dune clean
cleanall: clean
	rm -rf _fetch _prefix
