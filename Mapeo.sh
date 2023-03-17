#!/bin/bash

#
#
#

for ensamble in ASSEMBLY/*.fa; do
   ensamble_name=$(basename $ensamble | cut -d"-" -f1) # definir nombre del ensamble para comparar con nombre de lecturas
#   echo -e "primer ensamble_name: $ensamble_name"
#   bwa index -p $(basename $ensamble | cut -d "." -f "1") $ensamble # lleva a cabo bwa index y quita extension o formato
#   mv ./*.{amb, ann, bwt, pac, sa} ASSEMBLY/ # mover los indices a la carpeta donde se encuentran los ensambles

   for r1 in TRIMMING/*R1.trim.fastq.gz; do # solo considerar read1 para el for loop
      read_name=$(basename $r1 | cut -d"_" -f1 | cut -d"." -f1) # definir nombre del read
      r2=${r1/_R1./_R2.}

      if [[ $ensamble_name != $read_name ]]; then # si el ensamble y el read no se llaman igual ignoralos
         continue

      # si se llaman igual entonces has todos los comandos siguientes
      else
#         echo -e "read_name: $read_name\nensamble_name: $ensamble_name\n"
#         bwa mem -o $(basename $ensamble | cut -d "." -f "1").sam -M -t $(nproc) ASSEMBLY/$(basename $ensamble | cut -d "." -f "1") $r1 $r2

         # Filtrar los alineamientos para conservar únicamente las lecturas que mapean con alta calidad
         samtools view -b -h -@ 4 -f 3 -q 60 -o $(basename $ensamble | cut -d "." -f "1").tmp.bam $(basename $ensamble | cut -d "." -f "1").sam
         samtools sort -l 9 -@ 4 -o $( basename $ensamble | cut -d "." -f "1").bam $(basename $ensamble | cut -d "." -f "1").tmp.bam
         samtools index $(basename $ensamble | cut -d "." -f "1").bam
      fi
   done
done
