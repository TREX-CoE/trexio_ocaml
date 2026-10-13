#!/usr/bin/env bash
# update.sh — the single owner of binding code generation.
#
# Flow:
#   1. derive the TREXIO C tag from the dune-project binding version
#      (2.6.1NN  ==  TREXIO C MAJOR.MINOR.(PATCH/100),  e.g. 2.6.101 -> 2.6.1)
#   2. fetch the pinned release tarball (cached under _fetch/), and refresh
#      the committed trex.json in the repo root from the tarball, asserting
#      the tarball's own version matches the derived tag
#   3. python3 read_json.py  — regenerate lib/trexio.ml, lib/trexio.mli,
#      lib/trexio_stubs.c from the src/ templates
#      (the generator re-validates dune-project vs opam versions)
#   4. dune build @runtest   — compile the freshly generated files and run
#      the whole test suite, so a broken regeneration fails here, not later
#   5. print a git status/diff summary of lib/ + trex.json, so you can review
#      and commit the changes together if the TREXIO C API actually changed
#
# Requirements: bash, curl, tar, python3, and network access to github.com
# (only for step 2, and only when _fetch/trexio-<tag> is not cached).
# Step 4 additionally needs the TREXIO C library resolvable via pkg-config:
# a local bootstrap prefix (./setup.sh install-c-library <prefix>, default
# _prefix in this repo) is picked up automatically when present; otherwise
# PKG_CONFIG_PATH/LD_LIBRARY_PATH must point at an installed TREXIO.
#
# This is the ONLY script in the repo that fetches or generates anything.
# The generated files (lib/trexio.ml, lib/trexio.mli, lib/trexio_stubs.c)
# and the generator input (trex.json) are committed, so `opam install .`
# needs neither a network connection nor python3 at build time.

set -euo pipefail

cd "$(dirname "$0")"

usage() {
  cat >&2 <<EOF
usage: $(basename "$0")          # no arguments
EOF
  exit 1
}
[ "$#" -eq 0 ] || usage

# --- required tools ------------------------------------------------------------
for tool in curl tar python3 sed cut dune; do
  command -v "$tool" >/dev/null 2>&1 \
    || { echo "update.sh: missing required tool: $tool" >&2; exit 1; }
done

# --- C tag derived from the dune-project version -------------------------------
# Versioning (Rust-binding convention, cf. trexio-rs): the dune-project
# version is the single source of truth.  2.6.1NN  ==  TREXIO C library 2.6.1
# + binding revision NN.  The C-library tag is derived as
#   MAJOR.MINOR.(PATCH / 100),   e.g.  2.6.101 -> 2.6.1.
[ -f dune-project ] || {
  echo "update.sh: no dune-project in $(pwd)" >&2; exit 1; }
PV=$(sed -n 's/.*version \([0-9.][0-9.]*\).*/\1/p' dune-project | head -1)
MAJOR=$(echo "$PV" | cut -d. -f1)
MINOR=$(echo "$PV" | cut -d. -f2)
PATCH=$(echo "$PV" | cut -d. -f3)
is_num() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac }
if ! { is_num "$MAJOR" && is_num "$MINOR" && is_num "$PATCH" && [ "${#PATCH}" -ge 3 ]; }; then
  echo "update.sh: dune-project version '${PV:-<not found>}' does not follow the" >&2
  echo "           binding versioning convention (Rust-binding style):" >&2
  echo "           MAJOR.MINOR.PATCHR[R]  ==  TREXIO C MAJOR.MINOR.(PATCH/100) + revision RR," >&2
  echo "           e.g. 2.6.101 = TREXIO C library 2.6.1 + binding revision 01" >&2
  exit 1
fi
V="${MAJOR}.${MINOR}.$(( PATCH / 100 ))"
DIR="_fetch/trexio-$V"

# --- fetch (idempotent, cached under _fetch/) ----------------------------------
if [ ! -d "$DIR" ]; then
  mkdir -p _fetch
  URL_PRIMARY="https://github.com/TREX-CoE/trexio/releases/download/v$V/trexio-$V.tar.gz"
  URL_FALLBACK="https://github.com/TREX-CoE/trexio/archive/refs/tags/v$V.tar.gz"
  curl -fL --retry 3 -o "_fetch/src.tar.gz" "$URL_PRIMARY" \
    || curl -fL --retry 3 -o "_fetch/src.tar.gz" "$URL_FALLBACK"
  tar xzf "_fetch/src.tar.gz" -C _fetch
  rm -f _fetch/src.tar.gz
  echo "fetched TREXIO $V release" >&2
else
  echo "using cached TREXIO $V release: $DIR" >&2
fi

# --- assert the tarball's version matches the derived tag ----------------------
# The release tarball ships configure.ac with AC_INIT([trexio],[X.Y.Z],...);
# require that X.Y.Z equals the tag derived from dune-project.
TARBALL_V=$(sed -n 's/^AC_INIT(\[trexio\],\[\([0-9.][0-9.]*\)\].*/\1/p' \
  "$DIR/configure.ac" 2>/dev/null | head -1)
if [ "${TARBALL_V:-}" != "$V" ]; then
  echo "update.sh: tarball in $DIR reports version '${TARBALL_V:-<not found>}'" >&2
  echo "           but dune-project derives to TREXIO $V — refusing to proceed." >&2
  echo "           (delete $DIR to force a fresh fetch)" >&2
  exit 1
fi

# --- refresh the committed trex.json (generator input) ---------------------------
[ -f "$DIR/trex.json" ] || {
  echo "update.sh: no trex.json in $DIR" >&2; exit 1; }
cp "$DIR/trex.json" ./trex.json
echo "refreshed trex.json from $DIR" >&2

# --- regenerate the OCaml binding (the generator validates versions itself) ------
python3 read_json.py >&2
echo "regenerated lib/trexio.ml, lib/trexio.mli, lib/trexio_stubs.c" >&2

# --- build + run the test suite ---------------------------------------------------
# Prefer a local bootstrap prefix (make bootstrap / setup.sh install-c-library),
# falling back to whatever the ambient environment already provides.
if [ -f _prefix/lib/pkgconfig/trexio.pc ]; then
  export PKG_CONFIG_PATH="$PWD/_prefix/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export LD_LIBRARY_PATH="$PWD/_prefix/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
if ! dune build @runtest; then
  cat >&2 <<'EOF'
update.sh: `dune build @runtest` failed.
If the TREXIO C library is not resolvable via pkg-config, bootstrap it and/or
point the environment at it:
  ./setup.sh install-c-library <prefix>
  export PKG_CONFIG_PATH="<prefix>/lib/pkgconfig"
  export LD_LIBRARY_PATH="<prefix>/lib"
EOF
  exit 1
fi
echo "dune build @runtest: OK" >&2

# --- summary: review, and commit if the C API changed -----------------------------
echo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "=== git status of generated files (review; commit if non-empty) ===" >&2
  git status --short -- lib trex.json
  git diff --stat -- lib trex.json
  git diff --cached --stat -- lib trex.json
  echo "Review: if the TREXIO C API changed, commit the files above together" >&2
  echo "with the version bump (dune-project + trexio.opam + conf-trexio.opam)" >&2
  echo "as one change. Before committing, verify the user-facing path with:" >&2
  echo "  opam install . --with-test    # C library resolvable via pkg-config" >&2
else
  echo "not a git work tree; please diff lib/ + trex.json against the previous" >&2
  echo "release and commit the changes manually." >&2
fi
