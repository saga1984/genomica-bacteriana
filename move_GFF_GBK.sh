#!/bin/bash

#
# copia todos los archivos GFF3 producidos por prokka en el directorio actual
#

DIR1="GFF_ROARY"
if [[ ! -d ${DIR1} ]]; then
   mkdir ${DIR1}
fi

DIR2="GBK"
if [[ ! -d ${DIR2} ]]; then
   mkdir ${DIR2}
fi


for file in prokka_*; do
   if [[ -d $file ]]; then
      cd $file
      cp -v *.gff ../${DIR1}
      cp -v *.gbk ../${DIR2}
      cd ../
   fi
done
