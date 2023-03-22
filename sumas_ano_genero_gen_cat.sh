#!/bin/bash

# ---------------------------------------------------
#   obtiene el numero de genes por genero y por ano
# ---------------------------------------------------

#   crear las variables que vamos a usar en el for loop
# -------------------------------------------------------
##### windows (WSL2) #####
#lista_genes_cat="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM/lista_genes_cat.txt" # contiene lista de genes obtenidos de R
#GRAM_completo="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM/GRAM_completo.csv" # archivo descargado del server que relaciona gen con categoria

##### linux (Ubuntu 20.04) #####
# contiene lista de genes obtenidos de R
lista_genes_cat="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/lista_genes_cat.txt"
# archivo descargado del server que relaciona gen con categoria
GRAM_completo="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/GRAM_completo.csv"
# --------------------------------------------------------
# hacer for loop de anos generos y genes RAM
for genero in Escherichia Salmonella Enterococcus; do
   for gen in $(cat $lista_genes_cat); do
       gen_corto=$(basename $gen | cut -d "_" -f "1")
      for ano in 2017 2018 2019 2020 2021; do
         suma=$(cat $GRAM_completo | grep "$ano" | grep "$genero" | grep "$gen_corto" | wc -l)
         echo -e "$ano,$genero,$gen,$suma"
      done
   done
done > sumas_ano_genero_gen_cat.csv




############################## E coli cerdo ######################################
# windows (WSL2)
#lista_genes_cat="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM/lista_genes_cat.txt" # contiene lista de genes obtenidos de R
#GRAM_completo="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM/GRAM_completo.csv" # archivo descargado del server que relaciona gen con categoria

#linux (Ubuntu 20.04)
#lista_genes="/home/senasica2/Documentos/2022/visita_danesa_junio/Ecoli/lista_genes_cat.txt" # contiene lista de genes obtenidos de R
#GRAM_completo="/home/senasica2/Documentos/2022/visita_danesa_junio/Ecoli/Ecoli_cerdo_RAM.csv" # archivo descargado del server que relaciona gen con categoria

# hacer for loop de anos generos y genes RAM
#for genero in Escherichia; do
#   for gen in $(cat $lista_genes); do
#       gen_corto=$(basename $gen | cut -d "_" -f "1")
#      for ano in 2021; do
#         suma=$(cat $GRAM_completo | grep "$gen_corto" | wc -l)
#         echo -e "$ano,$genero,$gen,$suma"
#      done
#   done
#done > sumas_ano_genero_gen_cat2.csv


