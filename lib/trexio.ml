
type trexio_file

type trexio_exit_code = int

type trexio_backend =
| HDF5
| TEXT
| AUTO

type index = int
type dim   = int

external open_file : string -> char -> trexio_backend -> trexio_file = "caml_open_file"
external close_file : trexio_file -> unit = "caml_close_file"
external inquire_file : string -> bool = "caml_inquire_file"
external set_one_based : trexio_file -> unit = "caml_set_one_based"
external get_state : trexio_file -> int = "caml_get_state"
external set_state : trexio_file -> int -> unit = "caml_set_state"
external info : unit -> unit = "caml_info"

external to_orbital_list : Int64.t array -> int list = "caml_to_orbital_list"


external delete_metadata: trexio_file -> unit = "caml_delete_metadata"
external has_metadata_code_num: trexio_file -> bool = "caml_has_metadata_code_num"
external read_metadata_code_num : trexio_file -> dim = "caml_read_metadata_code_num"
external write_metadata_code_num: trexio_file -> dim -> unit = "caml_write_metadata_code_num"
external has_metadata_code: trexio_file -> bool = "caml_has_metadata_code"
external read_safe_metadata_code : trexio_file -> int -> int -> string array = "caml_read_safe_metadata_code"
external write_safe_metadata_code: trexio_file -> int -> int -> string array -> unit = "caml_write_safe_metadata_code"
let read_metadata_code ?(max_str_len=1024) f = 
  let size = 1 in 
  let size = size * read_metadata_code_num f in
  read_safe_metadata_code f size max_str_len

let write_metadata_code f a = 
  let size = 1 in 
  let max_str_len = Array.map String.length a
      |> Array.fold_left (fun x y -> if x>y then x else y) 0
      |> (+) 1 in
  let size = size * read_metadata_code_num f in
  write_safe_metadata_code f size max_str_len a

external has_metadata_author_num: trexio_file -> bool = "caml_has_metadata_author_num"
external read_metadata_author_num : trexio_file -> dim = "caml_read_metadata_author_num"
external write_metadata_author_num: trexio_file -> dim -> unit = "caml_write_metadata_author_num"
external has_metadata_author: trexio_file -> bool = "caml_has_metadata_author"
external read_safe_metadata_author : trexio_file -> int -> int -> string array = "caml_read_safe_metadata_author"
external write_safe_metadata_author: trexio_file -> int -> int -> string array -> unit = "caml_write_safe_metadata_author"
let read_metadata_author ?(max_str_len=1024) f = 
  let size = 1 in 
  let size = size * read_metadata_author_num f in
  read_safe_metadata_author f size max_str_len

let write_metadata_author f a = 
  let size = 1 in 
  let max_str_len = Array.map String.length a
      |> Array.fold_left (fun x y -> if x>y then x else y) 0
      |> (+) 1 in
  let size = size * read_metadata_author_num f in
  write_safe_metadata_author f size max_str_len a

external has_metadata_package_version: trexio_file -> bool = "caml_has_metadata_package_version"
external read_metadata_package_version_c : trexio_file -> int -> string = "caml_read_metadata_package_version"
let read_metadata_package_version ?(max_str_len=8192) f = read_metadata_package_version_c f max_str_len
external write_metadata_package_version: trexio_file -> string -> unit = "caml_write_metadata_package_version"
external has_metadata_description: trexio_file -> bool = "caml_has_metadata_description"
external read_metadata_description_c : trexio_file -> int -> string = "caml_read_metadata_description"
let read_metadata_description ?(max_str_len=8192) f = read_metadata_description_c f max_str_len
external write_metadata_description: trexio_file -> string -> unit = "caml_write_metadata_description"
external has_metadata_unsafe: trexio_file -> bool = "caml_has_metadata_unsafe"
external read_metadata_unsafe : trexio_file -> int = "caml_read_metadata_unsafe"
external write_metadata_unsafe: trexio_file -> int -> unit = "caml_write_metadata_unsafe"
external delete_electron: trexio_file -> unit = "caml_delete_electron"
external has_electron_num: trexio_file -> bool = "caml_has_electron_num"
external read_electron_num : trexio_file -> dim = "caml_read_electron_num"
external write_electron_num: trexio_file -> dim -> unit = "caml_write_electron_num"
external has_electron_up_num: trexio_file -> bool = "caml_has_electron_up_num"
external read_electron_up_num : trexio_file -> int = "caml_read_electron_up_num"
external write_electron_up_num: trexio_file -> int -> unit = "caml_write_electron_up_num"
external has_electron_dn_num: trexio_file -> bool = "caml_has_electron_dn_num"
external read_electron_dn_num : trexio_file -> int = "caml_read_electron_dn_num"
external write_electron_dn_num: trexio_file -> int -> unit = "caml_write_electron_dn_num"
external delete_nucleus: trexio_file -> unit = "caml_delete_nucleus"
external has_nucleus_num: trexio_file -> bool = "caml_has_nucleus_num"
external read_nucleus_num : trexio_file -> dim = "caml_read_nucleus_num"
external write_nucleus_num: trexio_file -> dim -> unit = "caml_write_nucleus_num"
external has_nucleus_charge: trexio_file -> bool = "caml_has_nucleus_charge"
external read_safe_nucleus_charge : trexio_file -> int -> float array = "caml_read_safe_nucleus_charge"
external write_safe_nucleus_charge: trexio_file -> int -> float array -> unit = "caml_write_safe_nucleus_charge"
let read_nucleus_charge f = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  read_safe_nucleus_charge f size

