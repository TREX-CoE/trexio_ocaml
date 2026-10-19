(* Round-trip test suite for the generated binding: one realistic
   write + read per backend (TEXT + HDF5), byte and native (dune),
   plus an `info` smoke. Mirrors the trexio-rs tests. *)

(* ------------------------------------------------------------------ helpers *)

let fail msg =
  Printf.eprintf "FAIL: %s\n%!" msg;
  exit 1

let expect_true b msg =
  if not b then fail msg

(* Whole-array == is physical identity: it would fail on fresh arrays. *)
let same a b =
  Array.length a = Array.length b && Array.for_all2 ( = ) a b

let expect_same label a b =
  if not (same a b) then
    fail (Printf.sprintf "%s: array mismatch (lengths %d vs %d)"
           label (Array.length a) (Array.length b))

(* ---------------------------------------------------------------- reference *)

let nucleus_num   = 12
let state_id      = 2
let charge_ref    = [| 6.; 6.; 6.; 6.; 6.; 6.; 1.; 1.; 1.; 1.; 1.; 1. |]
let coord_ref     = [|
  0.0;  1.39250319;  0.0;
  -1.20594314;  0.69625160;  0.0;
  -1.20594314; -0.69625160;  0.0;
  0.0; -1.39250319;   0.0;
  1.20594314; -0.69625160;  0.0;
  1.20594314;  0.69625160;  0.0;
  -2.14171677; 1.23652075;  0.0;
  -2.14171677; -1.23652075; 0.0;
  0.0; -2.47304151;   0.0;
  2.14171677; -1.23652075; 0.0;
  2.14171677;  1.23652075;  0.0;
  0.0;  2.47304151;   0.0 |]
let label_ref     = [| "C"; "Na"; "C"; "C 66"; "C"; "C"; "H 99"; "Ru"; "H"; "H"; "H"; "H" |]
let sym_str       = "B3U with some comments"
let ao_num        = 1000
let mo_num        = 150
let basis_shell_num = 24
let moi_ref       = Array.init 24 (fun i -> i)
let energy_ref    = Array.init mo_num (fun i -> float i -. 100.0)
let spin_ref      = Array.map (fun i -> if i < mo_num / 2 then 0 else 1) (Array.init mo_num (fun i -> i))

(* AO 2-electron integrals: 100 quadruplets (aabb), values 3.14 + i;
   ao_num = 1000 keeps 0-based indices valid for TEXT and HDF5. *)
let eri_nmax  = 100
let eri_ref   = Array.init eri_nmax (fun i ->
  (4 * i, 4 * i + 1, 4 * i + 2, 4 * i + 3, 3.14 +. float i))

(* 50 determinants with the Rust test's occupations; only decoders exist
   in this API, so build the bitfield bytes here (int_num = ceil(mo_num/64);
   word w carries 0-based orbitals 64w..64w+63). *)
let det_num   = 50
let int_num   = 3                       (* ceil(mo_num / 64) *)
let occ_up_ref = [ 0; 1; 2; 3; 75; 127; 128; 142 ]
let occ_dn_ref = [ 0; 2; 3; 79; 80; 138 ]

let bytes_of_occupations n_words occs =
  (* Host-endian int64 words: each word is serialized bit-patternwise into
     host byte order via Sys.big_endian (the OCaml stdlib has no
     Int64<->bytes conversion), which is exactly what the C library sees
     in the buffer on any platform. Bytes.init for zeros. *)
  let words = Array.make n_words 0L in
  let put_word (b : bytes) (off : int) (w : Int64.t) =
    for j = 0 to 7 do
      let k = if Sys.big_endian then 7 - j else j in (* 8-bit chunk of w that fills byte j *)
      Bytes.set b (off + j) (Char.chr
                  (Int64.to_int (Int64.logand (Int64.shift_right_logical w (8 * k)) 0xFFL)))
    done
  in
  let b = Bytes.init (n_words * 8) (fun _ -> Char.chr 0) in
  List.iter (fun occ ->
    if occ < 0 || occ >= n_words * 64 then
      fail (Printf.sprintf "bytes_of_occupations: orbital %d out of range [0, %d)"
             occ (n_words * 64));
    let word = occ / 64 in
    let bit  = occ mod 64 in
    words.(word) <- Int64.logor words.(word) (Int64.shift_left 1L bit)
  ) occs;
  for w = 0 to n_words - 1 do
    put_word b (8 * w) words.(w)
  done;
  b

