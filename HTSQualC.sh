#!/bin/bash

#
# hace trimming con HTSQualC y mueve los archivos .fastq.gz a una sola carpeta de resultados
#

# crear carpeta para guardar resultados filtrados (parado en la ruta donde se ubican los archivos .fastq)
dir="Trimming_HTSQualC"
mkdir $dir

# corre HTSQualC
for read1 in *_R1.fastq; do # corre para lecturas izquieras
   read2=${read1%%_R1.fastq}"_R2.fastq" # crea variable para lecturas derechas a partir de variable de lecturas izquierdas
#   echo -e "read1 = $read1\tread2 = $read2" # control
   # 18 procesos, limite de calidad (25), filtra Ns, tamaño minimo de lectura (70), adaptadores NexteraPE (previamente definido como variable de sistema)
   filter.py --cpu 18 --qthr 25 --nb 5 --msz 70 --adp $NexteraPE \
   --p1 $read1 \ # lecturas izquierdas
   --p2 $read2 \ # lecturas derechas
   --compress True # comprime el resultado (lecturas filtradas)
done

# mueve las lecturas filtradas a la carpeta de resultados (dir)
for file in *_out ; do
   mv -v $(echo $file/*.gz) $dir
done
