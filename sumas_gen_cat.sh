#!/bin/bash

#
#
#
############## windows ################
# crear la variable que se usara en el for loop
#GRAM_completo="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM/GRAM_completo.csv"
#lista_genes_cat="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM/lista_genes_cat.txt" # contiene lista de genes obtenidos de R

############# linux ################
GRAM_completo="/home/senasica2/Documentos/2022/visita_danesa_junio/Ecoli/Ecoli_cerdo_RAM.csv"
lista_genes_cat="/home/senasica2/Documentos/2022/visita_danesa_junio/Ecoli/lista_genes_cat.txt" # contiene lista de genes obtenidos de R

# crear un archivo con nombres de columnas
echo "Gen_Cat,Conteo" > gen_cat_conteo.csv

# hacer for loop para obtener la suma total de cada gen
for gen in $(cat $lista_genes_cat); do
   gen_corto=$(basename $gen | cut -d "_" -f "1")
      suma=$(cat $GRAM_completo | grep "$gen_corto" | wc -l)
      echo -e "$gen,$suma"
done >> gen_cat_conteo.csv
