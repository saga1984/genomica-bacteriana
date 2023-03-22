#!/bin/bash

#----------------------------------------------------------------------------------
#   Ejecutar AMRFinderPlus sobre todos los ensambles contenidos en un directorio
#----------------------------------------------------------------------------------


# definir directorio
dir="AMRFINDER_Cov90_Id60"

# si no existe, crear directorio
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# muestra menu de sinopsis, uso y perametros
uso() {

   echo " SYNOPSIS"
   echo -e "\t Identificación de genes RAM (y genes especiales a partir de ensambles contenidos dentro de ./ASSEMBLY)"
   echo -e "\n USO"
   echo -e "\tAMRFinder_solo.sh [opciones] <Especie>"
   echo -e "\n PARAMETROS"
   echo -e "\t-h \t\tEste menú de ayuda"
   echo -e "\t-e \t\tEspecie en la que seran identificados los genes RAM y especiales"
   echo -e "\t-l \t\tVer la lista de especies disponibles"
}

# si el numero de argumentos es igual a cero mostrar la funcion uso y salir con error
if [[ ${#} -eq 0 ]]; then
   uso
   exit 1
fi

# lista de especies diaponibles como opcion '-l'
especie_lista="\n(TOMADO DE LA LISTA DE ORGANISMOS DE AMRfinder(Plus))\nSalmonella\nEscherichia\nEnterococcus_faecium\nEnterococcus_faecalis\n"

# empezar un conteo
conteo=0


# crear archivo para guardar resultados finales
echo "Especie,ID,Genes_RAM" > ${dir}/AMRFinder_resultados_all.csv

AMRFinderPlus() {
   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for ensamble in ASSEMBLY/*.fa; do
      # crear una variable para nombre (ID) de la muestra
      ensamble_name=$(basename ${ensamble} .fa)
      # actualizar el conte tras cada vuelta del loop
      conteo=$[ ${conteo} + 1 ]
      # imprimir el numero y el nombre del ensamble
      echo -e "\n${conteo}\t$ensamble_name\n"

      # ejecutar AMRFinder
      amrfinder -n $ensamble -c 0.9 -i 0.6 --threads $(nproc) --plus -o ${dir}/AMRF_${ensamble_name}.tsv 2> /dev/null
      # filtrar el resultado
      cat ${dir}/AMRF_${ensamble_name}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4,$16,$17}' > ${dir}/AMRF_${ensamble_name}_filtrado.csv
      # convertir CSV a TSV
      sed 's/,/\t/g' ${dir}/AMRF_${ensamble_name}_filtrado.csv > ${dir}/AMRF_${ensamble_name}_filtrado.tsv

      #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
      # obtener lista de genes por ID de muestra en una sola fila
      awk -F, '{print $1}' ${dir}/AMRF_${ensamble_name}_filtrado.csv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ensamble_name}_filtrado.txt
      # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
      echo -e "Myroides,${ensamble_name},$(cat ${dir}/tmp_AMRF_${ensamble_name}_filtrado.txt)" >> ${dir}/AMRFinder_resultados_all.csv

      # eliminar archivos temporales
      rm ${dir}/tmp*
   done
}

# si existe un primer argumento, toma los valores del case hacer lo correpondiente
while getopts ":e:h:l" opciones; do
   case "${opciones}" in
      e)
           especie=${OPTAGR}
           echo -e "\nComenzando identificación de mutaciones por MARFinder(Plus) para la especie: ${OPTARG}\n"
           AMRFinderPlus
           echo -e "\nTerminando identificación de mutaciones por MARFinder(Plus) para la especie: ${OPTARG}\n"
           ;;
      h)
           uso
           ;;
      l)
           echo -e "${especie_lista}"
           ;;
      ?)
           echo "-${OPTARG} no es una opción válida"
           uso
           ;;
   esac
done