let write_nucleus_charge f a = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  write_safe_nucleus_charge f size a

external has_nucleus_coord: trexio_file -> bool = "caml_has_nucleus_coord"
external read_safe_nucleus_coord : trexio_file -> int -> float array = "caml_read_safe_nucleus_coord"
external write_safe_nucleus_coord: trexio_file -> int -> float array -> unit = "caml_write_safe_nucleus_coord"
let read_nucleus_coord f = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  let size = size * 3 in
  read_safe_nucleus_coord f size

let write_nucleus_coord f a = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  let size = size * 3 in
  write_safe_nucleus_coord f size a

external has_nucleus_label: trexio_file -> bool = "caml_has_nucleus_label"
external read_safe_nucleus_label : trexio_file -> int -> int -> string array = "caml_read_safe_nucleus_label"
external write_safe_nucleus_label: trexio_file -> int -> int -> string array -> unit = "caml_write_safe_nucleus_label"
let read_nucleus_label ?(max_str_len=1024) f = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  read_safe_nucleus_label f size max_str_len

let write_nucleus_label f a = 
  let size = 1 in 
  let max_str_len = Array.map String.length a
      |> Array.fold_left (fun x y -> if x>y then x else y) 0
      |> (+) 1 in
  let size = size * read_nucleus_num f in
  write_safe_nucleus_label f size max_str_len a

external has_nucleus_point_group: trexio_file -> bool = "caml_has_nucleus_point_group"
external read_nucleus_point_group_c : trexio_file -> int -> string = "caml_read_nucleus_point_group"
let read_nucleus_point_group ?(max_str_len=8192) f = read_nucleus_point_group_c f max_str_len
external write_nucleus_point_group: trexio_file -> string -> unit = "caml_write_nucleus_point_group"
external has_nucleus_repulsion: trexio_file -> bool = "caml_has_nucleus_repulsion"
external read_nucleus_repulsion : trexio_file -> float = "caml_read_nucleus_repulsion"
external write_nucleus_repulsion: trexio_file -> float -> unit = "caml_write_nucleus_repulsion"
external delete_ecp: trexio_file -> unit = "caml_delete_ecp"
external has_ecp_max_ang_mom_plus_1: trexio_file -> bool = "caml_has_ecp_max_ang_mom_plus_1"
external read_safe_ecp_max_ang_mom_plus_1 : trexio_file -> int -> int array = "caml_read_safe_ecp_max_ang_mom_plus_1"
external write_safe_ecp_max_ang_mom_plus_1: trexio_file -> int -> int array -> unit = "caml_write_safe_ecp_max_ang_mom_plus_1"
let read_ecp_max_ang_mom_plus_1 f = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  read_safe_ecp_max_ang_mom_plus_1 f size

let write_ecp_max_ang_mom_plus_1 f a = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  write_safe_ecp_max_ang_mom_plus_1 f size a

external has_ecp_z_core: trexio_file -> bool = "caml_has_ecp_z_core"
external read_safe_ecp_z_core : trexio_file -> int -> int array = "caml_read_safe_ecp_z_core"
external write_safe_ecp_z_core: trexio_file -> int -> int array -> unit = "caml_write_safe_ecp_z_core"
let read_ecp_z_core f = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  read_safe_ecp_z_core f size

let write_ecp_z_core f a = 
  let size = 1 in 
  let size = size * read_nucleus_num f in
  write_safe_ecp_z_core f size a

external has_ecp_num: trexio_file -> bool = "caml_has_ecp_num"
external read_ecp_num : trexio_file -> dim = "caml_read_ecp_num"
external write_ecp_num: trexio_file -> dim -> unit = "caml_write_ecp_num"
external has_ecp_ang_mom: trexio_file -> bool = "caml_has_ecp_ang_mom"
external read_safe_ecp_ang_mom : trexio_file -> int -> int array = "caml_read_safe_ecp_ang_mom"
external write_safe_ecp_ang_mom: trexio_file -> int -> int array -> unit = "caml_write_safe_ecp_ang_mom"
let read_ecp_ang_mom f = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  read_safe_ecp_ang_mom f size

let write_ecp_ang_mom f a = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  write_safe_ecp_ang_mom f size a

external has_ecp_nucleus_index: trexio_file -> bool = "caml_has_ecp_nucleus_index"
external read_safe_ecp_nucleus_index : trexio_file -> int -> index array = "caml_read_safe_ecp_nucleus_index"
external write_safe_ecp_nucleus_index: trexio_file -> int -> index array -> unit = "caml_write_safe_ecp_nucleus_index"
let read_ecp_nucleus_index f = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  read_safe_ecp_nucleus_index f size

let write_ecp_nucleus_index f a = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  write_safe_ecp_nucleus_index f size a

