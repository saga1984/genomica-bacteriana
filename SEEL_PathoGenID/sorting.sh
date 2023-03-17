#!/bin/bash

#
# separa los ensambles de acuerdo al genero identificado por kraken2 y kmerfinder para analisis posteriores
#

# for loop para generos
for genero in Salmonella Escherichia Listeria; do
   # for loop para directorios que se van a crear y poblar
   for dir in Salmonella Escherichia Listeria; do
      if [[ ${genero} == ${dir} ]]; then
         # for loop para todos los archivos fastq comprimidos en la carpeta actual
         for file in ASSEMBLY/*.fa; do
            fname_nopath=$(basename ${file} | cut -d '/' -f '2')
            # crear una variable para nombre (ID) de la muestra
            fname=$(basename ${file} | cut -d "-" -f "1")
            # genero para el mejor hit de kraken2
            krakenGenus=$(awk -v gname=${genero} '$4 == "G" && $6 == gname {print $6}' KRAKEN2/kraken_species_${fname}.txt)
            # echo -e "kraken ${fname} = ${krakenGenus}" # CONTROL
            # genero para el mejor hit de kmerfinder
            kmerfinderGenus=$(awk '{print $2}' KMERFINDER/KF_${fname}/results_spa.csv | sed -n '2p')
            # echo -e "kmefinder ${fname} = ${kmaerfinder}" # CONTROL
            # si tanto kraken2 como kamerfinder encuentran como genero Salmonella entonces
            if [[ ${krakenGenus} == "${genero}" && $kmerfinderGenus  == "${genero}" ]]; then
               # si no existe la carpeta Salmonella, Escherichia y Listeria, entonces crealas
               if [[ ! -d ASSEMBLY/${dir} ]]; then
                  # crea las carpetas Salmonella, Escherichia y Listeria segun sea el caso
                  mkdir ASSEMBLY/${dir}
               fi
               # copia los ensambles correspondientes a la carpeta Salmonella
               cp -v ASSEMBLY/${fname_nopath} ASSEMBLY/${dir}/${fname_nopath}
            fi
         done
      fi
   done
done
