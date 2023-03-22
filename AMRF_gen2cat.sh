#!/bin/bash

########################################################################
# convertir archivos de resultados de genes de AMRFinder en categorias
########################################################################

# definir variables que contienen informaciones de genes RAM y genes especiales
genesEspeciales=$(cat /home/admsen/RAMDataBase/genesespeciales.txt)
genesRAM=$(cat /home/admsen/RAMDataBase/genesram.txt)

# convertir RAM genes en categorias
for especie in Salmonella Escherichia Listeria Enterococcus_faecium Enterococcus_faecalis; do

   # crear archivos para gen vs categoria
   if [[ -f AMRFINDER/AMRFinder_${especie}_resultados_all.csv ]]; then
      cp -v AMRFINDER/AMRFinder_${especie}_resultados_all.csv AMRFINDER/AMRFinder_${especie}_gen_resultados_all.csv
      cp -v AMRFINDER/AMRFinder_${especie}_gen_resultados_all.csv AMRFINDER/AMRFinder_${especie}_categoria_resultados_all.csv

      # convertir genes RAM en categorias
      for gen_cat in $(echo ${genesRAM}); do
         # definir gen
         Gen=$(basename ${gen_cat} | cut -d '_' -f '1')
         # definir categoria
         Cat=$(basename ${gen_cat} | cut -d '_' -f '2')
         # convertir gen en categoria
         sed -i "s/${Gen}/${Cat}/g" AMRFINDER/AMRFinder_${especie}_categoria_resultados_all.csv
      done

      # convertir genes especiales en categorias
      for gen_cat in $(echo ${genesEspeciales}); do
         # definir gen
         Gen=$(basename ${gen_cat} | cut -d '_' -f '1')
         # definir categoria
         Cat=$(basename ${gen_cat} | cut -d '_' -f '2')
         # convertir gen en categoria
         sed -i "s/${Gen}/${Cat}/g" AMRFINDER/AMRFinder_${especie}_categoria_resultados_all.csv
      done
   fi
done

