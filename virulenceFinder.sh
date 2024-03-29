#!/bin/bash

# -------------------------------------------------------------------------
#  Ejecutar virulencefinder.py sobre todos los ensambles en un directorio
# -------------------------------------------------------------------------

# iniciar conteo en 0
conteo=0
# for loop para todos los ensambles en el directorio ASSEBLY
for ensamble in ASSEMBLY/*.fa; do
   # aumentar en 1 el conteo en cada paso del for loop
   conteo=$[ ${conteo} + 1 ]
   # guardar el ID de la secuencia
   ensamble_name=$(basename ${ensamble} | cut -d "-" -f "1")
   # mostrar numero y nombre del ensamble
   echo -e "$conteo:\t$ensamble_name"
   # crear una carpeta para cada ensamble
   mkdir VF_${ensamble_name}
   # ejecutar virulencefinder
   virulencefinder.py -i ${ensamble} -p ${virulencefinder_db}  -mp ${blastn} -o VF_${ensamble_name} -x -q
   # filtrar solo primeras tres columnas
   awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$3}' VF_${ensamble_name}/results_tab.tsv > VF_${ensamble_name}/results_corto.tsv
   # convertir a archivo CSV
   awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3}' VF_${ensamble_name}/results_corto.tsv > VF_${ensamble_name}/results_corto.csv
done

# ----------------------------------
#  Generar resultados mas amigables
# ----------------------------------

# crear directorio para guardar todos los resultados de VF
if [[ ! -d VIRULENCE ]]; then
   mkdir VIRULENCE
fi

# mover todos los resultados al nuevo directorio
mv VF_* VIRULENCE

# unir todos los resultados (cortos) en un solo archivo TSV y convertir a CSV (conservando ambos)
conteo=0
for dir in VIRULENCE/VF_*; do
   conteo=$[ $conteo + 1 ]
   echo -e "$conteo:\t$(basename $dir | cut -d '_' -f '2')\n$(cat $dir/results_corto.tsv)\n"
done > VIRULENCE/all_virulence.tsv

awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3}' VIRULENCE/all_virulence.tsv > VIRULENCE/all_virulence.csv


