# trexio_ocaml

**`trexio`** is the OCaml binding for the [TREXIO](https://trex-coe.github.io/trexio/)
file format and C library for storing wave functions and quantum-chemistry
integrals.

## What this repository is

A self-contained OPAM package: the OPAM package `trexio` (the binding), plus a
`conf-trexio` check package (see below). The binding wraps the
TREXIO **C library** via C stubs; it does **not** compile or bundle the C
library. It requires a pre-installed TREXIO C library (any normal means:
distro package, conda-forge `trexio`, nix channel, or the optional one-shot
bootstrap script in this repo) so that `pkg-config --exists trexio` succeeds.

## Provenance

The OCaml binding previously lived in [TREX-CoE/trexio](https://github.com/TREX-CoE/trexio)
under `ocaml/trexio/`. It has been moved out to this repository, which is now
its home.

<!-- TODO(task 07): link the PR/commit in TREX-CoE/trexio that removed the OCaml binding -->

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

Two steps:

1. Install the TREXIO C library by any normal means (distro package,
   conda-forge `trexio`, nix channel, or the optional one-shot bootstrap
   `./setup.sh install-c-library <prefix>`) so that
   `pkg-config --exists trexio` succeeds.
2. Install the OCaml binding from an OPAM switch:

   ```sh
   opam install trexio
   ```

   (until the `trexio` + `conf-trexio` records are submitted to the OPAM
   repository, install from this repository instead, e.g.
   `opam pin add trexio <path-to-this-repo>` and
   `opam pin add conf-trexio <path-to-this-repo>` with the C library present.)

For a local, test-enabled install from a checkout:

```sh
opam install . --with-test
```

The build itself is a plain `dune build` of **committed** sources (see
"Regenerating the binding" below), so it needs **no network access and no
python3** at build time — only the pre-installed C library, which
`dune-configurator` locates via `pkg-config trexio`.

## Local development

```sh
# optional one-shot bootstrap of the TREXIO C library into a prefix
make bootstrap                        # = ./setup.sh install-c-library _prefix
# then point the environment at it for manual dune runs (update.sh finds it
# itself when the prefix is ./_prefix in this repo):
export PKG_CONFIG_PATH="$PWD/_prefix/lib/pkgconfig"
export LD_LIBRARY_PATH="$PWD/_prefix/lib"

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
2. **Regenerate**: run `./update.sh` — it fetches the pinned release tarball
   (cached under `_fetch/`), asserts the tarball's own version, refreshes
   `trex.json`, regenerates the `lib/` sources via `read_json.py`, and then
   runs `dune build @runtest` (build + tests, byte and native). If the C API
   changed and a test or stub no longer holds, it fails here — fix that first.
3. **Verify the user-facing path**: `opam install . --with-test` from a clean
   OPAM switch, with the C library resolvable via `pkg-config` (the build is
   fully hermetic — no network, no python needed).
4. **Review and commit** the version bump, the regenerated `lib/` + `trex.json`,
   and any test fixes as one change.

The full playbook — version convention, diff review, verification gates,
publishing, and troubleshooting — is in [UPGRADING.md](UPGRADING.md).

### Prerequisites

- Building/testing: `gcc`, `pkg-config`, HDF5 development headers,
  `dune >= 3.1`, `dune-configurator`, `conf-pkg-config`
- `./update.sh` only: additionally `curl`, `tar`, `python3`, and network
  access to github.com (used only when `_fetch/trexio-<tag>` is not cached)
- `make bootstrap` only: additionally autotools (`autoconf`, `automake`,
  `libtool`) and the HDF5 development package

## Layout

```
dune-project             # package/version source of truth (see contract above)
trexio.opam              # OPAM record for the binding
conf-trexio.opam         # check package (pkg-config --exists trexio)
trex.json                # generator input (committed; refreshed by ./update.sh)
src/trexio.ml .mli .c    # hand-written binding *templates* (code-gen markers)
lib/trexio.ml .mli .c    # generated + committed library sources
lib/dune, lib/config/*   # dune library + dune-configurator (strict pkg-config check)
read_json.py             # code generator: trex.json + src/ -> lib/trexio.ml|.mli|trexio_stubs.c
update.sh                # code-generation driver (fetch trex.json, regenerate, build)
UPGRADING.md             # maintainer playbook: what to do when a new TREXIO C release appears
setup.sh                 # optional C-library bootstrap (./setup.sh install-c-library)
Makefile                 # dev convenience targets (bootstrap/build/test/install/update)
```

## License

BSD-3-Clause (see [LICENSE](LICENSE)).
