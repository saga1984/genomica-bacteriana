#!/bin/bash

for ensamble in 01.Ensamble/*-megahit.fa; do
   for profundidad in 03.Metabat/*-depth.txt; do
      ensamble_corto=$(basename ${ensamble} -megahit.fa)
      profundidad_corto=$(basename ${profundidad} .pulque-depth.txt)

      echo -e "\nEnsamble=${ensamble_corto}"
      echo -e "Profundidad=${profundidad_corto}\n"

      if [[ ${ensamble_corto} == ${profundidad_corto} ]];then
         metabat -i ${ensamble} -a ${profundidad} -o 03.Metabat/${ensamble_corto}_bins -t 5 --minCVSum 0 --saveCls -d -v --minCV 0.1>
      else
         continue
      fi
   done
done
