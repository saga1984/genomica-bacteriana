  GNU nano 4.9.2                                               TrimmingPE.sh                                                         
#!/bin/bash

#
# Trimmomatic curso metagenomas sobre todos los archivos dentro de (00.Datos)
#

# definir adaptadores
TrueSeq="/home/sgalvan/adapters/TruSeq2-PE.fa"

# ejecutar trimmomatic en todos los reads dentro de 00.Datos
for r1 in 00.Datos/*_1.*fastq.gz; do
   # definir variables
   r2=${r1/_1./_2.} # sustituir
   nombre1=${r1%%.p05.fastq.gz} # definir nombre corto r1 (remover sufijo)
   nombre2=${r2%%.p05.fastq.gz} # definir nombre corto r2 (remover sufijo)

  # correr trimmomatic PE
   trimmomatic PE -threads 10 -phred33 -trimlog triminfo.txt \
   ${r1} ${r2} \
   ${nombre1}.trimm.fastq.gz ${nombre1}.unpair.fastq.gz \
   ${nombre2}.trimm.fastq.gz ${nombre2}.unpair.fastq.gz \
   ILLUMINACLIP:${TruSeq}:2:30:10:8:True \
   LEADING:5 TRAILING:5 SLIDINGWINDOW:5:15 MINLEN:50
done
