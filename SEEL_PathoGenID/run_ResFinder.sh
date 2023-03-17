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
especie_list=(Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis)

# for cada uno de los generos bacterianos de análisis rutinario
for especie in "${especie_list[@]}"; do

   # definir genero
   genero=$(basename ${especie} | cut -d '_' -f '1')
   echo -e "Genero: = ${genero}\n" # CONTROL

   # crear archivo para guardar resultados finales
   echo "Especie,ID,Genes_RAM" > $dir/ResPointFinder_${especie}_resultados_all.csv

   # for loop para cada uno de los ensambles obtenidos y guardados en el directorio ASSEMBLY
   for ensamble in ASSEMBLY/*.fa; do
      # variable que guarda el ID de las muestras
      ensamble_name="$(basename $ensamble | cut -d '-' -f '1')" # guardar el ID de la secuencia

      ############################################### sorting por genero ###################################################
      # genero para el mejor hit de kraken2
      krakenGenus=$(awk -v gname=${genero} '$4 == "S" && $6 == gname {print $6"_"$7}' KRAKEN2/kraken_species_${ensamble_name}.txt | sed -n '1p')
      echo -e "especie identificada por kraken ${ensamble_name} = ${krakenGenus}" # CONTROL
      # genero para el mejor hit de kmerfinder
      kmerfinderGenus=$(awk '{print $2"_"$3}' KMERFINDER/KF_${ensamble_name}/results_spa.csv | grep "${krakenGenus}" | sed -n '1p')
      echo -e "\nespecie identificada por kmefinder ${ensamble_name} = ${kmerfinderGenus}" # CONTROL

      ############################################ identificacion por especie ################################################
      # si tanto kraken2 como kamerfinder identifican el mismo genero entonces
      if [[ ${krakenGenus} == ${kmerfinderGenus} ]]; then
         #echo "Kraken2 Y KmerFinder son iguales. entrando a 'case'" # CONTROL
         ###################### ejecutar run_ResFinder para cada una de las siguientes opciones de generos ###################
         case ${especie} in
            Salmonella_enterica)
                     # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                     if [[ ! -d ${dir}/RF_${ensamble_name} ]]; then
                        # definir var especie con espacio " " en lugar de  "_"
                        especie="$(echo ${especie} | tr '_' ' ')"
                        echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                        # ejecutar resfinder en modo point finder
                        run_resfinder.py --inputfasta ${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                        # filtrar los archivos importantes de ResPoint y Resfinder
                        grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_salmonella.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/RF_${ensamble_name}/ResPoint_${ensamble_name}_filtered.tsv
                        awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv
                        # filtrar los archivos importantes de Pointfinder
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_all_filtered.tsv
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv
                        # cambiar el nombre del archivo para que tome el nombre del ensamble
                        mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/RF_${ensamble_name}/${ensamble_name}_Prediction.tsv

                        ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                        # definir de nuevo especie
                        especie="$(echo ${especie} | tr ' ' '_')"
                        # obtener archivo de resultados de Pointfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt
                        # obtener archivo de resultados de Resfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt
                        # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                        echo -e "${especie},${ensamble_name},$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt)" >> $dir/ResPointFinder_${especie}_resultados_all.csv
                     else
                        continue
                     fi
                     ;;
            Escherichia_coli)
                     # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                     if [[ ! -d ${dir}/RF_${ensamble_name} ]]; then
                        # definir var especie con espacio " " en lugar de  "_"
                        especie="$(echo ${especie} | tr '_' ' ')"
                        echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                        # ejecutar resfinder en modo point finder
                        run_resfinder.py --inputfasta ${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                        # filtrar los archivos importantes de ResPoint y Resfinder
                        grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_salmonella.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/RF_${ensamble_name}/ResPoint_${ensamble_name}_filtered.tsv
                        awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv
                        # filtrar los archivos importantes de Pointfinder
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_all_filtered.tsv
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv
                        # cambiar el nombre del archivo para que tome el nombre del ensamble
                        mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/RF_${ensamble_name}/${ensamble_name}_Prediction.tsv

                        ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                        # definir de nuevo especie
                        especie="$(echo ${especie} | tr ' ' '_')"
                        # obtener archivo de resultados de Pointfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt
                        # obtener archivo de resultados de Resfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt
                        # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                        echo -e "${especie},${ensamble_name},$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt)" >> $dir/ResPointFinder_${especie}_resultados_all.csv
                     else
                        continue
                     fi
                     ;;
            Listeria_monocytogenes)
                     # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                     if [[ ! -d ${dir}/RF_${ensamble_name} ]]; then
                        echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                        # ejecutar resfinder
                        run_resfinder.py --inputfasta $ensamble --acquired -u -db_res_kma ${db_resfinder} -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}.log

                        # filtrar los archivos importantes de ResPoint y Resfinder
                        grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_salmonella.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/RF_${ensamble_name}/ResPoint_${ensamble_name}_filtered.tsv
                        awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv
                        # filtrar los archivos importantes de Pointfinder
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_all_filtered.tsv
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv
                        # cambiar el nombre del archivo para que tome el nombre del ensamble
                        mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/RF_${ensamble_name}/${ensamble_name}_Prediction.tsv

                        ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                        # definir de nuevo especie
                        especie="$(echo ${especie} | tr ' ' '_')"
                        # obtener archivo de resultados de Resfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt
                        # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                        echo -e "${especie},${ensamble_name},$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt)" >> $dir/ResPointFinder_${especie}_resultados_all.csv
                     else
                        continue
                     fi
                     ;;
            Enterococcus_faecium)
                     # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                     if [[ ! -d ${dir}/RF_${ensamble_name} ]]; then
                        # definir var especie con espacio " " en lugar de  "_"
                        especie="$(echo ${especie} | tr ' ' '_')"
                        echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                        # ejecutar resfinder en modo point finder
                        run_resfinder.py --inputfasta $ensamble --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}_faecium.log

                        # filtrar los archivos importantes de ResPoint y Resfinder
                        grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_salmonella.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/RF_${ensamble_name}/ResPoint_${ensamble_name}_filtered.tsv
                        awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv
                        # filtrar los archivos importantes de Pointfinder
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_all_filtered.tsv
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv
                        # cambiar el nombre del archivo para que tome el nombre del ensamble
                        mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/RF_${ensamble_name}/${ensamble_name}_Prediction.tsv

                        ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                        # definir de nuevo especie
                        especie="$(echo ${especie} | tr ' ' '_')"
                        # obtener archivo de resultados de Pointfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt
                        # obtener archivo de resultados de Resfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt
                        # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                        echo -e "${especie},${ensamble_name},$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt)" >> $dir/ResPointFinder_${especie}_resultados_all.csv
                     else
                        continue
                     fi
                     ;;
            Enterococcus_faecalis)
                     # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                     if [[ ! -d ${dir}/RF_${ensamble_name} ]]; then
                        # definir var especie con espacio " " en lugar de  "_"
                        especie="$(echo ${especie} | tr '_' ' ')"
                        echo -e "corriendo run_ResFinder usando, ensamble: ${ensamble},\tespecie: ${especie}\n" # CONTROL
                        # ejecutar resfinder en modo point finder
                        run_resfinder.py --inputfasta $ensamble --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -s "${especie}" -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> ${dir}/${genero}_faecalis.log

                        # filtrar los archivos importantes de ResPoint y Resfinder
                        grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_salmonella.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/RF_${ensamble_name}/ResPoint_${ensamble_name}_filtered.tsv
                        awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv
                        # filtrar los archivos importantes de Pointfinder
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_all_filtered.tsv
                        grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv
                        # cambiar el nombre del archivo para que tome el nombre del ensamble
                        mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/RF_${ensamble_name}/${ensamble_name}_Prediction.tsv

                        ###################### obtener archivo de genes RAM por ID en una sola fila en formato CSV #########################
                        # definir de nuevo especie
                        especie="$(echo ${especie} | tr ' ' '_')"
                        # obtener archivo de resultados de Pointfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Pointfinder_${ensamble_name}_known_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt
                        # obtener archivo de resultados de Resfinder
                        awk '{print $1}' ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt
                        # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
                        echo -e "${especie},${ensamble_name},$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_point_known.txt)" >> $dir/ResPointFinder_${especie}_resultados_all.csv
                     else
                        continue
                     fi
                     ;;
         esac
      fi
      # eliminar archivos temporales
      rm *tmp*
   done
   # eliminar comma al final de cada fila (existen en caso de que no se hubieran identificado mutaciones puntuales)
   sed -i 's/,$//g' $dir/ResPointFinder_${genero}_resultados_all
   sed -i 's/,$//g' $dir/ResPointFinder_${genero}_resultados_all
done

###############################
# convertir genes a categorias
###############################

RF_gen2cat.sh
