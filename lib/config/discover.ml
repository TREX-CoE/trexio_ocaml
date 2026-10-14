module C = Configurator.V1

(** pkg-config prints space-separated words (e.g. `-L/x -ltrexio -lm`). *)
let words s = C.Flags.extract_blank_separated_words s

(** Fallback discovery for a TREXIO C library that conf-trexio installed into the
    current opam switch (its build step runs `setup.sh install-c-library
    <switch-prefix>`). Only consulted when pkg-config finds nothing on the default
    search paths (system/conda installs, or a PKG_CONFIG_PATH pointing at a
    ./setup.sh prefix). *)
let switch_conf c =
  let switch = Unix.getenv "OPAM_SWITCH_PREFIX" in (* Not_found if unset *)
  let pcdir = Filename.concat (Filename.concat switch "lib") "pkgconfig" in
  if not (Sys.file_exists (Filename.concat pcdir "trexio.pc")) then
    raise Not_found
  else
    let env = [ "PKG_CONFIG_PATH=" ^ pcdir ] in
    let cflags = C.Process.run c ~env "pkg-config" [ "--cflags"; "trexio" ] in
    let libs = C.Process.run c ~env "pkg-config" [ "--libs"; "trexio" ] in
    if cflags.exit_code <> 0 || libs.exit_code <> 0 then
      C.die "Found %s/trexio.pc (the conf-trexio bootstrap library) but pkg-config failed:\n%s"
        pcdir
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
             C.die "TREXIO C library not found.\n  Install it (./setup.sh install-c-library <prefix>) and set PKG_CONFIG_PATH=<prefix>/lib/pkgconfig, or run 'opam install trexio' so conf-trexio bootstraps it into the opam switch.")
    in
    C.Flags.write_sexp "c_flags.sexp" conf.cflags;
    C.Flags.write_sexp "c_library_flags.sexp" conf.libs);;
