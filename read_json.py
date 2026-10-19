#!/usr/bin/env python

import json
import os
import re
import sys

# input json: argv[1], else the committed trex.json.
json_file  = "trex.json"
stubs_file = "trexio_stubs.c"
ml_file    = "trexio.ml"
mli_file   = ml_file + "i"

def fail(msg):
    print(msg, file=sys.stderr)
    sys.exit(1)

def split_template(name, marker):
    """(pre, post) = src/<name> text split at its code-gen marker."""
    lines = open("src/"+name).readlines()
    i = next((i for i, l in enumerate(lines) if l.startswith(marker)), None)
    if i is None: fail("no %r marker in src/%s" % (marker, name))
    return "".join(lines[:i]), "".join(lines[i:])

def emit(f, t, group, element, type_):
    f.write("".join(s.replace("{group}", group).replace("{element}", element)
                    .replace("{type}", type_) for s in t))

def check_version():
    # dune-project is the single source of truth for the binding version.
    with open('dune-project','r') as f:
       for line in f:
          if line.startswith("(version"):
             dune_version = line.split()[1].strip().replace(')','')
             break
       else:
          fail("dune-project: no (version ...) line found")

    # 2.6.1NN = TREXIO C library 2.6.1 (patch/100) + 2-digit binding revision NN
    m = re.fullmatch(r"([0-9]+)\.([0-9]+)\.([0-9]+)", dune_version)
    if m is None or len(m.group(3)) < 3:
       fail("dune-project version '%s' must be A.B.CNN (C patch + 2-digit "
            "binding revision, e.g. 2.6.101)" % dune_version)

    # The opam record must carry the same version.
    if not os.path.exists("trexio.opam"):
       fail("opam file trexio.opam not found")
    with open("trexio.opam","r") as f:
       for line in f:
          if line.startswith("version:"):
             opam_version = line.split()[1].strip().strip('"')
             break
       else:
          fail("trexio.opam: no version: line found")
    if opam_version != dune_version:
       fail("Inconsistent versions:\n"
            "dune-project: %s\n%s: %s\n"
            % (dune_version, "trexio.opam", opam_version))

def write_stubs(data):

    content_pre, content_post = split_template(stubs_file, "/**** ****/")

    with open("lib/"+stubs_file,'w') as f:
        f.write(content_pre)

        for group in data:
            t = """
CAMLprim value caml_delete_{group}(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_delete_{group}( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_has_{group}(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_{group}( File_val(file) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_bool(true) );
  } else {
    CAMLreturn ( Val_bool(false) );
  }
}
"""
            f.write( t.replace("{group}",group) )

            for element in data[group]:
                t = """
CAMLprim value caml_has_{group}_{element}(value file)
{
  CAMLparam1(file);
  trexio_exit_code rc = trexio_has_{group}_{element}( File_val(file) );
  CAMLreturn ( Val_bool(rc == TREXIO_SUCCESS) );
}
"""
                f.write( t.replace("{group}", group)
                          .replace("{element}", element) )

                # Scalar elements
                if data[group][element][1] == []:

                    if data[group][element][0] in [ "int", "dim", "index" ]:
                        t = """
CAMLprim value caml_read_{group}_{element}(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_{group}_{element}_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_{group}_{element}(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_{group}_{element}_64( File_val(file), (int64_t) Int_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}
"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{type}", data[group][element][0]) )

                    elif data[group][element][0] in [ "float" ]:
                        t = """
