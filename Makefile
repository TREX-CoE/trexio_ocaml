PREFIX ?= $(CURDIR)/_prefix
.PHONY: all update bootstrap build test install clean cleanall

all: build
update:                                         # refresh generated binding files from the pinned TREXIO release
	./update.sh
bootstrap:                                      # install the TREXIO C library locally
	./setup.sh install-c-library $(PREFIX)
build:
	dune build
test:
	dune build @runtest
install:
	opam install .
clean:
	dune clean
cleanall: clean
	rm -rf _fetch _prefix tmp tmp_*
