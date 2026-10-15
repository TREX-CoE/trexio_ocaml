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
 (description "TREXIO is a file format and library for wave functions and quantum-chemistry integrals.")
 (depends
  dune
  (dune-configurator :build)
  (conf-pkg-config :build)
  (odoc :with-doc))
 (tags
  ("Quantum chemistry" "Library"))
)

