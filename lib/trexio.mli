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
val has_metadata: trexio_file -> bool
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
val delete_nucleus: trexio_file -> unit
val has_nucleus: trexio_file -> bool
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
val delete_cell: trexio_file -> unit
val has_cell: trexio_file -> bool
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
val has_cell_g_a: trexio_file -> bool
val read_safe_cell_g_a : trexio_file -> int -> float array
val write_safe_cell_g_a: trexio_file -> int -> float array -> unit
val read_cell_g_a : trexio_file -> float array
val write_cell_g_a: trexio_file -> float array -> unit
val has_cell_g_b: trexio_file -> bool
val read_safe_cell_g_b : trexio_file -> int -> float array
val write_safe_cell_g_b: trexio_file -> int -> float array -> unit
val read_cell_g_b : trexio_file -> float array
val write_cell_g_b: trexio_file -> float array -> unit
val has_cell_g_c: trexio_file -> bool
val read_safe_cell_g_c : trexio_file -> int -> float array
val write_safe_cell_g_c: trexio_file -> int -> float array -> unit
val read_cell_g_c : trexio_file -> float array
val write_cell_g_c: trexio_file -> float array -> unit
val has_cell_two_pi: trexio_file -> bool
val read_cell_two_pi : trexio_file -> int
val write_cell_two_pi: trexio_file -> int -> unit
val delete_pbc: trexio_file -> unit
val has_pbc: trexio_file -> bool
val has_pbc_periodic: trexio_file -> bool
val read_pbc_periodic : trexio_file -> int
val write_pbc_periodic: trexio_file -> int -> unit
val has_pbc_k_point_num: trexio_file -> bool
val read_pbc_k_point_num : trexio_file -> dim
val write_pbc_k_point_num: trexio_file -> dim -> unit
val has_pbc_k_point: trexio_file -> bool
val read_safe_pbc_k_point : trexio_file -> int -> float array
val write_safe_pbc_k_point: trexio_file -> int -> float array -> unit
val read_pbc_k_point : trexio_file -> float array
val write_pbc_k_point: trexio_file -> float array -> unit
val has_pbc_k_point_weight: trexio_file -> bool
val read_safe_pbc_k_point_weight : trexio_file -> int -> float array
val write_safe_pbc_k_point_weight: trexio_file -> int -> float array -> unit
val read_pbc_k_point_weight : trexio_file -> float array
val write_pbc_k_point_weight: trexio_file -> float array -> unit
val has_pbc_madelung: trexio_file -> bool
val read_pbc_madelung : trexio_file -> float
val write_pbc_madelung: trexio_file -> float -> unit
val delete_electron: trexio_file -> unit
val has_electron: trexio_file -> bool
val has_electron_num: trexio_file -> bool
val read_electron_num : trexio_file -> dim
val write_electron_num: trexio_file -> dim -> unit
val has_electron_up_num: trexio_file -> bool
val read_electron_up_num : trexio_file -> int
val write_electron_up_num: trexio_file -> int -> unit
val has_electron_dn_num: trexio_file -> bool
val read_electron_dn_num : trexio_file -> int
val write_electron_dn_num: trexio_file -> int -> unit
val delete_state: trexio_file -> unit
val has_state: trexio_file -> bool
val has_state_num: trexio_file -> bool
val read_state_num : trexio_file -> dim
val write_state_num: trexio_file -> dim -> unit
val has_state_id: trexio_file -> bool
val read_state_id : trexio_file -> index
val write_state_id: trexio_file -> index -> unit
val has_state_energy: trexio_file -> bool
val read_state_energy : trexio_file -> float
val write_state_energy: trexio_file -> float -> unit
val has_state_current_label: trexio_file -> bool
val read_state_current_label : ?max_str_len:int -> trexio_file -> string
val write_state_current_label: trexio_file -> string -> unit
val has_state_label: trexio_file -> bool
val read_safe_state_label : trexio_file -> int -> int -> string array
val write_safe_state_label: trexio_file -> int -> int -> string array -> unit
val read_state_label : ?max_str_len:int -> trexio_file -> string array
val write_state_label: trexio_file -> string array -> unit
val has_state_file_name: trexio_file -> bool
val read_safe_state_file_name : trexio_file -> int -> int -> string array
val write_safe_state_file_name: trexio_file -> int -> int -> string array -> unit
val read_state_file_name : ?max_str_len:int -> trexio_file -> string array
val write_state_file_name: trexio_file -> string array -> unit
val delete_basis: trexio_file -> unit
val has_basis: trexio_file -> bool
val has_basis_type: trexio_file -> bool
val read_basis_type : ?max_str_len:int -> trexio_file -> string
val write_basis_type: trexio_file -> string -> unit
val has_basis_prim_num: trexio_file -> bool
val read_basis_prim_num : trexio_file -> dim
val write_basis_prim_num: trexio_file -> dim -> unit
val has_basis_shell_num: trexio_file -> bool
val read_basis_shell_num : trexio_file -> dim
val write_basis_shell_num: trexio_file -> dim -> unit
val has_basis_nao_grid_num: trexio_file -> bool
val read_basis_nao_grid_num : trexio_file -> dim
val write_basis_nao_grid_num: trexio_file -> dim -> unit
val has_basis_interp_coeff_cnt: trexio_file -> bool
val read_basis_interp_coeff_cnt : trexio_file -> dim
val write_basis_interp_coeff_cnt: trexio_file -> dim -> unit
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
val has_basis_r_power: trexio_file -> bool
val read_safe_basis_r_power : trexio_file -> int -> int array
val write_safe_basis_r_power: trexio_file -> int -> int array -> unit
val read_basis_r_power : trexio_file -> int array
val write_basis_r_power: trexio_file -> int array -> unit
val has_basis_nao_grid_start: trexio_file -> bool
val read_safe_basis_nao_grid_start : trexio_file -> int -> index array
val write_safe_basis_nao_grid_start: trexio_file -> int -> index array -> unit
val read_basis_nao_grid_start : trexio_file -> index array
val write_basis_nao_grid_start: trexio_file -> index array -> unit
val has_basis_nao_grid_size: trexio_file -> bool
val read_safe_basis_nao_grid_size : trexio_file -> int -> dim array
val write_safe_basis_nao_grid_size: trexio_file -> int -> dim array -> unit
val read_basis_nao_grid_size : trexio_file -> dim array
val write_basis_nao_grid_size: trexio_file -> dim array -> unit
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
val has_basis_exponent_im: trexio_file -> bool
val read_safe_basis_exponent_im : trexio_file -> int -> float array
val write_safe_basis_exponent_im: trexio_file -> int -> float array -> unit
val read_basis_exponent_im : trexio_file -> float array
val write_basis_exponent_im: trexio_file -> float array -> unit
val has_basis_coefficient: trexio_file -> bool
val read_safe_basis_coefficient : trexio_file -> int -> float array
val write_safe_basis_coefficient: trexio_file -> int -> float array -> unit
val read_basis_coefficient : trexio_file -> float array
val write_basis_coefficient: trexio_file -> float array -> unit
val has_basis_coefficient_im: trexio_file -> bool
val read_safe_basis_coefficient_im : trexio_file -> int -> float array
val write_safe_basis_coefficient_im: trexio_file -> int -> float array -> unit
val read_basis_coefficient_im : trexio_file -> float array
val write_basis_coefficient_im: trexio_file -> float array -> unit
val has_basis_oscillation_arg: trexio_file -> bool
val read_safe_basis_oscillation_arg : trexio_file -> int -> float array
val write_safe_basis_oscillation_arg: trexio_file -> int -> float array -> unit
val read_basis_oscillation_arg : trexio_file -> float array
val write_basis_oscillation_arg: trexio_file -> float array -> unit
val has_basis_oscillation_kind: trexio_file -> bool
val read_basis_oscillation_kind : ?max_str_len:int -> trexio_file -> string
val write_basis_oscillation_kind: trexio_file -> string -> unit
val has_basis_prim_factor: trexio_file -> bool
val read_safe_basis_prim_factor : trexio_file -> int -> float array
val write_safe_basis_prim_factor: trexio_file -> int -> float array -> unit
val read_basis_prim_factor : trexio_file -> float array
val write_basis_prim_factor: trexio_file -> float array -> unit
val has_basis_e_cut: trexio_file -> bool
val read_basis_e_cut : trexio_file -> float
val write_basis_e_cut: trexio_file -> float -> unit
val has_basis_nao_grid_radius: trexio_file -> bool
val read_safe_basis_nao_grid_radius : trexio_file -> int -> float array
val write_safe_basis_nao_grid_radius: trexio_file -> int -> float array -> unit
val read_basis_nao_grid_radius : trexio_file -> float array
val write_basis_nao_grid_radius: trexio_file -> float array -> unit
val has_basis_nao_grid_phi: trexio_file -> bool
val read_safe_basis_nao_grid_phi : trexio_file -> int -> float array
val write_safe_basis_nao_grid_phi: trexio_file -> int -> float array -> unit
val read_basis_nao_grid_phi : trexio_file -> float array
val write_basis_nao_grid_phi: trexio_file -> float array -> unit
val has_basis_nao_grid_grad: trexio_file -> bool
val read_safe_basis_nao_grid_grad : trexio_file -> int -> float array
val write_safe_basis_nao_grid_grad: trexio_file -> int -> float array -> unit
val read_basis_nao_grid_grad : trexio_file -> float array
val write_basis_nao_grid_grad: trexio_file -> float array -> unit
val has_basis_nao_grid_lap: trexio_file -> bool
val read_safe_basis_nao_grid_lap : trexio_file -> int -> float array
val write_safe_basis_nao_grid_lap: trexio_file -> int -> float array -> unit
val read_basis_nao_grid_lap : trexio_file -> float array
val write_basis_nao_grid_lap: trexio_file -> float array -> unit
val has_basis_interpolator_kind: trexio_file -> bool
val read_basis_interpolator_kind : ?max_str_len:int -> trexio_file -> string
val write_basis_interpolator_kind: trexio_file -> string -> unit
val has_basis_interpolator_phi: trexio_file -> bool
val read_safe_basis_interpolator_phi : trexio_file -> int -> float array
val write_safe_basis_interpolator_phi: trexio_file -> int -> float array -> unit
val read_basis_interpolator_phi : trexio_file -> float array
val write_basis_interpolator_phi: trexio_file -> float array -> unit
val has_basis_interpolator_grad: trexio_file -> bool
val read_safe_basis_interpolator_grad : trexio_file -> int -> float array
val write_safe_basis_interpolator_grad: trexio_file -> int -> float array -> unit
val read_basis_interpolator_grad : trexio_file -> float array
val write_basis_interpolator_grad: trexio_file -> float array -> unit
val has_basis_interpolator_lap: trexio_file -> bool
val read_safe_basis_interpolator_lap : trexio_file -> int -> float array
val write_safe_basis_interpolator_lap: trexio_file -> int -> float array -> unit
val read_basis_interpolator_lap : trexio_file -> float array
val write_basis_interpolator_lap: trexio_file -> float array -> unit
val delete_ecp: trexio_file -> unit
val has_ecp: trexio_file -> bool
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
val delete_grid: trexio_file -> unit
val has_grid: trexio_file -> bool
val has_grid_description: trexio_file -> bool
val read_grid_description : ?max_str_len:int -> trexio_file -> string
val write_grid_description: trexio_file -> string -> unit
val has_grid_rad_precision: trexio_file -> bool
val read_grid_rad_precision : trexio_file -> float
val write_grid_rad_precision: trexio_file -> float -> unit
val has_grid_num: trexio_file -> bool
val read_grid_num : trexio_file -> dim
val write_grid_num: trexio_file -> dim -> unit
val has_grid_max_ang_num: trexio_file -> bool
val read_grid_max_ang_num : trexio_file -> int
val write_grid_max_ang_num: trexio_file -> int -> unit
val has_grid_min_ang_num: trexio_file -> bool
val read_grid_min_ang_num : trexio_file -> int
val write_grid_min_ang_num: trexio_file -> int -> unit
val has_grid_coord: trexio_file -> bool
val read_safe_grid_coord : trexio_file -> int -> float array
val write_safe_grid_coord: trexio_file -> int -> float array -> unit
val read_grid_coord : trexio_file -> float array
val write_grid_coord: trexio_file -> float array -> unit
val has_grid_weight: trexio_file -> bool
val read_safe_grid_weight : trexio_file -> int -> float array
val write_safe_grid_weight: trexio_file -> int -> float array -> unit
val read_grid_weight : trexio_file -> float array
val write_grid_weight: trexio_file -> float array -> unit
val has_grid_ang_num: trexio_file -> bool
val read_grid_ang_num : trexio_file -> dim
val write_grid_ang_num: trexio_file -> dim -> unit
val has_grid_ang_coord: trexio_file -> bool
val read_safe_grid_ang_coord : trexio_file -> int -> float array
val write_safe_grid_ang_coord: trexio_file -> int -> float array -> unit
val read_grid_ang_coord : trexio_file -> float array
val write_grid_ang_coord: trexio_file -> float array -> unit
val has_grid_ang_weight: trexio_file -> bool
val read_safe_grid_ang_weight : trexio_file -> int -> float array
val write_safe_grid_ang_weight: trexio_file -> int -> float array -> unit
val read_grid_ang_weight : trexio_file -> float array
val write_grid_ang_weight: trexio_file -> float array -> unit
val has_grid_rad_num: trexio_file -> bool
val read_grid_rad_num : trexio_file -> dim
val write_grid_rad_num: trexio_file -> dim -> unit
val has_grid_rad_coord: trexio_file -> bool
val read_safe_grid_rad_coord : trexio_file -> int -> float array
val write_safe_grid_rad_coord: trexio_file -> int -> float array -> unit
val read_grid_rad_coord : trexio_file -> float array
val write_grid_rad_coord: trexio_file -> float array -> unit
val has_grid_rad_weight: trexio_file -> bool
val read_safe_grid_rad_weight : trexio_file -> int -> float array
val write_safe_grid_rad_weight: trexio_file -> int -> float array -> unit
val read_grid_rad_weight : trexio_file -> float array
val write_grid_rad_weight: trexio_file -> float array -> unit
val delete_ao: trexio_file -> unit
val has_ao: trexio_file -> bool
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
val has_ao_1e_int: trexio_file -> bool
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
val has_ao_1e_int_dipole_x: trexio_file -> bool
val read_safe_ao_1e_int_dipole_x : trexio_file -> int -> float array
val write_safe_ao_1e_int_dipole_x: trexio_file -> int -> float array -> unit
val read_ao_1e_int_dipole_x : trexio_file -> float array
val write_ao_1e_int_dipole_x: trexio_file -> float array -> unit
val has_ao_1e_int_dipole_y: trexio_file -> bool
val read_safe_ao_1e_int_dipole_y : trexio_file -> int -> float array
val write_safe_ao_1e_int_dipole_y: trexio_file -> int -> float array -> unit
val read_ao_1e_int_dipole_y : trexio_file -> float array
val write_ao_1e_int_dipole_y: trexio_file -> float array -> unit
val has_ao_1e_int_dipole_z: trexio_file -> bool
val read_safe_ao_1e_int_dipole_z : trexio_file -> int -> float array
val write_safe_ao_1e_int_dipole_z: trexio_file -> int -> float array -> unit
val read_ao_1e_int_dipole_z : trexio_file -> float array
val write_ao_1e_int_dipole_z: trexio_file -> float array -> unit
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
val has_ao_1e_int_dipole_x_im: trexio_file -> bool
val read_safe_ao_1e_int_dipole_x_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_dipole_x_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_dipole_x_im : trexio_file -> float array
val write_ao_1e_int_dipole_x_im: trexio_file -> float array -> unit
val has_ao_1e_int_dipole_y_im: trexio_file -> bool
val read_safe_ao_1e_int_dipole_y_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_dipole_y_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_dipole_y_im : trexio_file -> float array
val write_ao_1e_int_dipole_y_im: trexio_file -> float array -> unit
val has_ao_1e_int_dipole_z_im: trexio_file -> bool
val read_safe_ao_1e_int_dipole_z_im : trexio_file -> int -> float array
val write_safe_ao_1e_int_dipole_z_im: trexio_file -> int -> float array -> unit
val read_ao_1e_int_dipole_z_im : trexio_file -> float array
val write_ao_1e_int_dipole_z_im: trexio_file -> float array -> unit
val delete_ao_2e_int: trexio_file -> unit
val has_ao_2e_int: trexio_file -> bool
val has_ao_2e_int_eri: trexio_file -> bool
val read_ao_2e_int_eri : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_ao_2e_int_eri : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_ao_2e_int_eri_lr: trexio_file -> bool
val read_ao_2e_int_eri_lr : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_ao_2e_int_eri_lr : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_ao_2e_int_eri_cholesky_num: trexio_file -> bool
val read_ao_2e_int_eri_cholesky_num : trexio_file -> dim
val write_ao_2e_int_eri_cholesky_num: trexio_file -> dim -> unit
val has_ao_2e_int_eri_cholesky: trexio_file -> bool
val read_ao_2e_int_eri_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_ao_2e_int_eri_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val has_ao_2e_int_eri_lr_cholesky_num: trexio_file -> bool
val read_ao_2e_int_eri_lr_cholesky_num : trexio_file -> dim
val write_ao_2e_int_eri_lr_cholesky_num: trexio_file -> dim -> unit
val has_ao_2e_int_eri_lr_cholesky: trexio_file -> bool
val read_ao_2e_int_eri_lr_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_ao_2e_int_eri_lr_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val delete_mo: trexio_file -> unit
val has_mo: trexio_file -> bool
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
val has_mo_energy: trexio_file -> bool
val read_safe_mo_energy : trexio_file -> int -> float array
val write_safe_mo_energy: trexio_file -> int -> float array -> unit
val read_mo_energy : trexio_file -> float array
val write_mo_energy: trexio_file -> float array -> unit
val has_mo_spin: trexio_file -> bool
val read_safe_mo_spin : trexio_file -> int -> int array
val write_safe_mo_spin: trexio_file -> int -> int array -> unit
val read_mo_spin : trexio_file -> int array
val write_mo_spin: trexio_file -> int array -> unit
val has_mo_k_point: trexio_file -> bool
val read_safe_mo_k_point : trexio_file -> int -> index array
val write_safe_mo_k_point: trexio_file -> int -> index array -> unit
val read_mo_k_point : trexio_file -> index array
val write_mo_k_point: trexio_file -> index array -> unit
val delete_mo_1e_int: trexio_file -> unit
val has_mo_1e_int: trexio_file -> bool
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
val has_mo_1e_int_dipole_x: trexio_file -> bool
val read_safe_mo_1e_int_dipole_x : trexio_file -> int -> float array
val write_safe_mo_1e_int_dipole_x: trexio_file -> int -> float array -> unit
val read_mo_1e_int_dipole_x : trexio_file -> float array
val write_mo_1e_int_dipole_x: trexio_file -> float array -> unit
val has_mo_1e_int_dipole_y: trexio_file -> bool
val read_safe_mo_1e_int_dipole_y : trexio_file -> int -> float array
val write_safe_mo_1e_int_dipole_y: trexio_file -> int -> float array -> unit
val read_mo_1e_int_dipole_y : trexio_file -> float array
val write_mo_1e_int_dipole_y: trexio_file -> float array -> unit
val has_mo_1e_int_dipole_z: trexio_file -> bool
val read_safe_mo_1e_int_dipole_z : trexio_file -> int -> float array
val write_safe_mo_1e_int_dipole_z: trexio_file -> int -> float array -> unit
val read_mo_1e_int_dipole_z : trexio_file -> float array
val write_mo_1e_int_dipole_z: trexio_file -> float array -> unit
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
val has_mo_1e_int_dipole_x_im: trexio_file -> bool
val read_safe_mo_1e_int_dipole_x_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_dipole_x_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_dipole_x_im : trexio_file -> float array
val write_mo_1e_int_dipole_x_im: trexio_file -> float array -> unit
val has_mo_1e_int_dipole_y_im: trexio_file -> bool
val read_safe_mo_1e_int_dipole_y_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_dipole_y_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_dipole_y_im : trexio_file -> float array
val write_mo_1e_int_dipole_y_im: trexio_file -> float array -> unit
val has_mo_1e_int_dipole_z_im: trexio_file -> bool
val read_safe_mo_1e_int_dipole_z_im : trexio_file -> int -> float array
val write_safe_mo_1e_int_dipole_z_im: trexio_file -> int -> float array -> unit
val read_mo_1e_int_dipole_z_im : trexio_file -> float array
val write_mo_1e_int_dipole_z_im: trexio_file -> float array -> unit
val delete_mo_2e_int: trexio_file -> unit
val has_mo_2e_int: trexio_file -> bool
val has_mo_2e_int_eri: trexio_file -> bool
val read_mo_2e_int_eri : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_mo_2e_int_eri : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_mo_2e_int_eri_lr: trexio_file -> bool
val read_mo_2e_int_eri_lr : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_mo_2e_int_eri_lr : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_mo_2e_int_eri_cholesky_num: trexio_file -> bool
val read_mo_2e_int_eri_cholesky_num : trexio_file -> dim
val write_mo_2e_int_eri_cholesky_num: trexio_file -> dim -> unit
val has_mo_2e_int_eri_cholesky: trexio_file -> bool
val read_mo_2e_int_eri_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_mo_2e_int_eri_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val has_mo_2e_int_eri_lr_cholesky_num: trexio_file -> bool
val read_mo_2e_int_eri_lr_cholesky_num : trexio_file -> dim
val write_mo_2e_int_eri_lr_cholesky_num: trexio_file -> dim -> unit
val has_mo_2e_int_eri_lr_cholesky: trexio_file -> bool
val read_mo_2e_int_eri_lr_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_mo_2e_int_eri_lr_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val delete_determinant: trexio_file -> unit
val has_determinant: trexio_file -> bool
val has_determinant_num: trexio_file -> bool
val read_determinant_num : trexio_file -> dim
val has_determinant_list: trexio_file -> bool
val has_determinant_coefficient: trexio_file -> bool
val delete_csf: trexio_file -> unit
val has_csf: trexio_file -> bool
val has_csf_num: trexio_file -> bool
val read_csf_num : trexio_file -> dim
val write_csf_num: trexio_file -> dim -> unit
val has_csf_coefficient: trexio_file -> bool
val has_csf_det_coefficient: trexio_file -> bool
val read_csf_det_coefficient : trexio_file -> offset:dim -> buffer_size:dim -> (int*int * float) array
val write_csf_det_coefficient : trexio_file -> offset:dim -> (int*int * float) array -> unit
val delete_amplitude: trexio_file -> unit
val has_amplitude: trexio_file -> bool
val has_amplitude_single: trexio_file -> bool
val read_amplitude_single : trexio_file -> offset:dim -> buffer_size:dim -> (int*int * float) array
val write_amplitude_single : trexio_file -> offset:dim -> (int*int * float) array -> unit
val has_amplitude_single_exp: trexio_file -> bool
val read_amplitude_single_exp : trexio_file -> offset:dim -> buffer_size:dim -> (int*int * float) array
val write_amplitude_single_exp : trexio_file -> offset:dim -> (int*int * float) array -> unit
val has_amplitude_double: trexio_file -> bool
val read_amplitude_double : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_amplitude_double : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_amplitude_double_exp: trexio_file -> bool
val read_amplitude_double_exp : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int * float) array
val write_amplitude_double_exp : trexio_file -> offset:dim -> (int*int*int*int * float) array -> unit
val has_amplitude_triple: trexio_file -> bool
val read_amplitude_triple : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int*int*int * float) array
val write_amplitude_triple : trexio_file -> offset:dim -> (int*int*int*int*int*int * float) array -> unit
val has_amplitude_triple_exp: trexio_file -> bool
val read_amplitude_triple_exp : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int*int*int * float) array
val write_amplitude_triple_exp : trexio_file -> offset:dim -> (int*int*int*int*int*int * float) array -> unit
val has_amplitude_quadruple: trexio_file -> bool
val read_amplitude_quadruple : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int*int*int*int*int * float) array
val write_amplitude_quadruple : trexio_file -> offset:dim -> (int*int*int*int*int*int*int*int * float) array -> unit
val has_amplitude_quadruple_exp: trexio_file -> bool
val read_amplitude_quadruple_exp : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int*int*int*int*int * float) array
val write_amplitude_quadruple_exp : trexio_file -> offset:dim -> (int*int*int*int*int*int*int*int * float) array -> unit
val delete_rdm: trexio_file -> unit
val has_rdm: trexio_file -> bool
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
val has_rdm_1e_transition: trexio_file -> bool
val read_safe_rdm_1e_transition : trexio_file -> int -> float array
val write_safe_rdm_1e_transition: trexio_file -> int -> float array -> unit
val read_rdm_1e_transition : trexio_file -> float array
val write_rdm_1e_transition: trexio_file -> float array -> unit
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
val has_rdm_2e_transition: trexio_file -> bool
val read_rdm_2e_transition : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int*int*int*int * float) array
val write_rdm_2e_transition : trexio_file -> offset:dim -> (int*int*int*int*int*int * float) array -> unit
val has_rdm_2e_cholesky_num: trexio_file -> bool
val read_rdm_2e_cholesky_num : trexio_file -> dim
val write_rdm_2e_cholesky_num: trexio_file -> dim -> unit
val has_rdm_2e_cholesky: trexio_file -> bool
val read_rdm_2e_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_rdm_2e_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val has_rdm_2e_upup_cholesky_num: trexio_file -> bool
val read_rdm_2e_upup_cholesky_num : trexio_file -> dim
val write_rdm_2e_upup_cholesky_num: trexio_file -> dim -> unit
val has_rdm_2e_upup_cholesky: trexio_file -> bool
val read_rdm_2e_upup_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_rdm_2e_upup_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val has_rdm_2e_dndn_cholesky_num: trexio_file -> bool
val read_rdm_2e_dndn_cholesky_num : trexio_file -> dim
val write_rdm_2e_dndn_cholesky_num: trexio_file -> dim -> unit
val has_rdm_2e_dndn_cholesky: trexio_file -> bool
val read_rdm_2e_dndn_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_rdm_2e_dndn_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val has_rdm_2e_updn_cholesky_num: trexio_file -> bool
val read_rdm_2e_updn_cholesky_num : trexio_file -> dim
val write_rdm_2e_updn_cholesky_num: trexio_file -> dim -> unit
val has_rdm_2e_updn_cholesky: trexio_file -> bool
val read_rdm_2e_updn_cholesky : trexio_file -> offset:dim -> buffer_size:dim -> (int*int*int * float) array
val write_rdm_2e_updn_cholesky : trexio_file -> offset:dim -> (int*int*int * float) array -> unit
val delete_jastrow: trexio_file -> unit
val has_jastrow: trexio_file -> bool
val has_jastrow_type: trexio_file -> bool
val read_jastrow_type : ?max_str_len:int -> trexio_file -> string
val write_jastrow_type: trexio_file -> string -> unit
val has_jastrow_en_num: trexio_file -> bool
val read_jastrow_en_num : trexio_file -> dim
val write_jastrow_en_num: trexio_file -> dim -> unit
val has_jastrow_ee_num: trexio_file -> bool
val read_jastrow_ee_num : trexio_file -> dim
val write_jastrow_ee_num: trexio_file -> dim -> unit
val has_jastrow_een_num: trexio_file -> bool
val read_jastrow_een_num : trexio_file -> dim
val write_jastrow_een_num: trexio_file -> dim -> unit
val has_jastrow_en: trexio_file -> bool
val read_safe_jastrow_en : trexio_file -> int -> float array
val write_safe_jastrow_en: trexio_file -> int -> float array -> unit
val read_jastrow_en : trexio_file -> float array
val write_jastrow_en: trexio_file -> float array -> unit
val has_jastrow_ee: trexio_file -> bool
val read_safe_jastrow_ee : trexio_file -> int -> float array
val write_safe_jastrow_ee: trexio_file -> int -> float array -> unit
val read_jastrow_ee : trexio_file -> float array
val write_jastrow_ee: trexio_file -> float array -> unit
val has_jastrow_een: trexio_file -> bool
val read_safe_jastrow_een : trexio_file -> int -> float array
val write_safe_jastrow_een: trexio_file -> int -> float array -> unit
val read_jastrow_een : trexio_file -> float array
val write_jastrow_een: trexio_file -> float array -> unit
val has_jastrow_en_nucleus: trexio_file -> bool
val read_safe_jastrow_en_nucleus : trexio_file -> int -> index array
val write_safe_jastrow_en_nucleus: trexio_file -> int -> index array -> unit
val read_jastrow_en_nucleus : trexio_file -> index array
val write_jastrow_en_nucleus: trexio_file -> index array -> unit
val has_jastrow_een_nucleus: trexio_file -> bool
val read_safe_jastrow_een_nucleus : trexio_file -> int -> index array
val write_safe_jastrow_een_nucleus: trexio_file -> int -> index array -> unit
val read_jastrow_een_nucleus : trexio_file -> index array
val write_jastrow_een_nucleus: trexio_file -> index array -> unit
val has_jastrow_ee_scaling: trexio_file -> bool
val read_jastrow_ee_scaling : trexio_file -> float
val write_jastrow_ee_scaling: trexio_file -> float -> unit
val has_jastrow_en_scaling: trexio_file -> bool
val read_safe_jastrow_en_scaling : trexio_file -> int -> float array
val write_safe_jastrow_en_scaling: trexio_file -> int -> float array -> unit
val read_jastrow_en_scaling : trexio_file -> float array
val write_jastrow_en_scaling: trexio_file -> float array -> unit
val delete_qmc: trexio_file -> unit
val has_qmc: trexio_file -> bool
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
