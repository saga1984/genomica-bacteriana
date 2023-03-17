#!/bin/bash

#
# copia todos los archivos GFF3 producidos por prokka en el directorio actual
#

dir="ASSEMBLY/PROKKA"

mkdir ${dir}/GFF ${dir}/GBK

# ejecuta el siguiente loop para todos los archivos dentro del actual directorio
for file in ${dir}/prokka_*; do
   if [[ -d ${file} ]]; then # si el objeto es un directorio entonces
      cp -v ${file}/*.gff ${dir}/GFF # copia todo lo que termine en .gff a la carpeta GFF
      cp -v ${file}/*.gbk ${dir}/GBK  # copia todo lo que termine en .gbk a la carpeta GBK
   fi
done
