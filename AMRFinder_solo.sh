#!/bin/bash

#----------------------------------------------------------------------------------
#   Ejecutar AMRFinderPlus sobre todos los ensambles contenidos en un directorio
#----------------------------------------------------------------------------------

# muestra menu de sinopsis, uso y perametros (help)
uso() {
   echo ""
   echo " SINOPSIS:"
   echo -e "\t Identificación de genes RAM (y genes especiales) con AMRFinder(Plus),\n\t a partir de ensambles contenidos dentro de ./ASSEMBLY"
   echo -e "\n USO:"
   echo -e "\t$(basename ${0}) [opciones] <Especie>"
<<<<<<< HEAD
=======
   echo -e "\t$(basename ${0}) -l"
   echo -e "\t$(basename ${0}) -e Salmonella_enterica"
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
   echo -e "\n OPCIONES:"
   echo -e "\t-h \t\tMuestra este menú de ayuda"
   echo ""
   echo -e "\t-e \t\tEspecie o genero de secuencias de ineteres INCLUIDA en la lista de especiesdisponible"
   echo ""
   echo -e "\t-l \t\tVer la lista de especies disponibles"
   echo ""
}

# si el numero de opciones es igual a cero mostrar la funcion uso (help) y salir con error
if [[ ${#} -eq 0 ]]; then
   uso
   exit 1
fi

# lista de especies diaponibles con la opcion '-l'
especie_lista="
TOMADO DE LA LISTA DE ORGANISMOS DE AMRfinder(Plus)
\tSalmonella
\tEscherichia
\tEnterococcus_faecium
\tEnterococcus_faecalis
\tAcinetobacter_baumannii
\tCampylobacter
\tClostridioides_difficile
\tKlebsiella
\tNeisseria
\tPseudomonas_aeruginosa
\tStaphylococcus_aureus
\tStaphylococcus_pseudintermedius
\tStreptococcus_agalactiae
\tStreptococcus_pneumoniae
\tStreptococcus_pyogenes
\tVibrio_cholerae
"

# empezar un conteo
conteo=0

AMRFinderPlus() {

   # crear variable genero
   genero=$(echo ${OPTARG} | cut -d '_' -f '1')

   # definir directorio
   dir="AMRFINDER_${genero}"

   # si no existe, crear directorio
   if [[ ! -d ${dir} ]]; then
      mkdir ${dir}
   fi

   # crear archivo para guardar resultados finales
   echo "Especie,ID,Genes_RAM" > ${dir}/AMRFinder_resultados_all.csv

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for ensamble in ASSEMBLY/*.fa; do
      # crear una variable para nombre (ID) de la muestra
      ename=$(basename ${ensamble} -spades-assembly.fa)
      # actualizar el conte tras cada vuelta del loop
      conteo=$[ ${conteo} + 1 ]
      # imprimir el numero y el nombre del ensamble
      echo -e "\n${conteo}\t$ename\n"

      # ejecutar AMRFinder
      amrfinder --nucleotide ${ensamble} --threads $(nproc) --plus --organism ${OPTARG} --mutation_all ${dir}/AMRF_${ename}_mut.tsv  --output ${dir}/AMRF_${ename}.tsv 2> /dev/null

      # si el comando anterior se ejecuto correctamente, entonces: filtra archivos y crea archivos finales
      if [[ $? -eq 0 ]]; then
         # filtrar el resultado
         cat ${dir}/AMRF_${ename}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4,$16,$17}' > ${dir}/AMRF_${ename}_filtrado.csv
         # convertir CSV a TSV
         sed 's/,/\t/g' ${dir}/AMRF_${ename}_filtrado.csv > ${dir}/AMRF_${ename}_filtrado.tsv

         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
         # obtener lista de genes por ID de muestra en una sola fila
         awk -F, '{print $1}' ${dir}/AMRF_${ename}_filtrado.csv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ename}_filtrado.txt
         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
         echo -e "${OPTARG},${ename},$(cat ${dir}/tmp_AMRF_${ename}_filtrado.txt)" >> ${dir}/AMRFinder_resultados_all.csv

         # eliminar archivos temporales
         rm ${dir}/tmp*
      # si no se ejecuto correctamente, entonces borra el directorio y sal con error
      else
         echo -e "\nError!\n"
         rm -r -f ${dir}
         exit 1
      fi
   done
}


AMRFinderPlus_Otro() {

   # crear variable genero
   genero=$(echo ${OPTARG} | cut -d '_' -f '1')

   # definir directorio
   dir="AMRFINDER_${genero}"

   # si no existe, crear directorio
   if [[ ! -d ${dir} ]]; then
      mkdir ${dir}
   fi


   # crear archivo para guardar resultados finales
   echo "Especie,ID,Genes_RAM" > ${dir}/AMRFinder_resultados_all.csv

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for ensamble in ASSEMBLY/*.fa; do
      # crear una variable para nombre (ID) de la muestra
      ename=$(basename ${ensamble} -spades-assembly.fa)
      # actualizar el conte tras cada vuelta del loop
      conteo=$[ ${conteo} + 1 ]
      # imprimir el numero y el nombre del ensamble
      echo -e "\n${conteo}\t$ename\n"

      # ejecutar AMRFinder
      amrfinder --nucleotide ${ensamble} --threads $(nproc) --plus --mutation_all ${dir}/AMRF_${ename}_mut.tsv  --output ${dir}/AMRF_${ename}.tsv 2> /dev/null

      # si el comando anterior se ejecuto correctamente, entonces: filtra archivos y crea archivos finales
      if [[ $? -eq 0 ]]; then
         # filtrar el resultado
         cat ${dir}/AMRF_${ename}.tsv | awk 'BEGIN {FS="\t";OFS=","} {print $6,$7,$9,$14,$3,$4,$16,$17}' > ${dir}/AMRF_${ename}_filtrado.csv
         # convertir CSV a TSV
         sed 's/,/\t/g' ${dir}/AMRF_${ename}_filtrado.csv > ${dir}/AMRF_${ename}_filtrado.tsv

         #################################### archivo final en CSV de Genero, ID y Genes RAM #############################################
         # obtener lista de genes por ID de muestra en una sola fila
         awk -F, '{print $1}' ${dir}/AMRF_${ename}_filtrado.csv | uniq | sed '1d' | tr "\n" "," | sed 's/,$//g' > ${dir}/tmp_AMRF_${ename}_filtrado.txt
         # imprimir archivo final, lista de genes por ID de muestra en una sola fila, por genero
         echo -e "${OPTARG},${ename},$(cat ${dir}/tmp_AMRF_${ename}_filtrado.txt)" >> ${dir}/AMRFinder_resultados_all.csv

         # eliminar archivos temporales
         rm ${dir}/tmp*
      # si no se ejecuto correctamente, entonces borra el directorio y sal con error
      else
         echo -e "\nError!\n"
         rm -r -f ${dir}
         exit 1
      fi
   done
}


# lista de especies diaponibles con la opcion '-l'
Especie_Lista=(
Salmonella
Escherichia
Enterococcus_faecium
Enterococcus_faecalis
Acinetobacter_baumannii
Campylobacter
Clostridioides_difficile
Klebsiella
Neisseria
Pseudomonas_aeruginosa
Staphylococcus_aureus
Staphylococcus_pseudintermedius
Streptococcus_agalactiae
Streptococcus_pneumoniae
Streptococcus_pyogenes
Vibrio_cholerae
)


# parsear los argumentos y llamar las funciones principales
while getopts "e:hl" opciones; do
   case ${opciones} in
      e)
           # si a specie de interes se encuenta incluida en el array (lista de especies)
           if [[ "${Especie_Lista[@]}" =~ "${OPTARG}" ]];then
              echo -e "\nComenzando identificación de genes RAM y genes especiales por AMRFinder(Plus) para la especie: ${OPTARG}\n"
              AMRFinderPlus
              echo -e "\nIdentificación de genes RAM y genes especiales por MARFinder(Plus) terminada: Disfruta de tus análisis\n"
           else
              echo -e "\nComenzando identificación de genes y mutaciones  RAM por AMRFinder(Plus) para la especie ${OPTARG} (no incluida en la lista)\n"
              AMRFinderPlus_Otro
              echo -e "\nIdentificación de genes y mutaciones RAM por MARFinder(Plus): Disfruta de tus análisis\n"
           fi
           ;;
      h)
           uso
           ;;
      l)
           echo -e "${especie_lista}"
           ;;
      ?)
           echo -e "\n\tLa opción: -${OPTARG}, no es una opción válida\n"
           uso
           ;;
   esac
done
