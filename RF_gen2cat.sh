#!/bin/bash

###########################################################
# convertir archivos de resultados de genes en categorias
###########################################################

# definir variables que contienen informaciones de genes RAM y genes especiales
genesEspeciales=$(cat ${HOME}/RAMDataBase/genesespeciales.txt)
genesRAM=$(cat ${HOME}/RAMDataBase/genesram.txt)

dir="RES.POINT_FINDER"
# for loop de nombre de archivos de acuerdo a especies contempladas en análisis de ResFinder
for especie in Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis Citrobacter_freundii; do

   # crear archivos para gen vs categoria
   cat -n ${dir}/ResPointFinder_${especie}_resultados_all.csv > ${dir}/ResPointFinder_${especie}_gen_resultados_all.csv

   #########################################################################################################################
   # apartir de archivo de genes crear archivos de categorias 1 (solo Genero y ID) y categorias 2 (Genes RAM y especiales)
   #########################################################################################################################

   # archivo de categorias 1
   cat ${dir}/ResPointFinder_${especie}_gen_resultados_all.csv | cut -d ',' -f '1,2' \
   > ${dir}/ResPointFinder_${especie}_categoria1_resultados_all.csv
   # archivo de categorias 2 temporal (sin numeracion)
   cat ${dir}/ResPointFinder_${especie}_gen_resultados_all.csv | cut -d ',' -f '1,2' --complement \
   > ${dir}/tmp_ResPointFinder_${especie}_categoria2_resultados_all.csv

   # archivo de categorias 2 con numeracion
   cat -n ${dir}/tmp_ResPointFinder_${especie}_categoria2_resultados_all.csv \
   > ${dir}/ResPointFinder_${especie}_categoria2_resultados_all.csv

   # convertir genes RAM en categorias, solo en archivo de categorias 2
   for gen_cat in ${genesRAM}; do
      # definir gen
      Gen=$(basename ${gen_cat} | cut -d '_' -f '1')
      # definir categoria
      Cat=$(basename ${gen_cat} | cut -d '_' -f '2')
      # convertir gen en categoria
      sed -i "s/$Gen/$Cat/g" ${dir}/ResPointFinder_${especie}_categoria2_resultados_all.csv
   done

   # convertir genes especiales en categorias, solo en archivo de categorias 2
   for gen_cat in ${genesEspeciales}; do
      # definir gen
      Gen=$(basename ${gen_cat} | cut -d '_' -f '1')
      # definir categoria
      Cat=$(basename ${gen_cat} | cut -d '_' -f '2')
      # convertir gen en categoria
      sed -i "s/$Gen/$Cat/g" ${dir}/ResPointFinder_${especie}_categoria2_resultados_all.csv
   done

   #################
   # unir archivos
   #################

   # archivo de categorias 1 y remover primera columna e conteos
   join ${dir}/ResPointFinder_${especie}_categoria1_resultados_all.csv ${dir}/ResPointFinder_${especie}_categoria2_resultados_all.csv | cut -d ' ' -f '1' --complement \
   > ${dir}/ResPointFinder_${especie}_categoria_resultados_all.csv # guardar resultados en archivo final

   # dar formato final a archivos
   sed -i 's/ /,/g' ${dir}/ResPointFinder_${especie}_categoria_resultados_all.csv
   sed -i "s/\r//g" ${dir}/ResPointFinder_${especie}_categoria_resultados_all.csv
done

# eliminar archivos temporales
rm ${dir}/*tmp*
rm ${dir}/*_categoria1_*
rm ${dir}/*_categoria2_*

