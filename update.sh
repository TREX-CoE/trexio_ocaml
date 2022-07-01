#!/bin/bash -x

git submodule init trexio
ROOT=$PWD
OCAMLDIR=trexio/ocaml/trexio
cd trexio
git pull
#rm -rf _install
#mkdir _install
#
#./autogen.sh
#./configure --prefix=$PWD/_install
make
make check
make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/_install/lib
export LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/_install/lib
export C_INCLUDE_PATH=$C_INCLUDE_PATH:$PWD/_install/include

cd $OCAMLDIR
python3 ./read_json.py

#make
cd $ROOT
cp $OCAMLDIR/dune-project .
rm -rf lib
cp -r $OCAMLDIR/lib .

git add dune-project lib
git submodule deinit trexio




