#!/bin/bash

#
# Ejecuta ABRicate en todos los archivos (fasta) en un directorio
#

# asignar nombre a carpeta de resultados de ABRicate
dir="ABRICATE"

# crear directorio para guardar resultados de abricate, solo si no existe
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

#########################
#   ejecutar ABRicate   #
#########################

# generar lista de bases de datos a usar
abricate_db_list=(card vfdb plasmidfinder megares resfinder ncbi)

# ejecutar abricate con cada una de las diferentes bases de datos
for DB in "${abricate_db_list[@]}"; do
   # ejecutar abricate
   abricate -db ${DB} ASSEMBLY/*.fa --threads $(nproc) --nopath > ${dir}/ABRicate_${DB}.tsv 2> ${dir}/ABRicate_${DB}.log
   abricate --summary ${dir}/ABRicate_${DB}.tsv > ${dir}/ABRicate_matrix_${DB}.tsv

   # eliminar palabras no deseadas
   sed -i 's/-spades-assembly.fa//g' ${dir}/ABRicate_${DB}.tsv
   sed -i 's/-spades-assembly.fa//g' ${dir}/ABRicate_matrix_${DB}.tsv

   # filtrar para conservar solo columnas mas utiles
   awk 'BEGIN {FS=OFS="\t"}{print $1,$3,$4,$6,$10,$11,$12,$14}' ${dir}/ABRicate_${DB}.tsv > ${dir}/ABRicate_filtered_${DB}.tsv

   # convertir resultados a csv
   sed 's/\t/,/g' ${dir}/ABRicate_filtered_${DB}.tsv > ${dir}/ABRicate_filtered_${DB}.csv
   sed 's/\t/,/g' ${dir}/ABRicate_matrix_${DB}.tsv > ${dir}/ABRicate_matrix_${DB}.csv
done

