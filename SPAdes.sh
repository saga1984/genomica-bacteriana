#!/bin/bash

#
# corre spades y guarda un unico archivo fasta por lecturas pareadas en una carpeta destino
#

# crear carpetas para guardar resultados
mkdir ASSEMBLY

for P1 in TRIMMING/*1P.trim.fastq.gz; do
   # asignar variables
   P2="${P1/_1P./_2P.}" # asignar nombre de lecturas P2
   ename="$(basename $P1 | cut -d '_' -f '1')" # asignar nombre de ensamble para carpeta de resultados de SPAdes

   # correr SPAdes con la opción que produce resultados promedio entre otras opciones
   spades.py --isolate -1 $P1 \
                       -2 $P2 \
                       -t $(nproc) -o ${ename}_SPAdes

   # mover el resultado a nivel de contig a ASSEMBLY y eliminar carpeta de resultados
   mv ${ename}_SPAdes/contigs.fasta ${ename}_SPAdes/${ename}-spades-assembly.fasta # cambiar nombre
   mv ${ename}_SPAdes/${ename}-spades-assembly.fasta ASSEMBLY/${ename}-spades-assembly.fasta # cambiar de carpeta
   rm -r ${ename}_SPAdes # eliminar carpeta de resultados de SPAdes

   # eliminar contigs pequeños (menores a 500pb) (basado en:
   # la tubería MicroRunQC la cual es aceptado por GalaxyTrakr usa 200pb
   # varios articulos usan desde 200pb a 1000pb para bacterias (algunos estiman tamaño promedio de gen procariota de 1000pb))
   # algunas personas usan el criterio de ~ el doble del tamaño minimo de read (2 x 150pb = 300 pb)
   # por lo que se considera que 500pb es un buen valor
   seqtk seq -L 500 ASSEMBLY/${ename}-spades-assembly.fasta > ASSEMBLY/${ename}-spades-assembly.fa

   # eliminar archivos originales (con contigs completos)
   rm ASSEMBLY/${ename}-spades-assembly.fasta
done
