#!/usr/bin/env bash
# update.sh — the only place that fetches or generates binding code:
# derive the C tag from dune-project (A.B.1NN -> A.B.(P/100)), fetch the
# release tarball (cached under _fetch/), assert its version, refresh
# trex.json, regenerate lib/ from the src/ templates, run the test suite —
# a broken regeneration fails here, not later.

set -euo pipefail

cd "$(dirname "$0")"

[ "$#" -eq 0 ] || { echo "usage: $(basename "$0")   (no arguments)" >&2; exit 1; }

for tool in curl tar python3 sed cut dune; do
  command -v "$tool" >/dev/null 2>&1 \
    || { echo "update.sh: missing required tool: $tool" >&2; exit 1; }
done

# --- C tag derived from the dune-project version --------------------------------
[ -f dune-project ] || {
  echo "update.sh: no dune-project in $(pwd)" >&2; exit 1; }
PV=$(sed -n 's/.*version \([0-9.][0-9.]*\).*/\1/p' dune-project | head -1)
MAJOR=$(echo "$PV" | cut -d. -f1)
MINOR=$(echo "$PV" | cut -d. -f2)
PATCH=$(echo "$PV" | cut -d. -f3)
is_num() { case "$1" in ''|*[!0-9]*) return 1 ;; *) return 0 ;; esac }
if ! { is_num "$MAJOR" && is_num "$MINOR" && is_num "$PATCH" && [ "${#PATCH}" -ge 3 ]; }; then
  echo "update.sh: dune-project version '${PV:-<not found>}' must follow the" >&2
  echo "           A.B.1NN binding convention (e.g. 2.6.101 = TREXIO C 2.6.1 + revision 01)" >&2
  exit 1
fi
V="${MAJOR}.${MINOR}.$(( PATCH / 100 ))"
DIR="_fetch/trexio-$V"

# --- fetch (idempotent, cached under _fetch/) ------------------------------------
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

# --- assert the tarball version equals the derived tag ----------------------------
TARBALL_V=$(sed -n 's/^AC_INIT(\[trexio\],\[\([0-9.][0-9.]*\)\].*/\1/p' \
  "$DIR/configure.ac" 2>/dev/null | head -1)
if [ "${TARBALL_V:-}" != "$V" ]; then
  echo "update.sh: tarball in $DIR reports version '${TARBALL_V:-<not found>}'" >&2
  echo "           but dune-project derives to TREXIO $V — refusing to proceed." >&2
  echo "           (delete $DIR to force a fresh fetch)" >&2
  exit 1
fi

# --- refresh the committed trex.json (generator input) ------------------------------
[ -f "$DIR/trex.json" ] || {
  echo "update.sh: no trex.json in $DIR" >&2; exit 1; }
cp "$DIR/trex.json" ./trex.json
echo "refreshed trex.json from $DIR" >&2

# --- regenerate the OCaml binding (the generator validates versions itself) --------
python3 read_json.py
echo "regenerated lib/trexio.ml, lib/trexio.mli, lib/trexio_stubs.c" >&2

# --- build + run the test suite ------------------------------------------------------
# A local bootstrap prefix (make bootstrap) wins over the ambient environment.
if [ -f _prefix/lib/pkgconfig/trexio.pc ]; then
  export PKG_CONFIG_PATH="$PWD/_prefix/lib/pkgconfig${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  export LD_LIBRARY_PATH="$PWD/_prefix/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
if ! dune build @runtest; then
  cat >&2 <<'EOF'
update.sh: `dune build @runtest` failed.
If the TREXIO C library is not resolvable via pkg-config:
  ./setup.sh install-c-library <prefix>
  export PKG_CONFIG_PATH="<prefix>/lib/pkgconfig"   # and LD_LIBRARY_PATH=<prefix>/lib
EOF
  exit 1
fi
echo "dune build @runtest: OK" >&2

# --- summary: review, and commit if the C API changed -------------------------------
echo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "=== git status of generated files (review; commit if non-empty) ===" >&2
  git status --short -- lib trex.json
  git diff --stat -- lib trex.json
  git diff --cached --stat -- lib trex.json
  echo "Review: if the TREXIO C API changed, commit the files above together" >&2
  echo "with the version bump (dune-project + trexio.opam) as one change." >&2
else
  echo "not a git work tree; please diff lib/ + trex.json against the previous" >&2
  echo "release and commit the changes manually." >&2
fi
