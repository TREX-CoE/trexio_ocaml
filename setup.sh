#!/usr/bin/env bash
# setup.sh — optional TREXIO C-library bootstrap.
#
# Interface:
#   ./setup.sh build-c-library [prefix]     # fetch + configure + make (no install)
#   ./setup.sh install-c-library <prefix>   # build-c-library + make install + .pc fixup
#
# Code generation lives in ./update.sh (the single owner of fetch + regenerate);
# it is NOT called by the opam build — the trexio package builds from the
# committed generated files. This script IS called by the conf-trexio package
# when no C library is found via pkg-config (build: = build-c-library,
# install: = install-c-library), and it is the `make bootstrap` entry point too.
#
# The OCaml binding's own dune build never compiles the C library: it is
# either pre-installed (distro package, conda-forge 'trexio', nix, or a
# previous bootstrap) or built by conf-trexio (this script) from the vendored
# external/ tarball, and dune-configurator resolves its flags via
# `pkg-config trexio`.
#
# Versioning (Rust-binding convention, cf. trexio-rs): the dune-project
# version is the single source of truth.  2.6.1NN  ==  TREXIO C library 2.6.1
# + binding revision NN.  The C-library tag used for downloads is derived as
#   MAJOR.MINOR.(PATCH / 100),   e.g.  2.6.101 -> 2.6.1.
#
# Requirements: bash, sed, cut, tar, a C compiler + make; HDF5 development
# headers are optional (without them the C library is built TEXT-only);
# curl + network access to github.com only when external/trexio-<V>.tar.gz
# is not vendored. The release tarball ships a pre-generated configure, so
# no autotools packages are needed.

set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat >&2 <<EOF
usage: $(basename "$0") build-c-library [prefix]
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
build_c_library() {
  # Fetch (offline-first from external/) + configure + make; NO install.
  # This is what conf-trexio's opam build: stanza runs: the opam 2.x build
  # sandbox makes the destination prefix read-only during build, so nothing
  # here may write outside the build directory.
  #
  # Uses the release tarball's canonical autotools build (./configure + make):
  # the CMake build system shipped in TREXIO 2.6.1 has no pkg-config install
  # rule and thus never installs trexio.pc, whereas the autotools build does
  # (Makefile.am: pkgconfig_DATA = pkgconfig/trexio.pc).  Since the OCaml
  # build requires `pkg-config trexio` to succeed, the autotools build is the
  # one that satisfies the dependency model.  Flags mirror the intended
  # CMake configuration of the plan: HDF5 ON, Fortran OFF, no Python, no
  # tests executed.
  #
  # The install step also passes `make install prefix=...` as a
  # belt-and-braces override of the install location.
  local prefix="${1:-/usr/local}"
  fetch
  cd "$DIR"
  configure_if_needed "$prefix"
  make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"
}

# Re-runs ./configure only when there is no Makefile or when the Makefile
# was configured for a different --prefix. The installed trexio.pc has its
# libdir substituted at configure time (config.status), so the prefix baked
# into the tree must match the prefix being installed to; a stale Makefile
# from a previous bootstrap (possibly with a different prefix) then triggers
# a re-configure. In the common cases nothing happens: the conf-trexio
# install: stanza finds the Makefile that the build: stanza configured for
# the same prefix, and make afterwards does nothing.
configure_if_needed() {
  local prefix="$1"
  local cur=""
  if [ -f Makefile ]; then
    cur="$(sed -n 's/^prefix *= *//p' Makefile | head -1)"
  fi
  [ "$cur" = "$prefix" ] && return 0
  ./configure --prefix="$prefix" --without-fortran --enable-static --disable-shared --with-hdf5=yes \
    || ./configure --prefix="$prefix" --without-fortran --enable-static --disable-shared --with-hdf5=no
}

install_c_library() {
  # One-shot bootstrap: `make bootstrap`, CI, or the conf-trexio opam
  # install: stanza (which runs with a writable prefix, unlike build:).
  # Intended use:
  #   ./setup.sh install-c-library $PWD/_prefix
  # then:  export PKG_CONFIG_PATH="$_prefix/lib/pkgconfig"
  local prefix="${1:-}"
  if [ -z "$prefix" ]; then
    echo "usage: ./setup.sh install-c-library <prefix>" >&2
    exit 1
  fi
  build_c_library "$prefix"
  make install prefix="$prefix"
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
  build-c-library)    shift; build_c_library "${1:-}" ;;
  install-c-library)  shift; install_c_library "${1:-}" ;;
  codegen)
    echo "setup.sh: 'codegen' moved to ./update.sh" >&2
    echo "          run: ./update.sh" >&2
    exit 1
    ;;
  *)                  usage ;;
esac
