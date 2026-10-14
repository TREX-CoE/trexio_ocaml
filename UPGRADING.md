# Upgrading the binding to a new TREXIO C release

> **Audience:** the maintainer(s) of this OCaml binding.
>
> **Trigger:** a new TREXIO C release has been published. The `watch-release` CI
> job warns when the C version pinned here is strictly older than the latest
> upstream release. Upgrades are batched, not rushed: a binding that lags behind
> the newest C release is not broken — it simply does not expose it yet.

## How this repository works (read once)

- The binding follows the **released** TREXIO C tarball — never the C repository's
  `master`.
- Versioning convention (same as the TREXIO Rust binding):
  **binding version `A.B.CNN` = C library release `A.B.C` + binding revision `NN`**.
  The patch component is always ≥ 3 digits (i.e. ≥ 100). `dune-project` is the
  single source of truth; `trexio.opam` and `conf-trexio.opam` must state *exactly
  the same* version (enforced by `read_json.py` at generation time and by the
  `versions` CI job).
- The generated files (`lib/trexio.ml`, `lib/trexio.mli`, `lib/trexio_stubs.c`)
  and the generator input (`trex.json`) are **committed**. `./update.sh` is the
  *only* place that fetches or regenerates anything; `opam install .` needs
  neither network access nor python3.
- The TREXIO C release tarball is **vendored** in `external/` (plus its
  `.sha256`) as the offline source for the C-library *bootstrap* builds —
  `make bootstrap` and the `conf-trexio` bootstrap at `opam install` time,
  which are offline-first from that tarball. `./update.sh` (the regeneration
  flow) still fetches the release tarball over the network (cached under
  `_fetch/`).

## Step 1 — Choose the new binding version and write it down

1. New C release `A.B.C` (e.g. `2.7.0`) → first revision is **`A.B.001`**
   (e.g. `2.7.001`). Later binding-only fixes against the *same* C release
   keep bumping the revision (`...002`, `...003`, …).
2. Write that version into all **three** files: `dune-project`, `trexio.opam`,
   `conf-trexio.opam`. (The C tag is derived automatically from `dune-project`:
   `2.7.001` → `v2.7.0`.)
3. **Replace the vendored C tarball**: store the new release-asset tarball as
   `external/trexio-<Ctag>.tar.gz` (replacing the previous one) and regenerate
   its checksum:
   `cd external && sha256sum trexio-<Ctag>.tar.gz > trexio-<Ctag>.tar.gz.sha256`.
4. Do not commit yet.

## Step 2 — Regenerate and build: `./update.sh` (or `make update`)

What happens, step by step (every step fails loudly):

1. Derives the C tag from `dune-project` (e.g. `2.7.001` → `2.7.0`).
2. Fetches the release tarball (release asset first, source archive as
   fallback), cached under `_fetch/`; **asserts the tarball's own `AC_INIT`
   version equals the derived tag** — a mismatch is a hard stop.
3. Refreshes the committed `trex.json` from the tarball.
4. `python3 read_json.py` regenerates `lib/trexio.ml|.mli|.c`
   (re-validates the three version files again).
5. `dune build @runtest` — byte **and** native, TEXT **and** HDF5 round-trips.
   A broken regeneration, or a C API change the tests rely on, **fails here**,
   not in users' builds.

Prerequisites: `curl`, `tar`, `python3`, `dune`, plus a TREXIO C library
resolvable via pkg-config. On a dev box: `./setup.sh install-c-library _prefix`
(`make bootstrap`) — `update.sh` picks up `./_prefix` automatically.

## Step 3 — Review the diff (this is the actual upgrade work)

```sh
git diff -- trex.json   # what the codes can read/write: field set per data type
git diff -- lib/        # what OCaml users get: the binding's API surface
```

- **New C functions** → new OCaml wrappers appear. Spot-check the generated
  types, argument order, and error conventions against the C header in the
  fetched tarball.
- **Removed / renamed C functions** → the OCaml surface *shrinks*. That is a
  user-visible API break: note it in the commit message and in any release
  announcement.
- **Signature changes** → verify the stub and any `*_safe_*` contract in the
  same tarball (buffer sizing, `size_index` semantics; the generator emits size
  checks scaled by rank, e.g. 4× for ERI quadruplets).
