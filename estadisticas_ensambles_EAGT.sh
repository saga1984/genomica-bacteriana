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
   ensname="$(basename $ensamble | cut -d '_' -f '1,2')" # asignar nombre de ensamble (corto)
   ename="$(basename $ensname | cut -d '-' -f '1,2,3')" # asignar nombre de ensamble ( mas corto)
   assembly-stats $ensamble > ASSEMBLY/Stats/${ename}-stats.txt # crea un archivo de stats por ensamble
done

# -------------------------------
# script para obtener profundidad
# -------------------------------

Profundidad_EAGT.sh

# -------------------------------------------------------------------
#  segundo loop para agregar de cobertura al archivo de estadisticas
# -------------------------------------------------------------------

for file1 in $dir/*cov*; do
   f1=${file1%%-cov.txt} # obtener nombre corto de archivo, eliminando sufijo -cov.txt
   sed -i 's/^/Coverage = /' $file1 # agregar la palabra coverage a cada archivo que contiene coverge
   for file2 in $dir/*stats*; do
      f2=${file2%%-stats.txt} # obtener nombre corto de archivo, eliminando sufijo -stats.txt
      if [[ $f1 != $f2 ]]; then # si los archivos no se llaman igual
         continue # ignoralo
      else # de lo contrario
         #echo -e "f1 = $f1\tf2 = $f2" # control
         echo $(cat $file1) >> $file2 # agrega coverage en la ultima linea del archivo -stats.txt
      fi
   done
done

# ------------------------------------------------------------------------------
# tercer loop, creacion del archivo final formato .csv con todas las stadisticas
# ------------------------------------------------------------------------------

# Generar un archivo y poner los nombres de columnas
echo -e "ID,Contigs,Length,N50,Coverage" > $dir/estadisticas_ensamble.csv

# ordenar y agrupar estadisticas estadisticas a partir de estadisticas obtenidas por 1er loop
for file in $dir/*stats*; do
   # asignar nombre de ensamble (corto)
   fname="$(basename $file | cut -d '-' -f '1,2,3,4,5')"
   # obtener numero de contigs
   contigs="$(cat $file | sed -n '2p' | cut -d ',' -f '2' | cut -d ' ' -f '4')"
   # obtener longitud del ensamble
   length="$(cat $file | sed -n '2p' | cut -d ',' -f '1' | cut -d ' ' -f '3')"
   # obtener N50
   N50="$(cat $file | sed -n '3p' | cut -d ',' -f '1' | cut -d ' ' -f 3)"
   # obtener coverage
   cov="$(cat $file |  sed -n '11p' | cut -d ' ' -f '3')"
   # crea filas de archivo con datos obtenidos en las 3 filas anteriores
   echo -e "$fname,$contigs,$length,$N50,$cov"
# anexa lo generado por el loop en el archivo creado antes del loop
done >> $dir/estadisticas_ensamble.csv

# convertir archivo .csv a .tab
awk 'BEGIN {FS=","; OFS="\t"} {print $1,$2,$3,$4,$5}' $dir/estadisticas_ensamble.csv > $dir/estadisticas_ensamble.tab

# ------------------------------------------------------------------------
#     generar archivo global de estadisticas de ensamble y de lecturas
# ------------------------------------------------------------------------

# unir estadisticas de ensamble y de lecturas
paste $dir/estadisticas_ensamble.csv FASTQC/estadisticas_lecturas.csv | awk  'BEGIN {FS=" "; OFS=","}{print $1,$2,$3}' > $dir/temp_total_stats.csv

# quitar primera fila y agregarla de nuevo sin la "," final
cat $dir/temp_total_stats.csv | sed '1d' | sed '1i ID,Contigs,Length,N50,Coverage,R1,R2,PromR1R2' > $dir/estadisticas_totales.csv

# remover archivos temporales
rm $dir/temp*
