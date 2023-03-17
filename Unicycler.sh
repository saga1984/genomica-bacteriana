#!/bin/bash

#
# corre Unicycler y guarda un unico archivo fasta por lecturas pareadas en una carpeta destino
#

# crear carpetas para guardar resultados
dir="ASSEMBLY"
mkdir $dir

for P1 in TRIMMING/*1P.trim.fastq.gz; do
   # asignar variables
   P2="${P1/_1P./_2P.}" # asignar nombre de lecturas P2
   ename="$(basename $P1 | cut -d '_' -f '1')" # asignar nombre de ensamble para carpeta de resultados de SPAdes

   # correr Unicycler con la opción que produce resultados promedio entre otras opciones
   # eliminar contigs menores a 500 pb, usar todos los procesos disponibles y guardar solo archivos finales y resultados en carpetas individuales
   unicycler-runner.py -1 ${P1} -2 ${P2} --min_fasta_length 500 --keep 0 -t $(nproc) -o ${ename}_Unicycler

   # mover el resultado a nivel de contig a ASSEMBLY y eliminar carpeta de resultados
   mv ${ename}_Unicycler/assembly.fasta ${ename}_Unicycler/${ename}-unicycler-assembly.fa # cambiar nombre
   mv ${ename}_Unicycler/${ename}-unicycler-assembly.fa ${dir}/${ename}-unicycler-assembly.fa # cambiar de carpeta
   mv ${ename}_Unicycler ${dir}/ # mover carpeta de resultados de Unicycler a ASSEMBLY
done
