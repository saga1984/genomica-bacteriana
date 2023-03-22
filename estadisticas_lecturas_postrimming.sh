#!/bin/bash

#
# Ejecuta fastqc y obtiene estadisticas de lecturas listas para visualizarse en excel de todos los archivos generados por fasqc en un directorio
#

# moverse a la carpeta de "TRIMMING"
cd TRIMMING

######################
#    correr fastqc   #
######################

fastqc -t 12 --extract *fastq.gz

######################################################################
#     generar primer archivo con estadisticas de lecturas extenso    #
######################################################################

# Generar un archivo para guardar estadisticas basicas y poner los nombres de columnas
echo -e "ID,Numero,Longitud,%GC,PromedioQ" > lecturas_stats.csv

# Generar estadísticas basicas
for file in *fastqc; do
   file_name_R=$(basename $file | cut -d "." -f "1,2" )
   # capturar el número de lecturas por archivo
   Numero="$(cat $(echo $file/fastqc_data.txt) | sed -n '7p' | awk '{print $3}')"
   # capturar el tamaño de las lecturas por archivo
   Longitud="$(cat $(echo $file/fastqc_data.txt) | sed -n '9p'| awk '{print $3}')"
   # Capturar el contenido (%) de GC por archivo
   ContenidoGC="$(cat $(echo $file/fastqc_data.txt) | sed -n '10p'| awk '{print $2}')"
   # Obtener el promedio de calidad por archivo
   inicio="$(cat -n $file/fastqc_data.txt | grep '#Base' | awk '{print $1}' | sed -n '1p')"
   fin="$(cat -n $file/fastqc_data.txt | grep '>>END_MODULE' | awk '{print $1}' | sed -n '2p')"
   cat $(echo $file/fastqc_data.txt) | sed -n "$[ $(echo $inicio) + 1 ], $[ $(echo $fin) - 1] p" | awk '{sum += $2; n++} END {if (n > 0) print sum / n}' > PromedioQ
   # visualiza el resultado en forma de un archivo de excel
   echo -e "$file_name_R,$Numero,$Longitud,$ContenidoGC,$(cat PromedioQ)"
done >> lecturas_stats.csv # guardar las estadisticas en el archivo generado antes del for loop

# Generar estatus de estadisticas basicas (pass, warn, fail)
for file in *fastqc; do
   cat ${file}/fastqc_data.txt | grep '>>' | grep -v END_MODULE | tr -d '>>' | sed 's/\t/,/g' > ${file}_basic_stats.csv
   echo -e "$file,\n$(cat ${file}_basic_stats.csv)\n"
done > all_status_basic_stats.csv # guarda el resultado de todos los estatus juntos

# convertir el archivo .tab en .csv (para abrir en excel) y conservar ambos
awk 'BEGIN {FS="," ; OFS="\t"} {print $1, $2, $3, $4, $5}' lecturas_stats.csv > lecturas_stats.tab

###########################################################################################
#      generar archivo final en formato .csv con calidades de R1m R2 y promedio R1 R2     #
###########################################################################################

# directorio de trabajo
dir="FASTQC"

# crear directorio de trabajo
mkdir $dir

# mover resultados previos del script a $dir
mv *fastqc* $dir
mv lecturas_stats* $dir
mv all_status_basic_stats.csv $dir

# obtener filas de promedio de calidad de R1 y R2 por separado
awk 'NR % 2 == 0' $dir/lecturas_stats.csv | grep -v "ID" | cut -d "," -f "5" > $dir/temp_R1.txt
awk 'NR % 2 == 1' $dir/lecturas_stats.csv | grep -v "ID" | cut -d "," -f "5" > $dir/temp_R2.txt

# unir R1 y R2
paste $dir/temp_R1.txt $dir/temp_R2.txt > $dir/temp_R1R2_pasted.txt

# generar archivo final de estadisticas de lecturas: dar formato al archivo pasted, generar columna de promedios
awk '{print $1","$2, ($1 + $2)/2}' $dir/temp_R1R2_pasted.txt | sed '1i R1,R2,PromR1R2' > $dir/estadisticas_lecturas.csv

# remover archivos temporales
rm $dir/temp*
rm PromedioQ

# volver a carpeta inicial
cd ../
