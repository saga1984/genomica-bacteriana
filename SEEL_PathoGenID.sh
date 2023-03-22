#!/bin/bash

#
# pipeleine de analisis bioinformatico del area de Secuenciacion y bioinformatica CNRPyC del SENASICA
#

echo "############################################################################"
echo " PIPELINE DE ANALISIS BIOINFORMATICO DEL AREA DE BIOINFORMATICA DEL CNRPYC"
echo " SEQBIO_PyC version 3.0.0"
echo "############################################################################"
echo ""

# Hora y fecha de termino de analisis
echo ""
echo "############################################################################################"
echo " INICIANDO PIPELINE DE ANALISIS BIOINFORMATICO DE DATOS DE SECUENCIACION DE GENOMA COMPLETO"
echo " $(date)"
echo "############################################################################################"
echo ""

############################
# Estadisticas de lecturas #
############################
echo ""
echo "############################"
echo "# ESTADISTICAS DE LECTURAS #"
echo "############################"
echo""

# correr "FastQC" para obtener estadisticas de lecturas
echo ""
echo "###################################################################################"
echo " Comenzando analisis de calidad de lecturas, usando FastQC version: $(fastqc -v)"
echo "###################################################################################"
echo ""

estadisticas_lecturas.sh

########################
# Filtrado por calidad #
########################
echo ""
echo "########################"
echo "# FILTRADO POR CALIDAD #"
echo "########################"
echo ""

# correr "Trimmomatic" para limpieza de lecturas por calidad
echo ""
echo "##########################################################################################################"
echo " Comenzando recorte de lecturas de lecturas por calidad usando Trimmomatic version: Trimmomatic(PE) v$(TrimmomaticPE -version)"
echo "##########################################################################################################"
echo ""

TrimmomaticPE.sh

############################
# Estadisticas de lecturas #
############################
echo ""
echo "###################################################"
echo "# ESTADISTICAS DE LECTURAS RECORTADAS POR CALIDAD #"
echo "###################################################"
echo""

# correr "FastQC" obtener estadisticas de calidad de lecturas limpias
echo ""
echo "##########################################################################################################"
echo " Comenzando analisis de calidad de lecturas recortadas por calidad, usando FastQC version: $(fastqc -v)"
echo "##########################################################################################################"
echo ""

estadisticas_lecturas_postrimming.sh

######################
# Ensable de genomas #
######################
echo ""
echo "#######################"
echo "# ENSAMBLE DE GENOMAS #"
echo "#######################"
echo ""

# correr "SPAdes" para ensamblar genomas
echo ""
echo "###################################################################"
echo " Comenzando ensamble de genomas, usando SPAdes version: $(spades.py --version)"
echo "###################################################################"
echo ""

SPAdes.sh

#############################
# Estadisticas de ensambles #
#############################
echo ""
echo "#############################"
echo "# ESTADISTICAS DE ENSAMBLES #"
echo "#############################"
echo ""

# correr "assembly-stats", "BWA" y "SAMtools" para obtener estadísticas de ensambles
# este script llama al script: 'Profundidad.sh' que es el responsable de ejecutar a "BWA" y "SAMtools"
bwa 2> ./bwa_version.txt
echo ""
echo "##############################################################"
echo " Comenzando estadisticas de ensambles usando:"
echo " SAMtools version: $(samtools --version | sed '3d' | tr '\n' '\t')"
echo " BWA version: v$(grep 'Version' bwa_version.txt | awk '{print $2}')"
echo " Assembly-Stats version: v$(assembly-stats -v | awk '{print $2}')"
echo "##############################################################"
echo ""
rm ./bwa_version.txt

estadisticas_ensambles.sh

###########################################################################################################################################################
##############################################
# Identificacion taxonomica: genero, especie #
##############################################
echo ""
echo "#####################################################"
echo "# IDENTIFICACION TAXONOMICA: NIVEL GENERO Y ESPECIE #"
echo "#####################################################"
echo ""

# correr "KmerFinder" para identificación taxonomica a nivel de especie
echo ""
echo "#################################################################################"
echo " Comenzando identificacion taxonomica de Genero, usando KmerFinder version: v$(cat /disk1/Programas_bioinformaticos/kmerfinder/kmerfinder.py | grep 'run_info' | sed '2d' | awk '{print $4}' | cut -d ':' -f 2 | tr -d ,)"
echo "#################################################################################"
echo ""

KmerFinder.sh

# correr "Kraken2" para identificación taxonomica a nivel de especie
echo ""
echo "################################################################################"
echo " Comenzando identificacion taxonomica de Genero, usando Kraken2 version: v$(kraken2 -v | sed '2d' | awk '{print $3}')"
echo "################################################################################"
echo ""

kraken2.sh

###############################################################################################################
# mover ensambles a nuevas carpetas de acuerdo al genero idenficado por Kraken2 y KmerFinder
# este paso permite correr posteriormente "SeroTypeFinder", "sistr_cmd" y "SeqSero2" de forma más eficiente
###############################################################################################################
echo ""
echo "#######################################################################################"
echo " Comenzando identificacion taxonomica de Genero, clasificación de ensambles por Genero "
echo "#######################################################################################"
echo ""


