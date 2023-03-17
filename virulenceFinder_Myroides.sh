#!/bin/bash

# -------------------------------------------------------------------------
#  Ejecutar virulencefinder.py sobre todos los ensambles en un directorio
# -------------------------------------------------------------------------

# iniciar conteo en 0
conteo=0
DIR=VIRULENCE_l60_t60
if [[ ! -d ${DIR} ]]; then
   mkdir ${DIR}
fi

# for loop para todos los ensambles en el directorio ASSEBLY
#for ensamble in ASSEMBLY/*.fa; do
   # aumentar en 1 el conteo en cada paso del for loop
#   conteo=$[ ${conteo} + 1 ]
   # guardar el ID de la secuencia
#   ensamble_name=$(basename ${ensamble} .fa)
   # mostrar numero y nombre del ensamble
#   echo -e "$conteo:\t$ensamble_name"
   # crear una carpeta para cada ensamble
#   mkdir ${DIR}/VF_${ensamble_name}
   # ejecutar virulencefinder
#   virulencefinder.py -i ${ensamble} -p ${db_virulencefinder} -l 0.6 -t 0.6 -mp ${blastn} -o ${DIR}/VF_${ensamble_name} -x -q
   # filtrar solo primeras tres columnas
#   awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$3}' ${DIR}/VF_${ensamble_name}/results_tab.tsv > ${DIR}/VF_${ensamble_name}/results_corto.tsv
   # convertir a archivo CSV
#   awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3}' ${DIR}/VF_${ensamble_name}/results_corto.tsv > ${DIR}/VF_${ensamble_name}/results_corto.csv
#done

# ----------------------------------
#  Generar resultados mas amigables
# ----------------------------------

# unir todos los resultados (cortos) en un solo archivo TSV y convertir a CSV (conservando ambos)
conteo=0
for dir in ${DIR}/VF_*; do
   conteo=$[ $conteo + 1 ]
   echo -e "$conteo:\t$(basename ${dir} | cut -d '_' -f '2')\n$(cat ${dir}/results_corto.tsv)\n"
done > ${DIR}/all_virulence.tsv

awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3}' ${DIR}/all_virulence.tsv > ${DIR}/all_virulence.csv


