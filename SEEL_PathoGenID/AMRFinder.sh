#!/bin/bash

#----------------------------------------------------------------------------------
#   Ejecutar AMRFinderPlus sobre todos los ensambles contenidos en un directorio
#----------------------------------------------------------------------------------


# definir directorio
dir="AMRFINDER"

# si no existe, crear directorio
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# para cada uno de los generos vacterianos de analisis rutinario
for especie in Salmonella Escherichia Listeria Enterococcus_faecium Enterococcus_faecalis; do

   # crear archivo para guardar resultados finales
   echo "Especie,ID,Genes_RAM" > ${dir}/AMRFinder_${especie}_resultados_all.csv

   # definir genero
   genero=$(basename ${especie} | cut -d '_' -f '1')

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for ensamble in ASSEMBLY/*.fa; do
      # crear una variable para nombre (ID) de la muestra
      ensamble_name=$(basename ${ensamble} | cut -d "-" -f "1")
      # genero para el mejor hit de kraken2

      ##################################### sorting por identificacion taxonomica ##########################################
      # genero para el mejor hit de kraken2
      krakenGenus=$(awk -v gname=${genero} '$4 == "S" && $6 == gname {print $6"_"$7}' KRAKEN2/kraken_species_${ensamble_name}.txt | sed -n '1p')
      # genero para el mejor hit de kmerfinder
      kmerfinderGenus=$(awk '{print $2"_"$3}' KMERFINDER/KF_${ensamble_name}/results_spa.csv | grep "${krakenGenus}" | sed -n '1p')

      #################################### ejecucion de AMRFinder y filtrado de resultados ################################################
      # si tanto kraken2 como kamerfinder identifican el mismo genero entonces
      if [[ ${krakenGenus} == ${kmerfinderGenus} ]]; then
         #echo "Kraken2 Y KmerFinder son iguales. entrando a 'case'" # CONTROL

         # para cada una de las siguientes opciones de generos
         case ${especie} in
              Salmonella)
                      # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                      if [[ ! -f ${dir}/AMRF_${ensamble_name}_${genero}.tsv ]]; then
                         # ejecutar AMRFinder
                         amrfinder -n $ensamble -O ${genero} --threads $(nproc) --plus -o ${dir}/AMRF_${ensamble_name}_${genero}.tsv
                         # filtrar el resultado
                         cat ${dir}/AMRF_${ensamble_name}_${genero}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4}' > ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv
                         # convertir CSV a TSV
                         sed 's/,/\t/g' ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv > ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.tsv

                         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
                         # obtener lista de genes por ID de muestra en una sola fila
                         awk -F, '{print $1}' ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv | uniq | sed '1d' | cut -d "_" -f "1" | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ensamble_name}_${genero}_filtrado.txt
                         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
                         echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_AMRF_${ensamble_name}_${genero}_filtrado.txt)" >> ${dir}/AMRFinder_${especie}_resultados_all.csv
                      else
                         continue
                      fi
                      ;;
              Escherichia)
                      # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                      if [[ ! -f ${dir}/AMRF_${ensamble_name}_${genero}.tsv ]]; then
                         # ejecutar AMRFinder
                         amrfinder -n $ensamble -O ${genero} --threads $(nproc) --plus -o ${dir}/AMRF_${ensamble_name}_${genero}.tsv
                         # filtrar el resultado
                         cat ${dir}/AMRF_${ensamble_name}_${genero}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4}' > ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv
                         # convertir CSV a TSV
                         sed 's/,/\t/g' ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv > ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.tsv

                         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
                         # obtener lista de genes por ID de muestra en una sola fila
                         awk -F, '{print $1}' ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv | uniq | sed '1d' | cut -d "_" -f "1" | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ensamble_name}_${genero}_filtrado.txt
                         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
                         echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_AMRF_${ensamble_name}_${genero}_filtrado.txt)" >> ${dir}/AMRFinder_${especie}_resultados_all.csv
                      else
                         continue
                      fi
                      ;;
              Listeria)
                      # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                      if [[ ! -f ${dir}/AMRF_${ensamble_name}_${genero}.tsv ]]; then
                         # ejecutar AMRFinder
                         amrfinder -n $ensamble --threads $(nproc) --plus -o ${dir}/AMRF_${ensamble_name}_${genero}.tsv
                         # filtrar el resultado
                         cat ${dir}/AMRF_${ensamble_name}_${genero}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4}' > ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv
                         # convertir CSV a TSV
                         sed 's/,/\t/g' ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv > ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.tsv

                         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
                         # obtener lista de genes por ID de muestra en una sola fila
                         awk -F, '{print $1}' ${dir}/AMRF_${ensamble_name}_${genero}_filtrado.csv | uniq | sed '1d' | cut -d "_" -f "1" | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ensamble_name}_${genero}_filtrado.txt
                         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
                         echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_AMRF_${ensamble_name}_${genero}_filtrado.txt)" >> ${dir}/AMRFinder_${especie}_resultados_all.csv
                      else
                         continue
                      fi
                      ;;
              Enterococcus_faecium)
                      # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                      if [[ ! -f ${dir}/AMRF_${ensamble_name}_${especie}.tsv ]]; then
                         # ejecutar AMRFinder
                         amrfinder -n $ensamble -O ${especie} --threads $(nproc) --plus -o ${dir}/AMRF_${ensamble_name}_${especie}.tsv
                         # filtrar el resultado
                         cat ${dir}/AMRF_${ensamble_name}_${especie}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4}' > ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.csv
                         # convertir CSV a TSV
                         sed 's/,/\t/g' ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.csv > ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.tsv

                         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
                         # obtener lista de genes por ID de muestra en una sola fila
                         awk -F, '{print $1}' ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.csv | uniq | sed '1d' | cut -d "_" -f "1" | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ensamble_name}_${especie}_filtrado.txt
                         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
                         echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_AMRF_${ensamble_name}_${especie}_filtrado.txt)" >> ${dir}/AMRFinder_${especie}_resultados_all.csv
                      else
                         continue
                      fi
                      ;;
              Enterococcus_faecalis)
                      # si el archivo no existe crealo con AMRFinder, de lo contrario continua sin hacer nada
                      if [[ ! -f ${dir}/AMRF_${ensamble_name}_${especie}.tsv ]]; then
                         # ejecutar AMRFinder
                         amrfinder -n $ensamble -O ${especie} --threads $(nproc) --plus -o ${dir}/AMRF_${ensamble_name}_${especie}.tsv
                         # filtrar el resultado
                         cat ${dir}/AMRF_${ensamble_name}_${especie}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4}' > ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.csv
                         # convertir CSV a TSV
                         sed 's/,/\t/g' ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.csv > ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.tsv

                         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
                         # obtener lista de genes por ID de muestra en una sola fila
                         awk -F, '{print $1}' ${dir}/AMRF_${ensamble_name}_${especie}_filtrado.csv | uniq | sed '1d' | cut -d "_" -f "1" | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ensamble_name}_${especie}_filtrado.txt
                         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
                         echo -e "${especie},${ensamble_name},$(cat ${dir}/tmp_AMRF_${ensamble_name}_${especie}_filtrado.txt)" >> ${dir}/AMRFinder_${especie}_resultados_all.csv
                      else
                         continue
                      fi
                      ;;
         esac
      fi
   done
   # eliminar archivos temporales
   rm *tmp*
   rm ${dir}/*.txt
done

# eliminar archivos temporales y en formato json
rm -r -f tmp *json*

###############################
# convertir genes a categorias
###############################

AMRF_gen2cat.sh
