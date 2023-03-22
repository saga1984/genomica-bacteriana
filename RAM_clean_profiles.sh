#!/bin/bash

#
# limpia los archivos obtenidos por R, eliminando simbolos como "+" o "," no deseados
#

# modificar primera columna
awk -F, '{print $1}' Frecuencias_finales.csv | sed 's/^[[:punct:]]*//g; s/[[:punct:]]*$//g' | cat -n > tmp_firstColumn.txt
# unir + + simbolos mas que se encuentren separados
sed -i 's/+ */+/g' tmp_firstColumn.txt
# remover utimo simbolo +
sed -i 's/++*$//g' tmp_firstColumn.txt

# modificar segunda columna
awk -F, '{print $2}' Frecuencias_finales.csv | cat -n > tmp_secondColumn.txt

# unir de nuevo dos columnas
join tmp_firstColumn.txt tmp_secondColumn.txt > tmp_Frecuencias_finales_clean.csv

# dar formato a archivo de frecuencias limpio
cat tmp_Frecuencias_finales_clean.csv | tr ' ' ',' | tr '"' ' ' | sed '1s/,//' | cut -d ',' -f '1' --complement > \
Frecuencias_finales_clean_complete.csv

# eliminar simbolo "+" en medio
sed -i 's/++*/+/g' Frecuencias_finales_clean_complete.csv

# mostrar como stdout el archivo limpio
cat Frecuencias_finales_clean_complete.csv

# eliminar archivos temporales
rm tmp*
