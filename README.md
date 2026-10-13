# trexio_ocaml

**`trexio`** is the OCaml binding for the [TREXIO](https://trex-coe.github.io/trexio/)
file format and C library for storing wave functions and quantum-chemistry
integrals.

## What this repository is

A self-contained OPAM package: the OPAM package `trexio` (the binding), plus a
`conf-trexio` check package (see below, being finalized). The binding wraps the
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
   conda-forge `trexio`, nix, or the optional bootstrap
   `./setup.sh install-c-library <prefix>` — being finalized), so that
   `pkg-config --exists trexio` succeeds.
2. Install the OCaml binding from an OPAM switch:

   ```sh
   opam install trexio
   ```

   (a future release task adds the companion `conf-trexio` package to the OPAM
   repository; until the records are submitted, install from this repository,
   e.g. `opam pin add trexio <path-to-this-repo>` with the C library present.)

For a local, test-enabled install from a checkout:

```sh
opam install . --with-test
```

## Local development

```sh
# optional one-shot bootstrap of the TREXIO C library into a prefix
make bootstrap

# codegen (fetch the pinned release tarball -> trex.json -> read_json.py) + dune build
make

# run the test suite
make test

# install into the current OPAM switch
make install
```

> Note: the build toolchain in this repository (`setup.sh`/`Makefile`) is being
> finalized in the next release task; the `Makefile` currently present is the
> one imported from the previous location and will be rewritten.

### Prerequisites

- `gcc`, `cmake` (used to bootstrap the C library from the tarball)
- `pkg-config`
- HDF5 development headers
- `python3` (code generation runs during the build)
- `curl`
- `dune >= 3.1`, `dune-configurator`, `conf-pkg-config`

## Layout

```
dune-project               # package/version source of truth (see contract above)
trexio.opam                # OPAM record for the binding (rewritten in task 03)
conf-trexio.opam           # NEW: check package (pkg-config --exists trexio) — incoming
src/trexio.ml .mli .c      # hand-written binding *templates* (code-gen markers)
lib/dune, lib/config/*     # dune library + dune-configurator (strict pkg-config check)
read_json.py               # code generator: trex.json -> lib/trexio.ml|.mli|trexio_stubs.c
Makefile, setup.sh         # dev driver / bootstrap (setup.sh incoming)
```

## License

BSD-3-Clause (see [LICENSE](LICENSE)).