external has_ecp_exponent: trexio_file -> bool = "caml_has_ecp_exponent"
external read_safe_ecp_exponent : trexio_file -> int -> float array = "caml_read_safe_ecp_exponent"
external write_safe_ecp_exponent: trexio_file -> int -> float array -> unit = "caml_write_safe_ecp_exponent"
let read_ecp_exponent f = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  read_safe_ecp_exponent f size

let write_ecp_exponent f a = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  write_safe_ecp_exponent f size a

external has_ecp_coefficient: trexio_file -> bool = "caml_has_ecp_coefficient"
external read_safe_ecp_coefficient : trexio_file -> int -> float array = "caml_read_safe_ecp_coefficient"
external write_safe_ecp_coefficient: trexio_file -> int -> float array -> unit = "caml_write_safe_ecp_coefficient"
let read_ecp_coefficient f = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  read_safe_ecp_coefficient f size

let write_ecp_coefficient f a = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  write_safe_ecp_coefficient f size a

external has_ecp_power: trexio_file -> bool = "caml_has_ecp_power"
external read_safe_ecp_power : trexio_file -> int -> int array = "caml_read_safe_ecp_power"
external write_safe_ecp_power: trexio_file -> int -> int array -> unit = "caml_write_safe_ecp_power"
let read_ecp_power f = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  read_safe_ecp_power f size

let write_ecp_power f a = 
  let size = 1 in 
  let size = size * read_ecp_num f in
  write_safe_ecp_power f size a

external delete_basis: trexio_file -> unit = "caml_delete_basis"
external has_basis_type: trexio_file -> bool = "caml_has_basis_type"
external read_basis_type_c : trexio_file -> int -> string = "caml_read_basis_type"
let read_basis_type ?(max_str_len=8192) f = read_basis_type_c f max_str_len
external write_basis_type: trexio_file -> string -> unit = "caml_write_basis_type"
external has_basis_prim_num: trexio_file -> bool = "caml_has_basis_prim_num"
external read_basis_prim_num : trexio_file -> dim = "caml_read_basis_prim_num"
external write_basis_prim_num: trexio_file -> dim -> unit = "caml_write_basis_prim_num"
external has_basis_shell_num: trexio_file -> bool = "caml_has_basis_shell_num"
external read_basis_shell_num : trexio_file -> dim = "caml_read_basis_shell_num"
external write_basis_shell_num: trexio_file -> dim -> unit = "caml_write_basis_shell_num"
external has_basis_nucleus_index: trexio_file -> bool = "caml_has_basis_nucleus_index"
external read_safe_basis_nucleus_index : trexio_file -> int -> index array = "caml_read_safe_basis_nucleus_index"
external write_safe_basis_nucleus_index: trexio_file -> int -> index array -> unit = "caml_write_safe_basis_nucleus_index"
let read_basis_nucleus_index f = 
  let size = 1 in 
  let size = size * read_basis_shell_num f in
  read_safe_basis_nucleus_index f size

let write_basis_nucleus_index f a = 
  let size = 1 in 
  let size = size * read_basis_shell_num f in
  write_safe_basis_nucleus_index f size a

external has_basis_shell_ang_mom: trexio_file -> bool = "caml_has_basis_shell_ang_mom"
external read_safe_basis_shell_ang_mom : trexio_file -> int -> int array = "caml_read_safe_basis_shell_ang_mom"
external write_safe_basis_shell_ang_mom: trexio_file -> int -> int array -> unit = "caml_write_safe_basis_shell_ang_mom"
let read_basis_shell_ang_mom f = 
  let size = 1 in 
  let size = size * read_basis_shell_num f in
  read_safe_basis_shell_ang_mom f size

let write_basis_shell_ang_mom f a = 
  let size = 1 in 
  let size = size * read_basis_shell_num f in
  write_safe_basis_shell_ang_mom f size a

external has_basis_shell_factor: trexio_file -> bool = "caml_has_basis_shell_factor"
external read_safe_basis_shell_factor : trexio_file -> int -> float array = "caml_read_safe_basis_shell_factor"
external write_safe_basis_shell_factor: trexio_file -> int -> float array -> unit = "caml_write_safe_basis_shell_factor"
let read_basis_shell_factor f = 
  let size = 1 in 
  let size = size * read_basis_shell_num f in
  read_safe_basis_shell_factor f size

let write_basis_shell_factor f a = 
  let size = 1 in 
  let size = size * read_basis_shell_num f in
  write_safe_basis_shell_factor f size a

external has_basis_shell_index: trexio_file -> bool = "caml_has_basis_shell_index"
external read_safe_basis_shell_index : trexio_file -> int -> index array = "caml_read_safe_basis_shell_index"
external write_safe_basis_shell_index: trexio_file -> int -> index array -> unit = "caml_write_safe_basis_shell_index"
let read_basis_shell_index f = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  read_safe_basis_shell_index f size

let write_basis_shell_index f a = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  write_safe_basis_shell_index f size a

external has_basis_exponent: trexio_file -> bool = "caml_has_basis_exponent"
external read_safe_basis_exponent : trexio_file -> int -> float array = "caml_read_safe_basis_exponent"
external write_safe_basis_exponent: trexio_file -> int -> float array -> unit = "caml_write_safe_basis_exponent"
let read_basis_exponent f = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  read_safe_basis_exponent f size

