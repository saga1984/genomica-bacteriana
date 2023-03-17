#!/bin/bash

#
# Ejecuta trimmomatic sobre todos los reads de un directorio
#

# Crear los directorios destino para los resultados
mkdir -p TRIMMING/1U2U

# Ejecutar Trimmomatic en todos los reads
for r1 in *_R1*.fastq.gz; do # solo tomar una lectura (la forward)
   r2=${r1/_R1/_R2} # sustituir en la posicion indicada _1 por _2 para convertir a lectura dos (reverse)
   name=$(basename $r1 | cut -d "_" -f "1") # cortar todo lo que va despues de "_" del nombre de r1
   TrimmomaticPE -threads $(nproc) -phred33 $r1 $r2 \
   TRIMMING/${name}_1P.trim.fastq.gz TRIMMING/1U2U/${name}_1U.trim.fastq.gz \
   TRIMMING/${name}_2P.trim.fastq.gz TRIMMING/1U2U/${name}_2U.trim.fastq.gz \
   ILLUMINACLIP:${NexteraPE}:2:30:10 SLIDINGWINDOW:4:20 MINLEN:70
done
