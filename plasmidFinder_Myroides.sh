#!/bin/bash

#
# Script para ejecutar plasmidifnder sobre todos los ensambles contenidos en un directorio
#

# iniciar conteo en 0
conteo=0
DIR=PLASMIDS_l60_t60
if [[ ! -d ${DIR} ]]; then
   mkdir ${DIR}
fi

# for loop para todos los ensambles en el directorio ASSEBLY
for ensamble in ASSEMBLY/*.fa; do
   # aumentar en 1 el conteo en cada paso del for loop
   conteo=$[ ${conteo} + 1 ]
   # guardar el ID de la secuencia
   ensamble_name=$(basename ${ensamble} .fa)
   # mostrar numero y nombre del ensamble
   echo -e "$conteo:\t$ensamble_name"
   # crear una carpeta para cada ensamble
   mkdir ${DIR}/PF_${ensamble_name}
   # ejecutar plasmidfinder
<<<<<<< HEAD
   plasmidfinder.py -i ${ensamble} -p ${plasmidfinder_db} -l 0.6 -t 0.6 -mp ${blastn} -o ${DIR}/PF_${ensamble_name}
=======
   plasmidfinder.py -i ${ensamble} -p ${plasmidfinder_db} -l 0.6 -t 0.6 -mp ${blastn} > PF_${ensamble_name}.txt
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
   # filtrar solo primeras tres columnas
   awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$3}' ${DIR}/PF_${ensamble_name}/results_tab.tsv > ${DIR}/PF_${ensamble_name}/results_corto.tsv
   # convertir a archivo CSV
   awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3}' ${DIR}/PF_${ensamble_name}/results_corto.tsv > ${DIR}/PF_${ensamble_name}/results_corto.csv
done

# ----------------------------------
#  Generar resultados mas amigables
# ----------------------------------

# unir todos los resultados (cortos) en un solo archivo TSV y convertir a CSV (conservando ambos)
conteo=0
for dir in ${DIR}/PF_*; do
   conteo=$[ $conteo + 1 ]
<<<<<<< HEAD
   echo -e "$conteo:\t$(basename ${dir} .fa)\n$(cat ${dir}/results_corto.tsv)\n"
=======
   echo -e "$conteo:\t$(basename ${dir} | cut -d '_' -f '2')\n$(cat ${dir}/results_corto.tsv)\n"
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
done > ${DIR}/all_plasmids.tsv

awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3}' ${DIR}/all_plasmids.tsv > ${DIR}/all_plasmids.csv
