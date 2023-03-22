#!/bin/bash

#
# Script que obtien la profundidad de todos los ensambles de un directorio
# y guarda el resultado por ensamble en un archivo formato .txt
#

for ensamble in ASSEMBLY/*.fa; do
   ensamble_nombre=${ensamble%%-spades-assembly.fa} # definir nombre del ensamble
   ensamble_name=$(basename $ensamble_nombre | cut -d "/" -f "2")

   # correr bwa index
   bwa index -p $(basename $ensamble .fa) $ensamble # lleva a cabo bwa index

   for r1 in TRIMMING/*_1P.trim.fastq.gz; do # solo considerar read1 para el for loop
      read_name=$(basename $r1 | cut -d "/" -f "2" | cut -d "_" -f "1,2") # definir nombre del read
      r2=${r1/_1P./_2P.}
      # si el ensamble y el read no se llaman igual ignorarlos
      if [[ $ensamble_name != $read_name ]]; then
         continue
         # echo -e "IF nombre_ensamble: $ensamble_name \tnombre_read: $read_name"

      # si el read y el ensamble se llaman igual entonces has todos los comandos siguientes
      else
         # controles
         # echo -e "ELSE (BWA MEM) nombre_ensamble: $ensamble_name \tnombre_read: $read_name"

         # correr bwa mem
         bwa mem -o $(basename $ensamble .fa).sam -M -t $(nproc) $(basename $ensamble .fa) $r1 $r2

         # Filtrar los alineamientos para conservar únicamente las lecturas que mapean con alta calidad
         samtools view -b -h -@ 4 -f 3 -q 60 -o $(basename $ensamble .fa).tmp.bam $(basename $ensamble .fa).sam
         samtools sort -l 9 -@ 4 -o $( basename $ensamble .fa).bam $(basename $ensamble .fa).tmp.bam
         samtools index $(basename $ensamble .fa).bam

         # ------------------------------------------------
         # Obtener profundidad y moverla a la carpeta Stats
         # ------------------------------------------------
         samtools depth -aa $(basename $ensamble .fa).bam > ${ensamble_name}_depth # obten profundidad por contig
         # obten profundidad global y mueve el archivo ala carpeta Stats
         awk 'BEGIN{FS="\t"}{sum+=$3}END{print sum/NR}' ${ensamble_name}_depth > ASSEMBLY/Stats/${ensamble_name}-cov.txt

         # eliminar archivos
         rm $(basename $ensamble .fa).*
         rm ${ensamble_name}_depth
      fi
   done
done
