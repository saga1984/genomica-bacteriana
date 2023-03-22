#!/bin/bash

#
# Ejecutar AMRFinderPlus para encontrar mutaciones puntuales, sobre todos los ensambles en un directorio
#

DIR=ALL_MUT_AMR.FINDER
if [[ ! -d "${DIR}" ]]; then
   mkdir ${DIR}
fi

conteo=0
for ensamble in *.fa; do
   conteo=$[ $conteo + 1]
   ensamble_name="$(basename $ensamble | cut -d "_" -f 1)" # guardar el ID de la secuencia
   # mostrar numero y nombre de ensamble
   echo -e "$conteo: \t$ensamble_name"
   # ejecutar amrfinder
   amrfinder -n $ensamble -O Salmonella --plus > AMRF_mut_${ensamble_name}.txt
   # filtrar el resultado
   awk 'BEGIN {OFS="\t"} {print $6, $12}' AMRF_mut_${ensamble_name}.txt | grep -v "Stop" > AMRF_mut_${ensamble_name}_filtrado.txt
   # mostrar el resultado filtrado, luego mover los archivos a la carpeta ALL_MUT_AMR.FINDER
   echo "$(cat AMRF_${ensamble_name}_filtrado.txt)"
   mv AMRF_mut_${ensamble_name}_filtrado.txt ${DIR}
   mv AMRF_mut_${ensamble_name}.txt ${DIR}
   echo -e "\n"
done

# moverse al directorio donde estan todos los archivos
cd ${DIR}

conteo=0
for file in *filtrado*; do
   file_name=$(basename $file | cut -d "_" -f 3) # guardar el ID de la secuencia como una variable
   conteo=$[ $conteo +1 ] # hacer un conteo de archivos
   # mostrar numero consecutivoy nombre del archivo (ensamble)
   echo -e "$conteo: \t$file_name"
   echo "$(cat $file)"
   echo -e "\n"
done > ALL_MUT_AMRFinder.txt

# regresar al directorio original
cd ../

rm -r -f tmp *json*
