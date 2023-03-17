#!/bin/bash


for file in *AA.txt; do
   # asignar nombre de archivo
   fname=$(basename ${file} | cut -d '_' -f '1')
   # crear aerchivos temporales
   cat ${file} | grep "Query" | grep -v "NODE" | awk '{print $3}' > Query_${fname}.txt
   cat ${file} | grep "Sbjct" | awk '{print $3}' > Subject_${fname}.txt
   # imprimir como una sola linea de texto
   echo $(cat Subject_${fname}.txt) > Subject_${fname}.txt
   echo $(cat Query_${fname}.txt) > Query_${fname}.txt
   # eliminar espacios en blanco
   sed -i 's/ //g' Subject_${fname}.txt
   sed -i 's/ //g' Query_${fname}.txt
done

