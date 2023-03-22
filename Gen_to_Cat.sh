#!/bin/bash

# ---------------------------------------------------------------
#    convierte genes en categorias correspondientes en archivo
# ---------------------------------------------------------------

########### WSL2 ############
# lista que relaciona genes con categorias, que se usa para convertir gen en categoria
#lista_gen_cat="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM_Junio/Gen_Cat/lista_genes_cat.txt"
# archivo original con genes identificados por aislado
#GRAM_completo="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM_Junio/Gen_Cat/GRAM_completo.csv"
# archivo nuevo con categorias correspondiente en lugar de genes
#CRAM_completo="/mnt/c/Users/acmar/Documents/SSB2/2022/PVRAM_Junio/Gen_Cat/CRAM_completo.csv"


########### linux ###########
# lista que relaciona genes con categorias, que se usa para convertir gen en categoria
lista_gen_cat="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/lista_genes_cat.txt"
# archivo original con genes identificados por aislado
GRAM_completo="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/GRAM_completo.csv"
# archivo nuevo con categorias correspondiente en lugar de genes
CRAM_completo="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_completo.csv"

cp $GRAM_completo $CRAM_completo

for gen_cat in $(cat $lista_gen_cat); do
   Gen=$(basename $gen_cat | cut -d '_' -f '1')
   Cat=$(basename $gen_cat | cut -d '_' -f '2')
   sed -i "s/$Gen/$Cat/g" "$CRAM_completo"
done

