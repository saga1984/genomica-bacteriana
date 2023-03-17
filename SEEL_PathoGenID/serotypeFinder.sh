#!/bin/bash

# -------------------------------------------------------------------------
#   Predice el serotipo de E coli en todos los ensambles en un directorio
# -------------------------------------------------------------------------

# asignar directorio de resultados
dir="SEROTYPEFINDER"


# si no existe, crear directorio para guardar todos los resultados de VF
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# for loop para todos los ensables
for ensamble in ASSEMBLY/Escherichia/*.fa; do
   # definir nombre corto de ensamble
   ensamble_name=$(basename $ensamble | cut -d "-" -f 1) # guardar el ID de la secuencia
   # crear una carpeta para cada ensamble
   mkdir ${dir}/SF_${ensamble_name}
   # ejecutar virulencefinder
   serotypefinder.py -i ${ensamble} -p ${serotypefinder_db}  -mp ${blastn} -o ${dir}/SF_${ensamble_name} -x -q
   # filtrar solo primeras tres columnas
   awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$3,$4}' ${dir}/SF_${ensamble_name}/results_tab.tsv > ${dir}/SF_${ensamble_name}/results_filtrado.tsv
   # convertir a archivo CSV
   awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4}' ${dir}/SF_${ensamble_name}/results_filtrado.tsv > ${dir}/SF_${ensamble_name}/results_filtrado.csv
done

# ----------------------------------
#  Generar resultados mas amigables
# ----------------------------------

# unir todos los resultados (cortos) en un solo archivo TSV y convertir a CSV (conservando ambos)
for DIR in ${dir}/SF_*; do
   echo -e "$(basename ${DIR} | cut -d '_' -f '2')\n$(cat ${DIR}/results_filtrado.tsv)\n"
done > ${dir}/serotypefinder_resultados.tsv

# convertir formato de archivo final de TSV a CSV
awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4}' ${dir}/serotypefinder_resultados.tsv > ${dir}/serotypefinder_resultados.csv