let write_basis_exponent f a = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  write_safe_basis_exponent f size a

external has_basis_coefficient: trexio_file -> bool = "caml_has_basis_coefficient"
external read_safe_basis_coefficient : trexio_file -> int -> float array = "caml_read_safe_basis_coefficient"
external write_safe_basis_coefficient: trexio_file -> int -> float array -> unit = "caml_write_safe_basis_coefficient"
let read_basis_coefficient f = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  read_safe_basis_coefficient f size

let write_basis_coefficient f a = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  write_safe_basis_coefficient f size a

external has_basis_prim_factor: trexio_file -> bool = "caml_has_basis_prim_factor"
external read_safe_basis_prim_factor : trexio_file -> int -> float array = "caml_read_safe_basis_prim_factor"
external write_safe_basis_prim_factor: trexio_file -> int -> float array -> unit = "caml_write_safe_basis_prim_factor"
let read_basis_prim_factor f = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  read_safe_basis_prim_factor f size

let write_basis_prim_factor f a = 
  let size = 1 in 
  let size = size * read_basis_prim_num f in
  write_safe_basis_prim_factor f size a

external delete_ao: trexio_file -> unit = "caml_delete_ao"
external has_ao_cartesian: trexio_file -> bool = "caml_has_ao_cartesian"
external read_ao_cartesian : trexio_file -> int = "caml_read_ao_cartesian"
external write_ao_cartesian: trexio_file -> int -> unit = "caml_write_ao_cartesian"
external has_ao_num: trexio_file -> bool = "caml_has_ao_num"
external read_ao_num : trexio_file -> dim = "caml_read_ao_num"
external write_ao_num: trexio_file -> dim -> unit = "caml_write_ao_num"
external has_ao_shell: trexio_file -> bool = "caml_has_ao_shell"
external read_safe_ao_shell : trexio_file -> int -> index array = "caml_read_safe_ao_shell"
external write_safe_ao_shell: trexio_file -> int -> index array -> unit = "caml_write_safe_ao_shell"
let read_ao_shell f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  read_safe_ao_shell f size

let write_ao_shell f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  write_safe_ao_shell f size a

external has_ao_normalization: trexio_file -> bool = "caml_has_ao_normalization"
external read_safe_ao_normalization : trexio_file -> int -> float array = "caml_read_safe_ao_normalization"
external write_safe_ao_normalization: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_normalization"
let read_ao_normalization f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  read_safe_ao_normalization f size

let write_ao_normalization f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  write_safe_ao_normalization f size a

external delete_ao_1e_int: trexio_file -> unit = "caml_delete_ao_1e_int"
external has_ao_1e_int_overlap: trexio_file -> bool = "caml_has_ao_1e_int_overlap"
external read_safe_ao_1e_int_overlap : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_overlap"
external write_safe_ao_1e_int_overlap: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_overlap"
let read_ao_1e_int_overlap f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_overlap f size

let write_ao_1e_int_overlap f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_overlap f size a

external has_ao_1e_int_kinetic: trexio_file -> bool = "caml_has_ao_1e_int_kinetic"
external read_safe_ao_1e_int_kinetic : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_kinetic"
external write_safe_ao_1e_int_kinetic: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_kinetic"
let read_ao_1e_int_kinetic f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_kinetic f size

let write_ao_1e_int_kinetic f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_kinetic f size a

external has_ao_1e_int_potential_n_e: trexio_file -> bool = "caml_has_ao_1e_int_potential_n_e"
external read_safe_ao_1e_int_potential_n_e : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_potential_n_e"
external write_safe_ao_1e_int_potential_n_e: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_potential_n_e"
let read_ao_1e_int_potential_n_e f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_potential_n_e f size

let write_ao_1e_int_potential_n_e f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_potential_n_e f size a

external has_ao_1e_int_ecp: trexio_file -> bool = "caml_has_ao_1e_int_ecp"
external read_safe_ao_1e_int_ecp : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_ecp"
external write_safe_ao_1e_int_ecp: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_ecp"
let read_ao_1e_int_ecp f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_ecp f size

let write_ao_1e_int_ecp f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_ecp f size a

external has_ao_1e_int_core_hamiltonian: trexio_file -> bool = "caml_has_ao_1e_int_core_hamiltonian"
external read_safe_ao_1e_int_core_hamiltonian : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_core_hamiltonian"
external write_safe_ao_1e_int_core_hamiltonian: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_core_hamiltonian"
let read_ao_1e_int_core_hamiltonian f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_core_hamiltonian f size

let write_ao_1e_int_core_hamiltonian f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_core_hamiltonian f size a

external has_ao_1e_int_overlap_im: trexio_file -> bool = "caml_has_ao_1e_int_overlap_im"
external read_safe_ao_1e_int_overlap_im : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_overlap_im"
external write_safe_ao_1e_int_overlap_im: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_overlap_im"
let read_ao_1e_int_overlap_im f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_overlap_im f size

let write_ao_1e_int_overlap_im f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_overlap_im f size a

