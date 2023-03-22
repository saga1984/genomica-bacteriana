
#!/bin/bash

# --------------------------------------------------------------------------------------------
#    Ejecutar resfinder.py en modo pointfinder, sobre todos los ensambles en un directorio
# --------------------------------------------------------------------------------------------


# crear directorio para guardar resultados
dir="RES.POINT_FINDER"

# si no existe, crear directorio
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# lista de generos
especie_list=(Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis Citrobacter_freundii)

# for cada uno de los generos bacterianos de análisis rutinario
for especie in "${especie_list[@]}"; do

   # definir genero
   genero=$(basename ${especie} | cut -d '_' -f '1')
   echo -e "\nGenero: = ${genero}\n" # CONTROL

   # crear archivo para guardar resultados finales
   echo "Especie,ID,Genes_RAM" > ${dir}/ResPointFinder_${especie}_resultados_all.csv

   # for loop para cada uno de los ensambles obtenidos y guardados en el directorio ASSEMBLY
   for ensamble in ASSEMBLY/*.fa; do
      # variable que guarda el ID de las muestras
      ename=${ensamble##ASSEMBLY/}
      ensamble_name=${ename%%-spades-assembly.fa} # guardar el ID de la secuencia

      ###################### ejecutar run_ResFinder para cada una de las siguientes opciones de generos ###################
      case ${especie} in
         Salmonella_enterica)
                  # si el archivo existe, entonces ejecuta run_resfinder.py, de lo contrario continua sin hacer nada
                  if [[ -f ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename} ]]; then
                     # definir var especie con espacio " " en lugar de  "_"
                     echo ""
                     especie="$(echo ${especie} | tr '_' ' ')"
                     echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                     # ejecutar resfinder en modo point finder
                     run_resfinder.py --inputfasta ${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                     # filtrar los archivos importantes de ResPoint y Resfinder
                     grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${especie}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
                     awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv
                     # filtrar los archivos importantes de Pointfinder
                     grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/Pointfinder_${ensamble_name}_all_filtered.tsv
                     grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv
                     # cambiar el nombre del archivo para que tome el nombre del ensamble
                     mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/${ensamble_name}_Prediction.tsv

                     ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                     # definir de nuevo especie
                     especie="$(echo ${especie} | tr ' ' '_')"
                     # obtener archivo de resultados de Pointfinder
                     grep -E "T57S|S83F|S83Y|S83I|D87G|D87N|D87Y|D87K" ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv | cut -d $'\t' -f '1' | tr ' .' '_' | sed 's/_p_/_/' | uniq | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_point_known.txt
                     # obtener archivo de resultados de Resfinder
                     awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
                     # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                     echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/tmp_${ensamble_name}_point_known.txt)" >> ${dir}/ResPointFinder_${especie}_resultados_all.csv
                  else
                     continue
                  fi
                  ;;
         Escherichia_coli)
                  # si el archivo no existe crealo, de lo contrario continua sin hacer nada
                  if [[ -f ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename} ]]; then
                     # definir var especie con espacio " " en lugar de  "_"
                     especie="$(echo ${especie} | tr '_' ' ')"
                     echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                     # ejecutar resfinder en modo point finder
                     run_resfinder.py --inputfasta ${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                     # filtrar los archivos importantes de ResPoint y Resfinder
                     grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${especie}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
                     awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv
                     # filtrar los archivos importantes de Pointfinder
                     grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|folP|23S|16S_rrsB|16S_rrsC|16S_rrsH|ampC-promoter|rpoB" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/Pointfinder_${ensamble_name}_all_filtered.tsv
                     grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|folP|23S|16S_rrsB|16S_rrsC|16S_rrsH|ampC-promoter|rpoB" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv
                     # cambiar el nombre del archivo para que tome el nombre del ensamble
                     mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/${ensamble_name}_Prediction.tsv
                     ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                     # definir de nuevo especie
                     especie="$(echo ${especie} | tr ' ' '_')"
                     # obtener archivo de resultados de Pointfinder
                     grep -E "S83L|G81D|D82G|S39I|R81S" ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv | cut -d $'\t' -f '1' | tr ' .' '_' | sed 's/_p_/_/' | uniq | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_point_known.txt
                     # obtener archivo de resultados de Resfinder
                     awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
                     # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                     echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/tmp_${ensamble_name}_point_known.txt)" >> $dir/ResPointFinder_${especie}_resultados_all.csv
                  else
                     continue
                  fi
                  ;;
         Listeria_monocytogenes)
                  # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                  if [[ -f ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename} ]]; then
                     echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                     # ejecutar resfinder
                     run_resfinder.py --inputfasta ${ensamble} --acquired -u -db_res_kma ${db_resfinder} -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                     # filtrar los archivos importantes de ResPoint y Resfinder
                     grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${especie}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
                     awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv

                     ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                     # definir de nuevo especie
                     especie="$(echo ${especie} | tr ' ' '_')"
                     # obtener archivo de resultados de Resfinder
                     awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
                     # unir resultados de ResFinder en un solo archivo CSV con ID y Genero bacteriano
                     echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt)" >> ${dir}/ResPointFinder_${especie}_resultados_all.csv
                  else
                     continue
                  fi
                  ;;
         Enterococcus_faecium)
                  # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                  if [[ -f ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename} ]]; then
                     # definir var especie con espacio " " en lugar de  "_"
                     especie="$(echo ${especie} | tr ' ' '_')"
                     echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                     # ejecutar resfinder en modo point finder
                     run_resfinder.py --inputfasta ${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}_faecium.log

                     # filtrar los archivos importantes de ResPoint y Resfinder
                     grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${especie}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
                     awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv
                     # filtrar los archivos importantes de Pointfinder
                     grep -E "Mutation|gyrA|parC|pbp5" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/Pointfinder_${ensamble_name}_all_filtered.tsv
                     grep -E "Mutation|gyrA|parC|pbp5" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv
                     # cambiar el nombre del archivo para que tome el nombre del ensamble
                     mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/${ensamble_name}_Prediction.tsv

                     ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                     # definir de nuevo especie
                     especie="$(echo ${especie} | tr ' ' '_')"
                     # obtener archivo de resultados de Pointfinder
                     grep -E "S83I|S83R|S83RL|S83RY|S83RN|S80I|S80R|E84K|E84G|E84L" ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv | cut -d $'\t' -f '1' | tr ' .' '_' | sed 's/_p_/_/' | uniq | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_point_known.txt
                     # obtener archivo de resultados de Resfinder
                     awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
                     # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                     echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/tmp_${ensamble_name}_point_known.txt)" >> ${dir}/ResPointFinder_${especie}_resultados_all.csv
                  else
                     continue
                  fi
                  ;;
         Enterococcus_faecalis)
                  # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                  if [[ -f ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename} ]]; then
                     # definir var especie con espacio " " en lugar de  "_"
                     especie="$(echo ${especie} | tr '_' ' ')"
                     echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                     # ejecutar resfinder en modo point finder
                     run_resfinder.py --inputfasta ${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}_faecalis.log

                     # filtrar los archivos importantes de ResPoint y Resfinder
                     grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${especie}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
                     awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv
                     # filtrar los archivos importantes de Pointfinder
                     grep -E "Mutation|gyrA|parC" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/Pointfinder_${ensamble_name}_all_filtered.tsv
                     grep -E "Mutation|gyrA|parC" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv
                     # cambiar el nombre del archivo para que tome el nombre del ensamble
                     mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/${ensamble_name}_Prediction.tsv
                     ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                     # definir de nuevo especie
                     especie="$(echo ${especie} | tr ' ' '_')"
                     # obtener archivo de resultados de Pointfinder
                     grep -E "S83I|S83R|S83RL|S83RY|S83RN" ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv | cut -d $'\t' -f '1' | tr ' .' '_' | sed 's/_p_/_/' | uniq | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_point_known.txt
                     # obtener archivo de resultados de Resfinder
                     awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
                     # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                     echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/tmp_${ensamble_name}_point_known.txt)" >> ${dir}/ResPointFinder_${especie}_resultados_all.csv
                  else
                     continue
                  fi
                  ;;
         Citrobacter_freundii)
                  # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                  if [[ -f ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename} ]]; then
                     echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                     # ejecutar resfinder
                     run_resfinder.py --inputfasta ${ensamble} --acquired -u -db_res_kma ${db_resfinder} -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                     # filtrar los archivos importantes de ResPoint y Resfinder
                     grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${especie}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
                     awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv

                     ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                     # definir de nuevo especie
                     especie="$(echo ${especie} | tr ' ' '_')"
                     # obtener archivo de resultados de Resfinder
                     awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
                     # unir resultados de ResFinder en un solo archivo CSV con ID y Genero bacteriano
                     echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt)" >> ${dir}/ResPointFinder_${especie}_resultados_all.csv
                  else
                     echo "ASSEMBLY/$(echo ${especie} | cut -d '_' -f '1')/${ename}, NO EXISTE"
                     continue
                  fi
                  ;;
      esac
      # eliminar archivos temporales
      rm *tmp*
   done
   # eliminar comma al final de cada fila (existen en caso de que no se hubieran identificado mutaciones puntuales)
   sed -i 's/,$//g' ${dir}/ResPointFinder_${especie}_resultados_all.csv
   sed -i 's/,$//g' ${dir}/ResPointFinder_${especie}_resultados_all.csv
done

################################
# convertir genes a categorias #
################################
RF_gen2cat.sh

##########################################################
# obtener archivo de columnas para reporte de resultados #
##########################################################
<<<<<<< HEAD
# genes y categorias sin genes de estres
RF_CategoriasGenes_RAMcol.sh

=======

# genes sin genes de estres
# categorias cin Estres ni mutaciones cromosomicas
RF_CategoriasGenes_RAMcol.sh
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
