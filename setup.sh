#!/usr/bin/env bash
# setup.sh — optional TREXIO C-library bootstrap.
#
# Interface:
#   ./setup.sh install-c-library <prefix>   # one-shot bootstrap of the TREXIO C library
#
# Code generation lives in ./update.sh (the single owner of fetch + regenerate);
# it is NOT called by the opam build, and neither is this script: the OCaml
# package is built from the committed generated files.
#
# The C library is NEVER compiled as part of the OCaml build — it must be
# pre-installed (distro package, conda-forge 'trexio', nix, or this script),
# and dune-configurator resolves its compile/link flags via `pkg-config trexio`.
#
# Versioning (Rust-binding convention, cf. trexio-rs): the dune-project
# version is the single source of truth.  2.6.1NN  ==  TREXIO C library 2.6.1
# + binding revision NN.  The C-library tag used for downloads is derived as
#   MAJOR.MINOR.(PATCH / 100),   e.g.  2.6.101 -> 2.6.1.
#
# Requirements: bash, sed, cut, curl, tar, autotools (autoconf/automake/libtool,
# gcc), HDF5 development headers, and network access to github.com.

set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat >&2 <<EOF
usage: $(basename "$0") install-c-library <prefix>
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
# Offline-first: use the vendored tarball external/trexio-<V>.tar.gz when
# present; otherwise download the pinned release (release-asset URL only —
# the tag/source archive has no generated configure and cannot be built).
fetch() {
  [ -d "$DIR" ] && return
  mkdir -p _fetch
  if [ -f "external/trexio-$V.tar.gz" ]; then
    if [ -f "external/trexio-$V.tar.gz.sha256" ]; then
      ( cd external && sha256sum -c "trexio-$V.tar.gz.sha256" ) >&2
    fi
    tar xzf "external/trexio-$V.tar.gz" -C _fetch
    echo "using vendored external/trexio-$V.tar.gz" >&2
  else
    URL="https://github.com/TREX-CoE/trexio/releases/download/v$V/trexio-$V.tar.gz"
    curl -fL --retry 3 -o "_fetch/src.tar.gz" "$URL"
    tar xzf "_fetch/src.tar.gz" -C _fetch
    rm -f _fetch/src.tar.gz
    echo "fetched TREXIO $V release" >&2
  fi
}

# --- actions ------------------------------------------------------------------
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
  ./configure --prefix="$prefix" --without-fortran --enable-static --disable-shared --with-hdf5=yes \
    || ./configure --prefix="$prefix" --without-fortran --enable-static --disable-shared --with-hdf5=no
  make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"
  make install
  # Plain `pkg-config --libs` must be enough to link the static archive:
  # merge the static (private) deps into the installed .pc Libs line.
  local pc="$prefix/lib/pkgconfig/trexio.pc"
  if [ -f "$pc" ]; then
    local libs
    libs="$(PKG_CONFIG_PATH="$prefix/lib/pkgconfig" pkg-config --libs --static trexio 2>/dev/null || true)"
    if [ -n "$libs" ]; then
      sed -i "s|^Libs:.*|Libs: $libs|" "$pc"
    fi
  fi
  cd -
  echo "TREXIO C library installed to: $prefix  (use PKG_CONFIG_PATH=\"\$prefix/lib/pkgconfig\")" >&2
}

case "${1:-}" in
  install-c-library)  shift; install_c_library "${1:-}" ;;
  codegen)
    echo "setup.sh: 'codegen' moved to ./update.sh" >&2
    echo "          run: ./update.sh" >&2
    exit 1
    ;;
  *)                  usage ;;
esac
