#!/bin/bash

#
# Prepara archivos de blastx e identifica mutaciones puntuales, guarda resultados globales en un solo archivo
#

# correr script para preparar resultados de blast previo a encontrar mutaciones
mismatch_prepare.sh

# nombre del gen
gname="$(pwd | cut -d '/' -f '10,11')"

# conteo del 1 al 5 (sin contar el 2)
for (( i = 1; i < 6; i++)); do
   if [[ i -eq 2 ]]; then
      continue # no tomar en cuenta Sample 2
   else
      # correr el script de python mismatch.py
      mismatch.py -q $(cat Query_S${i}.txt) -s $(cat Subject_S${i}.txt) > mismatches_${i}.txt
      echo -e "Sample0${i} ${gname} mismatches: \n$(cat mismatches_${i}.txt) \n"
   fi
# guardar todos los resultados en un solo archivo
done > mismatches_all_results.txt