CAMLprim value caml_read_{group}_{element}(value file)
{
  CAMLparam1(file);
  double result;
  trexio_exit_code rc = trexio_read_{group}_{element}_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( caml_copy_double(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_{group}_{element}(value file, value data)
{
  CAMLparam2(file, data);
  trexio_exit_code rc = trexio_write_{group}_{element}_64( File_val(file), (double) Double_val(data) );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}
"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{type}", data[group][element][0]) )

                    elif data[group][element][0] in [ "string" ]:
                        t = """
CAMLprim value caml_read_{group}_{element}(value file, value max_str_len_in)
{
  CAMLparam2(file, max_str_len_in);
  int32_t max_str_len = Int_val(max_str_len_in);
  char* result = (char*) malloc((size_t) max_str_len);
  trexio_exit_code rc = trexio_read_{group}_{element}( File_val(file), result, max_str_len);
  if (rc == TREXIO_SUCCESS) {
    value v = caml_copy_string(result);
    free(result);
    CAMLreturn ( v );
  } else {
    free(result);
    caml_failwith(trexio_string_of_error(rc));
  }
}

CAMLprim value caml_write_{group}_{element}(value file, value data)
{
  CAMLparam2(file, data);
  const char* val = String_val(data);
  trexio_exit_code rc = trexio_write_{group}_{element}( File_val(file), val, (int32_t) strlen(val));
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_unit );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}
"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{type}", data[group][element][0]) )

                    if data[group][element][0] in [ "dim readonly" ]:
                        t = """
CAMLprim value caml_read_{group}_{element}(value file)
{
  CAMLparam1(file);
  int64_t result;
  trexio_exit_code rc = trexio_read_{group}_{element}_64( File_val(file), &result );
  if (rc == TREXIO_SUCCESS) {
    CAMLreturn ( Val_int(result) );
  } else {
    caml_failwith(trexio_string_of_error(rc));
  }
}

"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                      .replace("{type}", data[group][element][0].split()[0]) )

                # Array elements
                else:

                    if data[group][element][0] in [ "float" ]:
                        t = """
CAMLprim value caml_read_safe_{group}_{element}(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* read_data = (double*) malloc (size_max * sizeof(double));
  trexio_exit_code rc = trexio_read_safe_{group}_{element}_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     free(read_data);
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc_float_array((mlsize_t) size_max);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_double_field( result, i, read_data[i] );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_{group}_{element}(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  double* c_array = (double*) malloc (size_max * sizeof(double));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Double_field(array, i);
  }

  trexio_exit_code rc = trexio_write_safe_{group}_{element}_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     free(c_array);
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}

"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{type}", data[group][element][0]) )

                    elif data[group][element][0] in [ "int", "index", "dim" ]:
                        t = """
CAMLprim value caml_read_safe_{group}_{element}(value file_in, value size_max_in)
{
  CAMLparam2 ( file_in, size_max_in );
  CAMLlocal1 ( result );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* read_data = (int64_t*) malloc (size_max * sizeof(int64_t));
  trexio_exit_code rc = trexio_read_safe_{group}_{element}_64(file, read_data, size_max);
  if (rc != TREXIO_SUCCESS) {
     free(read_data);
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(size_max, 0);
  for (size_t i=0 ; i<size_max ; ++i) {
    Store_field( result, i, Val_int(read_data[i]) );
  }
  free(read_data);

  CAMLreturn (result);
}

CAMLprim value caml_write_safe_{group}_{element}(value file_in, value size_max_in, value array)
{
  CAMLparam3 ( file_in, size_max_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);

  int64_t* c_array = (int64_t*) malloc (size_max * sizeof(int64_t));
  for (size_t i=0 ; i<size_max ; ++i) {
    c_array[i] = Int_val( Field(array, i) );
  }

  trexio_exit_code rc = trexio_write_safe_{group}_{element}_64(file, c_array, size_max);
  if (rc != TREXIO_SUCCESS) {
     free(c_array);
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array);

  CAMLreturn ( Val_unit );
}

"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{type}", data[group][element][0]) )

                    elif data[group][element][0] in [ "string" ]:
                        t = """
CAMLprim value caml_read_safe_{group}_{element}(value file_in, value size_max_in, value max_str_len_in)
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
  trexio_exit_code rc = trexio_read_{group}_{element}(file, read_data, max_str_len);

  if (rc != TREXIO_SUCCESS) {
     free(read_data[0]); free(read_data);
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

CAMLprim value caml_write_safe_{group}_{element}(value file_in, value size_max_in, value max_str_len_in, value array)
{
  CAMLparam4 ( file_in, size_max_in, max_str_len_in, array );

  trexio_t* file = File_val( file_in );
  int64_t size_max = (int64_t) Int_val(size_max_in);
  int32_t max_str_len = Int_val(max_str_len_in);

  char** c_array = (char**) malloc (size_max * sizeof(char*));
  c_array[0] = (char*) malloc (size_max * (max_str_len+1) * sizeof(char));
  for (size_t i=1 ; i<size_max ; ++i) {
    c_array[i] = c_array[i-1] + max_str_len+1;
  }
  for (size_t i=0 ; i<size_max ; ++i) {
    const char* s = String_val( Field(array, i) );
    if (strlen(s) > (size_t)max_str_len) {
      free(c_array[0]); free(c_array);
      caml_invalid_argument("trexio: string longer than max_str_len");
    }
    strcpy(c_array[i], s);
  }
  trexio_exit_code rc = trexio_write_{group}_{element}(file, (const char**) c_array, max_str_len);
  if (rc != TREXIO_SUCCESS) {
     free(c_array[0]); free(c_array);
     caml_failwith(trexio_string_of_error(rc));
  }
  free(c_array[0]);
  free(c_array);

  CAMLreturn ( Val_unit );
}

"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{type}", data[group][element][0]) )

                    if data[group][element][0] in [ "float sparse" ]:
                        size = len(data[group][element][1])
                        t = """
