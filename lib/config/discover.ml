module C = Configurator.V1

let () =
  C.main ~name:"trexio" (fun c ->
    let conf =
      match C.Pkg_config.get c with
      | None ->
          C.die "TREXIO C library not found.\n  Install it first (e.g. your distro package, conda-forge 'trexio', nix, or: ./setup.sh install-c-library <prefix>).  Then re-run dune (or opam install trexio)."
      | Some pc ->
          match C.Pkg_config.query pc ~package:"trexio" with
          | None -> C.die "pkg-config trexio: package not found"
          | Some deps -> deps
    in
    C.Flags.write_sexp "c_flags.sexp" conf.cflags;
    C.Flags.write_sexp "c_library_flags.sexp" conf.libs);;
