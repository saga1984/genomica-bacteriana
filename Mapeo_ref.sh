#!/bin/bash

#
# Obtiene archivo .bam profundidad y cobertura de todos los archivos FASTQ sobre un genoma de referencia indicad al correr el comando ($1)
#

mapeo_ref(){

   # Hacer bwa index
   bwa index -p $(basename ${ensamble_ref} .fa) ${ensamble_ref} 2> bwa_index.log

   # iterar sobre todos los reads
   for r1 in TRIMMING/${fastq}_1P.trim.fastq.gz; do # solo considerar read1 para el for loop
      read_name=$(basename ${r1} | cut -d"_" -f "1" | cut -d"." -f "1") # definir nombre del read
      r2=${r1/_1P./_2P.} # definir read2 (haciendo susutitucion)
      echo -e "Mapeo de: Muestra = $read_name vs Ensamble = $ensamble_ref" # imprimirmapeo de muestra vs genoma de referencia
      # Hacer bwa mem (se obtiene archivo .sam)
      bwa mem -o ${read_name}_$(basename ${ensamble_ref} .fa).sam -M -t $(nproc) $(basename ${ensamble_ref} .fa) $r1 $r2 #2> bwa_mem.log

      # Filtrar los alineamientos para conservar únicamente las lecturas que mapean con alta calidad
      samtools view -b -h -@ 4 -f 3 -q 60 -o ${read_name}_$(basename ${ensamble_ref} .fa).tmp.bam ${read_name}_$(basename $ensamble_ref .fa).sam
      samtools sort -l 9 -@ 4 -o ${read_name}_$(basename ${ensamble_ref} .fa).bam ${read_name}_$(basename $ensamble_ref .fa).tmp.bam 2> samtools_sort.log # se obtiene archivo .bam (se recomiendo no borrrar, aunque es muy pesado)
      samtools index ${read_name}_$(basename ${ensamble_ref} .fa).bam # indexar archivo .bam

      # Obtener profundidad
      samtools depth -aa ${read_name}_$(basename ${ensamble_ref} .fa).bam > ${read_name}_$(basename ${ensamble_ref} .fa)_depth.txt
      awk 'BEGIN{FS="\t"} {sum+=$3}END{print sum/NR}' ${read_name}_$(basename ${ensamble_ref} .fa)_depth.txt > ${read_name}_$(basename ${ensamble_ref} .fa)_depth 2> /dev/null
      echo -e "Profundidad de: ${read_name}_$(basename ${ensamble_ref} .fa) = \t$(cat ${read_name}_$(basename ${ensamble_ref} .fa)_depth)"

      # Obtenr longitud
      length=$(grep -v \> ${ensamble_ref} | perl -pe 's/\n//' | wc -c)

      # Obtener cobertura
      awk 'BEGIN{FS="\t"}{if($3 > 0){print $0}}' ${read_name}_$(basename ${ensamble_ref} .fa)_depth.txt | wc -l | awk -v len="$length" '{print $1/len}' > ${read_name}_$(basename ${ensamble_ref} .fa)_coverage
      echo -e "Cobertura de: ${read_name}_$(basename ${ensamble_ref} .fa) = \t$(cat ${read_name}_$(basename ${ensamble_ref} .fa)_coverage)\n"
   done

   echo " "
   # eliminar archivos (temporales)
   rm ./*.{bwt,pac,ann,amb,sa,sam,bai,txt}
   rm ./*.tmp*

}

bam2fastq(){

  for file in ./*.bam; do
     fname=$(basename $file | cut -d "." -f "1") # nombre para guardar archivos
     samtools bam2fq $file > ${fname}.fastq # convertir .bam a .fastq
     # separar en R1 y R2
     cat ${fname}.fastq | grep '^@.*/1$' -A 3 --no-group-separator > ${fname}_R1.fastq # obtener R1
     cat ${fname}.fastq | grep '^@.*/2$' -A 3 --no-group-separator > ${fname}_R2.fastq # obtener R2
     rm ${fname}.fastq # remover archivo conjunto de R1, R2
     # comprimir archivos
     gzip -9 ${fname}_R1.fastq
     gzip -9 ${fname}_R2.fastq
  done

}

# menu de ayuda
USO="

  Uso:\t$(basename $0) -f <ID de aislado> -r <Genoma de Referencia>

  f)\t ID de aislado que se desea mapear,\n\t si se desea mapear todos los archivos de una carpeta introducir "*"

  r)\t Genoma de Referencia

  h)\tMenú de ayuda

"
# si no hay opciones muestra el menu de ayuda y sal
if [[ $# -eq 0 ]]; then
   echo -e "${USO}"
   exit 1
fi

# control de opciones
while getopts ":r:f:h" opt; do
   case ${opt} in
      f)
         # si no existe la opcion r, manda mensaje de uso yu sal
         if [[ $# -lt 3 ]]; then
            echo -e "\n  Se necesita introducir un ensamble de referencia"
            echo -e "${USO}"
         else
            fastq=${OPTARG}
         fi
         ;;
      r)
         # si existe la opcion de fastq, ejecuta el mapeo
         if [[ ! -z ${fastq} ]]; then
            ensamble_ref=${OPTARG}
            echo -e "  Comenzando mapeo de archivo(s) Fastq: ${fastq} contra Ensamble de referencia: ${ensamble_ref}"
            mapeo_ref
            echo -e "  Mapeo terminado"
            echo -e "  Comenzando obtencion de nuevos archivos FASTQ"
            bam2fastq
            repair.sh in1=./${fastq}_R1.fastq.gz in2=${fastq}_R2.fastq.gz out1=${fastq}-2_R1.fastq.gz out2=${fastq}-2_R2.fastq.gz
            echo -e "  Mapeo terminado"
       else
            echo -e "\n  Se necesita introducir un archivo Fastq filtrado por calidad"
         fi
         ;;
      h)
         echo -e "${USO}"
         ;;
      *)
         echo -e "\n  La opción introducida,-${OPTARG}, no es una opción invalida\n"
         echo -e "${USO}"
         ;;
   esac
done