external has_ao_1e_int_kinetic_im: trexio_file -> bool = "caml_has_ao_1e_int_kinetic_im"
external read_safe_ao_1e_int_kinetic_im : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_kinetic_im"
external write_safe_ao_1e_int_kinetic_im: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_kinetic_im"
let read_ao_1e_int_kinetic_im f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_kinetic_im f size

let write_ao_1e_int_kinetic_im f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_kinetic_im f size a

external has_ao_1e_int_potential_n_e_im: trexio_file -> bool = "caml_has_ao_1e_int_potential_n_e_im"
external read_safe_ao_1e_int_potential_n_e_im : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_potential_n_e_im"
external write_safe_ao_1e_int_potential_n_e_im: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_potential_n_e_im"
let read_ao_1e_int_potential_n_e_im f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_potential_n_e_im f size

let write_ao_1e_int_potential_n_e_im f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_potential_n_e_im f size a

external has_ao_1e_int_ecp_im: trexio_file -> bool = "caml_has_ao_1e_int_ecp_im"
external read_safe_ao_1e_int_ecp_im : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_ecp_im"
external write_safe_ao_1e_int_ecp_im: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_ecp_im"
let read_ao_1e_int_ecp_im f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_ecp_im f size

let write_ao_1e_int_ecp_im f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_ecp_im f size a

external has_ao_1e_int_core_hamiltonian_im: trexio_file -> bool = "caml_has_ao_1e_int_core_hamiltonian_im"
external read_safe_ao_1e_int_core_hamiltonian_im : trexio_file -> int -> float array = "caml_read_safe_ao_1e_int_core_hamiltonian_im"
external write_safe_ao_1e_int_core_hamiltonian_im: trexio_file -> int -> float array -> unit = "caml_write_safe_ao_1e_int_core_hamiltonian_im"
let read_ao_1e_int_core_hamiltonian_im f = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  read_safe_ao_1e_int_core_hamiltonian_im f size

let write_ao_1e_int_core_hamiltonian_im f a = 
  let size = 1 in 
  let size = size * read_ao_num f in
  let size = size * read_ao_num f in
  write_safe_ao_1e_int_core_hamiltonian_im f size a

external delete_ao_2e_int: trexio_file -> unit = "caml_delete_ao_2e_int"
external has_ao_2e_int_eri: trexio_file -> bool = "caml_has_ao_2e_int_eri"
external read_ao_2e_int_eri : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_ao_2e_int_eri"
external write_ao_2e_int_eri : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_ao_2e_int_eri"
external has_ao_2e_int_eri_lr: trexio_file -> bool = "caml_has_ao_2e_int_eri_lr"
external read_ao_2e_int_eri_lr : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_ao_2e_int_eri_lr"
external write_ao_2e_int_eri_lr : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_ao_2e_int_eri_lr"
external delete_mo: trexio_file -> unit = "caml_delete_mo"
external has_mo_type: trexio_file -> bool = "caml_has_mo_type"
external read_mo_type_c : trexio_file -> int -> string = "caml_read_mo_type"
let read_mo_type ?(max_str_len=8192) f = read_mo_type_c f max_str_len
external write_mo_type: trexio_file -> string -> unit = "caml_write_mo_type"
external has_mo_num: trexio_file -> bool = "caml_has_mo_num"
external read_mo_num : trexio_file -> dim = "caml_read_mo_num"
external write_mo_num: trexio_file -> dim -> unit = "caml_write_mo_num"
external has_mo_coefficient: trexio_file -> bool = "caml_has_mo_coefficient"
external read_safe_mo_coefficient : trexio_file -> int -> float array = "caml_read_safe_mo_coefficient"
external write_safe_mo_coefficient: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_coefficient"
let read_mo_coefficient f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_ao_num f in
  read_safe_mo_coefficient f size

let write_mo_coefficient f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_ao_num f in
  write_safe_mo_coefficient f size a

external has_mo_coefficient_im: trexio_file -> bool = "caml_has_mo_coefficient_im"
external read_safe_mo_coefficient_im : trexio_file -> int -> float array = "caml_read_safe_mo_coefficient_im"
external write_safe_mo_coefficient_im: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_coefficient_im"
let read_mo_coefficient_im f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_ao_num f in
  read_safe_mo_coefficient_im f size

let write_mo_coefficient_im f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_ao_num f in
  write_safe_mo_coefficient_im f size a

external has_mo_class: trexio_file -> bool = "caml_has_mo_class"
external read_safe_mo_class : trexio_file -> int -> int -> string array = "caml_read_safe_mo_class"
external write_safe_mo_class: trexio_file -> int -> int -> string array -> unit = "caml_write_safe_mo_class"
let read_mo_class ?(max_str_len=1024) f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  read_safe_mo_class f size max_str_len

let write_mo_class f a = 
  let size = 1 in 
  let max_str_len = Array.map String.length a
      |> Array.fold_left (fun x y -> if x>y then x else y) 0
      |> (+) 1 in
  let size = size * read_mo_num f in
  write_safe_mo_class f size max_str_len a

external has_mo_symmetry: trexio_file -> bool = "caml_has_mo_symmetry"
external read_safe_mo_symmetry : trexio_file -> int -> int -> string array = "caml_read_safe_mo_symmetry"
external write_safe_mo_symmetry: trexio_file -> int -> int -> string array -> unit = "caml_write_safe_mo_symmetry"
let read_mo_symmetry ?(max_str_len=1024) f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  read_safe_mo_symmetry f size max_str_len

