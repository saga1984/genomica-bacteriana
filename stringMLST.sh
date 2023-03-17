#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------------
#   Obtiene el MLST y ST de los diferentes generos bacterianos de analisis rutinarios: Salmonella, Listeria, Escherichia
# -------------------------------------------------------------------------------------------------------------------------

# copiar la base de datos al directorio actual
ln -s /disk1/Programas_bioinformaticos/stringMLST/* $(pwd)

# para cada uno de los generos vacterianos de analisis rutinario
for especie in Salmonella_enterica Escherichia_coli Listeria_monocytogenes Enterococcus_faecium Enterococcus_faecalis Citrobacter_freundii; do

   # definir genero
   genero=$(basename ${especie} | cut -d '_' -f '1')
   echo -e "Genero: = ${genero}\n" # CONTROL

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for file in TRIMMING/*_1P.*fastq.gz; do
      # crear una variable para nombre (ID) de la muestra
      fname=$(basename ${file} | cut -d "_" -f "1")
      # genero para el mejor hit de kraken2
      krakenGenus=$(awk '$4 == "S" {print $6"_"$7}' KRAKEN2/kraken_species_${fname}.txt | sed -n '1p')
      echo -e "especie identificada por kraken ${fname} = ${krakenGenus}" # CONTROL
      # genero para el mejor hit de kmerfinder
      kmerfinderGenus=$(awk '{print $2"_"$3}' KMERFINDER/KF_${fname}/results_spa.csv | grep "${krakenGenus}" | sed -n '1p')
      echo -e "especie identificada por kmefinder ${fname} = ${kmerfinderGenus}" # CONTROL

      # si tanto kraken2 como kamerfinder identifican el mismo genero entonces
      if [[ ${krakenGenus} == ${kmerfinderGenus} ]]; then
         # para cada una de las siguientes opciones de generos
         echo "entrando a CASE"
         case ${especie} in
            Salmonella_enterica)
                      # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
                      if [[ ! -f stringMLST_tmp_${genero}.tsv ]]; then
                         stringMLST.py --predict -d ./ -P "${especie}" -o stringMLST_tmp_${genero}.tsv
                         # remover filas con NAs y sin Sequence Typey  guardar resultado en otro archivo
                         grep -v "NA" stringMLST_tmp_${genero}.tsv | awk '$9 != 0' > stringMLST_${genero}_results.tsv
                         # eliminar filas duplicadas
                         cat stringMLST_${genero}_results.tsv | sort -r | uniq > stringMLST_${genero}.tsv
                         # convertir a formato CSV
                         sed 's/\t/,/g' stringMLST_${genero}.tsv > stringMLST_${genero}.csv # CSV
                      else
                         continue
                      fi
                      ;;
            Escherichia_coli)
                      # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
                      if [[ ! -f stringMLST_tmp_${genero}.tsv ]]; then
                         stringMLST.py --predict -d ./ -P "${especie}" -o stringMLST_tmp_${genero}.tsv # para Ecoli el archvo final se guarda de forma distinta
                         # remover filas con NAs y sin Sequence Type y guardar resultado en otro archivo
                         grep -v "NA" stringMLST_tmp_${genero}.tsv | awk '$9 != 0' > stringMLST_${genero}_results.tsv
                         # eliminar filas duplicadas
                         cat stringMLST_${genero}_results.tsv | sort -r | uniq > stringMLST_${genero}.tsv
                         # convertir a formato CSV
                         sed 's/\t/,/g' stringMLST_${genero}.tsv > stringMLST_${genero}.csv

                         # preparar archivo resultado de stringMLST corto
                         awk 'BEGIN {FS=OFS} {print $9,$2,$3,$4,$5,$6,$7,$8,$1}' stringMLST_${genero}.tsv > tmp_stringMLST_${genero}.tsv
                         # preparar base de datos de perfiles
                         awk 'BEGIN {FS=OFS} {print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10}' ${especie}_profile.txt > tmp_${genero}_profile.txt
                         # unir archivos
                         awk 'NR==FNR{a[$1$2$3$4$5$6$7$8]=$9" "$10;next}$1$2$3$4$5$6$7$8 in a{print $0, a[$1$2$3$4$5$6$7$8]}' tmp_${genero}_profile.txt tmp_stringMLST_${genero}.tsv > stringMLST_${genero}_completo.tsv
                         # obtener archivos finales (completos con CC) TSV y CSV
                         awk '{print $9","$2","$3","$4","$5","$6","$7","$8","$1","$10}' stringMLST_${genero}_completo.tsv > stringMLST_${genero}_completo.csv # CSV
                         sed 's/,/\t/g' stringMLST_${genero}_completo.csv > stringMLST_${genero}_completo.tsv # TSV
                      else
                         continue
                      fi
                      ;;
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
            Enterococcus_faecium)
                      # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
                      if [[ ! -f stringMLST_tmp_${especie}.tsv ]]; then
                         stringMLST.py --predict -d ./ -P "${especie}" -o stringMLST_tmp_${especie}.tsv

                         # remover filas con NAs y guardar resultado en otro archivo
                         grep -v "NA" stringMLST_tmp_${especie}.tsv > stringMLST_${especie}_results.tsv
                         # eliminar filas duplicadas
                         cat stringMLST_${especie}_results.tsv | sort -r | uniq > stringMLST_${especie}.tsv
                         # convertir a formato CSV
                         sed 's/\t/,/g' stringMLST_${especie}.tsv > stringMLST_${especie}.csv

                         # preparar archivo resultado de stringMLST corto
                         awk 'BEGIN {FS=OFS} {print $9,$2,$3,$4,$5,$6,$7,$8,$1}' stringMLST_${especie}.tsv > tmp_stringMLST_${especie}.tsv
                         # preparar base de datos de perfiles
                         awk 'BEGIN {FS=OFS} {print $1,$8,$2,$3,$4,$6,$7,$5,$9,$10}' ${especie}_profile.txt > tmp_${especie}_profile.txt
                         # unir archivos
                         awk 'NR==FNR{a[$1$2$3$4$5$6$7$8]=$9" "$10;next}$1$2$3$4$5$6$7$8 in a{print $0, a[$1$2$3$4$5$6$7$8]}' tmp_${especie}_profile.txt tmp_stringMLST_${especie}.tsv > stringMLST_${especie}_completo.tsv
                         # obtener archivos finales (completos con CC) TSV y CSV
                         awk '{print $9","$2","$3","$4","$5","$6","$7","$8","$1","$10}' stringMLST_${especie}_completo.tsv > stringMLST_${especie}_completo.csv # CSV
                         sed 's/,/\t/g' stringMLST_${especie}_completo.csv > stringMLST_${especie}_completo.tsv # TSV
                      else
                         continue
                      fi
                      ;;
            Enterococcus_faecalis)
                      # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
                      if [[ ! -f stringMLST_tmp_${especie}.tsv ]]; then
                         stringMLST.py --predict -d ./ -P ./"${especie}" -o stringMLST_tmp_${especie}.tsv
                         # remover filas con NAs y sin Sequence Type y guardar resultado en otro archivo
                         grep -v "NA" stringMLST_tmp_${especie}.tsv > stringMLST_${especie}_results.tsv
                         # eliminar filas duplicadas
                         cat stringMLST_${especie}_results.tsv | sort -r | uniq > stringMLST_${especie}.tsv
                         # convertir a formato CSV
                         sed 's/\t/,/g' stringMLST_${especie}.tsv > stringMLST_${especie}.csv
                      else
                         continue
                      fi
                      ;;
            Citrobacter_freundii)
                      # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
                      if [[ ! -f stringMLST_tmp_${genero}.tsv ]]; then
                         stringMLST.py --predict -d ./ -P "${especie}" -o stringMLST_tmp_${genero}.tsv
                         # remover filas con NAs y sin Sequence Typey  guardar resultado en otro archivo
                         grep -v "NA" stringMLST_tmp_${genero}.tsv | awk '$9 != 0' > stringMLST_${genero}_results.tsv
                         # eliminar filas duplicadas
                         cat stringMLST_${genero}_results.tsv | sort -r | uniq > stringMLST_${genero}.tsv
                         # convertir a formato CSV
                         sed 's/\t/,/g' stringMLST_${genero}.tsv > stringMLST_${genero}.csv # CSV
                      else
                         continue
                      fi
                      ;;
         esac
      fi
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