sorting.sh

##########################################################################################################################################################
#############
# Subtyping #
#############
echo ""
echo "#############"
echo "# SUBTYPING #"
echo "#############"
echo ""

# correr "stringMLST" subtyping de Listeria monocytogenes, Salmonella enterica, Escherichia coli
<<<<<<< HEAD
if [[ -d ASSEMBLY/Listeria ]]; then
=======
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
echo ""
echo "##########################################################################################################################################################"
echo " Comenzando subtyping de Listeria monocytogenes, Salmonella enterica y Escherichia coli, usando stringMLST version: $(stringMLST.py -v | awk '{print $2,$3,$4,$5,$6,$7}')"
echo "##########################################################################################################################################################"
echo ""
<<<<<<< HEAD
   stringMLST.sh
fi
=======

stringMLST.sh

# correr "MLST" subtyping de especies bacterianas cargadas a pubMLST
echo "##########TNC_02-2023#########"
mlst.sh
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

# correr "script casero BIGSdb_Lm" subtyping de Listeria monocytogenes, Salmonella enterica, Escherichia coli
if [[ -d ASSEMBLY/Listeria ]]; then
   echo ""
   echo "#######################################################################################################################"
   echo " Comenzando subtyping por identificacion de PCR serogrupo de Listeria, usando el script caser BIGSbd_Lm version: 1.0.0 "
   echo "#######################################################################################################################"
   echo ""
   BIGSdb_Lm.sh
fi

# correr "SeqSero2" subtyping de Salmonella enterica
if [[ -d ASSEMBLY/Salmonella ]]; then
   echo ""
   echo "##############################################################################"
   echo " Comenzando subtyping de Salmonella enterica, usando SeqSero2 version: v$(SeqSero2_package.py -v | awk '{print $2}')"
   echo "##############################################################################"
   echo ""
   SeqSero2.sh
fi
<<<<<<< HEAD
# correr "sistr" subtyping de Salmonella enterica
if [[ -d ASSEMBLY/Salmonella ]]; then
   echo ""
   echo "###############################################################################"
   echo " Comenzando subtyping de Salmonella enterica, usando sistr_cmd version: v$(sistr -V | awk '{print $2}')"
   echo "###############################################################################"
   echo ""
   sistr_cmd.sh
fi
=======

# correr "sistr" subtyping de Salmonella enterica
#if [[ -d ASSEMBLY/Salmonella ]]; then
#   echo ""
#   echo "###############################################################################"
#   echo " Comenzando subtyping de Salmonella enterica, usando sistr_cmd version: v$(sistr -V | awk '{print $2}')"
#   echo "###############################################################################"
#   echo ""
#   sistr_cmd.sh
#fi
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

# correr "SeroTypeFinder" subtyping de Escherichia coli
if [[ -d ASSEMBLY/Escherichia ]]; then
   echo ""
   echo "#################################################################################"
   echo " Comenzando subtyping de Escherichia coli, usando SeroTypeFinder version: v2.0.1"
   echo "#################################################################################"
   echo ""
   serotypeFinder.sh
fi

###################################################################################################################################################################
#############
# Genes RAM #
#############
echo ""
echo "#############"
echo "# GENES RAM #"
echo "#############"
echo ""

# correr "ResFinder" y "PointFinder" para identificación de genes RAM
echo ""
echo "#############################################################################################"
echo " Comenzando identificacion de genes RAM, usando ResFinder (con PointFinder) version: v$(run_resfinder.py -v)"
echo "#############################################################################################"
echo ""

run_ResFinder.sh

# correr "ABRicate" para identificación de genes RAM, plasmidos, genes de virulencia, etc. usando 9 dierentes bases de datos
# (ARG-ANNOT,EcOH, VFDB, plasmidfinder, CARD, MEGARES, NCBI, ResFinder, Ecoli_VF)
#echo ""
#echo "#########################################################################"
#echo " Comenzando identificacion de genes RAM, usando ABRicate version: v$(abricate -v | awk '{print $2}')"
#echo "#########################################################################"
#echo ""

#ABRicate.sh

# correr "AMRFinder" (Plus) para identificacion de genes RAM, genes de virulencia, tolerancia a metales pesados y biocidas, relacionadoa estres
echo ""
echo "############################################################################"
echo " Comenzando analisis de genes RAM, usando AMRFinder(Plus) version: v$(amrfinder --version)"
echo "############################################################################"
echo ""

<<<<<<< HEAD
AMRFinder.sh
=======
#AMRFinder.sh
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

#####################################################################################################################################################################
#####################################################
# unir resultados importantes en un solo directorio #
#####################################################
echo ""
echo "#################################################################################"
echo "   Reuniendo archivos importantes en un solo directorio de resultados: RESULTS   "
echo "#################################################################################"
echo ""

results.sh

# Hora y fecha de termino de analisis
echo ""
echo "############################################################################################"
echo " PIPELINE DE ANALISIS BIOINFORMATICO DE DATOS DE SECUENCIACION DE GENOMA COMPLETO TERMINADO"
echo " $(date)"
echo "############################################################################################"
echo ""
