#!/bin/bash

###############################################################################
# convertir archivos de resultados de genes de run_resfinder.sh en categorias
###############################################################################

# definir variables que contienen informaciones de genes RAM y genes especiales
genesEspeciales=$(cat /home/admsen/RAMDataBase/genesespeciales.txt)
genesRAM=$(cat /home/admsen/RAMDataBase/genesram.txt)

# for loop de nombre de archivos de acuerdo a especies contempladas en análisis de ResFinder
for especie in Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis; do

   # crear archivos para gen vs categoria
   cat -n RES.POINT_FINDER/ResPointFinder_${especie}_resultados_all.csv > RES.POINT_FINDER/ResPointFinder_${especie}_gen_resultados_all.csv

   #########################################################################################################################
   # apartir de archivo de genes crear archivos de categorias 1 (solo Genero y ID) y categorias 2 (Genes RAM y especiales)
   #########################################################################################################################

   # archivo de categorias 1
   cat RES.POINT_FINDER/ResPointFinder_${especie}_gen_resultados_all.csv | cut -d ',' -f '1,2' \
   > RES.POINT_FINDER/ResPointFinder_${especie}_categoria1_resultados_all.csv
   # archivo de categorias 2 temporal (sin numeracion)
   cat RES.POINT_FINDER/ResPointFinder_${especie}_gen_resultados_all.csv | cut -d ',' -f '1,2' --complement \
   > RES.POINT_FINDER/tmp_ResPointFinder_${especie}_categoria2_resultados_all.csv

   # archivo de categorias 2 con numeracion
   cat -n RES.POINT_FINDER/tmp_ResPointFinder_${especie}_categoria2_resultados_all.csv \
   > RES.POINT_FINDER/ResPointFinder_${especie}_categoria2_resultados_all.csv

   # convertir genes RAM en categorias, solo en archivo de categorias 2
   for gen_cat in ${genesRAM}; do
      # definir gen
      Gen=$(basename ${gen_cat} | cut -d '_' -f '1')
      # definir categoria
      Cat=$(basename ${gen_cat} | cut -d '_' -f '2')
      # convertir gen en categoria
      sed -i "s/$Gen/$Cat/g" RES.POINT_FINDER/ResPointFinder_${especie}_categoria2_resultados_all.csv
   done

   # convertir genes especiales en categorias, solo en archivo de categorias 2
   for gen_cat in ${genesEspeciales}; do
      # definir gen
      Gen=$(basename ${gen_cat} | cut -d '_' -f '1')
      # definir categoria
      Cat=$(basename ${gen_cat} | cut -d '_' -f '2')
      # convertir gen en categoria
      sed -i "s/$Gen/$Cat/g" RES.POINT_FINDER/ResPointFinder_${especie}_categoria2_resultados_all.csv
   done

   #################
   # unir archivos
   #################

   # archivo de categorias 1 y remover primera columna e conteos
   join RES.POINT_FINDER/ResPointFinder_${especie}_categoria1_resultados_all.csv RES.POINT_FINDER/ResPointFinder_${especie}_categoria2_resultados_all.csv | cut -d ' ' -f '1' --complement \
   > RES.POINT_FINDER/ResPointFinder_${especie}_categoria_resultados_all.csv # guardar resultados en archivo final

   # dar formato final a archivos
   sed -i 's/ /,/g' RES.POINT_FINDER/ResPointFinder_${especie}_categoria_resultados_all.csv
done

# eliminar archivos temporales
rm RES.POINT_FINDER/*tmp*
rm RES.POINT_FINDER/*_categoria1_*
rm RES.POINT_FINDER/*_categoria2_*
