#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------------
#   Obtiene el MLST y ST de los diferentes generos bacterianos de analisis rutinarios: Salmonella, Listeria, Escherichia
# -------------------------------------------------------------------------------------------------------------------------

# copiar la base de datos al directorio actual
ln -s /disk1/Programas_bioinformaticos/stringMLST/* $(pwd)

# para cada uno de los generos vacterianos de analisis rutinario
for especie in Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis; do

   # definir genero
   genero=$(basename ${especie} | cut -d '_' -f '1')
   echo -e "Genero: = ${genero}\n" # CONTROL

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for file in ./*_R1*fastq.gz; do
      # crear una variable para nombre (ID) de la muestra
      fname=$(basename ${file} | cut -d "_" -f "1")
      # genero para el mejor hit de kraken2
      krakenGenus=$(awk -v gname=${genero} '$4 == "S" {print $6"_"$7}' KRAKEN2/kraken_species_${fname}.txt | sed -n '1p')
      echo -e "especie identificada por kraken ${fname} = ${krakenGenus}" # CONTROL
      # genero para el mejor hit de kmerfinder
      kmerfinderGenus=$(awk '{print $2"_"$3}' KMERFINDER/KF_${fname}/results_spa.csv | grep "${krakenGenus}" | sed -n '1p')
      echo -e "especie identificada por kmefinder ${fname} = ${kmerfinderGenus}" # CONTROL
   done
done