let write_mo_symmetry f a = 
  let size = 1 in 
  let max_str_len = Array.map String.length a
      |> Array.fold_left (fun x y -> if x>y then x else y) 0
      |> (+) 1 in
  let size = size * read_mo_num f in
  write_safe_mo_symmetry f size max_str_len a

external has_mo_occupation: trexio_file -> bool = "caml_has_mo_occupation"
external read_safe_mo_occupation : trexio_file -> int -> float array = "caml_read_safe_mo_occupation"
external write_safe_mo_occupation: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_occupation"
let read_mo_occupation f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  read_safe_mo_occupation f size

let write_mo_occupation f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  write_safe_mo_occupation f size a

external delete_mo_1e_int: trexio_file -> unit = "caml_delete_mo_1e_int"
external has_mo_1e_int_overlap: trexio_file -> bool = "caml_has_mo_1e_int_overlap"
external read_safe_mo_1e_int_overlap : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_overlap"
external write_safe_mo_1e_int_overlap: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_overlap"
let read_mo_1e_int_overlap f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_overlap f size

let write_mo_1e_int_overlap f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_overlap f size a

external has_mo_1e_int_kinetic: trexio_file -> bool = "caml_has_mo_1e_int_kinetic"
external read_safe_mo_1e_int_kinetic : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_kinetic"
external write_safe_mo_1e_int_kinetic: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_kinetic"
let read_mo_1e_int_kinetic f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_kinetic f size

let write_mo_1e_int_kinetic f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_kinetic f size a

external has_mo_1e_int_potential_n_e: trexio_file -> bool = "caml_has_mo_1e_int_potential_n_e"
external read_safe_mo_1e_int_potential_n_e : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_potential_n_e"
external write_safe_mo_1e_int_potential_n_e: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_potential_n_e"
let read_mo_1e_int_potential_n_e f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_potential_n_e f size

let write_mo_1e_int_potential_n_e f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_potential_n_e f size a

external has_mo_1e_int_ecp: trexio_file -> bool = "caml_has_mo_1e_int_ecp"
external read_safe_mo_1e_int_ecp : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_ecp"
external write_safe_mo_1e_int_ecp: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_ecp"
let read_mo_1e_int_ecp f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_ecp f size

let write_mo_1e_int_ecp f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_ecp f size a

external has_mo_1e_int_core_hamiltonian: trexio_file -> bool = "caml_has_mo_1e_int_core_hamiltonian"
external read_safe_mo_1e_int_core_hamiltonian : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_core_hamiltonian"
external write_safe_mo_1e_int_core_hamiltonian: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_core_hamiltonian"
let read_mo_1e_int_core_hamiltonian f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_core_hamiltonian f size

let write_mo_1e_int_core_hamiltonian f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_core_hamiltonian f size a

external has_mo_1e_int_overlap_im: trexio_file -> bool = "caml_has_mo_1e_int_overlap_im"
external read_safe_mo_1e_int_overlap_im : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_overlap_im"
external write_safe_mo_1e_int_overlap_im: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_overlap_im"
let read_mo_1e_int_overlap_im f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_overlap_im f size

let write_mo_1e_int_overlap_im f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_overlap_im f size a

external has_mo_1e_int_kinetic_im: trexio_file -> bool = "caml_has_mo_1e_int_kinetic_im"
external read_safe_mo_1e_int_kinetic_im : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_kinetic_im"
external write_safe_mo_1e_int_kinetic_im: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_kinetic_im"
let read_mo_1e_int_kinetic_im f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_kinetic_im f size

let write_mo_1e_int_kinetic_im f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_kinetic_im f size a

external has_mo_1e_int_potential_n_e_im: trexio_file -> bool = "caml_has_mo_1e_int_potential_n_e_im"
external read_safe_mo_1e_int_potential_n_e_im : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_potential_n_e_im"
external write_safe_mo_1e_int_potential_n_e_im: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_potential_n_e_im"
let read_mo_1e_int_potential_n_e_im f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_potential_n_e_im f size

let write_mo_1e_int_potential_n_e_im f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_potential_n_e_im f size a

external has_mo_1e_int_ecp_im: trexio_file -> bool = "caml_has_mo_1e_int_ecp_im"
external read_safe_mo_1e_int_ecp_im : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_ecp_im"
external write_safe_mo_1e_int_ecp_im: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_ecp_im"
let read_mo_1e_int_ecp_im f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_ecp_im f size

let write_mo_1e_int_ecp_im f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_ecp_im f size a

external has_mo_1e_int_core_hamiltonian_im: trexio_file -> bool = "caml_has_mo_1e_int_core_hamiltonian_im"
external read_safe_mo_1e_int_core_hamiltonian_im : trexio_file -> int -> float array = "caml_read_safe_mo_1e_int_core_hamiltonian_im"
external write_safe_mo_1e_int_core_hamiltonian_im: trexio_file -> int -> float array -> unit = "caml_write_safe_mo_1e_int_core_hamiltonian_im"
let read_mo_1e_int_core_hamiltonian_im f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_mo_1e_int_core_hamiltonian_im f size

