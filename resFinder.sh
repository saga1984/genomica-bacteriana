#!/bin/bash

#
# Ejecutar resfinder.py en modo pointfinder, sobre todos los ensambles en un directorio
#

DIR="ALL_RES.FINDER"
if [[ ! -d "${DIR}" ]]; then
   mkdir ${DIR}
fi

conteo=0
for ensamble in *.fa; do
   conteo=$[ $conteo + 1 ]
   ensamble_name="$(basename $ensamble | cut -d "_" -f 1)" # guardar el ID de la secuencia
   # mostrar numero y nombre del ensamble
   echo -e "$conteo: \t$ensamble_name"
   # ejecutar resfinder
   resfinder.py -i ./$ensamble -p $resfinder_db  -mp /home/vangie/miniconda3/envs/Blast/bin/blastn > RF_${ensamble_name}.txt
   # filtrar el resultado
   grep "resistance_gene" RF_${ensamble_name}.txt | awk '{print $2}' | tr -d ",''" | tr -d '""'> RF_${ensamble_name}_filtrado.txt
   # mostrar el resultado filtrado, luego mover los archivos a la carpeta ALL_RES.FINDER
   echo "$(cat RF_${ensamble_name}_filtrado.txt)"
   mv RF_${ensamble_name}_filtrado.txt ${DIR}
   mv RF_${ensamble_name}.txt  ${DIR}
   echo -e "\n"
done > ALL_ResFinder.txt

mv ALL_ResFinder.txt ${DIR}
rm -r -f tmp *json*

