#!/bin/bash

#
# corre SeqSero2 sobre todos los ensambles de un directorio y filtra resultados
#

# definir el vector para guardar resultados
dir=SEQSERO2

# si el directorio no existe entonces crealo
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

#####################
# ejecutar SeqSero2 #
#####################

# for loop para todos los ensambles
for ensamble in ASSEMBLY/Salmonella/*.fa; do
   # nombre de ensable por ID
   ename=${ensamble##ASSEMBLY/Salmonella/}
   ensamble_name=${ename%%-spades-assembly.fa}
   echo "nombre de ensamble = ${ensamble_name}"
   # correr SeqSero2
   SeqSero2_package.py -i ${ensamble} -t 4 -p $(nproc) -m k -d ${dir}/${ensamble_name} > ${dir}/tmp_SeqSero_${ensamble_name}_output.txt
   # filtrar resultados para archivo final 1 formato TSV con ID y resultados en una sola fila
   echo -e "$(cat ${dir}/${ensamble_name}/SeqSero_result.tsv | grep ${ensamble_name} | grep -v cannot)"
done > ${dir}/SeqSero2_resultados.tsv

#########################################
# modificar archivo final de resultados #
#########################################

# agregar nombre de columna a primera fila
sed -i '1i Sample_name\tOutput_directory\tInput_files\tO_antigen_prediction\tH1_antigen_prediction(fliC)\tH2_antigen_prediction(fljB)\tPredicted_identification\tPredicted_antigenic_profile\tPredicted_serotype' ${dir}/SeqSero2_resultados.tsv
# eliminar el string "-spades-assembly.fa"
sed -i 's/-spades-assembly.fa//g' ${dir}/SeqSero2_resultados.tsv
# filtar filas mas imprtantes
awk  'BEGIN {FS=OFS="\t"} {print $1,$4,$5,$6,$7,$8,$9}' ${dir}/SeqSero2_resultados.tsv > ${dir}/SeqSero2_resultados_filtrados.tsv

#######################################################
# obtener sefundo archivo final de stdout de SeqSero2 #
#######################################################

# para todos los archivos generados por SeqSero con la palabla output
for file in ${dir}/tmp*output.txt; do
   echo ${file} # nombre
   echo "$(cat ${file})" # contenido
   echo "" # espacio
done > ${dir}/SeqSero2_output.txt # archivo final

# eliminar archivos temporales
rm ${dir}/tmp*txt