let write_mo_1e_int_core_hamiltonian_im f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_mo_1e_int_core_hamiltonian_im f size a

external delete_mo_2e_int: trexio_file -> unit = "caml_delete_mo_2e_int"
external has_mo_2e_int_eri: trexio_file -> bool = "caml_has_mo_2e_int_eri"
external read_mo_2e_int_eri : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_mo_2e_int_eri"
external write_mo_2e_int_eri : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_mo_2e_int_eri"
external has_mo_2e_int_eri_lr: trexio_file -> bool = "caml_has_mo_2e_int_eri_lr"
external read_mo_2e_int_eri_lr : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_mo_2e_int_eri_lr"
external write_mo_2e_int_eri_lr : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_mo_2e_int_eri_lr"
external delete_determinant: trexio_file -> unit = "caml_delete_determinant"
external has_determinant_num: trexio_file -> bool = "caml_has_determinant_num"
external read_determinant_num : trexio_file -> dim = "caml_read_determinant_num"
external has_determinant_list: trexio_file -> bool = "caml_has_determinant_list"
external has_determinant_coefficient: trexio_file -> bool = "caml_has_determinant_coefficient"
external delete_state: trexio_file -> unit = "caml_delete_state"
external has_state_num: trexio_file -> bool = "caml_has_state_num"
external read_state_num : trexio_file -> dim = "caml_read_state_num"
external write_state_num: trexio_file -> dim -> unit = "caml_write_state_num"
external has_state_label: trexio_file -> bool = "caml_has_state_label"
external read_safe_state_label : trexio_file -> int -> int -> string array = "caml_read_safe_state_label"
external write_safe_state_label: trexio_file -> int -> int -> string array -> unit = "caml_write_safe_state_label"
let read_state_label ?(max_str_len=1024) f = 
  let size = 1 in 
  let size = size * read_state_num f in
  read_safe_state_label f size max_str_len

let write_state_label f a = 
  let size = 1 in 
  let max_str_len = Array.map String.length a
      |> Array.fold_left (fun x y -> if x>y then x else y) 0
      |> (+) 1 in
  let size = size * read_state_num f in
  write_safe_state_label f size max_str_len a

external delete_rdm: trexio_file -> unit = "caml_delete_rdm"
external has_rdm_1e: trexio_file -> bool = "caml_has_rdm_1e"
external read_safe_rdm_1e : trexio_file -> int -> float array = "caml_read_safe_rdm_1e"
external write_safe_rdm_1e: trexio_file -> int -> float array -> unit = "caml_write_safe_rdm_1e"
let read_rdm_1e f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_rdm_1e f size

let write_rdm_1e f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_rdm_1e f size a

external has_rdm_1e_up: trexio_file -> bool = "caml_has_rdm_1e_up"
external read_safe_rdm_1e_up : trexio_file -> int -> float array = "caml_read_safe_rdm_1e_up"
external write_safe_rdm_1e_up: trexio_file -> int -> float array -> unit = "caml_write_safe_rdm_1e_up"
let read_rdm_1e_up f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_rdm_1e_up f size

let write_rdm_1e_up f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_rdm_1e_up f size a

external has_rdm_1e_dn: trexio_file -> bool = "caml_has_rdm_1e_dn"
external read_safe_rdm_1e_dn : trexio_file -> int -> float array = "caml_read_safe_rdm_1e_dn"
external write_safe_rdm_1e_dn: trexio_file -> int -> float array -> unit = "caml_write_safe_rdm_1e_dn"
let read_rdm_1e_dn f = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  read_safe_rdm_1e_dn f size

let write_rdm_1e_dn f a = 
  let size = 1 in 
  let size = size * read_mo_num f in
  let size = size * read_mo_num f in
  write_safe_rdm_1e_dn f size a

external has_rdm_2e: trexio_file -> bool = "caml_has_rdm_2e"
external read_rdm_2e : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_rdm_2e"
external write_rdm_2e : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_rdm_2e"
external has_rdm_2e_upup: trexio_file -> bool = "caml_has_rdm_2e_upup"
external read_rdm_2e_upup : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_rdm_2e_upup"
external write_rdm_2e_upup : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_rdm_2e_upup"
external has_rdm_2e_dndn: trexio_file -> bool = "caml_has_rdm_2e_dndn"
external read_rdm_2e_dndn : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_rdm_2e_dndn"
external write_rdm_2e_dndn : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_rdm_2e_dndn"
external has_rdm_2e_updn: trexio_file -> bool = "caml_has_rdm_2e_updn"
external read_rdm_2e_updn : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_rdm_2e_updn"
external write_rdm_2e_updn : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_rdm_2e_updn"
external has_rdm_2e_dnup: trexio_file -> bool = "caml_has_rdm_2e_dnup"
external read_rdm_2e_dnup : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array = "caml_read_rdm_2e_dnup"
external write_rdm_2e_dnup : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit = "caml_write_rdm_2e_dnup"
external delete_cell: trexio_file -> unit = "caml_delete_cell"
external has_cell_a: trexio_file -> bool = "caml_has_cell_a"
external read_safe_cell_a : trexio_file -> int -> float array = "caml_read_safe_cell_a"
external write_safe_cell_a: trexio_file -> int -> float array -> unit = "caml_write_safe_cell_a"
let read_cell_a f = 
  let size = 1 in 
  let size = size * 3 in
  read_safe_cell_a f size

