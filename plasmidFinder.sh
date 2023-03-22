#!/bin/bash

#
# Script para ejecutar plasmidifnder sobre todos los ensambles contenidos en un directorio
#

conteo="1"
for ensamble in ASSEMBLY/*.fa; do
   ename=$(basename ${ensamble} .fa)

   echo -e "\n ${conteo}.- ${ename}"
   conteo=$[ ${conteo} + 1 ]

   dir=PF_${ename}_l60_t60
   mkdir ${dir}
   plasmidfinder.py -l 0.6 -t 0.6 -i $ensamble -p ${plasmidfinder_db}  -mp ${blastn} -o ${dir}
   echo -e "\n"
done
