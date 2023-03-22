#!/bin/bash

# -------------------------------------------------------------------------
#   Predice el serotipo de E coli en todos los ensambles en un directorio
# -------------------------------------------------------------------------

conteo=0
for r1 in *_R1*.fastq.gz; do # solo tomar una lectura (la forward)
   r2=${r1/_R1./_R2.} # sustituir en la posicion indicada _1 por _2 para convertir a lectura dos (reverse)
   conteo=$[ $conteo + 1 ]
   read_name=$(basename $r1 | cut -d "_" -f 1) # guardar el ID de la secuencia
   # mostrar numero y nombre del ensamble
   echo -e "$conteo:\t$read_name"
   # crear una carpeta para cada ensamble
   mkdir SF_${read_name}
   # ejecutar virulencefinder
   serotypefinder.py -i $r1 $r2 -p $serotypefinder_db  -mp $kma -o SF_${read_name} -x -q
   # filtrar solo primeras tres columnas
   awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$3,$4}' SF_${read_name}/results_tab.tsv > SF_${read_name}/results_corto.tsv
   # convertir a archivo CSV
   awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4}' SF_${read_name}/results_corto.tsv > SF_${read_name}/results_corto.csv
done

# ----------------------------------
#  Generar resultados mas amigables
# ----------------------------------

# crear directorio para guardar todos los resultados de VF
if [[ ! -d SEROTYPE_ECOLI ]]; then
   mkdir SEROTYPE_ECOLI
fi

# mover todos los resultados al nuevo directorio
mv SF_* SEROTYPE_ECOLI

# unir todos los resultados (cortos) en un solo archivo TSV y convertir a CSV (conservando ambos)
conteo=0
for dir in SEROTYPE_ECOLI/SF_*; do
   conteo=$[ $conteo + 1 ]
   echo -e "$conteo:\t$(basename $dir | cut -d '_' -f '2')\n$(cat $dir/results_corto.tsv)\n"
done > SEROTYPE_ECOLI/all_serotype_Ecoli.tsv

awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4}' SEROTYPE_ECOLI/all_serotype_Ecoli.tsv > SEROTYPE_ECOLI/all_serotype_Ecoli.csv


