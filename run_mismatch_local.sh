#!/bin/bash

#
# Identicacion de mutaciones puntuales de proteinas (blastx) tomando en cuenta inicio y fin de alineamiento principal
#

####################
# Mensaje de ayuda #
####################

# mensaje que indeica la forma correcat de usar el script
Mensaje="
 Uso: run_mismatch_local -d [data base w/PATH]
   -h: This help messaje
   -d: protein data base, must specify PATH
"

# si el script no se ejecuta con opciones/argumentos, indicar uso correcto y salir con error
if [[ ${#} -eq 0 ]]; then
   echo -e "$Mensaje"
   exit 2
fi

##########################################################
# hacer blastx vs una base de datos de una sola accesion #
##########################################################

# nombre del gen
gname="$(pwd | cut -d '/' -f '8')"

mismatch_blastx()
{

for file in *spades-assembly.fa; do
   fname="$(basename $file | cut -d '-' -f '1')"
   blastx -query $file -db $ref_db -sorthits 1 -out blastx_${gname}_${fname}.txt 2> /dev/null
   # inicio de texto
   cat -n blastx_${gname}_${fname}.txt | grep "Score =" | sort -r -n -k 4 | awk '{print $1}' | cut -d ":" -f "1" | sed -n "1p" > inicio_tmp_${fname}.txt
   # obtener lista de numeros de filas de archivos de resultados de blastx
   cat -n blastx_${gname}_${fname}.txt | grep "Score =" | sort -r -n -k 4 | awk '{print $1}' | cut -d ":" -f "1" > middle_tmp_${fname}.txt
   # NOTA: version 1 de fin_tmp de archivos (con mas de un hit)
   # fin de texto
   awk -v final=$(cat inicio_tmp_${fname}.txt) '$1 > final' middle_tmp_${fname}.txt | sed -n '1p' > fin_tmp_${fname}.txt
   if [[ ! -s fin_tmp_${fname}.txt ]]; then # si la version 1 de fin_tmp esta vacia; entonces corre el siguiente bloque de codigo
      # remover archivo actual de fin_tmp
      rm fin_tmp_${fname}.txt
      # NOTA: version 2 de de fin_tmp (con solo un hit)
      # obtener nuevo valor de fin_tmp
      cat -n blastx_${gname}_${fname}.txt | tail -1 | awk '{print $1}' > fin_tmp_${fname}.txt
   fi
      # obtener documento filtrado
      cat blastx_${gname}_${fname}.txt | sed -n "$(cat inicio_tmp_$fname.txt), $(cat fin_tmp_$fname.txt)p" > filtrado_${fname}.txt 2> /dev/null
      # obtener Query
      grep "Query" filtrado_${fname}.txt | awk '{print $3}' > Query_${fname}.txt
      # obtener Subject
      grep "Sbjct" filtrado_${fname}.txt | awk '{print $3}' > Subject_${fname}.txt
      # unir en un string Query
      cat Query_${fname}.txt | tr -d '\n'  > Query_tmp_${fname}.txt
      # unir en un string Subject
      cat Subject_${fname}.txt | tr -d '\n' > Subject_tmp_${fname}.txt
      # obtener inicio de secuencia de Subject
      cat filtrado_${fname}.txt | grep "Sbjct" | awk '{print $2}' | sed -n '1p' > Sinicio_tmp_${fname}.txt
      # obtener fin de secuencia de Subject (como variable)
      cat filtrado_${fname}.txt | grep "Sbjct" | awk '{print $4}' | sort -nr | sed -n '1p' > Sfinal_tmp_${fname}.txt

      #########################################
      # comienza identificacion de mismatches #
      #########################################

      # correr mismatch.py
      mismatch.py -q $(cat Query_tmp_${fname}.txt) -s $(cat Subject_tmp_${fname}.txt) -n $(cat Sinicio_tmp_${fname}.txt) > mismatches_tmp_${fname}.txt 2> /dev/null
      # filtar solo valores menores al final de la secuencia de Subject (valores reales)
      awk -v final=$(cat Sfinal_tmp_${fname}.txt) '$2 < final' mismatches_tmp_${fname}.txt > mismatches_${fname}.txt
      # quitar espacios en blanco
      sed -i 's/ //g' mismatches_${fname}.txt
      # imprimir resultados
      echo -e "$fname ${gname} mismatches: \n$(cat mismatches_$fname.txt) \n"
      # eliminar archivos temporales
      #rm *tmp*
done  > mismatches_all_results_${gname}.txt

}

#########################################################
# Paserar argumentos y correr funcion "mismatch_blastx" #
#########################################################

<<<<<<< HEAD
while getopts ":d:h" opciones; do
=======
while getopts ":d:h"  opciones; do
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
   case "${opciones}" in
      d) #opcion para indicar data base con ruta
         ref_db="${OPTARG}" # asignar la ruta/nombre dela base de datos
         echo "Comenzando la identificacion de mutaciones puntuales"
         mismatch_blastx # correr la funcion que va a hacer blastx e identificar mutaciones
         echo "Mutaciones puntuales identificadas"
         ;;
      h) # mensaje de ayuda
         echo -e "${Mensaje}"
         ;;
      ?) # opcion invalida
         echo "Invalid opcion/argument: -${OPTARG}"
         echo -e "${Mensaje}"
         ;;
   esac
done

