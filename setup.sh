#!/usr/bin/env bash
# setup.sh — hermetic code-generation driver + optional C-library bootstrap.
#
# Interface:
#   ./setup.sh codegen                   # used by the opam build (default action)
#   ./setup.sh install-c-library <prefix>   # one-shot bootstrap of the TREXIO C library
#
# Code generation is hermetic: it downloads ONLY the pinned TREXIO release
# tarball to extract trex.json (the code generator input). The C library is
# NEVER compiled as part of the OCaml build — it must be pre-installed
# (distro package, conda-forge 'trexio', nix, or `./setup.sh install-c-library
# <prefix>`), and dune-configurator resolves its compile/link flags via
# `pkg-config trexio`.
#
# Versioning (Rust-binding convention, cf. trexio-rs): the dune-project
# version is the single source of truth.  2.6.1NN  ==  TREXIO C library 2.6.1
# + binding revision NN.  The C-library tag used for downloads is derived as
#   MAJOR.MINOR.(PATCH / 100),   e.g.  2.6.101 -> 2.6.1.
#
# Requirements for codegen in a hermetic environment: bash, sed, cut, curl,
# tar, python3, and network access to github.com.

set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat >&2 <<EOF
usage: $(basename "$0") codegen
       $(basename "$0") install-c-library <prefix>
EOF
  exit 1
}

# --- C tag derived from the dune-project version ----------------------------
[ -f dune-project ] || {
  echo "setup.sh: no dune-project in $(pwd)" >&2; exit 1; }
PV=$(sed -n 's/.*version \([0-9.][0-9.]*\).*/\1/p' dune-project | head -1)
MAJOR=$(echo "$PV" | cut -d. -f1)
MINOR=$(echo "$PV" | cut -d. -f2)
PATCH=$(echo "$PV" | cut -d. -f3)
is_num() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac }
if ! { is_num "$MAJOR" && is_num "$MINOR" && is_num "$PATCH" && [ "${#PATCH}" -ge 3 ]; }; then
  echo "setup.sh: dune-project version '${PV:-<not found>}' does not follow the" >&2
  echo "          binding versioning convention (Rust-binding style):" >&2
  echo "          MAJOR.MINOR.PATCHR[R]  ==  TREXIO C MAJOR.MINOR.(PATCH/100) + revision RR," >&2
  echo "          e.g. 2.6.101 = TREXIO C library 2.6.1 + binding revision 01" >&2
  exit 1
fi
V="${MAJOR}.${MINOR}.$(( PATCH / 100 ))"
DIR="_fetch/trexio-$V"

# --- shared fetch helper (idempotent, cached under _fetch/) -----------------
fetch() {
  [ -d "$DIR" ] && return
  mkdir -p _fetch
  URL_PRIMARY="https://github.com/TREX-CoE/trexio/releases/download/v$V/trexio-$V.tar.gz"
  URL_FALLBACK="https://github.com/TREX-CoE/trexio/archive/refs/tags/v$V.tar.gz"
  curl -fL --retry 3 -o "_fetch/src.tar.gz" "$URL_PRIMARY" \
    || curl -fL --retry 3 -o "_fetch/src.tar.gz" "$URL_FALLBACK"
  tar xzf "_fetch/src.tar.gz" -C _fetch
  rm -f _fetch/src.tar.gz
  echo "fetched TREXIO $V release for code generation" >&2
}

# --- actions ------------------------------------------------------------------
codegen() {
  # No C compiler, no autotools, no HDF5 — codegen alone needs only curl +
  # python3 (+ network) in a hermetic environment.
  fetch
  cp "$DIR/trex.json" .          # repo root, git-ignored
  python3 read_json.py           # writes lib/trexio.ml(.mli) + lib/trexio_stubs.c
  echo "code generation complete: lib/trexio.ml, lib/trexio.mli, lib/trexio_stubs.c" >&2
}

install_c_library() {
  # Optional bootstrap (dev/CI); intended use:
  #   ./setup.sh install-c-library $PWD/_prefix
  # then:  export PKG_CONFIG_PATH="$_prefix/lib/pkgconfig"
  #        export LD_LIBRARY_PATH="$_prefix/lib"
  #
  # NOT called by the opam build — the OCaml package never compiles the C lib.
  #
  # Uses the release tarball's canonical autotools build (./configure + make):
  # the CMake build system shipped in TREXIO 2.6.1 has no pkg-config install
  # rule and thus never installs trexio.pc, whereas the autotools build does
  # (Makefile.am: pkgconfig_DATA = pkgconfig/trexio.pc).  Since the OCaml
  # build requires `pkg-config trexio` to succeed, the autotools build is the
  # one that satisfies the dependency model.  Flags mirror the intended
  # CMake configuration of the plan: HDF5 ON, Fortran OFF, no Python, no
  # tests executed.
  local prefix="${1:-}"
  if [ -z "$prefix" ]; then
    echo "usage: ./setup.sh install-c-library <prefix>" >&2
    exit 1
  fi
  fetch
  cd "$DIR"
  ./configure --prefix="$prefix" --with-hdf5=yes --without-fortran
  make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"
  make install
  cd -
  echo "TREXIO C library installed to: $prefix  (use PKG_CONFIG_PATH=\"\$prefix/lib/pkgconfig\")" >&2
}

case "${1:-codegen}" in
  codegen)            shift; codegen "$@" ;;
  install-c-library)  shift; install_c_library "${1:-}" ;;
  *)                  usage ;;
esac
