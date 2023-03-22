#!/bin/bash
#
# script que cambia el nombre de los ensambles, los deja cortos y con terminación .fa
#


for file in ./*; do
   # remueve todo lo que viene despues del nombre del aislado, para todos los aislados
   mv "${file}" "$(basename ${file} | cut -d '-' -f '1')"

   # le agrega la termiacion .fa del formato fasta, para todos los aislados
   dn=$(dirname $file)
   fn=$(basename $file)
   mv "$file" "${dn}/${fn}.fa"
done




