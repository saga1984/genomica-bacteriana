#!/bin/bash

#
# Obtiene archivo .bam profundidad y cobertura de todos los archivos FASTQ sobre un genoma de referencia indicad al correr el comando ($1)
#

ensamble_ref="$1"

# Hacer bwa index
bwa index -p $(basename $ensamble_ref .fa) $ensamble_ref 2> bwa_index.log

# iterar sobre todos los reads
for r1 in TRIMMING/*_1P.trim.fastq.gz; do # solo considerar read1 para el for loop
   read_name=$(basename $r1 | cut -d"_" -f "1" | cut -d"." -f "1") # definir nombre del read
   r2=${r1/_1P./_2P.} # definir read2 (haciendo susutitucion)
   echo -e "Mapeo de: Muestra = $read_name vs Ensamble = $ensamble_ref" # imprimirmapeo de muestra vs genoma de referencia
#   # Hacer bwa mem (se obtiene archivo .sam)
   bwa mem -o ${read_name}_$(basename $ensamble_ref .fa).sam -M -t $(nproc) $(basename $ensamble_ref .fa) $r1 $r2 #2> bwa_mem.log

#   # Filtrar los alineamientos para conservar únicamente las lecturas que mapean con alta calidad
   samtools view -b -h -@ 4 -f 3 -q 60 -o ${read_name}_$(basename $ensamble_ref .fa).tmp.bam ${read_name}_$(basename $ensamble_ref .fa).sam
   samtools sort -l 9 -@ 4 -o ${read_name}_$(basename $ensamble_ref .fa).bam ${read_name}_$(basename $ensamble_ref .fa).tmp.bam 2> samtools_sort.log # se obtiene archivo .bam (se recomiendo no borrrar, aunque es muy pesado)
   samtools index ${read_name}_$(basename $ensamble_ref .fa).bam # indexar archivo .bam

   # Obtener profundidad
   samtools depth -aa ${read_name}_$(basename $ensamble_ref .fa).bam > ${read_name}_$(basename $ensamble_ref .fa)_depth.txt
   awk 'BEGIN{FS="\t"} {sum+=$3}END{print sum/NR}' ${read_name}_$(basename $ensamble_ref .fa)_depth.txt > ${read_name}_$(basename $ensamble_ref .fa)_depth 2> /dev/null
   echo -e "Profundidad de: ${read_name}_$(basename $ensamble_ref .fa) = \t$(cat ${read_name}_$(basename $ensamble_ref .fa)_depth)"

   # Obtenr longitud
   length=$(grep -v \> $ensamble_ref | perl -pe 's/\n//' | wc -c)

   # Obtener cobertura
   awk 'BEGIN{FS="\t"}{if($3 > 0){print $0}}' ${read_name}_$(basename $ensamble_ref .fa)_depth.txt | wc -l | awk -v len="$length" '{print $1/len}' > ${read_name}_$(basename $ensamble_ref .fa)_coverage
   echo -e "Cobertura de: ${read_name}_$(basename $ensamble_ref .fa) = \t$(cat ${read_name}_$(basename $ensamble_ref .fa)_coverage)\n"
done

echo " "
# eliminar archivos (temporales)
rm ./*.{bwt,pac,ann,amb,sa,sam,bai,txt}
rm ./*.tmp*
