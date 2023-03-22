#!/bin/bash

# --------------------------------------------------------------------------------------------
#    Ejecutar resfinder.py en modo pointfinder, sobre todos los ensambles en un directorio
# --------------------------------------------------------------------------------------------

######### variables usadas como opciones ##########
# menu de ayuda opcion -h
menu_ayuda="
 SINOPSIS:
\t Identifica genes RAM y genes especiales, usando ResFinder(PointFinder)
\t para todos los genes ubicados en un directorio. Ej:(ASSEMBLY)
\n USO:
\t $(basename ${0}), [OPCIONES] <ESPECIE>
\n OPCIONES:
\t -e \t\t Especie de las secuencias de interes (NOTA: solo se podra identificar mutaciones puntuales si la especie
\t\t\t de interes esta INCLUIDA en la lista de especies disponibles, de lo contrario solo se analizaran genes adquiridos

\t -l \t\t Lista de especies disponibles, ver con '-l'

\t -h \t\t Muestre este menu de ayuda
"

# lista de especies opcion -l
lista_especies="
LISTA DE ESPECIES TOMADA DE RESFINDER (https://cge.food.dtu.dk/services/ResFinder/)\n
'Campylobacter spp.'
Campylobacter jejuni
Campylobacter coli
Escherichia coli
Enterococcus faecalis
Enterococcus faecium
Klebsiella
Helicobacter pylori
'Salmonella spp.'
Salmonella enterica
Plasmodium falciparum
Neisseria gonorrhoeae
Mycobacterium tuberculosis
Staphylococcus aureus
"

# si no se agregan opciones ni argmentos durante el llamado de la funcion
# entonces muesta el menu de ayuda y sal
if [[ $# -eq 0 ]]; then
   echo -e "${menu_ayuda}"
   exit 1
fi

# generar conteo
conteo=0

ResFinder(){

   # crear variable genero
   genero=$(echo ${OPTARG} | cut -d ' ' -f '1')

   # crear directorio para guardar resultados
   dir="RES.POINT_FINDER_${genero}"

   # si no existe, crear directorio
   if [[ ! -d ${dir} ]]; then
      mkdir ${dir}
   fi

   # crear archivo para guardar resultados finales en formato csv
   echo -e "Especie,ID,GenesRAM" > ${dir}/ResPointFinder_resultados_all.csv

   # for loop para cada uno de los ensambles obtenidos y guardados en el directorio ASSEMBLY
   for ensamble in ASSEMBLY/*.fa; do
      # variable que guarda el ID de las muestras
      ensamble_name=$(basename ${ensamble} -spades-assembly.fa)
      # aumentar conteo en cada vuelta del loop
      conteo=$[ ${conteo} + 1 ]
      # mostrar numero y nombre de muestra
      echo -e "\n$conteo\t${ensamble_name}\n"
      # variable de OPTARG unido por "_"
      optarg=$(echo "${OPTARG}" | tr ' ' '_')

      ############ ejecutar resfinder en modo point finder #################
      run_resfinder.py --inputfasta ./${ensamble} --acquired --point -u -db_res_kma ${db_resfinder} -db_point_kma ${db_pointfinder} -b ${blastn} -s "${OPTARG}" -o ${dir}/RF_${ensamble_name} 2> /dev/null

      # si run_resfiner.py se ejecuta bien, entonces realiza lo siguiente
      if [[ $? -eq 0 ]]; then
         # filtrar los archivos importantes de ResPoint y Resfinder
         grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table_${optarg}.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/ResPoint_${ensamble_name}_filtered.tsv
         awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv
         # filtrar los archivos importantes de Pointfinder
         grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' > ${dir}/Pointfinder_${ensamble_name}_all_filtered.tsv
         grep -E "Mutation|acrB|pmrA|pmrB|gyrA|gyrB|parC|parE|16S_rrsD" ${dir}/RF_${ensamble_name}/PointFinder_results.txt | awk 'BEGIN{FS=OFS="\t"}{print $1, $2, $3, $4}' | grep -v "Unknown" > ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv
         # cambiar el nombre del archivo para que tome el nombre del ensamble
         mv ${dir}/RF_${ensamble_name}/PointFinder_prediction.txt ${dir}/${ensamble_name}_Prediction.tsv
         ################################################ obtener archivo final de genes ########################################################
         # obtener archivo de resultados de Pointfinder
         grep -E "T57S|S83F|S83Y|S83I|D87G|D87N|D87Y|D87K" ${dir}/Pointfinder_${ensamble_name}_known_filtered.tsv | cut -d $'\t' -f '1' | tr ' .' '_' | sed 's/_p_/_/' | uniq | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_point_known.txt
         # obtener archivo de resultados de Resfinder
         awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
         # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
         echo -e "${optarg},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt),$(cat ${dir}/tmp_${ensamble_name}_point_known.txt)" >> ${dir}/ResPointFinder_resultados_all.csv

         # eliminar comma al final de cada fila (existen en caso de que no se hubieran identificado mutaciones puntuales)
         sed -i 's/,$//g' $dir/ResPointFinder_resultados_all.csv

      # de lo contarrio, elimina la carpeta recien creada y sal
      else
         echo -e "\nError!\n"
         rm -r -f ${dir}
         exit 1
      fi
      # eliminar archivos temporales
      rm ${dir}/*tmp*
   done
}


ResFinder_Other(){

   echo "No se realizara la identificacion de mutaciones puntuales para ${OPTARG}"

   # crear variable genero
   genero=$(echo ${OPTARG} | cut -d ' ' -f '1')

   # crear directorio para guardar resultados
   dir="RESFINDER_${OPTARG}"

   # si no existe, crear directorio
   if [[ ! -d ${dir} ]]; then
      mkdir ${dir}
   fi

   # crear archivo para guardar resultados finales en formato csv
   echo -e "Especie,ID,GenesRAM" > ${dir}/ResFinder_resultados_all.csv

   # for loop para cada uno de los ensambles obtenidos y guardados en el directorio ASSEMBLY
   for ensamble in ASSEMBLY/*.fa; do
      # variable que guarda el ID de las muestras
      ensamble_name=$(basename ${ensamble} -spades-assembly.fa)
      # aumentar conteo en cada vuelta del loop
      conteo=$[ ${conteo} + 1 ]
      # mostrar numero y nombre de muestra
      echo -e "\n$conteo\t${ensamble_name}\n"
      # variable de OPTARG unido por "_"
      optarg=$(echo "${OPTARG}" | tr ' ' '_')

      ################ ejecutar resfinder ###############
      run_resfinder.py --inputfasta ./${ensamble} --acquired -db_res_kma ${db_resfinder} -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> /dev/null

      # si run_resfiner.py se ejecuta bien, entonces realiza lo siguiente
      if [[ $? -eq 0 ]]; then
         # filtrar los archivos importantes de ResPoint y Resfinder
         awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/Resfinder_${ensamble_name}_filtered.tsv

         # obtener archivo de resultados de Resfinder
         awk '{print $1}' ${dir}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_${ensamble_name}_res.txt
         # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
         echo -e "${optarg},${ensamble_name},$(cat ${dir}/tmp_${ensamble_name}_res.txt)" >> ${dir}/ResFinder_resultados_all.csv

         # eliminar comma al final de cada fi+la (existen en caso de que no se hubieran identificado mutaciones puntuales)
         sed -i 's/,$//g' $dir/ResFinder_resultados_all.csv
      # de lo contarrio, elimina la carpeta recien creada y sal
      else
         echo -e "\nError!\n"
         rm -r -f ${dir}
         exit 1
      fi
      # eliminar archivos temporales
      rm ${dir}/*tmp*
   done
}



Lista_Especies=(
"Campylobacter spp."
"Campylobacter jejuni"
"Campylobacter coli"
"Escherichia coli"
"Enterococcus faecalis"
"Enterococcus faecium"
"Klebsiella"
"Helicobacter pylori"
"Salmonella spp."
"Salmonella enterica"
"Plasmodium falciparum"
"Neisseria gonorrhoeae"
"Mycobacterium tuberculosis"
"Staphylococcus aureus")



# parsear opciones y llamar funciones
while getopts "e:hl" opciones; do
   case ${opciones} in
      e)
           # si la esspecie de ineteres se encuentra INCLUIDA en la lista, entonces
           if [[ " ${Lista_Especies[@]} " =~ " ${OPTARG} " ]]; then
              echo -e "\nComenzando identificación de genes RAM y genes especiales por resfinder y pointfinder, para la especie: ${OPTARG}"
              ResFinder
              echo -e "\nIdentificación de genes RAM y genes especiales por resfinder y pointfinder Completado. Disfruta de tus resultados\n"
           # de lo contrario, corre
           else
              echo -e "\nComenzando identificación de genes RAM y genes especiales por resfinder, para la especie: ${OPTARG}"
              ResFinder_Other
              echo -e "\nIdentificación de genes RAM y genes especiales por resfinder Completado. Disfruta de tus resultados\n"
           fi
           ;;
      l)
           echo -e "${lista_especies}"
           ;;
      h)
           echo -e "${menu_ayuda}"
           ;;
      *)
           echo -e "\n\tLa opción: -${OPTARG}, no es una opción válida\n"
           echo -e "${menu_ayuda}"
           ;;
   esac
done

