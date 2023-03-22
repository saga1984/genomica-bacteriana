#!/bin/bash

DIR=RESULTS
########################################## SeqSero2 ######################################################
dir=SEQSERO2

# obtener archivo de resultados en formato de reporte de resultados
awk '{print$1", Antígeno O:"$2", H1:"$3", H2:"$4", Perfil:"$11", ser:"$12}' ${dir}/SeqSero2_resultados_filtrados.tsv \
| sed '1d' | grep -v "nombre" | sort > ${dir}/SeqSero2col.txt

######################################### stringMLST #######################################################
dir=STRINGMLST

# obtener archivo de resultados en formato de reporte de resultados
awk '{print $1", aroC("$2"), dnaN("$3"), hemD("$4"), hisD("$5"), purE("$6"), sucA("$7"), thrA("$8"); ST("$9")"}' \
${dir}/stringMLST_Salmonella.tsv | sed '1d' | sort > ${dir}/stringMLSTcol.txt

### unir archivos de stringMLST y SeqSero2 ###
#join -j 1 -t"," STRINGMLST/stringMLSTcol.txt SEQSERO2/SeqSero2col.txt | sed 's/), Antígeno/)\t Antígeno/g' \
#> ${DIR}/string_seqsero.tsv

# truco para separar IDs en excel
#sed -i 's/,/:/1' ${DIR}/string_seqsero.tsv

############################################## ResFinder ########################################################
#dir=RES.POINT_FINDER

# modificar el archivo para unirlo con archivo de genes (con el comando join
#for especie in \
#Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis_ Citrobacter_freundii; do
#   sed -i 's/,/,\t/1' ${dir}/RAMcol_categorias_${especie}.txt
#done

### unir archivos de genes y categorias ###
#join -j 1 -t "," ${dir}/RAMcol_genes_Salmonella_enterica.txt ${dir}/RAMcol_categorias_Salmonella_enterica.txt \
#> ${DIR}/genes_categorias_ram.tsv

# truco para separar IDs en excel
#sed -i 's/,/:/1' ${DIR}/genes_categorias_ram.tsv
