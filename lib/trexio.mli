(*
(** Constants *)
val package_version : string
val version_major   : int
val version_minor   : int
val version_patch   : int
val git_hash        : string
*)

(** Open/close *)

type trexio_file
type trexio_exit_code
type trexio_backend =
  | HDF5
  | TEXT
  | AUTO

type index = int
type dim   = int

val open_file : string -> char -> trexio_backend -> trexio_file
val inquire_file : string -> bool
val close_file : trexio_file -> unit
val set_one_based : trexio_file -> unit
val get_state : trexio_file -> int
val set_state : trexio_file -> int -> unit
val info : unit -> unit

val to_orbital_list : Int64.t array -> int list
val to_orbital_list_up_dn : (Int64.t array)*(Int64.t array) -> (int list)*(int list)

val delete_metadata: trexio_file -> unit
val has_metadata_code_num: trexio_file -> bool
val read_metadata_code_num : trexio_file -> dim
val write_metadata_code_num: trexio_file -> dim -> unit
val has_metadata_code: trexio_file -> bool
val read_safe_metadata_code : trexio_file -> int -> int -> string array
val write_safe_metadata_code: trexio_file -> int -> int -> string array -> unit
val read_metadata_code : ?max_str_len:int -> trexio_file -> string array
val write_metadata_code: trexio_file -> string array -> unit
val has_metadata_author_num: trexio_file -> bool
val read_metadata_author_num : trexio_file -> dim
val write_metadata_author_num: trexio_file -> dim -> unit
val has_metadata_author: trexio_file -> bool
val read_safe_metadata_author : trexio_file -> int -> int -> string array
val write_safe_metadata_author: trexio_file -> int -> int -> string array -> unit
val read_metadata_author : ?max_str_len:int -> trexio_file -> string array
val write_metadata_author: trexio_file -> string array -> unit
val has_metadata_package_version: trexio_file -> bool
val read_metadata_package_version : ?max_str_len:int -> trexio_file -> string
val write_metadata_package_version: trexio_file -> string -> unit
val has_metadata_description: trexio_file -> bool
val read_metadata_description : ?max_str_len:int -> trexio_file -> string
val write_metadata_description: trexio_file -> string -> unit
val has_metadata_unsafe: trexio_file -> bool
val read_metadata_unsafe : trexio_file -> int
val write_metadata_unsafe: trexio_file -> int -> unit
val delete_electron: trexio_file -> unit
val has_electron_num: trexio_file -> bool
val read_electron_num : trexio_file -> dim
val write_electron_num: trexio_file -> dim -> unit
val has_electron_up_num: trexio_file -> bool
val read_electron_up_num : trexio_file -> int
val write_electron_up_num: trexio_file -> int -> unit
val has_electron_dn_num: trexio_file -> bool
val read_electron_dn_num : trexio_file -> int
val write_electron_dn_num: trexio_file -> int -> unit
val delete_nucleus: trexio_file -> unit
val has_nucleus_num: trexio_file -> bool
val read_nucleus_num : trexio_file -> dim
val write_nucleus_num: trexio_file -> dim -> unit
val has_nucleus_charge: trexio_file -> bool
val read_safe_nucleus_charge : trexio_file -> int -> float array
val write_safe_nucleus_charge: trexio_file -> int -> float array -> unit
val read_nucleus_charge : trexio_file -> float array
val write_nucleus_charge: trexio_file -> float array -> unit
val has_nucleus_coord: trexio_file -> bool
val read_safe_nucleus_coord : trexio_file -> int -> float array
val write_safe_nucleus_coord: trexio_file -> int -> float array -> unit
val read_nucleus_coord : trexio_file -> float array
val write_nucleus_coord: trexio_file -> float array -> unit
val has_nucleus_label: trexio_file -> bool
val read_safe_nucleus_label : trexio_file -> int -> int -> string array
val write_safe_nucleus_label: trexio_file -> int -> int -> string array -> unit
val read_nucleus_label : ?max_str_len:int -> trexio_file -> string array
val write_nucleus_label: trexio_file -> string array -> unit
val has_nucleus_point_group: trexio_file -> bool
val read_nucleus_point_group : ?max_str_len:int -> trexio_file -> string
val write_nucleus_point_group: trexio_file -> string -> unit
val has_nucleus_repulsion: trexio_file -> bool
val read_nucleus_repulsion : trexio_file -> float
val write_nucleus_repulsion: trexio_file -> float -> unit
val delete_ecp: trexio_file -> unit
val has_ecp_max_ang_mom_plus_1: trexio_file -> bool
val read_safe_ecp_max_ang_mom_plus_1 : trexio_file -> int -> int array
val write_safe_ecp_max_ang_mom_plus_1: trexio_file -> int -> int array -> unit
val read_ecp_max_ang_mom_plus_1 : trexio_file -> int array
val write_ecp_max_ang_mom_plus_1: trexio_file -> int array -> unit
val has_ecp_z_core: trexio_file -> bool
val read_safe_ecp_z_core : trexio_file -> int -> int array
val write_safe_ecp_z_core: trexio_file -> int -> int array -> unit
val read_ecp_z_core : trexio_file -> int array
val write_ecp_z_core: trexio_file -> int array -> unit
val has_ecp_num: trexio_file -> bool
val read_ecp_num : trexio_file -> dim
val write_ecp_num: trexio_file -> dim -> unit
val has_ecp_ang_mom: trexio_file -> bool
val read_safe_ecp_ang_mom : trexio_file -> int -> int array
val write_safe_ecp_ang_mom: trexio_file -> int -> int array -> unit
val read_ecp_ang_mom : trexio_file -> int array
val write_ecp_ang_mom: trexio_file -> int array -> unit
val has_ecp_nucleus_index: trexio_file -> bool
val read_safe_ecp_nucleus_index : trexio_file -> int -> index array
val write_safe_ecp_nucleus_index: trexio_file -> int -> index array -> unit
val read_ecp_nucleus_index : trexio_file -> index array
val write_ecp_nucleus_index: trexio_file -> index array -> unit
val has_ecp_exponent: trexio_file -> bool
val read_safe_ecp_exponent : trexio_file -> int -> float array
val write_safe_ecp_exponent: trexio_file -> int -> float array -> unit
val read_ecp_exponent : trexio_file -> float array
val write_ecp_exponent: trexio_file -> float array -> unit
val has_ecp_coefficient: trexio_file -> bool
val read_safe_ecp_coefficient : trexio_file -> int -> float array
val write_safe_ecp_coefficient: trexio_file -> int -> float array -> unit
val read_ecp_coefficient : trexio_file -> float array
val write_ecp_coefficient: trexio_file -> float array -> unit
val has_ecp_power: trexio_file -> bool
val read_safe_ecp_power : trexio_file -> int -> int array
val write_safe_ecp_power: trexio_file -> int -> int array -> unit
val read_ecp_power : trexio_file -> int array
val write_ecp_power: trexio_file -> int array -> unit
val delete_basis: trexio_file -> unit
val has_basis_type: trexio_file -> bool
val read_basis_type : ?max_str_len:int -> trexio_file -> string
val write_basis_type: trexio_file -> string -> unit
val has_basis_prim_num: trexio_file -> bool
val read_basis_prim_num : trexio_file -> dim
val write_basis_prim_num: trexio_file -> dim -> unit
val has_basis_shell_num: trexio_file -> bool
val read_basis_shell_num : trexio_file -> dim
val write_basis_shell_num: trexio_file -> dim -> unit
val has_basis_nucleus_index: trexio_file -> bool
val read_safe_basis_nucleus_index : trexio_file -> int -> index array
val write_safe_basis_nucleus_index: trexio_file -> int -> index array -> unit
val read_basis_nucleus_index : trexio_file -> index array
val write_basis_nucleus_index: trexio_file -> index array -> unit
val has_basis_shell_ang_mom: trexio_file -> bool
val read_safe_basis_shell_ang_mom : trexio_file -> int -> int array
val write_safe_basis_shell_ang_mom: trexio_file -> int -> int array -> unit
val read_basis_shell_ang_mom : trexio_file -> int array
val write_basis_shell_ang_mom: trexio_file -> int array -> unit
val has_basis_shell_factor: trexio_file -> bool
val read_safe_basis_shell_factor : trexio_file -> int -> float array
val write_safe_basis_shell_factor: trexio_file -> int -> float array -> unit
val read_basis_shell_factor : trexio_file -> float array
val write_basis_shell_factor: trexio_file -> float array -> unit
val has_basis_shell_index: trexio_file -> bool
val read_safe_basis_shell_index : trexio_file -> int -> index array
val write_safe_basis_shell_index: trexio_file -> int -> index array -> unit
val read_basis_shell_index : trexio_file -> index array
val write_basis_shell_index: trexio_file -> index array -> unit
val has_basis_exponent: trexio_file -> bool
val read_safe_basis_exponent : trexio_file -> int -> float array
val write_safe_basis_exponent: trexio_file -> int -> float array -> unit
val read_basis_exponent : trexio_file -> float array
val write_basis_exponent: trexio_file -> float array -> unit
val has_basis_coefficient: trexio_file -> bool
val read_safe_basis_coefficient : trexio_file -> int -> float array
val write_safe_basis_coefficient: trexio_file -> int -> float array -> unit
val read_basis_coefficient : trexio_file -> float array
val write_basis_coefficient: trexio_file -> float array -> unit
val has_basis_prim_factor: trexio_file -> bool
val read_safe_basis_prim_factor : trexio_file -> int -> float array
val write_safe_basis_prim_factor: trexio_file -> int -> float array -> unit
val read_basis_prim_factor : trexio_file -> float array
val write_basis_prim_factor: trexio_file -> float array -> unit
val delete_ao: trexio_file -> unit
val has_ao_cartesian: trexio_file -> bool
val read_ao_cartesian : trexio_file -> int
val write_ao_cartesian: trexio_file -> int -> unit
val has_ao_num: trexio_file -> bool
val read_ao_num : trexio_file -> dim
val write_ao_num: trexio_file -> dim -> unit
val has_ao_shell: trexio_file -> bool
val read_safe_ao_shell : trexio_file -> int -> index array
val write_safe_ao_shell: trexio_file -> int -> index array -> unit
val read_ao_shell : trexio_file -> index array
val write_ao_shell: trexio_file -> index array -> unit
val has_ao_normalization: trexio_file -> bool
val read_safe_ao_normalization : trexio_file -> int -> float array
val write_safe_ao_normalization: trexio_file -> int -> float array -> unit
val read_ao_normalization : trexio_file -> float array
val write_ao_normalization: trexio_file -> float array -> unit
val delete_ao_1e_int: trexio_file -> unit
val has_ao_1e_int_overlap: trexio_file -> bool
val read_safe_ao_1e_int_overlap : trexio_file -> int -> float array
val write_safe_ao_1e_int_overlap: trexio_file -> int -> float array -> unit
val read_ao_1e_int_overlap : trexio_file -> float array
val write_ao_1e_int_overlap: trexio_file -> float array -> unit
val has_ao_1e_int_kinetic: trexio_file -> bool
val read_safe_ao_1e_int_kinetic : trexio_file -> int -> float array
val write_safe_ao_1e_int_kinetic: trexio_file -> int -> float array -> unit
val read_ao_1e_int_kinetic : trexio_file -> float array
val write_ao_1e_int_kinetic: trexio_file -> float array -> unit
val has_ao_1e_int_potential_n_e: trexio_file -> bool
val read_safe_ao_1e_int_potential_n_e : trexio_file -> int -> float array
val write_safe_ao_1e_int_potential_n_e: trexio_file -> int -> float array -> unit
val read_ao_1e_int_potential_n_e : trexio_file -> float array
val write_ao_1e_int_potential_n_e: trexio_file -> float array -> unit
val has_ao_1e_int_ecp: trexio_file -> bool
val read_safe_ao_1e_int_ecp : trexio_file -> int -> float array
val write_safe_ao_1e_int_ecp: trexio_file -> int -> float array -> unit
val read_ao_1e_int_ecp : trexio_file -> float array
val write_ao_1e_int_ecp: trexio_file -> float array -> unit
val has_ao_1e_int_core_hamiltonian: trexio_file -> bool
val read_safe_ao_1e_int_core_hamiltonian : trexio_file -> int -> float array
val write_safe_ao_1e_int_core_hamiltonian: trexio_file -> int -> float array -> unit
val read_ao_1e_int_core_hamiltonian : trexio_file -> float array
val write_ao_1e_int_core_hamiltonian: trexio_file -> float array -> unit
val has_ao_1e_int_overlap_im: trexio_file -> bool
val read_safe_ao_1e_int_overlap_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_overlap_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_overlap_im : trexio_file -> float array
val write_ao_1e_int_overlap_im: trexio_file -> float array -> unit
val has_ao_1e_int_kinetic_im: trexio_file -> bool
val read_safe_ao_1e_int_kinetic_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_kinetic_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_kinetic_im : trexio_file -> float array
val write_ao_1e_int_kinetic_im: trexio_file -> float array -> unit
val has_ao_1e_int_potential_n_e_im: trexio_file -> bool
val read_safe_ao_1e_int_potential_n_e_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_potential_n_e_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_potential_n_e_im : trexio_file -> float array
val write_ao_1e_int_potential_n_e_im: trexio_file -> float array -> unit
val has_ao_1e_int_ecp_im: trexio_file -> bool
val read_safe_ao_1e_int_ecp_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_ecp_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_ecp_im : trexio_file -> float array
val write_ao_1e_int_ecp_im: trexio_file -> float array -> unit
val has_ao_1e_int_core_hamiltonian_im: trexio_file -> bool
val read_safe_ao_1e_int_core_hamiltonian_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_core_hamiltonian_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_core_hamiltonian_im : trexio_file -> float array
val write_ao_1e_int_core_hamiltonian_im: trexio_file -> float array -> unit
val delete_ao_2e_int: trexio_file -> unit
val has_ao_2e_int_eri: trexio_file -> bool
val read_ao_2e_int_eri : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_ao_2e_int_eri : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_ao_2e_int_eri_lr: trexio_file -> bool
val read_ao_2e_int_eri_lr : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_ao_2e_int_eri_lr : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val delete_mo: trexio_file -> unit
val has_mo_type: trexio_file -> bool
val read_mo_type : ?max_str_len:int -> trexio_file -> string
val write_mo_type: trexio_file -> string -> unit
val has_mo_num: trexio_file -> bool
val read_mo_num : trexio_file -> dim
val write_mo_num: trexio_file -> dim -> unit
val has_mo_coefficient: trexio_file -> bool
val read_safe_mo_coefficient : trexio_file -> int -> float array
val write_safe_mo_coefficient: trexio_file -> int -> float array -> unit
val read_mo_coefficient : trexio_file -> float array
val write_mo_coefficient: trexio_file -> float array -> unit
val has_mo_coefficient_im: trexio_file -> bool
val read_safe_mo_coefficient_im : trexio_file -> int -> float array
val write_safe_mo_coefficient_im: trexio_file -> int -> float array -> unit
val read_mo_coefficient_im : trexio_file -> float array
val write_mo_coefficient_im: trexio_file -> float array -> unit
val has_mo_class: trexio_file -> bool
val read_safe_mo_class : trexio_file -> int -> int -> string array
val write_safe_mo_class: trexio_file -> int -> int -> string array -> unit
val read_mo_class : ?max_str_len:int -> trexio_file -> string array
val write_mo_class: trexio_file -> string array -> unit
val has_mo_symmetry: trexio_file -> bool
val read_safe_mo_symmetry : trexio_file -> int -> int -> string array
val write_safe_mo_symmetry: trexio_file -> int -> int -> string array -> unit
val read_mo_symmetry : ?max_str_len:int -> trexio_file -> string array
val write_mo_symmetry: trexio_file -> string array -> unit
val has_mo_occupation: trexio_file -> bool
val read_safe_mo_occupation : trexio_file -> int -> float array
val write_safe_mo_occupation: trexio_file -> int -> float array -> unit
val read_mo_occupation : trexio_file -> float array
val write_mo_occupation: trexio_file -> float array -> unit
val delete_mo_1e_int: trexio_file -> unit
val has_mo_1e_int_overlap: trexio_file -> bool
val read_safe_mo_1e_int_overlap : trexio_file -> int -> float array
val write_safe_mo_1e_int_overlap: trexio_file -> int -> float array -> unit
val read_mo_1e_int_overlap : trexio_file -> float array
val write_mo_1e_int_overlap: trexio_file -> float array -> unit
val has_mo_1e_int_kinetic: trexio_file -> bool
val read_safe_mo_1e_int_kinetic : trexio_file -> int -> float array
val write_safe_mo_1e_int_kinetic: trexio_file -> int -> float array -> unit
val read_mo_1e_int_kinetic : trexio_file -> float array
val write_mo_1e_int_kinetic: trexio_file -> float array -> unit
val has_mo_1e_int_potential_n_e: trexio_file -> bool
val read_safe_mo_1e_int_potential_n_e : trexio_file -> int -> float array
val write_safe_mo_1e_int_potential_n_e: trexio_file -> int -> float array -> unit
val read_mo_1e_int_potential_n_e : trexio_file -> float array
val write_mo_1e_int_potential_n_e: trexio_file -> float array -> unit
val has_mo_1e_int_ecp: trexio_file -> bool
val read_safe_mo_1e_int_ecp : trexio_file -> int -> float array
val write_safe_mo_1e_int_ecp: trexio_file -> int -> float array -> unit
val read_mo_1e_int_ecp : trexio_file -> float array
val write_mo_1e_int_ecp: trexio_file -> float array -> unit
val has_mo_1e_int_core_hamiltonian: trexio_file -> bool
val read_safe_mo_1e_int_core_hamiltonian : trexio_file -> int -> float array
val write_safe_mo_1e_int_core_hamiltonian: trexio_file -> int -> float array -> unit
val read_mo_1e_int_core_hamiltonian : trexio_file -> float array
val write_mo_1e_int_core_hamiltonian: trexio_file -> float array -> unit
val has_mo_1e_int_overlap_im: trexio_file -> bool
val read_safe_mo_1e_int_overlap_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_overlap_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_overlap_im : trexio_file -> float array
val write_mo_1e_int_overlap_im: trexio_file -> float array -> unit
val has_mo_1e_int_kinetic_im: trexio_file -> bool
val read_safe_mo_1e_int_kinetic_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_kinetic_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_kinetic_im : trexio_file -> float array
val write_mo_1e_int_kinetic_im: trexio_file -> float array -> unit
val has_mo_1e_int_potential_n_e_im: trexio_file -> bool
val read_safe_mo_1e_int_potential_n_e_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_potential_n_e_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_potential_n_e_im : trexio_file -> float array
val write_mo_1e_int_potential_n_e_im: trexio_file -> float array -> unit
val has_mo_1e_int_ecp_im: trexio_file -> bool
val read_safe_mo_1e_int_ecp_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_ecp_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_ecp_im : trexio_file -> float array
val write_mo_1e_int_ecp_im: trexio_file -> float array -> unit
val has_mo_1e_int_core_hamiltonian_im: trexio_file -> bool
val read_safe_mo_1e_int_core_hamiltonian_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_core_hamiltonian_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_core_hamiltonian_im : trexio_file -> float array
val write_mo_1e_int_core_hamiltonian_im: trexio_file -> float array -> unit
val delete_mo_2e_int: trexio_file -> unit
val has_mo_2e_int_eri: trexio_file -> bool
val read_mo_2e_int_eri : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_mo_2e_int_eri : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_mo_2e_int_eri_lr: trexio_file -> bool
val read_mo_2e_int_eri_lr : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_mo_2e_int_eri_lr : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val delete_determinant: trexio_file -> unit
val has_determinant_num: trexio_file -> bool
val read_determinant_num : trexio_file -> dim
val has_determinant_list: trexio_file -> bool
val has_determinant_coefficient: trexio_file -> bool
val delete_state: trexio_file -> unit
val has_state_num: trexio_file -> bool
val read_state_num : trexio_file -> dim
val write_state_num: trexio_file -> dim -> unit
val has_state_label: trexio_file -> bool
val read_safe_state_label : trexio_file -> int -> int -> string array
val write_safe_state_label: trexio_file -> int -> int -> string array -> unit
val read_state_label : ?max_str_len:int -> trexio_file -> string array
val write_state_label: trexio_file -> string array -> unit
val delete_rdm: trexio_file -> unit
val has_rdm_1e: trexio_file -> bool
val read_safe_rdm_1e : trexio_file -> int -> float array
val write_safe_rdm_1e: trexio_file -> int -> float array -> unit
val read_rdm_1e : trexio_file -> float array
val write_rdm_1e: trexio_file -> float array -> unit
val has_rdm_1e_up: trexio_file -> bool
val read_safe_rdm_1e_up : trexio_file -> int -> float array
val write_safe_rdm_1e_up: trexio_file -> int -> float array -> unit
val read_rdm_1e_up : trexio_file -> float array
val write_rdm_1e_up: trexio_file -> float array -> unit
val has_rdm_1e_dn: trexio_file -> bool
val read_safe_rdm_1e_dn : trexio_file -> int -> float array
val write_safe_rdm_1e_dn: trexio_file -> int -> float array -> unit
val read_rdm_1e_dn : trexio_file -> float array
val write_rdm_1e_dn: trexio_file -> float array -> unit
val has_rdm_2e: trexio_file -> bool
val read_rdm_2e : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_rdm_2e : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_rdm_2e_upup: trexio_file -> bool
val read_rdm_2e_upup : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_rdm_2e_upup : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_rdm_2e_dndn: trexio_file -> bool
val read_rdm_2e_dndn : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_rdm_2e_dndn : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_rdm_2e_updn: trexio_file -> bool
val read_rdm_2e_updn : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_rdm_2e_updn : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_rdm_2e_dnup: trexio_file -> bool
val read_rdm_2e_dnup : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_rdm_2e_dnup : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val delete_cell: trexio_file -> unit
val has_cell_a: trexio_file -> bool
val read_safe_cell_a : trexio_file -> int -> float array
val write_safe_cell_a: trexio_file -> int -> float array -> unit
val read_cell_a : trexio_file -> float array
val write_cell_a: trexio_file -> float array -> unit
val has_cell_b: trexio_file -> bool
val read_safe_cell_b : trexio_file -> int -> float array
val write_safe_cell_b: trexio_file -> int -> float array -> unit
val read_cell_b : trexio_file -> float array
val write_cell_b: trexio_file -> float array -> unit
val has_cell_c: trexio_file -> bool
val read_safe_cell_c : trexio_file -> int -> float array
val write_safe_cell_c: trexio_file -> int -> float array -> unit
val read_cell_c : trexio_file -> float array
val write_cell_c: trexio_file -> float array -> unit
val delete_pbc: trexio_file -> unit
val has_pbc_periodic: trexio_file -> bool
val read_pbc_periodic : trexio_file -> int
val write_pbc_periodic: trexio_file -> int -> unit
val has_pbc_k_point: trexio_file -> bool
val read_safe_pbc_k_point : trexio_file -> int -> float array
val write_safe_pbc_k_point: trexio_file -> int -> float array -> unit
val read_pbc_k_point : trexio_file -> float array
val write_pbc_k_point: trexio_file -> float array -> unit
val delete_qmc: trexio_file -> unit
val has_qmc_num: trexio_file -> bool
val read_qmc_num : trexio_file -> dim
val write_qmc_num: trexio_file -> dim -> unit
val has_qmc_point: trexio_file -> bool
val read_safe_qmc_point : trexio_file -> int -> float array
val write_safe_qmc_point: trexio_file -> int -> float array -> unit
val read_qmc_point : trexio_file -> float array
val write_qmc_point: trexio_file -> float array -> unit
val has_qmc_psi: trexio_file -> bool
val read_safe_qmc_psi : trexio_file -> int -> float array
val write_safe_qmc_psi: trexio_file -> int -> float array -> unit
val read_qmc_psi : trexio_file -> float array
val write_qmc_psi: trexio_file -> float array -> unit
val has_qmc_e_loc: trexio_file -> bool
val read_safe_qmc_e_loc : trexio_file -> int -> float array
val write_safe_qmc_e_loc: trexio_file -> int -> float array -> unit
val read_qmc_e_loc : trexio_file -> float array
val write_qmc_e_loc: trexio_file -> float array -> unit
(**** ****)

val read_determinant_list : trexio_file -> offset:int -> buffer_size:int -> (bytes * bytes) array
val write_determinant_list : trexio_file -> offset:int -> (bytes * bytes) array -> unit

val read_determinant_coefficient : trexio_file -> offset:int -> buffer_size:int -> float array
val write_determinant_coefficient : trexio_file -> offset:int -> float array -> unit


