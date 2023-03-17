#!/bin/bash

#
# script que descarga archivos SRA desde NCBI, los convierte a FASTQ comprimidos y elimina archivos SRA
#

cat lista*.txt | while read sra; do
   wget https://sra-downloadb.be-md.ncbi.nlm.nih.gov/sos1/sra-pub-run-1/$sra/$sra.1 # descargar (desde NCBI) archivo SRA
   fasterq-dump --progress --force --verbose --threads $(nproc) --split-files $sra.1 # convertir SRA a FASTQ
   gzip $sra.1_?.fastq # comprimir archivos FASTQ
   rm $sra.1 # eliminar archivo SRA
done