- **`trex.json` changes** → extend the test suite (`tests/trexio_tests.ml`):
  new round-trip fields, new data types. Keep the established invariants:
  `ao_num = 1000` (so ERI indices round-trip as `uint16` under HDF5, where
  `uint8` would not fit), both TEXT and HDF5 writers, byte + native runs.
- **Determinism check (important):** regeneration is deterministic. If the C
  version did *not* change, a fresh `./update.sh` must leave `lib/` and
  `trex.json` byte-identical (zero diff). A non-empty diff on an unchanged C
  release is a generator regression, not a release.
- **Never hand-edit `lib/trexio.ml|.mli|.c`** — they are overwritten by the next
  `update.sh`. Bugs in binding code belong in the `src/` templates or in
  `read_json.py`, then regenerate.

## Step 4 — Gate: full verification before committing

1. `dune build @runtest` — already run by `update.sh`; must be green (and
   `SKIP HDF5` must never appear).
2. `opam lint trexio.opam conf-trexio.opam` — clean.
3. **Hermetic install with a true build**, C library resolvable via pkg-config,
   no network needed:

   ```sh
   opam remove -y trexio conf-trexio
   rm -rf <switch>/.opam-switch/{build,backup,overlay}   # force a real build
   opam install . --with-test -y
   ```

   (opam silently reuses stashed build trees — the `rm -rf` is what prevents a
   "build" that never built.)
4. **Negative test:** with no C library in scope
   (`env -u PKG_CONFIG_PATH -u LD_LIBRARY_PATH`, clean environment), the build
   must **fail** at `conf-trexio` (`pkg-config --exists trexio`). Beware: an
   ambient `PKG_CONFIG_PATH`/`LD_LIBRARY_PATH` pointing at some stray TREXIO
   makes this test pass for the wrong reason.

## Step 5 — Commit, tag, push

- One commit: the version bump (three files) + `trex.json` + `lib/` + any test
  updates as a single change. Suggested message:
  `update to TREXIO C 2.7.0 (binding 2.7.001)`.
- Local tag `v2.7.001` — purely informational (this repo does not use
  `dune subst`; the tag does not rewrite versions).
- Push; CI must go green — in particular the `versions` job (3-digit patch
  component + all three version files agree) and `watch-release` (the pinned
  C version now equals the latest, so its warning clears).

## Step 6 — Publish (once the package is in the OPAM repository)

Important: This section has to be done by a human. AI agents are forbidden to
make PRs in the opam repository. AI agents can suggest instructions to humans,
and potentially prepare everything on the local machine, so that humans can
proceed easly with this step.

Open a PR to the OPAM repository [ocaml/opam-repository](https://github.com/ocaml/opam-repository)
bumping **both** records — `trexio` *and*
`conf-trexio` — to the new version, together, in one PR. That is the moment
`opam update && opam install trexio` reaches the new code for users.

(If the records are not published yet, the upgrade is simply part of the
initial submission of both records.)

## Variant: binding-only fixes (no new C release)

1. Bump the revision only, in the three version files
   (e.g. `2.6.101` → `2.6.102`).
2. `./update.sh` — re-fetches the *same* C tarball; expect **zero diff** in
   `lib/` and `trex.json` (otherwise go back to the determinism check above).
3. Make the fix (generator / `src/` templates / tests), re-run `./update.sh`,
   pass the Step 4 gate, then Steps 5–6.

## Invariants — keep in every upgrade

- Never hand-edit the committed generated files in `lib/`.
- Never introduce network, python3, or C compilation into the
  `opam install .` path.
- Never follow the C repository's `master`; released tarballs only.
- Never let `dune-project`, `trexio.opam`, and `conf-trexio.opam` disagree.

## Troubleshooting

| Symptom | Meaning / fix |
|---|---|
| `update.sh: tarball … reports version … refusing to proceed` | stale `_fetch/` cache — `rm -rf _fetch/trexio-<V>` and re-run. |
| `update.sh` cannot fetch the release | tag is not a published release yet (asset **and** source archive 404) — check the C repo's releases page first. |
| `SKIP HDF5` in test output | the C library in scope lacks HDF5 — rebuild it (`make bootstrap`) or fix the environment. Any `SKIP HDF5` is a gate failure. |
| tests racing on a shared temp file | the suite uses per-PID test dirs; don't reintroduce shared paths in new tests. |
| opam reports "synchronised (no changes)" and builds nothing | opam reused a stashed build tree — force a real build (Step 4.3). |
| `watch-release` CI warning | time to run this procedure. |
