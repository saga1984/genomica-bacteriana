#!/bin/bash

#
# Obtiene estadisticas a partir de una carpeta de estadisticas individuales
# obtenidas por el script sorting_hat.sh (assembly_stats.sh)
# Ademas obtiene estadisticas globales de ensambles y lecturas
#

# ------------------------------------------------------------------------------
#    generar archivo de estadisticas de lecturas en dos formatos: .csv y .tab
# ------------------------------------------------------------------------------

# crear directorio de trabajo
mkdir ASSEMBLY/Stats

# volver variable el diectorio de trabajo
dir="ASSEMBLY/Stats"

# Generar un archivo y poner los nombres de columnas
echo -e "ID,Length,Coverage,Contigs" > $dir/ensamble_stats.csv

# Generar estadisticas a partir de las estadisticas obtenidas por sorting_hat.sh
for file in $dir/*stats*; do
   # se obtiene nombre corto de ID a partir de nombre de archivo
   file_name=$(basename $file | cut -d "-" -f "1")
   # obtiene numero de contigs
   numero="$(cat $file | sed -n '2p' | awk 'BEGIN {FS="\t"} {print $2}')"
   # obtiene profundidad de ensamble
   profundidad="$(cat $file | sed -n '3p' | awk 'BEGIN {FS="\t"} {print $2}')"
   # obtiene tamaño de ensamble
   tamano="$(cat $file | sed -n '4p' | awk 'BEGIN {FS="\t"} {print $2}')"
   # crea filas de archivo con datos obtenidos en las 3 filas anteriores
   echo -e "$file_name,$tamano,$profundidad,$numero"
# anexa lo generado por el loop en el archivo creado antes del loop
done >> $dir/ensamble_stats.csv #

# convertir el archivo .csv en .tab (para abrir en excel) y conservar ambos
awk 'BEGIN {FS="," ; OFS="\t"} {print $1, $2, $3, $4}' $dir/ensamble_stats.csv > $dir/ensamble_stats.tab

# ----------------------------------------------------------------------------------------
#     generar archivo global de estadisticas de ensamble y de lecturas en formato .csv
# ----------------------------------------------------------------------------------------

# unir estadisticas de ensamble y de lecturas
paste $dir/ensamble_stats.csv FASTQC/estadisticas_lecturas.csv | awk  'BEGIN {FS=" "; OFS=","}{print $1,$2,$3}' > $dir/temp_total_stats.csv

# quitar primera fila y agregarla de nuevo sin la "," final
cat $dir/temp_total_stats.csv | sed '1d' | sed '1i ID,Contigs,Length,N50,Coverage,R1,R2,PromR1R2' > $dir/enstadisticas_totales.csv

# remover archivos temporales: estadisticas de lecturas corto y estadisticas totales con ","
#rm FASTQC/estadisticas_lecturas.csv
#rm $dir/temp_total_stats.csv
