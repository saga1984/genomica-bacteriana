#!/bin/bash

# ----------------------------------------------------------------------------------------
# script que corre shigatyper y crea un archivo con ID, especie y serotipo en formato .csv
# ----------------------------------------------------------------------------------------

# crear carpeta ShigaTyper
mkdir ./ShigaTyper

# crear archivo .CSV de resultados de shigatyper
echo -e "Sample_ID\tSerotype_prediction\tNotes" > ./ShigaTyper/shigatyper_results.csv

for r1 in *R1*.fastq.gz; do # solo tomar una lectura (la 1)
   r2=${r1/_R1/_R2} # sustituir en la posicion indicada _1 por _2 para convertir a lectura dos
   shigatyper --R1 $r1 --R2 $r2 # correr shigatyper
done

# llenar archivo .CSV con resultados de shigatyper
echo "$(cat *.tsv | grep "Shigella")" | sort  >> ./ShigaTyper/shigatyper_results.csv

# mover todos los resultados de shigatyper a carpeta ShigaTyper
mv ./*.tsv ./ShigaTyper
mv ./*hits* ./ShigaTyper

# ------------------------------
#     crear archivo final
# ------------------------------

# columna 1, ID de lecturas
awk '{FS=" "; OFS=","} {print $1}' ShigaTyper/shigatyper_results.csv > ShigaTyper/columna1

# columna 2, especie
awk '{FS=" "; OFS="_"} {print $2, $3}' ShigaTyper/shigatyper_results.csv | sed '1d' | sed '1i Species' | tr -d "," > ShigaTyper/columna2

# columna 3, serotipo
awk '{FS=" "; OFS="_"} {print $4, $5}' ShigaTyper/shigatyper_results.csv | sed '1d' | sed '1i Serotype' | tr -d "," > ShigaTyper/columna3

# unir columnas
paste ShigaTyper/columna* > ShigaTyper/columnas123

# crear archivo final
awk '{FS="\t"; OFS=","} {print $1, $2, $3}' ShigaTyper/columnas123 > ShigaTyper/Resultados_Shigatyper.csv

# eliminar archivos no deseados
rm ShigaTyper/columna*
