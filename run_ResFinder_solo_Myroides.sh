#!/bin/bash

# --------------------------------------------------------------------------------------------
#    Ejecutar resfinder.py en modo pointfinder, sobre todos los ensambles en un directorio
# --------------------------------------------------------------------------------------------


# crear directorio para guardar resultados
dir="RESFINDER_Cov70_Id50"

# si no existe, crear directorio
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# generar conteo
conteo=0

# crear archivo para resultados conjuntados
echo "Myroides,ID,GenesRAM" > $dir/ResFinder_resultados_all.csv

# for loop para cada uno de los ensambles obtenidos y guardados en el directorio ASSEMBLY
for ensamble in ASSEMBLY/*.fa; do
   # variable que guarda el ID de las muestras
   ensamble_name="$(basename $ensamble .fa)" # guardar el ID de la secuencia
   # aumentar conteo en cada vuelta del loop
   conteo=$[ ${conteo} + 1 ]
   # mostrar numero y nombre de muestra
   echo -e "$conteo\t${ensamble_name}\n"

   # ejecutar resfinder en modo point finder
   run_resfinder.py --inputfasta ./$ensamble --acquired -l 0.7 -t 0.5 -db_res_kma ${db_resfinder} -b ${blastn} -o ${dir}/RF_${ensamble_name} 2> /dev/null

   # filtrar los archivos importantes de ResPoint y Resfinder
   grep -E "Class|Resistant" ${dir}/RF_${ensamble_name}/pheno_table.txt | awk  'BEGIN{FS=OFS="\t"} {print $1, $2, $4, $5}' > ${dir}/RF_${ensamble_name}/ResFinder_${ensamble_name}_filtered.tsv
   awk 'BEGIN {FS=OFS="\t"} {print $1, $8}' ${dir}/RF_${ensamble_name}/ResFinder_results_tab.txt > ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv

   # obtener archivo de resultados de Resfinder
   awk '{print $1}' ${dir}/RF_${ensamble_name}/Resfinder_${ensamble_name}_filtered.tsv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt
   # unir resultados de Res y Point Finder en un solo archivo CSV con ID y Genero bacteriano
   echo -e "Myroides,${ensamble_name},$(cat ${dir}/RF_${ensamble_name}/tmp_${ensamble_name}_res.txt)" >> $dir/ResFinder_resultados_all.csv

   # eliminar comma al final de cada fila (existen en caso de que no se hubieran identificado mutaciones puntuales)
   sed -i 's/,$//g' $dir/ResFinder_resultados_all.csv

   # eliminar archivos temporales
   rm ${dir}/RF_${ensamble_name}/*tmp*
done

