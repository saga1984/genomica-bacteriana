#!/bin/bash

#
# separa los ensambles de acuerdo al genero identificado por kraken2 y kmerfinder para analisis posteriores
#

for genero in Salmonella Escherichia Listeria; do
   for dir in Salmonella Escherichia Listeria; do
      if [[ ${genero} == ${dir} ]]; then
         # for loop para todos los archivos fastq comprimidos en la carpeta actual
         for file in ./*_R1*fastq.gz; do
            # crear una variable para nombre (ID) de la muestra
            fname=$(basename ${file} | cut -d "_" -f "1")
            # genero para el mejor hit de kraken2
            krakenGenus=$(awk -v gname=${genero} '$4 == "G" && $6 == gname {print $6}' KRAKEN2/kraken_species_${fname}.txt)
            # echo -e "kraken ${fname} = ${krakenGenus}" # CONTROL
            # genero para el mejor hit de kmerfinder
            kmerfinderGenus=$(awk '{print $2}' KMERFINDER/KF_${fname}/results_spa.csv | sed -n '2p')
            # echo -e "kmefinder ${fname} = ${kmaerfinder}" # CONTROL
            # si tanto kraken2 como kamerfinder encuentran como genero Salmonella entonces
            if [[ ${krakenGenus} == "${genero}" && $kmerfinderGenus  == "${genero}" ]]; then
               # si no existe la carpeta SALMONELLA entonces
               if [[ ! -d ASSEMBLY/${dir} ]]; then
                  # crea la carpeta Salmonella
                  mkdir ASSEMBLY/${dir}
               fi
               # copia los ensambles correspondientes a la carpeta SALMONELLA
               cp -v ASSEMBLY/${fname}-spades-assembly.fa ASSEMBLY/${dir}/${fname}-spades-assembly.fa
            fi
         done
      fi
   done
done
