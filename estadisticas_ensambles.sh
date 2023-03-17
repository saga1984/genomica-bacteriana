#!/bin/bash

#
# script que obtiene estadisticas de calidad de ensamble por ensamble en formato .tab
# y por ensambles totales en un directorio en formato .csv
#

# crear directorio de trabajo
mkdir ASSEMBLY/Stats

# volver variable directorio de trabajo
dir="ASSEMBLY/Stats"

# --------------------------------------------------------------------
# primer loop, creacion de archivos de estadisticas con assembly-stats
# --------------------------------------------------------------------
# NOTA: assembly-stats no obtiene profundidad, se debe obtener por separado

for ensamble in ASSEMBLY/*.fa; do
   ensamble_name=${ensamble%%-spades-assembly.fa} # asignar nombre de ensamble (corto)
   ename=$(basename ${ensamble_name} | cut -d '/' -f '2') # asignar nombre de ensamble ( más corto)
   assembly-stats ${ensamble} > ASSEMBLY/Stats/${ename}-stats.txt # crea un archivo de stats por ensamble
done

# -------------------------------
# script para obtener profundidad
# -------------------------------

Profundidad.sh

# -------------------------------------------------------------------
#  segundo loop para agregar de cobertura al archivo de estadisticas
# -------------------------------------------------------------------

for file1 in ${dir}/*coverage*; do
   f1=${file1%%-coverage.txt} # obtener nombre corto de archivo, eliminando sufijo "-cov.txt"
   for file2 in ${dir}/*stats*; do
      f2=${file2%%-stats.txt} # obtener nombre corto de archivo, eliminando sufijo "-stats.txt"
      if [[ ${f1} != ${f2} ]]; then # si los archivos no se llaman igual
         continue # ignoralo
      else # de lo contrario
         echo -e "f1 = ${f1}\tf2 = ${f2}" # control
         echo $(cat ${file1}) >> ${file2} # agrega coverage en la ultima linea del archivo -stats.txt
      fi
   done
done

# -------------------------------------------------------------------
#  tercer loop para agregar de cobertura al archivo de estadisticas
# -------------------------------------------------------------------

for file1 in ${dir}/*depth*; do
   f1=${file1%%-depth.txt} # obtener nombre corto de archivo, eliminando sufijo "-depth.txt"
   for file2 in ${dir}/*stats*; do
      f2=${file2%%-stats.txt} # obtener nombre corto de archivo, eliminando sufijo "-stats.txt"
      if [[ ${f1} != ${f2} ]]; then # si los archivos no se llaman igual
         continue # ignoralo
      else # de lo contrario
         echo -e "f1 = ${f1}\tf2 = ${f2}" # control
         echo $(cat ${file1}) >> ${file2} # agrega coverage en la ultima linea del archivo -stats.txt
      fi
   done
done

# ------------------------------------------------------------------------------------
#    cuarto loop, creacion del archivo final formato .csv con todas las stadisticas
# ------------------------------------------------------------------------------------

# Generar un archivo y poner los nombres de columnas
echo -e "ID,Contigs,Length,Largest_contig,N50,N90,N_count,Gaps,Coverage,Depth" > ${dir}/estadisticas_ensamble.csv

# ordenar y agrupar estadisticas estadisticas a partir de estadisticas obtenidas por 1er loop
for file in ${dir}/*stats*; do
   # asignar nombre de ensamble (corto)
   fname="$(basename $file | cut -d '-' -f '1')"
   # obtener numero de contigs
   contigs=$(cat ${file} | sed -n '2p' | cut -d ',' -f '2' | cut -d ' ' -f '4')
   # obtener longitud del ensamble
   length=$(cat ${file} | sed -n '2p' | cut -d ',' -f '1' | cut -d ' ' -f '3')
   # obtener tamaño de contig mas grande
   largest=$(cat ${file} | sed -n '2p' | cut -d ',' -f '4' | cut -d ' ' -f '4')
   # obtener N50
   N50=$(cat ${file} | sed -n '3p' | cut -d ',' -f '1' | cut -d ' ' -f '3')
   # obtener N90
   N90=$(cat ${file} | sed -n '7p' | cut -d ',' -f '1' | cut -d ' ' -f '3')
   # obtener Ns
   n_count=$(cat ${file} | sed -n '9p' | cut -d ',' -f '1' | cut -d ' ' -f '3')
   # obtener gaps
   gaps=$(cat ${file} | sed -n '10p' | cut -d ',' -f '1' | cut -d ' ' -f '3')
   # obtener profundidad
   coverage=$(cat ${file} | sed -n '11p' | cut -d ' ' -f '3')
   # obtener cobertura
   depth=$(cat ${file} |  sed -n '12p' | cut -d ' ' -f '3')
   # crea filas de archivo con datos obtenidos en las 3 filas anteriores
   echo -e "$fname,$contigs,$length,$largest,$N50,$N90,$n_count,$gaps,$coverage,$depth"
# anexa lo generado por el loop en el archivo creado antes del loop
done >> ${dir}/estadisticas_ensamble.csv

# eliminar '-stats.txt'
sed -i 's/-stats.txt//g' ${dir}/estadisticas_ensamble.csv

# convertir archivo CSV a TSV
sed 's/,/\t/g' ${dir}/estadisticas_ensamble.csv > ${dir}/estadisticas_ensamble.tsv

# ------------------------------------------------------------------------
#     generar archivo global de estadisticas de ensamble y de lecturas
# ------------------------------------------------------------------------

# unir estadisticas de ensamble y de lecturas
paste ${dir}/estadisticas_ensamble.csv TRIMMING/FASTQC/estadisticas_lecturas.csv | awk  'BEGIN {FS=" "; OFS=","}{print $1,$2,$3}' > ${dir}/temp_total_stats.csv

# quitar primera fila y agregarla de nuevo sin la "," final
cat ${dir}/temp_total_stats.csv | sed '1d' | sed '1i ID,Contigs,Length,Largest_contig,N50,N90,N_count,Gaps,Coverage,Depth,R1,R2,PromR1R2' > ${dir}/estadisticas_totales.csv

# convertir CSV a TSV
sed 's/,/\t/g' ${dir}/estadisticas_totales.csv > ${dir}/estadisticas_totales.tsv

# remover archivos temporales
rm ${dir}/temp*

# remover archivos de cobertura y profundidad
rm ${dir}/*coverage.txt
rm ${dir}/*depth.txt