let write_cell_a f a = 
  let size = 1 in 
  let size = size * 3 in
  write_safe_cell_a f size a

external has_cell_b: trexio_file -> bool = "caml_has_cell_b"
external read_safe_cell_b : trexio_file -> int -> float array = "caml_read_safe_cell_b"
external write_safe_cell_b: trexio_file -> int -> float array -> unit = "caml_write_safe_cell_b"
let read_cell_b f = 
  let size = 1 in 
  let size = size * 3 in
  read_safe_cell_b f size

let write_cell_b f a = 
  let size = 1 in 
  let size = size * 3 in
  write_safe_cell_b f size a

external has_cell_c: trexio_file -> bool = "caml_has_cell_c"
external read_safe_cell_c : trexio_file -> int -> float array = "caml_read_safe_cell_c"
external write_safe_cell_c: trexio_file -> int -> float array -> unit = "caml_write_safe_cell_c"
let read_cell_c f = 
  let size = 1 in 
  let size = size * 3 in
  read_safe_cell_c f size

let write_cell_c f a = 
  let size = 1 in 
  let size = size * 3 in
  write_safe_cell_c f size a

external delete_pbc: trexio_file -> unit = "caml_delete_pbc"
external has_pbc_periodic: trexio_file -> bool = "caml_has_pbc_periodic"
external read_pbc_periodic : trexio_file -> int = "caml_read_pbc_periodic"
external write_pbc_periodic: trexio_file -> int -> unit = "caml_write_pbc_periodic"
external has_pbc_k_point: trexio_file -> bool = "caml_has_pbc_k_point"
external read_safe_pbc_k_point : trexio_file -> int -> float array = "caml_read_safe_pbc_k_point"
external write_safe_pbc_k_point: trexio_file -> int -> float array -> unit = "caml_write_safe_pbc_k_point"
let read_pbc_k_point f = 
  let size = 1 in 
  let size = size * 3 in
  read_safe_pbc_k_point f size

let write_pbc_k_point f a = 
  let size = 1 in 
  let size = size * 3 in
  write_safe_pbc_k_point f size a

external delete_qmc: trexio_file -> unit = "caml_delete_qmc"
external has_qmc_num: trexio_file -> bool = "caml_has_qmc_num"
external read_qmc_num : trexio_file -> dim = "caml_read_qmc_num"
external write_qmc_num: trexio_file -> dim -> unit = "caml_write_qmc_num"
external has_qmc_point: trexio_file -> bool = "caml_has_qmc_point"
external read_safe_qmc_point : trexio_file -> int -> float array = "caml_read_safe_qmc_point"
external write_safe_qmc_point: trexio_file -> int -> float array -> unit = "caml_write_safe_qmc_point"
let read_qmc_point f = 
  let size = 1 in 
  let size = size * read_qmc_num f in
  let size = size * read_electron_num f in
  let size = size * 3 in
  read_safe_qmc_point f size

let write_qmc_point f a = 
  let size = 1 in 
  let size = size * read_qmc_num f in
  let size = size * read_electron_num f in
  let size = size * 3 in
  write_safe_qmc_point f size a

external has_qmc_psi: trexio_file -> bool = "caml_has_qmc_psi"
external read_safe_qmc_psi : trexio_file -> int -> float array = "caml_read_safe_qmc_psi"
external write_safe_qmc_psi: trexio_file -> int -> float array -> unit = "caml_write_safe_qmc_psi"
let read_qmc_psi f = 
  let size = 1 in 
  let size = size * read_qmc_num f in
  read_safe_qmc_psi f size

let write_qmc_psi f a = 
  let size = 1 in 
  let size = size * read_qmc_num f in
  write_safe_qmc_psi f size a

external has_qmc_e_loc: trexio_file -> bool = "caml_has_qmc_e_loc"
external read_safe_qmc_e_loc : trexio_file -> int -> float array = "caml_read_safe_qmc_e_loc"
external write_safe_qmc_e_loc: trexio_file -> int -> float array -> unit = "caml_write_safe_qmc_e_loc"
let read_qmc_e_loc f = 
  let size = 1 in 
  let size = size * read_qmc_num f in
  read_safe_qmc_e_loc f size

let write_qmc_e_loc f a = 
  let size = 1 in 
  let size = size * read_qmc_num f in
  write_safe_qmc_e_loc f size a

(**** ****)

external read_determinant_list : trexio_file -> offset:int -> buffer_size:int -> (bytes * bytes) array = "caml_read_determinant_list"
external write_determinant_list : trexio_file -> offset:int -> (bytes * bytes) array -> unit = "caml_write_determinant_list"

external read_determinant_coefficient : trexio_file -> offset:int -> buffer_size:int -> float array = "caml_read_determinant_coefficient"
external write_determinant_coefficient : trexio_file -> offset:int -> float array -> unit = "caml_write_determinant_coefficient"


let to_orbital_list_up_dn (up,dn) =
  (to_orbital_list up, to_orbital_list dn)


