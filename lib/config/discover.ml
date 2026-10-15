(** Resolve the TREXIO C library:
    1. a system installation visible to pkg-config, API >= [floor]
       (system, conda, nix — via PKG_CONFIG_PATH);
    2. the [_c-prefix] tree the opam record's build step bootstrapped
       into the package root;
    3. the OPAM switch a previous record's install: populated.
    [floor] must track the opam record's --atleast-version gate. *)
module C = Configurator.V1

(** pkg-config output words (newlines -> spaces, so a trailing newline is
    not extracted as a spurious flag). *)
let words s =
  C.Flags.extract_blank_separated_words
    (String.map (fun c -> if c = '\n' then ' ' else c) s)

(** Required C API. *)
let floor = "2.6.1"

let pc_of prefix =
  Filename.concat (Filename.concat (Filename.concat prefix "lib") "pkgconfig") "trexio.pc"

(** Query the [trexio] module of an explicit .pc file. *)
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

(** The build step's [_c-prefix]: dune's action dir is the rule's build dir,
    not the package root, so probe candidate roots. *)
let local_conf c =
  let pc_of_root root = pc_of (Filename.concat root "_c-prefix") in
  (match List.find_opt (fun root -> Sys.file_exists (pc_of_root root))
          [ "."; ".."; "../../.." ]
   with None -> None
    | Some root -> Some (conf_from_pc c (pc_of_root root)))

(** The switch a previous [install:] populated: $OPAM_SWITCH_PREFIX, else
    derived from the toolchain (ocamlc -where = <prefix>/lib/ocaml). *)
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
  | Some s, _, _ -> s
  | _, Some s, _ -> s
  | _, _, Some s -> s
  | None, None, None ->
    C.die "TREXIO C library (API >= %s) not found; an opam build bootstraps it itself — for a manual build run ./setup.sh install-c-library <prefix> and point PKG_CONFIG_PATH at <prefix>/lib/pkgconfig."
      floor

let () =
  C.main ~name:"trexio" (fun c ->
      let conf = resolve c in
      C.Flags.write_sexp "c_flags.sexp" conf.cflags;
      C.Flags.write_sexp "c_library_flags.sexp" conf.libs);;
