#!/bin/bash

#
# remover genes relacionados a estres y eliminar categoria de estres en archivo categorias
#

# variables a usar
genesEspeciales=$(cat /home/senasica2/RAMDataBase/genesespeciales.txt)
dir=RES.POINT_FINDER

for especie in Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis Citrobacter_freundii; do
   ################################################ genes ##########################################################

   # crear un nuevo archivo de genes
   cp ${dir}/ResPointFinder_${especie}_resultados_all.csv ${dir}/tmp.${especie}_reporte_genes.txt

   # remover genes de estres
   for gen in ${genesEspeciales}; do
      # definir gen
      Gen=$(basename ${gen} | cut -d '_' -f '1')
      # sustituir gen con string vacio (eliminar)
      sed -i "s/,${Gen}//g" ${dir}/tmp.${especie}_reporte_genes.txt
   done

   # eliminar ultima coma
   sed -i 's/,$//g' ${dir}/tmp.${especie}_reporte_genes.txt

   ####### eliminar primera columna y cambiar nombre #######
   cat ${dir}/tmp.${especie}_reporte_genes.txt | cut -d ',' -f '1' --complement > ${dir}/RAMcol_genes_${especie}.txt

   ############################################## categorias ##########################################################

   # agregar string para hacer salto, durante la eliminacion de duplicados en categorias
   awk '{print "Salto,"$0}' ${dir}/ResPointFinder_${especie}_categoria_resultados_all.csv > \
   ${dir}/tmp.ResPointFinder_${especie}_categoria_resultados_all.csv
   # remover mutaciones cromosomicas de parC y crear un nuevo archivo de categorias
   sed 's/Quinolonas_T57S/Quinolonas/g' ${dir}/tmp.ResPointFinder_${especie}_categoria_resultados_all.csv > ${dir}/tmp.${especie}_reporte_categorias.txt
   # remover posiciones de mutaciones cromosomicas, gyrA
   sed -i 's/Quinolonas_S83[FY]/Quinolonas/g' ${dir}/tmp.${especie}_reporte_categorias.txt
   sed -i 's/Quinolonas_D87[YNG]/Quinolonas/g' ${dir}/tmp.${especie}_reporte_categorias.txt
   # remover la categoria de estres
   sed -i 's/,Estres//g' ${dir}/tmp.${especie}_reporte_categorias.txt
   # eliminar duplicados
   cat ${dir}/tmp.${especie}_reporte_categorias.txt | tr ',' '\n' | uniq | tr '\n' ',' | sed 's/Salto,/\n/g' > ${dir}/tmp_${especie}_reporte_categorias.txt
   cat ${dir}/tmp_${especie}_reporte_categorias.txt | cut -d ',' -f '1' --complement > ${dir}/RAMcol_categorias_${especie}.txt
   ####### eliminar ultima coma ######
   sed -i 's/,$//g' ${dir}/RAMcol_categorias_${especie}.txt

   # remover archivos temporales
   rm ${dir}/tmp*
done
