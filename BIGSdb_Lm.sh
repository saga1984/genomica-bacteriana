#!/bin/bash

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------
#   Obtener el serotipo de aislados (genomas ensamblados) de Listeria monocytogenes, de forma local, funciona con blast+ v2.12 (no funciona con blast+ v2.9)
# ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

# definir carpeta para guardar resultados finales
dir="SEROGROUP_LISTERIA"

# si no existe, crear carpeta para archivos final y mover archivos finales
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

###############################################################################
#   hacer la base de datos. NOTA: solo se corre una vez si es que no existe
###############################################################################

#for file in ${BIGSdb_Lm_db}/*.fa; do
#   makeblastdb -in ${file} -input_type fasta -dbtype nucl
#done

############################################################################################
# filtrar muestras que se identifiquen como Listeria tanto por Kraken2 como por KmerFinder
############################################################################################

# for loop para cada archivo fasta de variantes alelicas de genes para serogrupo de Listeria monocytogenes (bases de datos)
for DB in lmo0737 lmo1118 ORF2110 ORF2819 prs; do
# for loop para todos los ensambles dentro del directorio ASSEMBLY
<<<<<<< HEAD
   for ensamble in ASSEMBLY/*.fa; do
      # definir nombre del ensamble
      ename=${ensamble##ASSEMBLY/}
      ensamble_name=${ename%%-spades-assembly.fa}

      ############################################### sorting por genero ###################################################
      # genero para el mejor hit de kmerfinder
      kmerfinderGenus=$(awk '{print $2}' KMERFINDER/KF_${ensamble_name}/results_spa.csv | grep "Listeria" | sed -n '1p')
      echo -e "especie identificada por kmefinder ${ensamble_name} = ${kmerfinderGenus}" # CONTROL

      ############################################ identificacion por especie ################################################
      # si tanto kraken2 como kamerfinder identifican el mismo genero entonces
      if [[ ${kmerfinderGenus} == "Listeria" ]]; then

         ###################
         #   hacer blastn
         ###################

         echo -e "Blastn de ${ensamble_name} para predecir PCR_SEROGRUPO\n"
         # correr blast para cada ensamble y para cada gen dentro de la base de datos
         blastn -query ${ensamble} -db ${BIGSdb_Lm_db}/${DB}.fa > ${ensamble_name}_${DB}.txt

         ##########################################################
         # filtrar los numeros de variantes alelicas en cada caso
         ##########################################################

         grep -n "Sequences producing significant alignments:" ${ensamble_name}_${DB}.txt | cut -d ':' -f 1 > n1
         sed -n "$(echo $[ $(cat n1) + 2 ]) p" ${ensamble_name}_${DB}.txt | cut -d '_' -f '2' | cut -d ' ' -f '1' > ${DB}_allele_${ensamble_name}_${DB}.txt
      fi
=======
   for ensamble in ASSEMBLY/Listeria/*.fa; do
      # definir nombre del ensamble
      ename=${ensamble##ASSEMBLY/Listeria/} # remover prefijo
      ensamble_name=${ename%%-spades-assembly.fa} # remover sufijo
      echo -e "\nObteniendo serotipo de:\t${ensamble_name}\n"
      ###################
      #   hacer blastn
      ###################

      echo -e "Blastn de ${ensamble_name} para predecir PCR_SEROGRUPO\n"
      # correr blast para cada ensamble y para cada gen dentro de la base de datos
      blastn -query ${ensamble} -db ${BIGSdb_Lm_db}/${DB}.fa > ${ensamble_name}_${DB}.txt

      ##########################################################
      # filtrar los numeros de variantes alelicas en cada caso
      ##########################################################

      grep -n "Sequences producing significant alignments:" ${ensamble_name}_${DB}.txt | cut -d ':' -f 1 > n1
      sed -n "$(echo $[ $(cat n1) + 2 ]) p" ${ensamble_name}_${DB}.txt | cut -d '_' -f '2' | cut -d ' ' -f '1' > ${DB}_allele_${ensamble_name}_${DB}.txt
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
   done
done

######################################################################################
# produce un formato tabulado legible de perfiles alelicos de Listeria monocytogenes
######################################################################################

<<<<<<< HEAD
for file in *allele*; do
=======
for file in ./*_allele_*; do
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
   echo -e "$(echo ${file} | cut -d '_' -f 3 | cut -d '.' -f 1) \t $(cat ${file})" > ${file}
done

cat lmo0737* > tmp_lmo0737
awk '$2 != blank' tmp_lmo0737 > lmo0737

cat lmo1118* > tmp_lmo1118
awk '$2 != blank' tmp_lmo1118 > lmo1118

cat ORF2110* > tmp_ORF2110
awk '$2 != blank' tmp_ORF2110 > ORF2110

cat ORF2819*  > tmp_ORF2819
awk '$2 != blank' tmp_ORF2819 > ORF2819

cat prs*  > tmp_prs
awk '$2 != blank' tmp_prs > prs

#############################################################################################################
# script para crear el patron de perfil alelico a buscar, en formato tabulado y con los nombres de aislados
#############################################################################################################

serotype_tabulate.awk lmo0737 lmo1118 ORF2110 ORF2819 prs > tmp_profile

# rellenar espacios en blanco en los esquemas de variantes alelicas
<<<<<<< HEAD
awk 'BEGIN {FS=OFS="\t"} {for(i = 1; i <= NF; i++) if($i ~ /^ *$/) $i = 0 }; {print $0}' tmp_profile > profile.tsv
=======
awk 'BEGIN {FS=OFS="\t"} {for(i=1; i<=NF; i++) if($i ~ /^ *$/) $i = 0 }; {print $0}' tmp_profile > profile.tsv
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

# asigar columnas a a profile
sed -i '1i\ID\tlmo0737\tlmo1118\tORF2110\tORF2819\tprs' profile.tsv

###############################################
#   preparar archivos para unirlos y unirlos
###############################################

# BIGSdb_Lm ya es una variable de sistema especificada en .bashrc
cp -v ${BIGSdb_Lm_db}/profiles_Lm_serotype.txt $PWD/ # copia la base de datos que contiene el serotipo basado en perfil alelico al directorio actual
#cat -n profile | tail -1 | awk '{print $1}' > n0 # obtener el numero de aislados
#echo $[ $(cat n0) + 1 ] > n1 # sumas 1 al numero de aislados para el for loop (C-style)
awk 'BEGIN {FS="\t"} {print $2,$3,$4,$5,$6,$1}' profile.tsv > nuevo_profile # preparar el archivo profile para loop
awk 'BEGIN {FS="\t"} {print $2,$3,$4,$5,$6,$1,$7}' profiles_Lm_serotype.txt > nuevo_profile_db # preparar la base de datos que contiene al serotipo para loop
awk 'NR==FNR{a[$1$2$3$4$5]=$6;next}$1$2$3$4$5 in a{print $0, a[$1$2$3$4$5]}' nuevo_profile nuevo_profile_db > tmp_serogrupo # unir archivos en base a las primeras cinco columnas comunes


###########################################################
#     crear archivos finales y moverlos a carpeta final
###########################################################

awk 'BEGIN {OFS="\t"} {print $8,$1,$2,$3,$4,$5,$6,$7}' tmp_serogrupo > tmp.serogrupo # imprime en formato tabulado el archivo serotipo y guardalo en un archivo nuevo
<<<<<<< HEAD
echo "Isolate,lmo0737,lmo1118,ORF2110,ORF2819,prs,pro-file_id,serogroup" > Lm_PCRserogrupo.csv # poner headers (primera fila con nombres)
awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4,$5,$6,$7,$8}' tmp.serogrupo >> Lm_PCRserogrupo.csv # crear archivo de resultados en formato .cvs
awk 'BEGIN {FS=","; OFS="\t"} {print $1,$2,$3,$4,$5,$6,$7,$8}' Lm_PCRserogrupo.csv > Lm_PCRserogrupo.tsv # crear archivo de resultados en formato .tsv

# eliminar segunda fila (nombres de columnas de profile.tsv)
sed -i '2d' Lm_PCRserogrupo.tsv
sed -i '2d' Lm_PCRserogrupo.csv

# imprimir archivo final
=======
awk 'BEGIN {FS="\t"; OFS=","} {print $1,$2,$3,$4,$5,$6,$7,$8}' tmp.serogrupo > Lm_PCRserogrupo.csv # crear archivo de resultados en formato .cvs
awk 'BEGIN {FS=","; OFS="\t"} {print $1,$2,$3,$4,$5,$6,$7,$8}' Lm_PCRserogrupo.csv > Lm_PCRserogrupo.tsv # crear archivo de resultados en formato .tsv

# imprimir archivo final

>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
echo -e "\n\n                PCR SEROGROUP     "
cat Lm_PCRserogrupo.tsv
echo ""

#######################
#   remover archivos
#######################

# remover archivos temporales
rm lmo0737 lmo1118 ORF2110 ORF2819 prs
rm *tmp*
rm *.txt
rm n1
<<<<<<< HEAD
rm *nuevo*

# mover todos los archivos finales a directorio de resultados
mv *Lm_PCRserogrupo* ${dir}
mv profile.tsv ${dir}/Lm_PCRserogrupo_profile.tsv

=======
rm nuevo_profile*

# mover todos los archivos finales a directorio de resultados
mv *Lm_PCRserogrupo* ${dir}
mv profile.tsv ${dir}
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
