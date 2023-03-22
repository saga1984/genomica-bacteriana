#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   Obtener el serotipo de aislados (genomas ensamblados) de Listeria monocytogenes, de forma local y segura, funciona con blast+ v2.12 (no funciona con blast+ v2.9)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------


# ------------
#   scripts
# ------------
change_name.sh # script que cambia el nombre del archivo para poder ser leido por el siguiente script
serotype_blastn.sh # script para hacer blastn de los ensambles contra las bases de datos (creadas inicialmente con makeblastdb y descargadas del BIGSdb-Lm)
serotype_get_alleles.sh # script para obtener los mejores hits del blastn (las variantes alelicas presentes en los aislados)
serotype_prepare.sh # cript para preparar los datos para tabulacion
# script para crear el patron de perfil alelico a buscar, en formato tabulado y con los nombres de aislados
serotype_tabulate.awk lmo0737 lmo1118 ORF2110 ORF2819 prs > profile


# --------------------------------------------
#   preparar archivos para unirlos y unirlos
# --------------------------------------------
# BIGSdb_Lm ya es una variable de sistema especificada en .bashrc
cp $BIGSdb_Lm_db/profiles_Lm_serotype.txt $PWD/ # copia la base de datos que contiene el serotipo basado en perfil alelico al directorio actual
cat -n profile | tail -1 | awk '{print $1}' > n0 # obtener el numero de aislados
echo $[ $(cat n0) + 1 ] > n1 # sumas 1 al numero de aislados para el for loop (C-style)
awk 'BEGIN {FS="\t"} {print $2,$3,$4,$5,$6,$1}' profile > nuevo_profile # preparar el archivo profile para loop
awk 'BEGIN {FS="\t"} {print $2,$3,$4,$5,$6,$1,$7}' profiles_Lm_serotype.txt > nuevo_profile_db # preparar la base de datos que contiene al serotipo para loop
awk 'NR==FNR{a[$1$2$3$4$5]=$6;next}$1$2$3$4$5 in a{print $0, a[$1$2$3$4$5]}' nuevo_profile nuevo_profile_db > serotipo # unir archivos en base a las primeras cinco columnas comunes


# ---------------------------------------------------------
#     crear archivos finales y moverlos a carpeta final
# ---------------------------------------------------------
awk 'BEGIN {OFS="\t"} {print $8,$1,$2,$3,$4,$5,$6,$7}' serotipo > tmp.serotipo # imprime en formato tabulado el archivo serotipo y guardalo en un archivo nuevo
echo "Isolate,lmo0737,lmo1118,ORF2110,ORF2819,prs,pro-file_id,serogroup" > serotype.csv # poner headers (primera fila con nombres)
awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4,$5,$6,$7,$8}' tmp.serotipo >> serotype.csv # crear archivo de resultados en formato .cvs
awk 'BEGIN {FS=","; OFS="\t"} {print $1,$2,$3,$4,$5,$6,$7,$8}' serotype.csv > serotype.tab # crear archivo de resultados en formato .tab
# crear carpeta para archivos final y mover archivos finales
mkdir Serotype_Lm
mv serotype* Serotype_Lm

#   remover archivos
# --------------------
# loop para remover archivos

# remover archivos temporales
rm *profile*
rm n0 n1 serotipo
rm lmo0737 lmo1118 ORF2110 ORF2819 prs
rm tmp.*
rm *.fa
rm *.txt

# imprimir archivo final
cat serotype.tab

