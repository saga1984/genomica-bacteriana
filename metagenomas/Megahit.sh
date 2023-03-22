#!/bin/bash

#
# corre megahit en todos los ensambles en una carpeta (00-Datos)
# guarda los resultados en otro directorio (01.Ensamble)
#

# para todos los ensambles intercalados, realiza lo siguiente
for readHQ in 00.Datos/*HQ.fastq.gz; do
   # definir variables
   nombre_corto=${readHQ%%.HQ.fastq.gz} # nombre corto (sin sufijo)
   short_name=$(basename ${nombre_corto}) # nombre mas corto (sin prefijo)

   # correr megahit
   megahit --12 ${readHQ} --k-list 21,33,55,77,99,121 \
   --min-count 2 --verbose -t 10 -o 01.Ensamble/${short_name}.pulque --out-prefix megahit
done
