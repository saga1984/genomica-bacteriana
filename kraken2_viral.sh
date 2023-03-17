#!/bin/bash

#
# programa que ejecuta kraken2 sobre todos los archivos formato FATSQ en un directorio y filtra resultados
#

# -------------------------------------------------------------
#   ejecutar kraken sobre todas las lecturas de un directorio
# -------------------------------------------------------------

# crear directorio de resultados y volverlo variable
dir="KRAKEN2_VIRAL"
mkdir $dir

# NOTA: kraken2_db es el nombre de la base de datos de kraken2 en el server y se guardo la variable directamente en el archivo ~/.bashrc

# ejecutar kraken y editar reporte de resultados
for r1 in TRIMMING/*_1P.*fastq.gz; do # solo itera sobre lecturas R1
   r2=${r1/_R1/_R2} # crea nombre para lecturas R2
   name=$(basename $r1 | cut -d "_" -f "1") # crea nombre corto de resultado

   # correr kraken2, enviar log a archivo kraken2_log.txt
   kraken2 --db $kraken2_viral_db --threads $(nproc) --gzip-compressed --use-names --paired --report ${dir}/kraken_${name}.txt ${r1} ${r2} 2> ${dir}/kraken2_log.txt
   # filtrar resultados de kraken (si la col 4 tiene caracteres que contengan G o S (genero especie o subespecies) y la col 1 tiene valor mayor a 1, entonces imprimelo)
   awk '$4 ~ "[DGS]" && $1 > 0.01' ${dir}/kraken_${name}.txt > ${dir}/kraken_species_${name}.txt
   # filtrar resultados de kraken (si la col 1 tiene valor mayor a 1, entonces imprimelo)
   awk '$1 > 0.01' ${dir}/kraken_${name}.txt > ${dir}/kraken_short_${name}.txt
   # agregar nombre de columnas a archivo filtrado (especies)
   sed -i '1i coverage%\tcoverage#\tasigned\trank_especie\tNCBItaxonomicID\ttaxonomic_name' ${dir}/kraken_species_${name}.txt
   # agregar nombre de columnas a archivo filtrado (% coverage > 1)
   sed -i '1i coverage%\tcoverage#\tasigned\trank_especie\tNCBItaxonomicID\ttaxonomic_name' ${dir}/kraken_short_${name}.txt

done

# --------------------------------------------------------
#  Crear archivos finales formato TSV
# --------------------------------------------------------

# crear un solo archivo de resultados para todas las muestras en un directorio
for file in ${dir}/*species*; do # para todo archivo que contenga la palabra short en el directorio KRAKEN2
   fname=$(basename $file | cut -d "_" -f "3") # guardar un nombre corto de archivo
   echo -e "\n$fname \n $(cat $file)" # mandar a standar output el nombre corto del archivo y su contenido
done > ${dir}/kraken_species_all_results.tsv # guarda el resultado del loop en un archivo

# crear un solo archivo de resultados para todas las muestras en un directorio
for file in ${dir}/*short*; do # para todo archivo que contenga la palabra short en el directorio KRAKEN2
   fname=$(basename $file | cut -d "_" -f "3") # guardar un nombre corto de archivo
   echo -e "\n$fname \n $(cat $file)" # mandar a standar output el nombre corto del archivo y su contenido
done > ${dir}/kraken_short_all_results.tsv # guarda el resultado del loop en un archivo

# --------------------------------------------------------
#  Corregir archivos finales en formato TSV
# --------------------------------------------------------

# eliminar ".txt" de archivos finales
sed -i 's/.txt//g' ${dir}/kraken_species_all_results.tsv
sed -i 's/.txt//g' ${dir}/kraken_short_all_results.tsv

# eliminar "results.tsv" de archivos finales
echo "$(grep -v 'all' ${dir}/kraken_species_all_results.tsv)" > ${dir}/kraken_species_all_results.tsv
echo "$(grep -v 'all' ${dir}/kraken_short_all_results.tsv)" > ${dir}/kraken_short_all_results.tsv

# --------------------------------------------------------
#  Convertir archivos finales a formato CSV
# --------------------------------------------------------

# convertir archivos finales formato CSV
sed 's/\t/,/g' ${dir}/kraken_short_all_results.tsv > ${dir}/kraken_short_all_results.csv
sed 's/\t/,/g' ${dir}/kraken_species_all_results.tsv > ${dir}/kraken_species_all_results.csv


