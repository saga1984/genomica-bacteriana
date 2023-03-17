#!/bin/bash

#
# Obtiene archivo .bam profundidad y cobertura de todos los archivos FASTQ sobre un genoma de referencia indicad al correr el comando ($1)
#

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

function script_mapeo {
   # crear carpeta para guardar resultados de mapeo
   dir="FASTQ_MAPEO_$(basename ${ensamble_ref} .fa)"

   # crear el directorio
   mkdir ${dir} 2> /dev/null

   # Hacer bwa index
   bwa index -p $(basename $ensamble_ref .fa) $ensamble_ref 2> bwa_index.log

   # iterar sobre todos los reads
   for r1 in ./*_R1.fastq.gz; do # solo considerar read1 para el for loop
      read_name=$(basename $r1 | cut -d"_" -f "1" | cut -d"." -f "1") # definir nombre del read
      r2=${r1/_R1./_R2.} # definir read2 (haciendo susutitucion)
      echo -e "Mapeo de: Muestra = $read_name vs Ensamble = $ensamble_ref" # imprimirmapeo de muestra vs genoma de referencia
      # Hacer bwa mem (se obtiene archivo .sam)
      bwa mem -o ${read_name}_$(basename $ensamble_ref .fa).sam -M -t $(nproc) $(basename $ensamble_ref .fa) $r1 $r2 2> bwa_mem.log

      # Filtrar los alineamientos para conservar únicamente las lecturas que mapean con alta calidad
      samtools view -b -h -@ $(nproc) -f 3 -q 60 -o ${read_name}_$(basename $ensamble_ref .fa).tmp.bam ${read_name}_$(basename $ensamble_ref .fa).sam
      samtools sort -l 9 -@ $(nproc) -o ${read_name}_$(basename $ensamble_ref .fa).bam ${read_name}_$(basename $ensamble_ref .fa).tmp.bam 2> samtools_sort.log # se obtiene archivo .bam (se recomiendo no borrrar, aunque es muy pesado)
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
   done > ${dir}/resultados_covertura_profundidad.txt

   # eliminar archivos (temporales)
   rm ./*.{bwt,pac,ann,amb,sa,sam,txt} 2> /dev/null
   #rm ./*tmp* 2> /dev/null

   # mover archivos importantes a nuevo directorio
   mv *{.bam,log,bai} ${dir}
   mv *_{coverage,depth} ${dir}

   echo " "

}

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

# ---------------------------------------
#  uso correcto del script: script_mapeo
# ---------------------------------------

# variable que indica la forma correcta de usar el script
USO="
uso: $(basename $0) -a [REFERENCE ASSEMBLY]
   -a:\t assembly used to map against the reads (mandatory argument)
   -h:\t shows this help menu
"

# si el script no se ejecuta correctamente (sin argumentos/opciones), entonces indicar uso correcto y salir con error
if [[ $# -eq 0 ]]; then
   echo -e "$USO"
   exit 2
fi

# ----------------------------------------------------------------------
#  parsear de argumentos y ejecutar el script script_mapeo_ref_virus.sh
# ----------------------------------------------------------------------

# parseo de opciones/argumentos
while getopts ":a:h"  opciones; do
   case "${opciones}" in
      a)
         ensamble_ref="${OPTARG}" # asignar ensamble de referencia
         echo -e "Comenzando Mapeo contra genoma de referencia: ${ensamble_ref} \n"
         script_mapeo # mapear
         echo -e "Mapeo terminado \n"
         ;;
      h)
         echo -e "$USO"
         ;;
      ?)
         echo "invalid option -${OPTARG}"
         echo -e "$USO"
         ;;
   esac
done

