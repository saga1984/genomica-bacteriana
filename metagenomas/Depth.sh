#!/bin/bash

for ensamble in 02.Mapeo/*_sorted.bam; do
   # asignar variables
   nombre_corto=$(basename ${ensamble} _sorted.bam)

   # obtener profundidades
   jgi_summarize_bam_contig_depths --outputDepth 03.Metabat/${nombre_corto}-depth.txt ${ensamble}
done