let up_ref  = bytes_of_occupations int_num occ_up_ref
let dn_ref  = bytes_of_occupations int_num occ_dn_ref
let det_ref : (bytes * bytes) array =
  Array.make det_num (up_ref, dn_ref)

(* ---------------------------------------------------------------- write *)

(* Reads past the stored tail raise (TREXIO_END), so chunked writes keep
   growing offsets, as in the Rust test. *)
let write path backend =
  Printf.printf "-- write: %s\n%!" path;
  expect_true (not (Trexio.inquire_file path))
    (path ^ " should not exist before write");
  let f = Trexio.open_file path 'w' backend in
  ( expect_true (not (Trexio.has_nucleus f)) "has_nucleus must be false before write";
    expect_true (not (Trexio.has_nucleus_num f)) "has_nucleus_num must be false before write";
    expect_true (not (Trexio.has_nucleus_charge f)) "has_nucleus_charge must be false before write";
    expect_true (not (Trexio.has_ao_2e_int f)) "has_ao_2e_int must be false before write";
    expect_true (not (Trexio.has_ao_2e_int_eri f)) "has_ao_2e_int_eri must be false before write";
    expect_true (not (Trexio.has_determinant_list f)) "has_determinant_list must be false before write" );
  Trexio.write_nucleus_num f nucleus_num;
  Trexio.write_nucleus_charge f charge_ref;
  Trexio.write_nucleus_point_group f sym_str;
  Trexio.write_nucleus_coord f coord_ref;
  Trexio.write_nucleus_label f label_ref;
  Trexio.write_basis_shell_num f basis_shell_num;
  Trexio.write_basis_nucleus_index f moi_ref;
  Trexio.write_state_id f state_id;
  if not (Trexio.has_ao_num f) then Trexio.write_ao_num f ao_num;
  if not (Trexio.has_mo_num f) then Trexio.write_mo_num f mo_num;
  Trexio.write_mo_energy f energy_ref;
  Trexio.write_mo_spin f spin_ref;
  (* Integrals: 100 quadruplets, 5 chunks of 20, growing offset *)
  ( let bufsize = 20 in
    let rec loop offset =
      if offset >= eri_nmax then ()
      else
        let k = min bufsize (eri_nmax - offset) in
        Trexio.write_ao_2e_int_eri f ~offset (Array.sub eri_ref offset k);
        loop (offset + k)
    in
    loop 0 );
  Trexio.write_electron_up_num f 8;
  Trexio.write_electron_dn_num f 6;
  (* Determinants: 50, 5 chunks of 10, growing offset *)
  ( let bufsize = det_num / 5 in
    let rec loop offset =
      if offset >= det_num then ()
      else
        let k = min bufsize (det_num - offset) in
        Trexio.write_determinant_list f ~offset (Array.sub det_ref offset k);
        loop (offset + k)
    in
    loop 0 );
  Trexio.close_file f;
  ()

(* ------------------------------------------------------------------ read *)

(* Read [total] records in increments of <= [buffer_size]; each request
   must stay within the stored data (past-tail reads raise). *)
let read_chunks read total buffer_size =
  let rec loop offset chunks =
    if offset >= total then
      let chunks = List.rev chunks in
      let first = List.hd chunks in
      let len = List.fold_left (fun n c -> n + Array.length c) 0 chunks in
      let out = Array.make len (Array.get first 0) in
      let pos = ref 0 in
      List.iter (fun c ->
          Array.blit c 0 out !pos (Array.length c);
          pos := !pos + Array.length c
        ) chunks;
      out
    else
      let k = min buffer_size (total - offset) in
      let chunk = read offset k in
      if Array.length chunk <> k then
        fail (Printf.sprintf "read_chunks at offset %d: expected %d records, got %d"
               offset k (Array.length chunk));
      loop (offset + k) (chunk :: chunks)
  in
  loop 0 []

