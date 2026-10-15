# trexio_ocaml

**`trexio_ocaml`** is the OCaml binding for the [TREXIO](https://trex-coe.github.io/trexio/)
file format and C library for wave functions and quantum-chemistry integrals.

## What this is

One OPAM record: `trexio` (the binding: C stubs over the TREXIO C library).

`opam install trexio` works out of the box: if `pkg-config
--atleast-version=2.6.1 trexio` already succeeds (system 2.6.1+, conda, nix,
…) that installation is used; otherwise the record builds the **vendored**
`external/trexio-<Ctag>.tar.gz` **statically, offline** — into `./_c-prefix`
during `build:` (used by the build) and into the opam switch during
`install:` (persists for later).
A suitable system C library is always preferred.

## Versioning

Binding version `A.B.CNN` = TREXIO release `A.B.C` + binding revision `NN`
(same convention as the TREXIO Rust binding); e.g. `2.6.101` = TREXIO `2.6.1`,
OCaml revision `01`. `dune-project` is the single source of truth; the `.opam`
file must always state the same version.

## Installation

```sh
opam install trexio            # from the OPAM repository
opam install . --with-test     # from a checkout
```

## Local development

```sh
make bootstrap                 # vendored C library into ./_prefix (offline, static)
export PKG_CONFIG_PATH="$PWD/_prefix/lib/pkgconfig"   # for manual dune runs
make                           # build (committed generated sources)
make test                      # TEXT + HDF5 round-trips, byte + native
make install                   # into the current OPAM switch
```

## Upgrading to a new TREXIO C release (for maintainers)

1. Bump the binding version in `dune-project` and `trexio.opam`.
2. Replace `external/trexio-<Ctag>.tar.gz` with the new release and
   regenerate its `.sha256`:
   `cd external && sha256sum trexio-<Ctag>.tar.gz > trexio-<Ctag>.tar.gz.sha256`.
3. `./update.sh` — fetches, asserts the version, regenerates `trex.json` +
   `lib/`, runs the full test suite.

Full playbook (diff review, verification gates, publishing,
troubleshooting): [UPGRADING.md](UPGRADING.md).

## Prerequisites

- build/test: `gcc`, `pkg-config`, `dune >= 3.1`, `dune-configurator`;
  HDF5 headers **optional** (without them the C library is TEXT-only and the
  tests print `SKIP HDF5`)
- `./update.sh`: additionally `curl`, `tar`, `python3` and network (only
  when `_fetch/` has no cache)
- `make bootstrap`: a C compiler + `make` (the tarball ships its own
  `configure` + `libtool`); HDF5 dev package for an HDF5-enabled C library

## Layout

```
dune-project               # package/version definitions (source of truth)
trexio.opam
trex.json                  # generator input (committed; refreshed by ./update.sh)
src/                       # hand-written binding templates (code-gen markers)
lib/                       # generated + committed sources (+ dune-configurator setup)
read_json.py               # generator: trex.json + src/ -> lib/
update.sh                  # fetch + regenerate + test (only place that fetches)
setup.sh                   # C bootstrap (make bootstrap / opam build step): offline, static
external/                  # vendored TREXIO C tarball + .sha256
Makefile                   # dev convenience targets
```

## Provenance

The binding previously lived in [TREX-CoE/trexio](https://github.com/TREX-CoE/trexio)
under `ocaml/trexio/` ([removed in `fa86b5e`](https://github.com/TREX-CoE/trexio/commit/fa86b5e));
this repository is its home.

## License

BSD-3-Clause (see [LICENSE](LICENSE)).
