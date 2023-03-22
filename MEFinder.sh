#!/bin/bash

# asignar nombre de directorio de resultados
dir=MEFINDER

# si el directorio no existe, crealo
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# para cada ensamble, hacer lo siguiente
for ensamble in ASSEMBLY/*.fa; do
   ename=$(basename ${ensamble} | cut -d "-" -f "1") # nombre de archivo
   mefinder find --contig ${ensamble} ${dir}/mefinder_${ename} # ejecutar mefinder find
   awk 'BEGIN{FS=OFS=","} {print $1,$2,$4,$5}' ${dir}/mefinder_${ename}.csv > ${dir}/mefinder_${ename}_filtered.csv
done

# unir todos los resultados
conteo=o
for file in ${dir}/*filtered.csv; do
   conteo=$[ ${conteo} + 1 ]
   echo -e "${conteo}:\t$(basename ${file} .csv)\n$(cat ${file})\n"
done > ${dir}/all_mge.csv

# convertir a TSV
awk 'BEGIN {FS=","; OFS="\t"} {print $0}' ${dir}/all_mge.csv > ${dir}/all_mge.tsv
