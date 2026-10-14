# trexio_ocaml

**`trexio`** is the OCaml binding for the [TREXIO](https://trex-coe.github.io/trexio/)
file format and C library for storing wave functions and quantum-chemistry
integrals.

## What this repository is

A self-contained OPAM package: the OPAM package `trexio` (the binding), plus a
`conf-trexio` provision package (see below). The binding wraps the TREXIO
**C library** via C stubs; the binding's own build never compiles the C
library. The `conf-trexio` dependency guarantees a C library is *available*:
if `pkg-config --exists trexio` already succeeds (pre-installed C library —
distro package, conda-forge `trexio`, nix channel, …) it is used as-is;
otherwise `conf-trexio` builds the **vendored**
`external/trexio-<Ctag>.tar.gz` release tarball (statically, offline) into
the OPAM switch. Net effect: `opam install trexio` works on a machine with no
TREXIO installed, and always prefers an existing C library when one is
present.

## Provenance

The OCaml binding previously lived in [TREX-CoE/trexio](https://github.com/TREX-CoE/trexio)
under `ocaml/trexio/`. It was removed from that repository
([commit `fa86b5e`](https://github.com/TREX-CoE/trexio/commit/fa86b5e)) and moved
here; this repository is now its home.

## Versioning contract

The binding follows the **released** TREXIO C library, *not* the evolving
`master` branch of `trexio` on GitHub. The versioning convention is the same
as the TREXIO Rust binding (`trexio-rs`):

> binding version `A.B.CNN` = TREXIO C library release `A.B.C` + binding
> revision `NN`

So version `2.6.101` means: TREXIO C library release **2.6.1**, binding
revision **01**. The C-library tag is *derived* from the binding version as
`major.minor.(patch/100)`. The single source of truth for the binding version
is the `dune-project` file (there is no separate `VERSION` file).

## Installation (users)

One step:

1. Install the OCaml binding from an OPAM switch:

   ```sh
   opam install trexio
   ```

   The `conf-trexio` dependency handles the C library for you: it uses an
   existing TREXIO C installation when `pkg-config --exists trexio`
   succeeds, otherwise it builds the vendored
   `external/trexio-<Ctag>.tar.gz` (statically, into the switch). A
   pre-installed C library is always preferred over the bootstrap.

   (Until the `trexio` + `conf-trexio` records are submitted to the OPAM
   repository, install from this repository instead, e.g.
   `opam pin add trexio <path-to-this-repo>` and
   `opam pin add conf-trexio <path-to-this-repo>`.)

For a local, test-enabled install from a checkout:

```sh
opam install . --with-test
```

The build itself is a plain `dune build` of **committed** sources (see
"Regenerating the binding" below) and needs **no python3** at build time;
nor any network access — the bootstrapped C library comes from the *vendored*
tarball (below). `dune-configurator` locates the C library via
`pkg-config trexio`, falling back to `$OPAM_SWITCH_PREFIX/lib/pkgconfig`
when `conf-trexio` bootstrapped it into the switch.

## Local development

```sh
# one-shot bootstrap of the TREXIO C library into ./_prefix (offline: from
# the vendored external/ tarball; static-only, so no runtime paths needed):
make bootstrap                        # = ./setup.sh install-c-library _prefix
# then point the environment at it for manual dune runs (update.sh finds it
# itself when the prefix is ./_prefix in this repo):
export PKG_CONFIG_PATH="$PWD/_prefix/lib/pkgconfig"

# build (uses the committed, already-generated sources)
make

# run the test suite (TEXT + HDF5 round-trips, byte + native)
make test

# install into the current OPAM switch
make install
```

### Upgrading the binding (maintainers)

The OCaml library sources (`lib/trexio.ml`, `lib/trexio.mli`,
`lib/trexio_stubs.c`) and the generator input (`trex.json`) are **generated
and committed**; nobody ever fetches anything at build time. The binding is
upgraded from a released TREXIO C library, from time to time, in four steps:

1. **Bump the binding version** when targeting a new C release: the new
   version goes into `dune-project` **and** `trexio.opam` +
   `conf-trexio.opam` (all three must agree — the generator enforces this).
   The C tag is derived automatically: `2.7.101` → `v2.7.1`.
2. **Replace the vendored C tarball** with the new release: store the new
   release-asset tarball as `external/trexio-<Ctag>.tar.gz` (replacing the
   previous one) and regenerate its checksum:
   `cd external && sha256sum trexio-<Ctag>.tar.gz > trexio-<Ctag>.tar.gz.sha256`.
3. **Regenerate**: run `./update.sh` — it fetches the pinned release tarball
   (cached under `_fetch/`), asserts the tarball's own version, refreshes
   `trex.json`, regenerates the `lib/` sources via `read_json.py`, and then
   runs `dune build @runtest` (build + tests, byte and native). If the C API
   changed and a test or stub no longer holds, it fails here — fix that first.
4. **Verify the user-facing path**: `opam install . --with-test` from a clean
   OPAM switch (the build is fully hermetic — no network, no python needed;
   if no C library is installed, `conf-trexio` bootstraps it from
   `external/` into the switch).
5. **Review and commit** the version bump, the new `external/` tarball +
   `.sha256`, the regenerated `lib/` + `trex.json`, and any test fixes as one
   change.

The full playbook — version convention, diff review, verification gates,
publishing, and troubleshooting — is in [UPGRADING.md](UPGRADING.md).

### Prerequisites

- Building/testing: `gcc`, `pkg-config`, `dune >= 3.1`, `dune-configurator`,
  `conf-pkg-config`; HDF5 development headers **optional** (without them the
  bootstrapped C library is TEXT-only and the test suite prints `SKIP HDF5`)
- `./update.sh` only: additionally `curl`, `tar`, `python3`, and network
  access to github.com (used only when `_fetch/trexio-<tag>` is not cached)
- `make bootstrap` only: a C compiler + `make` (the vendored release tarball
  ships its own `configure` and `libtool`, so no autotools packages are
  needed); for an HDF5-enabled C library, the HDF5 development package

## Layout

```
dune-project             # package/version source of truth (see contract above)
trexio.opam              # OPAM record for the binding
conf-trexio.opam         # provision package: system C library if present, else bootstrap external/ into the switch
trex.json                # generator input (committed; refreshed by ./update.sh)
src/trexio.ml .mli .c    # hand-written binding *templates* (code-gen markers)
lib/trexio.ml .mli .c    # generated + committed library sources
lib/dune, lib/config/*   # dune library + dune-configurator (pkg-config, with a $OPAM_SWITCH_PREFIX fallback)
read_json.py             # code generator: trex.json + src/ -> lib/trexio.ml|.mli|trexio_stubs.c
update.sh                # code-generation driver (fetch trex.json, regenerate, build)
UPGRADING.md             # maintainer playbook: what to do when a new TREXIO C release appears
setup.sh                 # C-library bootstrap (./setup.sh install-c-library): offline from external/, static-only
external/                # vendored TREXIO C release tarball + .sha256 (offline bootstrap source)
Makefile                 # dev convenience targets (bootstrap/build/test/install/update)
```

## License

BSD-3-Clause (see [LICENSE](LICENSE)).
