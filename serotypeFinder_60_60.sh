#!/bin/bash

# -------------------------------------------------------------------------
#   Predice el serotipo de E coli en todos los ensambles en un directorio
# -------------------------------------------------------------------------

# asiganr la variable que indica la ruta a blastn
blastn="/home/senasica2/Bioinformatica_Programas/ncbi-blast-2.12.0+/bin/blastn"

# asignar la ruta que indica la ruta a la base de datos de VF
# alternativamente se puede fijar esta ruta como variable de sistema en ~/.bashrc
virulencefinder_db="/home/senasica2/Bioinformatica_Programas/virulencefinder/virulencefinder_db"

conteo=0
for ensamble in ASSEMBLY/*.fa; do
   conteo=$[ $conteo + 1 ]
   ensamble_name=$(basename $ensamble | cut -d "-" -f 1) # guardar el ID de la secuencia
   # mostrar numero y nombre del ensamble
   echo -e "$conteo:\t$ensamble_name"
   # crear una carpeta para cada ensamble
   mkdir SF_${ensamble_name}
   # ejecutar virulencefinder
   serotypefinder.py -i $ensamble -p $serotypefinder_db  -t 0.1 -l 0.1 -mp $blastn -o SF_${ensamble_name} -x -q
   # filtrar solo primeras tres columnas
   awk 'BEGIN {FS=OFS="\t"} {print $1,$2,$3,$4}' SF_${ensamble_name}/results_tab.tsv > SF_${ensamble_name}/results_corto.tsv
   # convertir a archivo CSV
   awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4}' SF_${ensamble_name}/results_corto.tsv > SF_${ensamble_name}/results_corto.csv
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


