#!/bin/bash

#
# Obtener el serotipo de aislados (genomas ensamblados) de Listeria monocytogenes, de forma local y segura, funciona con blast+ v2.12 (no funciona con blast+ v2.9)
#

# scripts
change_name.sh # script que cambia el nombre del archivo para poder ser leido por el siguiente script
serotype_blastn.sh # script para hacer blastn de los ensambles contra las bases de datos (creadas inicialmente con makeblastdb y descargadas del BIGSdb-Lm)
serotype_get_alleles.sh # script para obtener los mejores hits del blastn (las variantes alelicas presentes en los aislados)
serotype_prepare.sh # script para preparar los datos para tabulacion
serotype_tabulate.awk lmo0737 lmo1118 ORF2110 ORF2819 prs > profile # script para crear el patron de perfil alelico a buscar, en formato tabulado y con los nombres de aislados

# preparar archivos para loop
serotipo_db="/home/senasica2/Documentos/2022/Listerias/serogrupo/serotipo_db"
cp $serotipo_db/profiles_Lm_serotype.txt $PWD/ # copia la base de datos que contiene el serotipo basado en perfil alelico al directorio actual
cat -n profile | tail -1 | awk '{print $1}' > n0 # obtener el numero de aislados
echo $[ $(cat n0) + 1 ] > n1 # sumas 1 al numero de aislados para el for loop (C-style)
awk 'BEGIN {FS="\t"} {print $2,$3,$4,$5,$6,$1}' profile > nuevo_profile # preparar el archivo profile para loop
awk 'BEGIN {FS="\t"} {print $2,$3,$4,$5,$6,$1,$7}' profiles_Lm_serotype.txt > nuevo_profiles # preparar la base de datos que contiene al serotipo para loop

# C-style for loop
for ((a = 1; a < $(cat n1); a++)); do # inicio de loop (de 1 hasta numero de aislados mas uno), crea el archivo final fila por fila
   cat nuevo_profile | sed -n "${a} p" > nuevo_profile_${a} # imprime el archivo profile preparado para loop fila por fila
   awk 'BEGIN{RS="\r\n" ; OFS=FS} NR==FNR{a[$1 FS $2 FS $3 FS $4 FS $5] = $0 ; next} {ind = $1 FS $2 FS $3 FS $4 FS $5} ind in a {print $6, a[ind]}' nuevo_profiles nuevo_profile_${a} # obtiene el archivo final
done > serotipo # fin del loop y guarda el resultado en el archivo serotipo

#toques finales
awk 'BEGIN {OFS="\t"} {print $1,$2,$3,$4,$5,$6,$7,$8}' serotipo > serotipo2 # imprime en formato tabulado el archivo serotipo y guardalo en un archivo nuevo
awk 'BEGIN {print "Isolate lmo0737 lmo1118 ORF2110 ORF2819 prs pro-file_id serogroup"} {print $0}' serotipo2 > serotype # poner headers (primera fila con nombres)

# loop para remover archivos
for ((a = 1; a < $(cat n1); a++)); do 
   rm nuevo_profile_${a}
done

# remover archivos
rm nuevo_profile n0 n1 profile nuevo_profiles serotipo serotipo2 $PWD/*.txt lmo0737 lmo1118 ORF2110 ORF2819 prs

# imprimir archivo final
cat serotype

