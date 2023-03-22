#!/bin/bash

#
# obtener archivos fastq a partir de archivos .bam
#

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

