#!/bin/bash

#
# Parseo que obtiene la identidad (del valor de Identities mas alto) de todos los resultados de blast en una carpeta
#


for file in blast_*; do
   file_name="$(basename $file | cut -d "_" -f "2,3")"
   cat $file |  grep "Identities" | sed -n "1 p" | awk '{print $4}' | tr -d "()" | tr -d "," | tr -d "%" > identidad_$file_name
   echo -e "$file_name \t$(cat identidad_$file_name)"
   rm identidad_$file_name
done > Identidades.xlsx

