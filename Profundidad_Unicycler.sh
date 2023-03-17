#!/bin/bash

#
# Script que obtien la profundidad de todos los ensambles de un directorio
# y guarda el resultado por ensamble en un archivo formato .txt
#

for ensamble in ASSEMBLY/*.fa; do
   # primer filtro para nombre corto de ensamble
   ensamble_nombre=${ensamble%%-unicycler-assembly.fa}
   # nombre corto de ensamble final
   ensamble_name=$(basename ${ensamble_nombre} | cut -d '/' -f '2')

   # correr bwa index
   bwa index -p $(basename ${ensamble} .fa) ${ensamble} # lleva a cabo bwa index

   for r1 in TRIMMING/*_1P.trim.fastq.gz; do # solo considerar read1 para el for loop
      read_name=$(basename ${r1} | cut -d '/' -f '2' | cut -d '_' -f '1') # definir nombre del read
      r2=${r1/_1P./_2P.}
      #### control ####
      echo -e "ENSAMBLE_NAME: ${ensamble_name}\tREAD_NAME: ${read_name}"
      # si el ensamble y el read no se llaman igual ignorarlos
      if [[ ${ensamble_name} != ${read_name} ]]; then
         continue
         #### control ####
         echo -e "IF CONTROL:\tnombre_ensamble: ${ensamble_name} \tnombre_read: ${read_name}" # control

      # si el read y el ensamble se llaman igual entonces has todos los comandos siguientes
      else
         ##### control #####
         echo -e "ELSE CONTROL:\tnombre_ensamble: ${ensamble_name} \tnombre_read: ${read_name}" # control

         # correr bwa mem
         bwa mem -o $(basename ${ensamble} .fa).sam -M -t $(nproc) $(basename ${ensamble} .fa) $r1 $r2

         # Filtrar los alineamientos para conservar únicamente las lecturas que mapean con alta calidad
         samtools view -b -h -@ $(nproc) -f 3 -q 60 -o $(basename ${ensamble} .fa).tmp.bam $(basename ${ensamble} .fa).sam
         samtools sort -l 9 -@ $(nproc) -o $( basename ${ensamble} .fa).bam $(basename ${ensamble} .fa).tmp.bam
         samtools index $(basename ${ensamble} .fa).bam

         # -------------------------------------------------------
         #     Obtener profundidad y moverla a la carpeta Stats
         # -------------------------------------------------------
         samtools depth -aa $(basename ${ensamble} .fa).bam > ${ensamble_name}_depth # obten profundidad por contig
         # obten profundidad global y mueve el archivo ala carpeta Stats
         awk 'BEGIN{FS="\t"}{sum+=$3}END{print sum/NR}' ${ensamble_name}_depth > ASSEMBLY/Stats/${ensamble_name}-depth.txt
         # agregar la palabra Depth a cada archivo que contiene profundidad
         sed -i 's/^/Depth = /' ASSEMBLY/Stats/${ensamble_name}-depth.txt

         # ------------------------------------------------------
         #     Obtener cobertura y moverla a la carpeta Stats
         # ------------------------------------------------------
         grep -v \> ${ensamble} | perl -pe 's/\n//' | wc -c > ${ensamble_name}_length
         # obtener cobertura y moverla a la carpeta stats
         awk 'BEGIN{FS="\t"}{if($3 > 0){print $0}}' ${ensamble_name}_depth | wc -l | awk -v len="$(cat ${ensamble_name}_length)" '{print $1/len}' > ASSEMBLY/Stats/${ensamble_name}-coverage.txt
         # agregar la palabra coverage a cada archivo que contiene cobertura
         sed -i 's/^/Coverage = /' ASSEMBLY/Stats/${ensamble_name}-coverage.txt

         # eliminar archivos
         rm $(basename $ensamble .fa).*
         rm ${ensamble_name}_depth
         rm ${ensamble_name}_length
      fi
   done
done
