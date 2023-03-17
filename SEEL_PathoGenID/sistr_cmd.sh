#!/bin/bash

#
# Aplicar sistr a todos los ensambles de un directorio
#


# --------------------------------------------------
#  correr sistr_cmd y crear archivo temporal incial
# --------------------------------------------------

# definir directorio de resultados
dir="SISTR_CMD"

# crear una carpeta para almacenar los resultados
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

# crear el que sera archivo final con nombre de columnas para guardar resultados de todas las muestras
echo -e "ID,cgmlst_ST,cgmlst_distance,cgmlst_found_loci,cgmlst_genome_match,cgmlst_matching_alleles,cgmlst_subspecies,fasta_filepath,genome,h1,h2,o_antigen,serovar_cgmlst" > ${dir}/sistr_resultados.csv

#############################################################
# for loop para todos los ensables en la carpeta Salmonella #
#############################################################

for ensamble in ASSEMBLY/Salmonella/*.fa; do
   # generar nombre corto para ensables
   ensamble_name=$(basename ${ensamble} | cut -d "-" -f "1") # guardar el ID de la secuencia
   # ejecutar el programa
   sistr -f csv -o ${dir}/${ensamble_name}-sistr.csv -t $(nproc) -i ASSEMBLY/Salmonella/$(basename ${ensamble}) $(basename ${ensamble} .fa)
   # dar formato
   linea2=$(cat ${dir}/${ensamble_name}-sistr.csv | sed -n "2p")
   # imprimir lo que sera la informacion para el archivo final
   echo -e "${ensamble_name},${linea2}"
done >> ${dir}/sistr_resultados.csv # archivo final


##############################################
#  crear archivo de ID + serotipo por cgMLST #
##############################################

# filtrar para obtener un archivo solo con ID y serotipo (cgMLST)
awk 'BEGIN {FS=OFS=","} {print $1, $NF}' ${dir}/sistr_resultados.csv | grep -v 'serovar' > ${dir}/serotipos_cgMLTS.csv
# agregar nombre de columnas a archivo de serotipos
sed -i '1i ID,Serotipo' ${dir}/serotipos_cgMLTS.csv