(* Host-endian 8-byte buffers -> Int64 words: the buffer order is the
   one the C library uses for the TREXIO on-disk int64 layout on any
   platform, so decode it with the same Sys.big_endian-aware chunk
   order as [bytes_of_occupations] uses when writing (the OCaml
   stdlib has no Int64<->bytes conversion). *)
let int64_words (b : bytes) : Int64.t array =
  let n = Bytes.length b / 8 in
  let a = Array.make n 0L in
  for i = 0 to n - 1 do
    let off = 8 * i in
    let w = ref 0L in
    for j = 0 to 7 do
      let k = if Sys.big_endian then 7 - j else j in
      w := Int64.logor !w
           (Int64.shift_left (Int64.of_int (Char.code (Bytes.get b (off + j)))) (8 * k))
    done;
    a.(i) <- !w
  done;
  a

let read fname backend =
  Printf.printf "-- read: %s\n%!" fname;
  expect_true (Trexio.inquire_file fname) (fname ^ " should exist before read");
  let f = Trexio.open_file fname 'r' backend in
  ( expect_true (Trexio.has_nucleus f) "has_nucleus must be true after write";
    expect_true (Trexio.has_nucleus_num f) "has_nucleus_num must be true after write";
    expect_true (Trexio.has_nucleus_charge f) "has_nucleus_charge must be true after write";
    expect_true (Trexio.has_ao_2e_int f) "has_ao_2e_int must be true after write";
    expect_true (Trexio.has_ao_2e_int_eri f) "has_ao_2e_int_eri must be true after write";
    expect_true (Trexio.has_determinant_list f) "has_determinant_list must be true after write" );
  expect_true (Trexio.read_nucleus_num f = nucleus_num)
    (Printf.sprintf "read_nucleus_num: expected %d, got %d" nucleus_num (Trexio.read_nucleus_num f));
  expect_true (Trexio.read_nucleus_point_group ~max_str_len:64 f = sym_str)
    (Printf.sprintf "read_nucleus_point_group: expected %S, got %S"
       sym_str (Trexio.read_nucleus_point_group ~max_str_len:64 f));
  expect_same "read_nucleus_charge" (Trexio.read_nucleus_charge f) charge_ref;
  expect_same "read_nucleus_coord" (Trexio.read_nucleus_coord f) coord_ref;
  expect_same "read_nucleus_label"
    (Trexio.read_nucleus_label ~max_str_len:6 f) label_ref;
  expect_true (Trexio.read_basis_shell_num f = basis_shell_num)
    (Printf.sprintf "read_basis_shell_num: expected %d, got %d" basis_shell_num (Trexio.read_basis_shell_num f));
  expect_same "read_basis_nucleus_index" (Trexio.read_basis_nucleus_index f) moi_ref;
  expect_true (Trexio.read_state_id f = state_id)
    (Printf.sprintf "read_state_id: expected %d, got %d" state_id (Trexio.read_state_id f));
  expect_true (Trexio.read_ao_num f = ao_num)
    (Printf.sprintf "read_ao_num: expected %d, got %d" ao_num (Trexio.read_ao_num f));
  expect_true (Trexio.read_mo_num f = mo_num)
    (Printf.sprintf "read_mo_num: expected %d, got %d" mo_num (Trexio.read_mo_num f));
  expect_same "read_mo_energy" (Trexio.read_mo_energy f) energy_ref;
  expect_same "read_mo_spin" (Trexio.read_mo_spin f) spin_ref;
  (* Integrals: 5 chunks (4x22 + 12), reassembled and compared. *)
  let eri =
    read_chunks
      (fun offset k -> Trexio.read_ao_2e_int_eri f ~offset ~buffer_size:k)
      eri_nmax 22
  in
  expect_true (Array.length eri = eri_nmax)
    (Printf.sprintf "ao_2e_int_eri: expected %d quadruplets, got %d" eri_nmax (Array.length eri));
  ( let same = Array.length eri = Array.length eri_ref &&
                 Array.for_all2 (fun e r ->
                    match e, r with
                    | (a, b, c, d, v), (a', b', c', d', v') ->
                      a = a' && b = b' && c = c' && d = d' && v = v'
                ) eri eri_ref
    in
    if not same then fail "ao_2e_int_eri: quadruplets differ from the reference" );
  (* Determinants *)
  expect_true (Trexio.read_determinant_num f = det_num)
    (Printf.sprintf "read_determinant_num: expected %d, got %d" det_num (Trexio.read_determinant_num f));
  let det_list =
    read_chunks
      (fun offset k -> Trexio.read_determinant_list f ~offset ~buffer_size:k)
      det_num 20
  in
  expect_true (Array.length det_list = det_num)
    (Printf.sprintf "determinant_list: expected %d determinants, got %d"
       det_num (Array.length det_list));
  (* Per entry: raw-byte equality with the reference, and decoded
     occupation lists equal to the reference (all 50, it is cheap). *)
  let (up_occ, dn_occ) = Trexio.to_orbital_list_up_dn (int64_words up_ref, int64_words dn_ref) in
  expect_true (up_occ = occ_up_ref)
    (Printf.sprintf "to_orbital_list_up_dn (up): expected [%s], got [%s]"
       (String.concat "; " (List.map string_of_int occ_up_ref))
       (String.concat "; " (List.map string_of_int up_occ)));
  expect_true (dn_occ = occ_dn_ref)
    (Printf.sprintf "to_orbital_list_up_dn (dn): expected [%s]"
       (String.concat "; " (List.map string_of_int occ_dn_ref)));
  Array.iteri (fun i (up, dn) ->
    if up <> up_ref then
      fail (Printf.sprintf "determinant %d: up-spin bitfield bytes differ from reference" i);
    if dn <> dn_ref then
      fail (Printf.sprintf "determinant %d: dn-spin bitfield bytes differ from reference" i);
    let (u, d) = Trexio.to_orbital_list_up_dn (int64_words up, int64_words dn) in
    if u <> occ_up_ref then
      fail (Printf.sprintf "determinant %d: decoded up occupations %s != [%s]"
             i (String.concat ";" (List.map string_of_int u))
             (String.concat ";" (List.map string_of_int occ_up_ref)));
    if d <> occ_dn_ref then
      fail (Printf.sprintf "determinant %d: decoded dn occupations %s != [%s]"
             i (String.concat ";" (List.map string_of_int d))
             (String.concat ";" (List.map string_of_int occ_dn_ref)))
  ) det_list;
  Trexio.close_file f;
  ()

(* ---------------------------------------------------------------- entry *)

(* Per-pid tmp dir: the byte and native binaries run in parallel. *)
let dir = Filename.concat (Sys.getcwd ()) (Printf.sprintf "tmp_%d" (Unix.getpid ()))
let text_file = Filename.concat dir "test_write.dir"
let h5_file = Filename.concat dir "test_write.hdf5"

let () =
  Printf.printf "CWD: %s\n%!" (Sys.getcwd ());
  let _ = Trexio.info () in                      (* smoke *)
  let _ = Sys.command (Printf.sprintf "rm -f %s" h5_file) in
  let _ = Sys.command (Printf.sprintf "rm -rf %s" text_file) in
  let _ = (try Sys.mkdir dir 0o755 with Sys_error _ -> ()) in
  ( write text_file Trexio.TEXT; read text_file Trexio.TEXT )   (* must pass *)
  ;
  ( try (write h5_file Trexio.HDF5; read h5_file Trexio.HDF5)
    with Failure msg -> Printf.eprintf "SKIP HDF5 (C library without HDF5?): %s\n%!" msg )
  ;
  Printf.printf "TREXIO OCAML TESTS: OK\n"
