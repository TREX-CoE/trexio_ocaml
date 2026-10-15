(** Resolve the TREXIO C library for the binding build.
    Preference order, with the API floor enforced on the system path:
    1. a system installation visible to pkg-config with API >= [floor]
       (system, conda, nix — via PKG_CONFIG_PATH);
    2. the [_c-prefix] tree the opam record's build step bootstrapped into
       the package root (machines without a suitable system library);
    3. the OPAM switch a previous record [install:] populated
       ($OPAM_SWITCH_PREFIX, or derived from the toolchain when the
       variable is not exported).

    [floor] must stay in sync with the gate
    "pkg-config --atleast-version=<floor> trexio" in the .opam records. *)
module C = Configurator.V1

(** Words of raw pkg-config output; newlines become spaces, otherwise a
    trailing newline would be extracted as a spurious flag token. *)
let words s =
  C.Flags.extract_blank_separated_words
    (String.map (fun c -> if c = '\n' then ' ' else c) s)

(** C API floor required by the generated stubs. *)
let floor = "2.6.1"

let pc_of prefix =
  Filename.concat (Filename.concat (Filename.concat prefix "lib") "pkgconfig") "trexio.pc"

(** Query the [trexio] module from an explicit .pc file. *)
let conf_from_pc c pc =
  let env = [ "PKG_CONFIG_PATH=" ^ Filename.dirname pc ] in
  let cflags = C.Process.run c ~env "pkg-config" [ "--cflags"; "trexio" ] in
  let libs = C.Process.run c ~env "pkg-config" [ "--libs"; "trexio" ] in
  if cflags.exit_code <> 0 || libs.exit_code <> 0 then
    C.die "Found %s but pkg-config failed reading it:\n%s" pc
      (if cflags.exit_code <> 0 then cflags.stderr else libs.stderr);
  { C.Pkg_config.libs = words libs.stdout; cflags = words cflags.stdout }

(** [Some conf] when pkg-config sees a [trexio] with the API floor. *)
let system_conf c =
  let ok = C.Process.run c "pkg-config" [ "--atleast-version=" ^ floor; "trexio" ] in
  if ok.exit_code <> 0 then None
  else
    (match C.Pkg_config.get c
     with None -> None
      | Some pc -> C.Pkg_config.query pc ~package:"trexio")

(** The opam record's build step bootstraps the C library into [_c-prefix]
    under the package root. This script runs from dune's action directory
    ([<root>/_build/default/lib] in the out-of-source layout, [<root>/lib]
    in-place), so probe the candidate roots. *)
let local_conf c =
  let pc_of_root root = pc_of (Filename.concat root "_c-prefix") in
  (match List.find_opt (fun root -> Sys.file_exists (pc_of_root root))
         [ "."; ".."; "../../.." ]
   with None -> None
    | Some root -> Some (conf_from_pc c (pc_of_root root)))

(** The OPAM switch a previous [install:] populated: $OPAM_SWITCH_PREFIX if
    it holds a bootstrapped .pc, else derived from the toolchain
    (`ocamlc -where` = <prefix>/lib/ocaml) when the variable is not
    exported. *)
let switch_conf c =
  let explicit = try [ Unix.getenv "OPAM_SWITCH_PREFIX" ] with Not_found -> [] in
  let derived =
    match C.Process.run c "ocamlc" [ "-where" ] with
    | r when r.exit_code <> 0 -> []
    | r ->
      (match String.split_on_char '\n' r.stdout with
       | [] -> []
       | lib :: _ -> [ Filename.dirname (Filename.dirname lib) ])
  in
  (match List.find_opt (fun p -> Sys.file_exists (pc_of p)) (explicit @ derived)
   with None -> None
    | Some prefix -> Some (conf_from_pc c (pc_of prefix)))

let resolve c =
  match (system_conf c, local_conf c, switch_conf c) with
  | Some conf, _, _ -> conf
  | None, Some conf, _ -> conf
  | None, None, Some conf -> conf
  | None, None, None ->
    C.die
      "TREXIO C library (API %s or newer) not found.\n  The opam record bootstraps the vendored C library into _c-prefix (build:) and into the switch (install:); for a manual build run ./setup.sh install-c-library <prefix> and point PKG_CONFIG_PATH at <prefix>/lib/pkgconfig."
      floor

let () =
  C.main ~name:"trexio" (fun c ->
      let conf = resolve c in
      C.Flags.write_sexp "c_flags.sexp" conf.cflags;
      C.Flags.write_sexp "c_library_flags.sexp" conf.libs);;
