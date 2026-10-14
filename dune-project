(lang dune 3.1)

(name trexio)
(version 2.6.101)

(generate_opam_files false)

(source
 (github trex-coe/trexio_ocaml))

(authors
  "Anthony Scemama <scemama@irsamc.ups-tlse.fr>"
  "Evgeny Posenitskiy <posenitskiy@irsamc.ups-tlse.fr>"
)

(maintainers
  "Anthony Scemama <scemama@irsamc.ups-tlse.fr>"
)

(license "BSD-3-Clause")

(documentation "https://trex-coe.github.io/trexio/")

(package
 (name trexio)
 (synopsis "Binding for the TREXIO Input/Output library")
 (description "TREXIO is a file format and library for storing wave functions and integrals for quantum chemistry.")
 (depends
  dune
  (dune-configurator :build)
  (conf-pkg-config :build)
  conf-trexio
  (odoc :with-doc))
 (tags
  ("Quantum chemistry" "Library"))
)

(package
 (name conf-trexio)
 (synopsis "TREXIO C library: present (system) or bootstrapped from the vendored source")
 (description "Ensures the TREXIO C library (headers + libtrexio) is discoverable by pkg-config: uses the system/conda copy if present, otherwise builds the vendored external/trexio-2.6.1.tar.gz statically into the opam switch via setup.sh.")
 (allow_empty)
 (depends (conf-pkg-config :build) (conf-gcc :build)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
