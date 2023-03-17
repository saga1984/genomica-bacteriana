#!/bin/bash

##########################################################
# conjunta resultados importantes de pipeline de analisis
##########################################################

# asignar nombre de directorio
dir="RESULTS"

# si no existe, crealo
if [[ ! -d ${dir} ]]; then
   mkdir $dir
fi

#################################
# control de calidad de lecturas
#################################

# copiar resultados de calidad de lecturas como los obtenidos por fastqcr  a RESULTS
cp -v  FASTQC/all_status_basic_stats.csv ${dir}

# copiar archivos principales de resultados de estadisticas de lecturas a RESULTS
cp -v FASTQC/lecturas_stats.tab ${dir}/estadisticas_lecturas.tsv
sed 's/\t/,/g' ${dir}/estadisticas_lecturas.tsv > ${dir}/estadisticas_lecturas.csv

##############################################
# control de calidad de lecturas postrimming
##############################################

# copiar resultados de calidad de lecturas postrimming como los obtenidos por fastqcr  a RESULTS
cp -v  TRIMMING/FASTQC/all_status_basic_stats.csv ${dir}

# copiar archivos principales de resultados de estadisticas de lecturas postrimming a RESULTS
cp -v TRIMMING/FASTQC/lecturas_stats.tab ${dir}/estadisticas_lecturas.tsv
sed 's/\t/,/g' ${dir}/estadisticas_lecturas.tsv > ${dir}/estadisticas_lecturas.csv

##############################
# estadisticas de ensambles
##############################

# copiar resultados de estadisticas de ensambles a RESULTS
cp -v ASSEMBLY/Stats/estadisticas* ${dir}



# ------------------------------------------------------------------------------------------------



######################################
# identificacion taxonomica: Kraken2
######################################

# copiar resultados de Kraken2 a RESULTS
cp -v KRAKEN2/*all* ${dir}

#########################################
# identificacion taxonomica: KmerFinder
#########################################

# copiar resultados de KmerFinder a RESULTS
cp -v KMERFINDER/*all* ${dir}



# ------------------------------------------------------------------------------------------------



#############################################################################
# subtipado de Salmonella, Listeria, Eterococcus y Escherichia: stringMLST
#############################################################################

# copiar resultados de stringMLST a RESULTS
cp -v $(ls STRINGMLST/* | grep -v "results") ${dir}

######################################################################
# subtipado de Listeria por PCR serogrupo: script in house BIGSdb_Lm
######################################################################

cp -v SEROGROUP_LISTERIA/Lm_PCRserogrupo* ${dir}

######################################
# subtipado de Salmonella: SeqSero2
######################################

# copiar resultados de SeqSero2 a RESULTS
cp -v SEQSERO2/SeqSero2* ${dir}

##################################
# subtipado de Salmonella: sistr
##################################

# copiar resultados de sistr_cmd a RESULTS
cp -v SISTR_CMD/sistr_resultados.csv ${dir}
cp -v SISTR_CMD/serotipos_cgMLTS.csv ${dir}

##################################
# subtipado de Salmonella: sistr
##################################

# copiar resultados de SeroTypeFinder a RESULTS
cp -v SEROTYPEFINDER/serotypefinder_resultados* ${dir}


# ---------------------------------------------------------------------------------------------


#########################################################
# identiificacion de genes RAM: ResFinder (PointFinder)
#########################################################

# si no esxiste el directorio, crealo
if [[ ! -d ${dir}/RAM/RESFINDER ]];then
   mkdir -p ${dir}/RAM/RESFINDER
fi

# copiar resultados de ResFinder a RESULTS
cp -v RES.POINT_FINDER/ResPointFinder*_gen_*all.csv ${dir}
cp -v RES.POINT_FINDER/ResPointFinder*_categoria_*all.csv ${dir}

# copiar resultados mas detallados a una carpeta unica
cp -v RES.POINT_FINDER/RF_*/*filtered* ${dir}/RAM/RESFINDER/

###########################################
# identiificacion de genes RAM: AMRFINDER
###########################################

# si no esxiste el directorio, crealo
#if [[ ! -d ${dir}/RAM/AMRFINDER ]];then
#   mkdir -p ${dir}/RAM/AMRFINDER
#fi

# copiar resultados de AMRFinder a RESULTS
#cp -v AMRFINDER/AMRFinder*gen*all.csv ${dir}
#cp -v AMRFINDER/AMRFinder*categoria*all.csv ${dir}

# copiar resultados mas detallados a una carpeta unica
#cp -v AMRFINDER/AMRF*filtrado* ${dir}/RAM/AMRFINDER/

##########################################
# identiificacion de genes RAM: ABRicate
##########################################

# si no esxiste el directorio, crealo
#if [[ ! -d ${dir}/RAM/ABRICATE ]];then
#   mkdir ${dir}/RAM/ABRICATE
#fi

# copiar resultados de ABRicate a RESULTS
#cp -v AMRFINDER/*all* ${dir}

#cp -v AMRFINDER/ABRicate*filtered* ${dir}/RAM/ABRICATE
