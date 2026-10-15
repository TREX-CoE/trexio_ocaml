module C = Configurator.V1

(** Words of raw pkg-config output; newlines become spaces, otherwise a
    trailing newline would be extracted as a spurious flag token. *)
let words s =
  C.Flags.extract_blank_separated_words
    (String.map (fun c -> if c = '\n' then ' ' else c) s)

(** <switch>/lib/pkgconfig/trexio.pc *)
let pc_of prefix =
  Filename.concat (Filename.concat (Filename.concat prefix "lib") "pkgconfig") "trexio.pc"

(** The switch that conf-trexio installed the C library into:
    $OPAM_SWITCH_PREFIX if it holds a bootstrapped .pc, else derived from
    the toolchain (`ocamlc -where` = <prefix>/lib/ocaml) when the variable
    is not exported. Not_found if no bootstrapped library exists. *)
let switch_prefix c =
  let explicit = try [ Unix.getenv "OPAM_SWITCH_PREFIX" ] with Not_found -> [] in
  let derived =
    match C.Process.run c "ocamlc" [ "-where" ] with
    | r when r.exit_code <> 0 -> []
    | r ->
        match String.split_on_char '\n' r.stdout with
        | [] -> []
        | lib :: _ -> [ Filename.dirname (Filename.dirname lib) ]
  in
  match List.find_opt (fun p -> Sys.file_exists (pc_of p)) (explicit @ derived) with
  | Some prefix -> prefix
  | None -> raise Not_found

(** Fallback for the C library that conf-trexio installed into the switch —
    used only when pkg-config finds nothing on the usual paths. *)
let switch_conf c =
  let prefix = switch_prefix c in
  let pc = pc_of prefix in
  let env = [ "PKG_CONFIG_PATH=" ^ Filename.dirname pc ] in
  let cflags = C.Process.run c ~env "pkg-config" [ "--cflags"; "trexio" ] in
  let libs = C.Process.run c ~env "pkg-config" [ "--libs"; "trexio" ] in
  if cflags.exit_code <> 0 || libs.exit_code <> 0 then
    C.die "Found %s (the conf-trexio bootstrap library) but pkg-config failed:\n%s"
      pc
      (if cflags.exit_code <> 0 then cflags.stderr else libs.stderr);
  let conf : C.Pkg_config.package_conf =
    { libs = words libs.stdout; cflags = words cflags.stdout } in
  conf

let () =
  C.main ~name:"trexio" (fun c ->
    let system_conf =
      match C.Pkg_config.get c with
      | None -> None
      | Some pc -> C.Pkg_config.query pc ~package:"trexio"
    in
    let conf =
      match system_conf with
      | Some deps -> deps
      | None ->
          (try switch_conf c
           with Not_found ->
             C.die "TREXIO C library not found.\n  Install one, or run 'opam install trexio' so conf-trexio bootstraps it into the opam switch.")
    in
    C.Flags.write_sexp "c_flags.sexp" conf.cflags;
    C.Flags.write_sexp "c_library_flags.sexp" conf.libs);;
