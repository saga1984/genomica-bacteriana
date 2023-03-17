#!/bin/bash

# ----------------------------------------------------------------------------------
#   correr kmerfinder en todos los ensambles de un directorio y filtrar resultados
# ----------------------------------------------------------------------------------

# crear directorio de resultados de kmerfinder (y volverlo variable)
dir="KMERFINDER"
mkdir $dir

# correr kmerfinder y modificar resultados
for ensamble in ASSEMBLY/*.fa; do
   # definir nombre de archivo de resultados
   ename=$(basename ${ensamble} | cut -d "/" -f "2" | cut -d "-" -f "1")

   # correr kmerfinder ($kmerfinder_db ya es variable de sistema)
   kmerfinder.py -q -i ${ensamble} -db ${kmerfinder_db}/bacteria/bacteria.ATG -tax ${kmerfinder_db}/bacteria/bacteria.tax -o KF_${ename}

   # mover resultados a un solo directorio
   mv KF_${ename} ${dir}
   # convertir archivos de resultados a CSV
   sed 's/\t/,/g' ${dir}/KF_${ename}/results.spa > ${dir}/KF_${ename}/results_spa.csv
   sed 's/\t/,/g' ${dir}/KF_${ename}/results.txt > ${dir}/KF_${ename}/results_txt.csv

   # generar archivo conteniendo todos los resultados
   for file in ${dir}/KF_${ename}/*_spa.csv; do
      echo -e "${ename} \n$(cat ${file}) \n"
   done
done > ${dir}/kmerfinder_all_results.txt


