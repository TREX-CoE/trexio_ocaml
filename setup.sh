#!/usr/bin/env bash
# setup.sh — TREXIO C-library bootstrap (make bootstrap / the opam record).
#
#   ./setup.sh build-c-library [prefix]     # fetch + configure + make (no install)
#   ./setup.sh install-c-library <prefix>   # build-c-library + make install + .pc fixup
#
# Offline-first from the vendored external/trexio-<V>.tar.gz (.sha256-checked),
# static-only, HDF5 optional (TEXT-only C library without its headers). The
# release tarball ships its own configure + libtool, so no autotools packages
# are needed. V is derived from the dune-project version: A.B.1NN -> A.B.(P/100).

set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat >&2 <<EOF
usage: $(basename "$0") build-c-library [prefix]
       $(basename "$0") install-c-library <prefix>
EOF
  exit 1
}

# --- C tag derived from the dune-project version --------------------------------
[ -f dune-project ] || { echo "setup.sh: no dune-project in $(pwd)" >&2; exit 1; }
PV=$(sed -n 's/.*version \([0-9.][0-9.]*\).*/\1/p' dune-project | head -1)
MAJOR=$(echo "$PV" | cut -d. -f1)
MINOR=$(echo "$PV" | cut -d. -f2)
PATCH=$(echo "$PV" | cut -d. -f3)
is_num() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac }
if ! { is_num "$MAJOR" && is_num "$MINOR" && is_num "$PATCH" && [ "${#PATCH}" -ge 3 ]; }; then
  echo "setup.sh: dune-project version '${PV:-<not found>}' must follow the A.B.1NN binding convention" >&2
  exit 1
fi
V="${MAJOR}.${MINOR}.$(( PATCH / 100 ))"
DIR="_fetch/trexio-$V"

# --- fetch (idempotent, cached under _fetch/) ------------------------------------
# Offline-first: vendored tarball first; network fallback is the release asset
# only (the tag/source archive has no generated configure and cannot be built).
fetch() {
  [ -d "$DIR" ] && return
  mkdir -p _fetch
  if [ -f "external/trexio-$V.tar.gz" ]; then
    [ -f "external/trexio-$V.tar.gz.sha256" ] \
      && ( cd external && sha256sum -c "trexio-$V.tar.gz.sha256" ) >&2
    tar xzf "external/trexio-$V.tar.gz" -C _fetch
    echo "using vendored external/trexio-$V.tar.gz" >&2
  else
    curl -fL --retry 3 -o "_fetch/src.tar.gz" \
      "https://github.com/TREX-CoE/trexio/releases/download/v$V/trexio-$V.tar.gz"
    tar xzf "_fetch/src.tar.gz" -C _fetch
    rm -f _fetch/src.tar.gz
    echo "fetched TREXIO $V release" >&2
  fi
}

# --- build: the trexio record's build: stanza (opam 2.x makes the prefix
#     read-only during build:, so everything stays inside the build directory).
#     The autotools build is required (not the tarball's CMake): only it
#     installs trexio.pc (Makefile.am: pkgconfig_DATA = pkgconfig/trexio.pc).
build_c_library() {
  local prefix="${1:-/usr/local}"
  fetch
  cd "$DIR"
  # The v2.6.1 configure probes the Fortran compiler unconditionally
  # (AC_FC_FREEFORM) and hard-fails when no free-form flag works:
  # "Fortran does not accept free-form source" (newer gfortran, e.g. the
  # opam-ci images). Fortran is never built (--without-fortran), so
  # neutralize the fatal. With a future configure without this fatal the
  # substitution matches nothing and is a no-op.
  sed -i.bak \
    -e 's|^  as_fn_error 77 "Fortran does not accept free-form source" .*|  : # fortran free-form probe failed; harmless (Fortran is not built: --without-fortran)|' \
    configure && rm -f configure.bak
  configure_if_needed "$prefix"
  make -j"$(nproc 2>/dev/null || sysctl -n hw.ncpu)"
}

# Re-running ./configure only when the Makefile's recorded --prefix differs:
# the installed trexio.pc has its libdir substituted at configure time
# (config.status), so a stale Makefile (different prefix) must re-configure.
# In the opam flow the install: stanza finds the Makefile that build:
# configured for the same prefix, and make afterwards does nothing.
configure_if_needed() {
  local prefix="$1" cur=""
  [ -f Makefile ] && cur="$(sed -n 's/^prefix *= *//p' Makefile | head -1)"
  [ "$cur" = "$prefix" ] && return 0
  ./configure --prefix="$prefix" --without-fortran --enable-static --disable-shared --with-hdf5=yes \
    || ./configure --prefix="$prefix" --without-fortran --enable-static --disable-shared --with-hdf5=no
}

# --- install: one-shot bootstrap (make bootstrap, CI, or the trexio record's
#     install: stanza, which runs with a writable prefix). -----------------
install_c_library() {
  local prefix="${1:-}"
  [ -n "$prefix" ] || { echo "usage: ./setup.sh install-c-library <prefix>" >&2; exit 1; }
  build_c_library "$prefix"
  make install prefix="$prefix"
  # Plain `pkg-config --libs` must be enough to link the static archive:
  # merge the static (private) deps into the installed .pc Libs line.
  local pc="$prefix/lib/pkgconfig/trexio.pc"
  if [ -f "$pc" ]; then
    local libs
    libs="$(PKG_CONFIG_PATH="$prefix/lib/pkgconfig" pkg-config --libs --static trexio 2>/dev/null || true)"
    [ -n "$libs" ] && sed -i "s|^Libs:.*|Libs: $libs|" "$pc"
  fi
  cd -
  echo "TREXIO C library installed to: $prefix  (use PKG_CONFIG_PATH=\"\$prefix/lib/pkgconfig\")" >&2
}

case "${1:-}" in
  build-c-library)    shift; build_c_library "${1:-}" ;;
  install-c-library)  shift; install_c_library "${1:-}" ;;
  codegen)            echo "setup.sh: 'codegen' moved to ./update.sh — run: ./update.sh" >&2; exit 1 ;;
  *)                  usage ;;
esac