CAMLprim value caml_read_{group}_{element}(value file_in, value offset_in, value buffer_size_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_size_in );
  CAMLlocal2 ( result, data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Int_val( buffer_size_in );

  int64_t size_max = buffer_size;
  int32_t* index_sparse_read = (int32_t*) malloc ({size}*size_max*sizeof(int32_t));
  double* value_sparse_read = (double*) malloc (size_max*sizeof(double));

  trexio_exit_code rc = trexio_read_safe_{group}_{element}(file, offset, &buffer_size,
                                               index_sparse_read, {size}*size_max,
                                               value_sparse_read, size_max);

  if (rc != TREXIO_SUCCESS) {
     free(index_sparse_read); free(value_sparse_read);
     caml_failwith(trexio_string_of_error(rc));
  }

  result = caml_alloc(buffer_size, 0);
  for (size_t i=0 ; i<buffer_size ; ++i) {
    data = caml_alloc_tuple({size}+1);
    for (int j=0 ; j<{size} ; ++j) {
      Store_field(data, j, Val_int( index_sparse_read[{size}*i+j] ));
    }
    Store_field(data, {size}, caml_copy_double( value_sparse_read[i] ));
    Store_field(result, i, data);
  }

  free(index_sparse_read);
  free(value_sparse_read);

  CAMLreturn(result);

}


CAMLprim value caml_write_{group}_{element}(value file_in, value offset_in, value buffer_in)
{
  CAMLparam3 ( file_in, offset_in, buffer_in );
  CAMLlocal1 ( data );

  trexio_t* file = File_val( file_in );
  int64_t offset = Int_val( offset_in );
  int64_t buffer_size = Wosize_val( buffer_in );
  const int64_t size_max = buffer_size;

  int32_t* index_sparse_write = (int32_t*) malloc ({size}*size_max*sizeof(int32_t));
  double* value_sparse_write = (double*) malloc (size_max*sizeof(double));

  for (size_t i=0 ; i<buffer_size ; ++i) {

    data = Field(buffer_in, i);
    for (int j=0 ; j<{size} ; ++j) {
      index_sparse_write[{size}*i+j] = Int_val( Field(data, j) );
    }
    value_sparse_write[i] = Double_val( Field(data, {size}) );
  }

  trexio_exit_code rc = trexio_write_safe_{group}_{element}(file, offset, buffer_size,
                                               index_sparse_write, {size}*size_max,
                                               value_sparse_write, size_max);

  if (rc != TREXIO_SUCCESS) {
     free(index_sparse_write); free(value_sparse_write);
     caml_failwith(trexio_string_of_error(rc));
  }

  free(index_sparse_write);
  free(value_sparse_write);

  CAMLreturn( Val_unit );

}


