#include <stdio.h>
#include <trexio.h>
#include <string.h>
#define CAML_NAME_SPACE
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>
#include <caml/misc.h>

static trexio_t* File_val( value file )
{
  return *((trexio_t**) Data_abstract_val(file));
}


CAMLprim value caml_open_file(value filename, value mode, value backend)
{
  CAMLparam3(filename, mode, backend);

  trexio_exit_code rc = 0;
  value v = caml_alloc(1, Abstract_tag);

  trexio_t* result = trexio_open (String_val(filename),
                                  Int_val(mode),
                                  Int_val(backend),
                                  &rc);

  *((trexio_t **) Data_abstract_val(v)) = result;

  if (rc == TREXIO_SUCCESS) {
    CAMLreturn( v );
  } else  {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_close_file(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_close( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_inquire_file(value filename)
{
  CAMLparam1 (filename);
  trexio_exit_code rc = trexio_inquire( String_val (filename) );
  CAMLreturn(Val_bool(rc == TREXIO_SUCCESS));
}


CAMLprim value caml_set_one_based(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_set_one_based( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_set_state(value file, value state)
{
  CAMLparam2(file, state);
  printf("%d\n", Int_val(state));
  trexio_exit_code rc = trexio_set_state( File_val(file), (int32_t) Int_val(state) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_get_state(value file)
{
  CAMLparam1(file);
  int32_t result;
  trexio_exit_code rc = trexio_get_state( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_info(value unit)
{
  CAMLparam1(unit);
  trexio_exit_code rc = trexio_info();
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_to_orbital_list(value bitfield)
{
  CAMLparam1 ( bitfield );
  CAMLlocal2 ( result, cons );

  int32_t N_int = Wosize_val(bitfield);
  bitfield_t* d1 = (bitfield_t*) malloc (N_int * sizeof(bitfield_t));
  for (int i=0 ; i<N_int ; ++i) {
      d1[i] = Int64_val(Field(bitfield,i));
  }

  int32_t* list = (int32_t*) malloc(N_int * sizeof(bitfield_t) * sizeof(int32_t));
  int32_t occupied_num = 0;

  trexio_exit_code rc = trexio_to_orbital_list (N_int, d1, list, &occupied_num);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(d1);

  result = Val_emptylist;
  for (int i=occupied_num-1 ; i >= 0 ; --i) {
    cons = caml_alloc(2, 0);
    Store_field(cons, 0, Val_int(list[i])); // head
    Store_field(cons, 1, result); // head
    result = cons;
  }

  free(list);
  CAMLreturn(result);
}



CAMLprim value caml_delete_metadata(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_metadata( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_metadata_code_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_code_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_metadata_code_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_metadata_code_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_metadata_code_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_metadata_code_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_metadata_code(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_code( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_metadata_code(value file_in, value size_max_in, value max_str_len_in)
{
  CAMLparam3 ( file_in, size_max_in, max_str_len_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** read_data = (char**) malloc (size_max * sizeof(char*));
  read_data[0] = (char*) malloc (size_max * (int64_t) (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
     read_data[i] = read_data[i-1] + max_str_len+1;
  }
  trexio_exit_code rc = trexio_read_metadata_code(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, caml_copy_string(read_data[i]) );
  }

  free(read_data[0]);
  free(read_data);

  CAMLreturn (result);

}

CAMLprim value caml_write_safe_metadata_code(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char*));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    strcpy(c_array[i], String_val( Field(array, i) ));
  }

  printf("%d\n", max_str_len);
  fprintf(stderr,"%d\n", max_str_len);
  trexio_exit_code rc = trexio_write_metadata_code(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_metadata_author_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_author_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_metadata_author_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_metadata_author_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_metadata_author_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_metadata_author_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_metadata_author(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_author( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_metadata_author(value file_in, value size_max_in, value max_str_len_in)
{
  CAMLparam3 ( file_in, size_max_in, max_str_len_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** read_data = (char**) malloc (size_max * sizeof(char*));
  read_data[0] = (char*) malloc (size_max * (int64_t) (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
     read_data[i] = read_data[i-1] + max_str_len+1;
  }
  trexio_exit_code rc = trexio_read_metadata_author(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, caml_copy_string(read_data[i]) );
  }

  free(read_data[0]);
  free(read_data);

  CAMLreturn (result);

}

CAMLprim value caml_write_safe_metadata_author(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char*));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    strcpy(c_array[i], String_val( Field(array, i) ));
  }

  printf("%d\n", max_str_len);
  fprintf(stderr,"%d\n", max_str_len);
  trexio_exit_code rc = trexio_write_metadata_author(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_metadata_package_version(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_package_version( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_metadata_package_version(value file, value max_str_len_in)
{
  CAMLparam2(file, max_str_len_in);
  int32_t max_str_len = Int_val(max_str_len_in);
  char result[max_str_len];
  trexio_exit_code rc = trexio_read_metadata_package_version( File_val(file), result, max_str_len);
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_string(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_metadata_package_version(value file, value data)
{
  CAMLparam2(file, data);
  const char* val = String_val(data);
  trexio_exit_code rc = trexio_write_metadata_package_version( File_val(file), val, (int32_t) strlen(val));
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_metadata_description(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_description( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_metadata_description(value file, value max_str_len_in)
{
  CAMLparam2(file, max_str_len_in);
  int32_t max_str_len = Int_val(max_str_len_in);
  char result[max_str_len];
  trexio_exit_code rc = trexio_read_metadata_description( File_val(file), result, max_str_len);
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_string(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_metadata_description(value file, value data)
{
  CAMLparam2(file, data);
  const char* val = String_val(data);
  trexio_exit_code rc = trexio_write_metadata_description( File_val(file), val, (int32_t) strlen(val));
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_metadata_unsafe(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_metadata_unsafe( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_metadata_unsafe(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_metadata_unsafe_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_metadata_unsafe(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_metadata_unsafe_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_delete_electron(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_electron( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_electron_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_electron_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_electron_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_electron_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_electron_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_electron_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_electron_up_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_electron_up_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_electron_up_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_electron_up_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_electron_up_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_electron_up_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_electron_dn_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_electron_dn_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_electron_dn_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_electron_dn_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_electron_dn_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_electron_dn_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_delete_nucleus(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_nucleus( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_nucleus_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_nucleus_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_nucleus_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_nucleus_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_nucleus_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_nucleus_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_nucleus_charge(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_nucleus_charge( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_nucleus_charge(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_nucleus_charge_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_nucleus_charge(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_nucleus_charge_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_nucleus_coord(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_nucleus_coord( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_nucleus_coord(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_nucleus_coord_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_nucleus_coord(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_nucleus_coord_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_nucleus_label(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_nucleus_label( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_nucleus_label(value file_in, value size_max_in, value max_str_len_in)
{
  CAMLparam3 ( file_in, size_max_in, max_str_len_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** read_data = (char**) malloc (size_max * sizeof(char*));
  read_data[0] = (char*) malloc (size_max * (int64_t) (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
     read_data[i] = read_data[i-1] + max_str_len+1;
  }
  trexio_exit_code rc = trexio_read_nucleus_label(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, caml_copy_string(read_data[i]) );
  }

  free(read_data[0]);
  free(read_data);

  CAMLreturn (result);

}

CAMLprim value caml_write_safe_nucleus_label(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char*));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    strcpy(c_array[i], String_val( Field(array, i) ));
  }

  printf("%d\n", max_str_len);
  fprintf(stderr,"%d\n", max_str_len);
  trexio_exit_code rc = trexio_write_nucleus_label(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_nucleus_point_group(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_nucleus_point_group( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_nucleus_point_group(value file, value max_str_len_in)
{
  CAMLparam2(file, max_str_len_in);
  int32_t max_str_len = Int_val(max_str_len_in);
  char result[max_str_len];
  trexio_exit_code rc = trexio_read_nucleus_point_group( File_val(file), result, max_str_len);
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_string(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_nucleus_point_group(value file, value data)
{
  CAMLparam2(file, data);
  const char* val = String_val(data);
  trexio_exit_code rc = trexio_write_nucleus_point_group( File_val(file), val, (int32_t) strlen(val));
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_nucleus_repulsion(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_nucleus_repulsion( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_nucleus_repulsion(value file)
{
  CAMLparam1(file);
  double result;
  trexio_exit_code rc = trexio_read_nucleus_repulsion_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_double(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_nucleus_repulsion(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_nucleus_repulsion_64( File_val(file), (double) Double_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_delete_ecp(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_ecp( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ecp_max_ang_mom_plus_1(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_max_ang_mom_plus_1( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_max_ang_mom_plus_1(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_ecp_max_ang_mom_plus_1_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_max_ang_mom_plus_1(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_ecp_max_ang_mom_plus_1_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ecp_z_core(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_z_core( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_z_core(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_ecp_z_core_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_z_core(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_ecp_z_core_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ecp_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_ecp_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_ecp_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_ecp_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_ecp_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ecp_ang_mom(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_ang_mom( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_ang_mom(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_ecp_ang_mom_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_ang_mom(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_ecp_ang_mom_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ecp_nucleus_index(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_nucleus_index( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_nucleus_index(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_ecp_nucleus_index_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_nucleus_index(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_ecp_nucleus_index_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ecp_exponent(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_exponent( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_exponent(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ecp_exponent_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_exponent(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ecp_exponent_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ecp_coefficient(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_coefficient( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_coefficient(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ecp_coefficient_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_coefficient(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ecp_coefficient_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ecp_power(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ecp_power( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ecp_power(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_ecp_power_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ecp_power(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_ecp_power_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_basis(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_basis( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_basis_type(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_type( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_basis_type(value file, value max_str_len_in)
{
  CAMLparam2(file, max_str_len_in);
  int32_t max_str_len = Int_val(max_str_len_in);
  char result[max_str_len];
  trexio_exit_code rc = trexio_read_basis_type( File_val(file), result, max_str_len);
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_string(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_basis_type(value file, value data)
{
  CAMLparam2(file, data);
  const char* val = String_val(data);
  trexio_exit_code rc = trexio_write_basis_type( File_val(file), val, (int32_t) strlen(val));
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_basis_prim_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_prim_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_basis_prim_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_basis_prim_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_basis_prim_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_basis_prim_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_basis_shell_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_shell_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_basis_shell_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_basis_shell_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_basis_shell_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_basis_shell_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_basis_nucleus_index(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_nucleus_index( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_nucleus_index(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_basis_nucleus_index_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_nucleus_index(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_basis_nucleus_index_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_basis_shell_ang_mom(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_shell_ang_mom( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_shell_ang_mom(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_basis_shell_ang_mom_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_shell_ang_mom(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_basis_shell_ang_mom_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_basis_shell_factor(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_shell_factor( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_shell_factor(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_basis_shell_factor_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_shell_factor(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_basis_shell_factor_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_basis_shell_index(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_shell_index( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_shell_index(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_basis_shell_index_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_shell_index(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_basis_shell_index_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_basis_exponent(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_exponent( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_exponent(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_basis_exponent_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_exponent(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_basis_exponent_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_basis_coefficient(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_coefficient( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_coefficient(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_basis_coefficient_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_coefficient(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_basis_coefficient_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_basis_prim_factor(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_basis_prim_factor( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_basis_prim_factor(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_basis_prim_factor_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_basis_prim_factor(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_basis_prim_factor_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_ao(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_ao( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ao_cartesian(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_cartesian( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_ao_cartesian(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_ao_cartesian_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_ao_cartesian(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_ao_cartesian_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ao_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_ao_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_ao_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_ao_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_ao_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ao_shell(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_shell( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_shell(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_ao_shell_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_shell(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_ao_shell_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_normalization(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_normalization( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_normalization(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_normalization_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_normalization(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_normalization_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_ao_1e_int(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_ao_1e_int( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ao_1e_int_overlap(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_overlap( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_overlap(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_overlap_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_overlap(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_overlap_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_kinetic(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_kinetic( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_kinetic(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_kinetic_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_kinetic(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_kinetic_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_potential_n_e(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_potential_n_e( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_potential_n_e(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_potential_n_e_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_potential_n_e(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_potential_n_e_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_ecp(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_ecp( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_ecp(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_ecp_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_ecp(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_ecp_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_core_hamiltonian(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_core_hamiltonian( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_core_hamiltonian(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_core_hamiltonian_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_core_hamiltonian(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_core_hamiltonian_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_overlap_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_overlap_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_overlap_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_overlap_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_overlap_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_overlap_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_kinetic_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_kinetic_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_kinetic_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_kinetic_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_kinetic_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_kinetic_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_potential_n_e_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_potential_n_e_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_potential_n_e_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_potential_n_e_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_potential_n_e_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_potential_n_e_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_ecp_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_ecp_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_ecp_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_ecp_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_ecp_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_ecp_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_ao_1e_int_core_hamiltonian_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_1e_int_core_hamiltonian_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_ao_1e_int_core_hamiltonian_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_ao_1e_int_core_hamiltonian_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_ao_1e_int_core_hamiltonian_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_ao_1e_int_core_hamiltonian_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_ao_2e_int(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_ao_2e_int( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_ao_2e_int_eri(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_2e_int_eri( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_ao_2e_int_eri(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_ao_2e_int_eri(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_ao_2e_int_eri(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_ao_2e_int_eri(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_has_ao_2e_int_eri_lr(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_ao_2e_int_eri_lr( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_ao_2e_int_eri_lr(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_ao_2e_int_eri_lr(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_ao_2e_int_eri_lr(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_ao_2e_int_eri_lr(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_delete_mo(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_mo( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_mo_type(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_type( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_mo_type(value file, value max_str_len_in)
{
  CAMLparam2(file, max_str_len_in);
  int32_t max_str_len = Int_val(max_str_len_in);
  char result[max_str_len];
  trexio_exit_code rc = trexio_read_mo_type( File_val(file), result, max_str_len);
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_string(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_mo_type(value file, value data)
{
  CAMLparam2(file, data);
  const char* val = String_val(data);
  trexio_exit_code rc = trexio_write_mo_type( File_val(file), val, (int32_t) strlen(val));
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_mo_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_mo_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_mo_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_mo_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_mo_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_mo_coefficient(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_coefficient( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_coefficient(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_coefficient_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_coefficient(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_coefficient_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_coefficient_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_coefficient_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_coefficient_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_coefficient_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_coefficient_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_coefficient_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_class(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_class( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_class(value file_in, value size_max_in, value max_str_len_in)
{
  CAMLparam3 ( file_in, size_max_in, max_str_len_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** read_data = (char**) malloc (size_max * sizeof(char*));
  read_data[0] = (char*) malloc (size_max * (int64_t) (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
     read_data[i] = read_data[i-1] + max_str_len+1;
  }
  trexio_exit_code rc = trexio_read_mo_class(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, caml_copy_string(read_data[i]) );
  }

  free(read_data[0]);
  free(read_data);

  CAMLreturn (result);

}

CAMLprim value caml_write_safe_mo_class(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char*));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    strcpy(c_array[i], String_val( Field(array, i) ));
  }

  printf("%d\n", max_str_len);
  fprintf(stderr,"%d\n", max_str_len);
  trexio_exit_code rc = trexio_write_mo_class(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_symmetry(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_symmetry( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_symmetry(value file_in, value size_max_in, value max_str_len_in)
{
  CAMLparam3 ( file_in, size_max_in, max_str_len_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** read_data = (char**) malloc (size_max * sizeof(char*));
  read_data[0] = (char*) malloc (size_max * (int64_t) (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
     read_data[i] = read_data[i-1] + max_str_len+1;
  }
  trexio_exit_code rc = trexio_read_mo_symmetry(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, caml_copy_string(read_data[i]) );
  }

  free(read_data[0]);
  free(read_data);

  CAMLreturn (result);

}

CAMLprim value caml_write_safe_mo_symmetry(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char*));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    strcpy(c_array[i], String_val( Field(array, i) ));
  }

  printf("%d\n", max_str_len);
  fprintf(stderr,"%d\n", max_str_len);
  trexio_exit_code rc = trexio_write_mo_symmetry(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_occupation(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_occupation( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_occupation(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_occupation_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_occupation(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_occupation_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_mo_1e_int(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_mo_1e_int( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_mo_1e_int_overlap(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_overlap( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_overlap(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_overlap_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_overlap(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_overlap_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_kinetic(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_kinetic( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_kinetic(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_kinetic_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_kinetic(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_kinetic_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_potential_n_e(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_potential_n_e( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_potential_n_e(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_potential_n_e_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_potential_n_e(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_potential_n_e_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_ecp(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_ecp( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_ecp(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_ecp_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_ecp(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_ecp_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_core_hamiltonian(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_core_hamiltonian( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_core_hamiltonian(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_core_hamiltonian_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_core_hamiltonian(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_core_hamiltonian_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_overlap_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_overlap_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_overlap_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_overlap_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_overlap_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_overlap_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_kinetic_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_kinetic_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_kinetic_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_kinetic_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_kinetic_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_kinetic_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_potential_n_e_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_potential_n_e_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_potential_n_e_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_potential_n_e_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_potential_n_e_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_potential_n_e_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_ecp_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_ecp_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_ecp_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_ecp_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_ecp_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_ecp_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_mo_1e_int_core_hamiltonian_im(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_1e_int_core_hamiltonian_im( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_mo_1e_int_core_hamiltonian_im(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_mo_1e_int_core_hamiltonian_im_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_mo_1e_int_core_hamiltonian_im(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_mo_1e_int_core_hamiltonian_im_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_mo_2e_int(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_mo_2e_int( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_mo_2e_int_eri(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_2e_int_eri( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_mo_2e_int_eri(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_mo_2e_int_eri(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_mo_2e_int_eri(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_mo_2e_int_eri(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_has_mo_2e_int_eri_lr(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_mo_2e_int_eri_lr( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_mo_2e_int_eri_lr(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_mo_2e_int_eri_lr(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_mo_2e_int_eri_lr(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_mo_2e_int_eri_lr(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_delete_determinant(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_determinant( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_determinant_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_determinant_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_determinant_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_determinant_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}


CAMLprim value caml_has_determinant_list(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_determinant_list( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_has_determinant_coefficient(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_determinant_coefficient( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_delete_state(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_state( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_state_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_state_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_state_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_state_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_state_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_state_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_state_label(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_state_label( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_state_label(value file_in, value size_max_in, value max_str_len_in)
{
  CAMLparam3 ( file_in, size_max_in, max_str_len_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** read_data = (char**) malloc (size_max * sizeof(char*));
  read_data[0] = (char*) malloc (size_max * (int64_t) (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
     read_data[i] = read_data[i-1] + max_str_len+1;
  }
  trexio_exit_code rc = trexio_read_state_label(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, caml_copy_string(read_data[i]) );
  }

  free(read_data[0]);
  free(read_data);

  CAMLreturn (result);

}

CAMLprim value caml_write_safe_state_label(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char*));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    strcpy(c_array[i], String_val( Field(array, i) ));
  }

  printf("%d\n", max_str_len);
  fprintf(stderr,"%d\n", max_str_len);
  trexio_exit_code rc = trexio_write_state_label(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_rdm(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_rdm( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_rdm_1e(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_1e( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_rdm_1e(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_rdm_1e_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_rdm_1e(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_rdm_1e_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_rdm_1e_up(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_1e_up( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_rdm_1e_up(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_rdm_1e_up_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_rdm_1e_up(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_rdm_1e_up_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_rdm_1e_dn(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_1e_dn( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_rdm_1e_dn(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_rdm_1e_dn_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_rdm_1e_dn(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_rdm_1e_dn_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_rdm_2e(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_2e( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_rdm_2e(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_rdm_2e(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_rdm_2e(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_rdm_2e(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_has_rdm_2e_upup(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_2e_upup( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_rdm_2e_upup(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_rdm_2e_upup(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_rdm_2e_upup(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_rdm_2e_upup(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_has_rdm_2e_dndn(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_2e_dndn( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_rdm_2e_dndn(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_rdm_2e_dndn(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_rdm_2e_dndn(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_rdm_2e_dndn(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_has_rdm_2e_updn(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_2e_updn( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_rdm_2e_updn(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_rdm_2e_updn(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_rdm_2e_updn(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_rdm_2e_updn(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_has_rdm_2e_dnup(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_rdm_2e_dnup( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_rdm_2e_dnup(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_rdm_2e_dnup(file, offset, &buffer_size,
                                               index_sparse_read, size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple(4+1);
    for (int j=0 ; j<4 ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[4*i+j] ));
    }
    Store_field(data, 4, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_rdm_2e_dnup(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc (4*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<4 ; ++j) {
      index_sparse_write[4*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, 4) );
  }

  trexio_exit_code rc = trexio_write_safe_rdm_2e_dnup(file, offset, buffer_size,
                                               index_sparse_write, size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}



CAMLprim value caml_delete_cell(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_cell( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_cell_a(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_cell_a( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_cell_a(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_cell_a_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_cell_a(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_cell_a_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_cell_b(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_cell_b( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_cell_b(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_cell_b_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_cell_b(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_cell_b_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_cell_c(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_cell_c( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_cell_c(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_cell_c_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_cell_c(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_cell_c_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_pbc(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_pbc( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_pbc_periodic(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_pbc_periodic( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_pbc_periodic(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_pbc_periodic_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_pbc_periodic(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_pbc_periodic_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_pbc_k_point(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_pbc_k_point( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_pbc_k_point(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_pbc_k_point_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_pbc_k_point(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_pbc_k_point_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_delete_qmc(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_qmc( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_qmc_num(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_qmc_num( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_qmc_num(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_qmc_num_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_qmc_num(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_qmc_num_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_qmc_point(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_qmc_point( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_qmc_point(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_qmc_point_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_qmc_point(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_qmc_point_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_qmc_psi(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_qmc_psi( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_qmc_psi(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_qmc_psi_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_qmc_psi(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_qmc_psi_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}


CAMLprim value caml_has_qmc_e_loc(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_qmc_e_loc( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}

CAMLprim value caml_read_safe_qmc_e_loc(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_qmc_e_loc_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_qmc_e_loc(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_qmc_e_loc_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}

/**** ****/

CAMLprim value caml_read_determinant_list(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal4 ( result, detup, detdn, det );

  trexio_t* file = File_val(file_in);
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int32_t int_num = 0;
  trexio_exit_code rc = trexio_get_int64_num(file, &int_num);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  int64_t* buffer = (int64_t*) malloc ( buffer_size * int_num * 2 * sizeof(int64_t) );

  rc = trexio_read_determinant_list (file, offset, &buffer_size, buffer);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  size_t icount = 0;
  for (size_t i=0 ; i<buffer_size ; ++i) {
     detup = caml_alloc_initialized_string(int_num*sizeof(int64_t), (char*) &(buffer[icount]));
     icount += int_num;
     detdn = caml_alloc_initialized_string(int_num*sizeof(int64_t), (char*) &(buffer[icount]));
     icount += int_num;
     det = caml_alloc_tuple(2);
     Store_field( det, 0, detup );
     Store_field( det, 1, detdn );
     Store_field( result, i, det );
  }

  free(buffer);
  CAMLreturn(result);
}

CAMLprim value caml_write_determinant_list(value file_in, value offset_in, value array)
{
  CAMLparam3 ( file_in, offset_in, array );
  CAMLlocal3 ( detup, detdn, det );

  trexio_t* file = File_val(file_in);
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( array );

  int32_t int_num = 0;
  trexio_exit_code rc = trexio_get_int64_num(file, &int_num);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  int64_t* buffer = (int64_t*) malloc ( buffer_size * int_num * 2 * sizeof(int64_t) );

  for (size_t i=0 ; i<buffer_size ; ++i) {
    det = Field(array, i);
    detup = Field(det, 0);
    detdn = Field(det, 1);
    memcpy(&(buffer[i*int_num*2]), String_val(detup), int_num*sizeof(int64_t));
    memcpy(&(buffer[i*int_num*2 + int_num]), String_val(detdn), int_num*sizeof(int64_t));
  }

  rc = trexio_write_determinant_list (file, offset, buffer_size, buffer);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(buffer);
  CAMLreturn( Val_unit );
}

CAMLprim value caml_read_determinant_coefficient(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val(file_in);
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  double* buffer = (double*) malloc ( buffer_size * sizeof(double) );

  trexio_exit_code rc = trexio_read_determinant_coefficient (file, offset, &buffer_size, buffer);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size * Double_wosize, Double_array_tag);
  for (size_t i=0 ; i<buffer_size ; ++i) {
     Store_double_field( result, i, buffer[i]);
  }

  free(buffer);
  CAMLreturn(result);
}


CAMLprim value caml_write_determinant_coefficient(value file_in, value offset_in, value array)
{
  CAMLparam3 ( file_in, offset_in, array );

  trexio_t* file = File_val(file_in);
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( array );

  double* buffer = (double*) malloc ( buffer_size * sizeof(double) );

  for (size_t i=0 ; i<buffer_size ; ++i) {
    buffer[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_determinant_coefficient (file, offset, buffer_size, buffer);
  if (rc != TREXIO_SUCCESS) {
     caml_failwith(trexio_string_of_error(rc));
  }

  free(buffer);
  CAMLreturn( Val_unit );
}


