#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------------
#   Obtiene el MLST y ST de los diferentes generos bacterianos de analisis rutinarios: Salmonella, Listeria, Escherichia
# -------------------------------------------------------------------------------------------------------------------------

# copiar la base de datos al directorio actual
ln -s /home/senasica2/Bioinformatica_Programas/stringMLST/* $(pwd)

# para cada uno de los generos vacterianos de analisis rutinario
for especie in Listeria_monocytogenes; do

   # definir genero
   genero=$(basename ${especie} | cut -d '_' -f '1')
   echo -e "Genero: = ${genero}\n" # CONTROL

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for file in TRIMMING/*_1P.*fastq.gz; do
      # crear una variable para nombre (ID) de la muestra
      fname=$(basename ${file} | cut -d "_" -f "1")

      # para cada una de las siguientes opciones de generos
      echo "entrando a CASE"
      case ${especie} in
         Listeria_monocytogenes)
                   # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
                   if [[ ! -f stringMLST_tmp_${genero}.tsv ]]; then
                      stringMLST.py --predict -d ./ -P "${especie}" -o stringMLST_tmp_${genero}.tsv
                      # remover filas con NAs y sin Sequence Type y guardar resultado en otro archivo
                      grep -v "NA" stringMLST_tmp_${genero}.tsv | awk '$9 != 0' > stringMLST_${genero}_results.tsv
                      # eliminar filas duplicadas
                      cat stringMLST_${genero}_results.tsv | sort -r | uniq > stringMLST_${genero}.tsv
                      # convertir a formato CSV
                      sed 's/\t/,/g' stringMLST_${genero}.tsv > stringMLST_${genero}.csv

                      # preparar archivo resultado de stringMLST corto
                      awk 'BEGIN {FS=OFS} {print $9,$2,$3,$4,$5,$6,$7,$8,$1}' stringMLST_${genero}.tsv > tmp_stringMLST_${genero}.tsv
                      # preparar base de datos de perfiles
                      awk 'BEGIN {FS=OFS} {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' ${especie}_profile.txt > tmp_${genero}_profile.txt
                      # unir archivos
                      awk 'NR==FNR{a[$1$2$3$4$5$6$7$8]=$9" "$10" "$11;next}$1$2$3$4$5$6$7$8 in a{print $0, a[$1$2$3$4$5$6$7$8]}' tmp_${genero}_profile.txt tmp_stringMLST_${genero}.tsv > stringMLST_${genero}_completo.tsv
                      # obtener archivos finales (completos con CC) TSV y CSV
                      awk '{print $9","$2","$3","$4","$5","$6","$7","$8","$1","$10","$11" "$12}' stringMLST_${genero}_completo.tsv > stringMLST_${genero}_completo.csv # CSV
                      sed 's/,/\t/g' stringMLST_${genero}_completo.csv > stringMLST_${genero}_completo.tsv # TSV
                   else
                      continue
                   fi
                   ;;
             esac
   done
   # eliminar links suaves
   rm ${especie}*
done

# remover archivos temporales
rm *tmp*

# ---------------------------------------------------------------------
#   crear un directorio para guardar resultados y mover archivos finales
# ---------------------------------------------------------------------

dir="STRINGMLST"
mkdir ${dir}
mv stringMLST* ${dir}