"""
                        f.write( t.replace("{group}", group)
                                  .replace("{element}", element)
                                  .replace("{size}", str(size))
                                  .replace("{type}", data[group][element][0]) )

        f.write(content_post)

def write_mli(data):

    content_pre, content_post = split_template(mli_file, "(**** ****)")

    with open("lib/"+mli_file,'w') as f:
        f.write(content_pre)

        for group in data:
            t  = "val delete_{group}: trexio_file -> unit\n"
            t += "val has_{group}: trexio_file -> bool\n"
            f.write( t.replace("{group}",group) )

            for element in data[group]:
                t = "val has_{group}_{element}: trexio_file -> bool\n"
                f.write( t.replace("{group}", group)
                          .replace("{element}", element) )

                # Scalar elements
                if data[group][element][1] == []:

                    if data[group][element][0] in [ "int", "float", "dim", "index" ]:
                        t = [ "val read_{group}_{element} : trexio_file -> {type}\n" ,
                              "val write_{group}_{element}: trexio_file -> {type} -> unit\n" ]
                        emit(f, t, group, element, data[group][element][0])

                    elif data[group][element][0] in [ "string" ]:
                        t = [ "val read_{group}_{element} : ?max_str_len:int -> trexio_file -> {type}\n" ,
                              "val write_{group}_{element}: trexio_file -> {type} -> unit\n" ]
                        emit(f, t, group, element, data[group][element][0])

                    elif data[group][element][0] in [ "dim readonly" ]:
                        t = [ "val read_{group}_{element} : trexio_file -> {type}\n" ]
                        emit(f, t, group, element, data[group][element][0].split()[0])

                # Arrays
                else:

                    if data[group][element][0] in [ "int", "float", "dim", "index" ]:
                        t = [ "val read_safe_{group}_{element} : trexio_file -> int -> {type} array\n" ,
                              "val write_safe_{group}_{element}: trexio_file -> int -> {type} array -> unit\n"
                              "val read_{group}_{element} : trexio_file -> {type} array\n" ,
                              "val write_{group}_{element}: trexio_file -> {type} array -> unit\n"
]
                        emit(f, t, group, element, data[group][element][0])

                    elif data[group][element][0] in [ "string" ]:
                        t = [ "val read_safe_{group}_{element} : trexio_file -> int -> int -> {type} array\n" ,
                              "val write_safe_{group}_{element}: trexio_file -> int -> int -> {type} array -> unit\n"
                              "val read_{group}_{element} : ?max_str_len:int -> trexio_file -> {type} array\n" ,
                              "val write_{group}_{element}: trexio_file -> {type} array -> unit\n"
]
                        emit(f, t, group, element, data[group][element][0])

                    elif data[group][element][0] in [ "float sparse" ]:
                        size = len(data[group][element][1])
                        typ = "(" + "*".join( [ "int" for _ in range(size) ]) + " * float) array"
                        t = [ "val read_{group}_{element} : trexio_file -> offset:dim -> buffer_size:dim -> {type}\n" ,
                              "val write_{group}_{element} : trexio_file -> offset:dim -> {type} -> unit\n" ,
                            ]
                        emit(f, t, group, element, typ)

        f.write(content_post)


def write_ml(data):

    content_pre, content_post = split_template(ml_file, "(**** ****)")

    with open("lib/"+ml_file,'w') as f:
        f.write(content_pre)

        for group in data:
            t  = "external delete_{group}: trexio_file -> unit = \"caml_delete_{group}\"\n"
            t += "external has_{group}: trexio_file -> bool = \"caml_has_{group}\"\n"
            f.write( t.replace("{group}",group) )

            for element in data[group]:
                t = "external has_{group}_{element}: trexio_file -> bool = \"caml_has_{group}_{element}\"\n"
                f.write( t.replace("{group}", group)
                          .replace("{element}", element) )

                # Scalar elements
                if data[group][element][1] == []:

                    if data[group][element][0] in [ "int", "float", "dim", "index" ]:
                        t = [ "external read_{group}_{element} : trexio_file -> {type} = \"caml_read_{group}_{element}\"\n" ,
                              "external write_{group}_{element}: trexio_file -> {type} -> unit = \"caml_write_{group}_{element}\"\n" ]
                        emit(f, t, group, element, data[group][element][0])

                    if data[group][element][0] in [ "string" ]:
                        t = [ "external read_{group}_{element}_c : trexio_file -> int -> {type} = \"caml_read_{group}_{element}\"\n" ,
                              "let read_{group}_{element} ?(max_str_len=8192) f = read_{group}_{element}_c f max_str_len\n",
                              "external write_{group}_{element}: trexio_file -> {type} -> unit = \"caml_write_{group}_{element}\"\n" ]
                        emit(f, t, group, element, data[group][element][0])

                    elif data[group][element][0] in [ "dim readonly" ]:
                        t = [ "external read_{group}_{element} : trexio_file -> {type} = \"caml_read_{group}_{element}\"\n" ]
                        emit(f, t, group, element, data[group][element][0].split()[0])

                # Arrays
                else:

                    if data[group][element][0] in [ "int", "float", "dim", "index" ]:
                        t = [ "external read_safe_{group}_{element} : trexio_file -> int -> {type} array = \"caml_read_safe_{group}_{element}\"\n" ,
                              "external write_safe_{group}_{element}: trexio_file -> int -> {type} array -> unit = \"caml_write_safe_{group}_{element}\"\n",
                               "let read_{group}_{element} f = \n  let size = 1 in \n"]
                        t_prime = []
                        for dim in data[group][element][1]:
                            try:    # A dimensioning variable
                              dim_group, dim_element = dim.split('.')
                              t_prime += [f"  let size = size * read_{dim_group}_{dim_element} f in\n"]
                            except: # Only an integer
                              t_prime += [f"  let size = size * {dim} in\n"]

                        t += t_prime
                        t += [ "  read_safe_{group}_{element} f size\n\n" ]
                        t += [ "let write_{group}_{element} f a = \n  let size = 1 in \n"]
                        t += t_prime
                        t += [ "  write_safe_{group}_{element} f size a\n\n" ]
                        emit(f, t, group, element, data[group][element][0])

                    elif data[group][element][0] in [ "string" ]:
                        t = [ "external read_safe_{group}_{element} : trexio_file -> int -> int -> {type} array = \"caml_read_safe_{group}_{element}\"\n" ,
                              "external write_safe_{group}_{element}: trexio_file -> int -> int -> {type} array -> unit = \"caml_write_safe_{group}_{element}\"\n",
                               "let read_{group}_{element} ?(max_str_len=1024) f = \n  let size = 1 in \n"]
                        t_prime = []
                        for dim in data[group][element][1]:
                            try:    # A dimensioning variable
                              dim_group, dim_element = dim.split('.')
                              t_prime += [f"  let size = size * read_{dim_group}_{dim_element} f in\n"]
                            except: # Only an integer
                              t_prime += [f"  let size = size * {dim} in\n"]

                        t += t_prime
                        t += [ "  read_safe_{group}_{element} f size max_str_len\n\n" ,
                               "let write_{group}_{element} f a = \n  let size = 1 in \n",
                               "  let max_str_len = Array.map String.length a\n" ,
                               "      |> Array.fold_left (fun x y -> if x>y then x else y) 0\n",
                               "      |> (+) 1 in\n" ]
                        t += t_prime
                        t += [ "  write_safe_{group}_{element} f size max_str_len a\n\n" ]
                        emit(f, t, group, element, data[group][element][0])


                    elif data[group][element][0] in [ "float sparse" ]:
                        size = len(data[group][element][1])
                        typ = "(" + "*".join( [ "int" for _ in range(size) ]) + " * float) array"
                        t = [ "external read_{group}_{element} : trexio_file -> offset:dim -> buffer_size:dim -> {type} = \"caml_read_{group}_{element}\"\n" ,
                              "external write_{group}_{element} : trexio_file -> offset:dim -> {type} -> unit = \"caml_write_{group}_{element}\"\n"
                            ]
                        emit(f, t, group, element, typ)

        f.write(content_post)




def main():

    global json_file
    if len(sys.argv) > 1:
        json_file = sys.argv[1]

    check_version()
    with open(json_file,'r') as f:
        data = json.load(f)
        for group in data:
          for element in data[group]:
             if data[group][element][0] == "str":
                  data[group][element][0] = "string"

    write_ml(data)
    write_mli(data)
    write_stubs(data)

if __name__ == "__main__":
    main()

