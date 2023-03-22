#!/bin/bash

for mapa in 02.Mapeo/*.sam; do
   nombre_corto=$(basename ${mapa} .sam)

   samtools view -bShu ${mapa} | \
   samtools sort -@ 5 -o ${nombre_corto}_sorted.bam
   samtools index ${nombre_corto}_sorted.bam
done
