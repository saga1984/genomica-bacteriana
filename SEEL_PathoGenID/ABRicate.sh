#!/bin/bash

#
# Ejecuta ABRicate en todos los archivos (fasta) en un directorio
#

# definir directorio para guardar resultados de abricate
dir="ABRICATE"

# si el directorio no existe crealo
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
   # for loop para todos los ensambles
   for ensamble in ASSEMBLY/*.fa; do
      # nombre corto de ensabmble
      ensamble_name=$(basename ${ensamble} | cut -d '-' -f '1')

      # ejecutar abricate
      abricate -db ${DB} ASSEMBLY/*.fa --threads $(nproc) --nopath > ${dir}/ABRicate_${DB}.tsv 2> ${dir}/ABRicate_${DB}.log
      abricate --summary ${dir}/ABRicate_${DB}.tsv > ${dir}/ABRicate_matrix_${DB}.tsv

      # eliminar palabras no deseadas
      sed -i 's/-spades-assembly.fa//g' ${dir}/ABRicate_${DB}.tsv
      sed -i 's/-spades-assembly.fa//g' ${dir}/ABRicate_matrix_${DB}.tsv

      # filtrar para conservar solo columnas mas utiles
      awk 'BEGIN {FS=OFS="\t"}{print $1,$6,$14,$12,$3,$4,$10,$11}' ${dir}/ABRicate_${DB}.tsv > ${dir}/ABRicate_filtered_${DB}.tsv

      # convertir resultados a csv
      sed 's/\t/,/g' ${dir}/ABRicate_filtered_${DB}.tsv > ${dir}/ABRicate_filtered_${DB}.csv
      sed 's/\t/,/g' ${dir}/ABRicate_matrix_${DB}.tsv > ${dir}/ABRicate_matrix_${DB}.csv

      # obtener un solo archivo final de genes en formato amigable por cada base de datos, separar resultados por ID de la muestra
      cat ${dir}/ABRicate_filtered_${DB}.tsv | awk '{print $1,$2}' | sed 's/Escherichia_coli_//g' | sed 's/_beta-lactamase//g' | awk -v var=${ensamble_name} '$1 == var'  > ${dir}/tmp_${ensamble_name}_${DB}.txt
      # obtener archivo final en formato CSV de conjunto de genes por ID en sola fila
      awk '{print $2}' ${dir}/tmp_${ensamble_name}_${DB}.txt | uniq | tr "\n" "," | sed 's/,$//g' > ${dir}/${ensamble_name}_${DB}.txt

      # imprimir ID y contenido de archivos para un archivo final
      echo -e "${ensamble_name},$(cat ${dir}/${ensamble_name}_${DB}.txt)"

   # guardar resultados del for loop en un archivo por base de datos
   done > ${dir}/ABRicate_${DB}_results_all.csv

   # agregar nombre de columnas a archivo final
   sed -i "1i ID,Genes_RAM" ${dir}/ABRicate_${DB}_results_all.csv

# elminar archivos temporales
rm ${dir}/*tmp*
rm ${dir}/*.txt

done
