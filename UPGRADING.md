# Upgrading to a new TREXIO C release

> **Audience:** maintainers. **Trigger:** a new TREXIO C release (the
> `watch-release` CI job warns). Upgrades are batched, not rushed: a binding
> that lags the newest C release is not broken — it does not expose it yet.

## Ground rules

- Follow the **released** C tarball only — never the C repository's `master`.
- Version `A.B.CNN` = C release `A.B.C` + revision `NN` (3-digit patch);
  `dune-project` is the source of truth, `trexio.opam` must agree (enforced
  by `read_json.py` and the `versions` CI job).
- The generated files (`lib/trexio.ml|.mli|.c`) and `trex.json` are
  **committed**; `./update.sh` is the only place that fetches or regenerates.
- The C release tarball is **vendored** in `external/` (+ `.sha256`): the
  bootstrap (`make bootstrap`, the `trexio` record at `opam install` time)
  is offline-first from it.
- **Never hand-edit `lib/`** — fix the `src/` templates or `read_json.py`.

## Step 1 — version + tarball

1. New C release `A.B.C` → first revision `A.B.001`; later binding-only
   fixes keep bumping the revision.
2. Write the version into `dune-project` and `trexio.opam` (the C tag is
   derived automatically: `2.7.001` → `v2.7.0`).
3. **Replace the vendored tarball** as `external/trexio-<Ctag>.tar.gz`
   (delete the old one) and regenerate its checksum:
   `cd external && sha256sum trexio-<Ctag>.tar.gz > trexio-<Ctag>.tar.gz.sha256`.
4. Do not commit yet.

## Step 2 — `./update.sh` (or `make update`)

Derives the C tag from `dune-project`, fetches the release tarball (cached
under `_fetch/`, **asserts the tarball's `AC_INIT` version equals the tag**),
refreshes `trex.json`, regenerates `lib/`, then runs `dune build @runtest` —
a broken regeneration, or an API change the tests rely on, fails **here**,
not in users' builds. Needs a pkg-config-resolvable C library: `make
bootstrap` provides `./_prefix`, picked up automatically.

## Step 3 — review the diff (the actual upgrade work)

```sh
git diff -- trex.json   # what the codes can read/write: fields per data type
git diff -- lib/        # what OCaml users get: the API surface
```

- **New C functions** → check the generated wrappers (types, argument order,
  error conventions) against the C header in the tarball.
- **Removed/renamed C functions** → user-visible API break: note it in the
  commit and any release announcement.
- **Signature changes** → check the `*_safe_*` contract in the tarball
  (buffer sizing, `size_index` semantics).
- **`trex.json` changes** → extend `tests/trexio_tests.ml`, keeping the
  invariants: `ao_num = 1000` (ERI indices fit `uint16` under HDF5), TEXT +
  HDF5 writers, byte + native runs.
- **Determinism:** for an unchanged C version, a fresh `./update.sh` must
  leave `lib/` + `trex.json` byte-identical; a non-empty diff is a generator
  regression, not a release.

## Step 4 — gate (before committing)

1. `dune build @runtest` green, and **no `SKIP HDF5`**.
2. `opam lint trexio.opam` clean.
3. Hermetic install from a clean switch (works without any system C
   library — the bootstrap leg):

   ```sh
   opam pin remove -y trexio 2>/dev/null || true
   opam pin add -y trexio .            # some opam versions install it here; harmless
   opam remove -y trexio 2>/dev/null || true
   rm -rf <switch>/.opam-switch/{build,backup,overlay}   # force a real build
   opam install -y --with-test trexio  # the pin makes this build the checkout
   ```

4. **Bootstrap test:** with no C library in scope, the record's build step
   must build the vendored tarball (log line `using vendored
   external/trexio-<V>.tar.gz`) and the suite must still pass — beware an
   ambient `PKG_CONFIG_PATH`/`LD_LIBRARY_PATH` pointing at a stray TREXIO.

## Step 5 — commit, tag, push

One commit: version bump (two files) + new `external/` tarball + `trex.json`
+ `lib/` + any test fixes. Local tag `vA.B.CNN` (informational). Push; CI
must be green, in particular the `versions` job and `watch-release`.

## Step 6 — publish (once the package is in the OPAM repository)

Human-only step: AI agents are forbidden to make PRs in the opam repository
(they may prepare everything locally so the human can proceed easily).

Open one PR to [ocaml/opam-repository](https://github.com/ocaml/opam-repository)
bumping the `trexio` record to the new version. That is the moment
`opam update && opam install trexio` reaches the new code for users.

## Variant: binding-only fix (no new C release)

Bump the revision in the two version files → `./update.sh` (expect **zero
diff** in `lib/` + `trex.json`) → make the fix → Steps 4–6.

## Invariants — keep in every upgrade

- No hand-editing the committed generated files in `lib/`.
- No network or python3 in the `opam install` path; the only C compilation
  there is the bootstrap of the vendored C library (skipped when a suitable
  system library is present).
- Released tarballs only; `dune-project` and `trexio.opam` always agree.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `update.sh` cannot fetch the release | tag not published yet (asset 404) — check the C repo's releases page. |
| `SKIP HDF5` in test output | C library in scope lacks HDF5 — `make bootstrap` or fix the env. Any `SKIP HDF5` is a gate failure. |
| opam says "synchronised (no changes)" and builds nothing | a stashed build tree was reused — do Step 4.3. |
| `watch-release` CI warning | time to run this procedure. |
