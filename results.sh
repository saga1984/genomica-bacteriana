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

if [[ -d FASTQC ]]; then
   # copiar resultados de calidad de lecturas como los obtenidos por fastqcr  a RESULTS
   cp -v  FASTQC/all_status_basic_stats.csv ${dir} 2> /dev/null

   # copiar archivos principales de resultados de estadisticas de lecturas a RESULTS
   cp -v FASTQC/lecturas_stats.tab ${dir}/estadisticas_lecturas.tsv 2> /dev/null
   sed 's/\t/,/g' ${dir}/estadisticas_lecturas.tsv > ${dir}/estadisticas_lecturas.csv 2> /dev/null
fi

##############################################
# control de calidad de lecturas postrimming
##############################################

if [[ -d TRIMMING/FASTQC ]]; then
   # copiar resultados de calidad de lecturas postrimming como los obtenidos por fastqcr  a RESULTS
   cp -v  TRIMMING/FASTQC/all_status_basic_stats.csv ${dir}/all_status_basic_stats_postrimming.csv 2> /dev/null

   # copiar archivos principales de resultados de estadisticas de lecturas postrimming a RESULTS
   cp -v TRIMMING/FASTQC/lecturas_stats.tab ${dir}/estadisticas_lecturas_postrimming.tsv 2> /dev/null
   sed 's/\t/,/g' ${dir}/estadisticas_lecturas_postrimming.tsv > ${dir}/estadisticas_lecturas_postrimming.csv 2> /dev/null
fi

##############################
# estadisticas de ensambles
##############################

if [[ -d ASSEMBLY/Stats ]]; then
   # copiar resultados de estadisticas de ensambles a RESULTS
   cp -v ASSEMBLY/Stats/estadisticas* ${dir} 2> /dev/null
fi


# ------------------------------------------------------------------------------------------------



######################################
# identificacion taxonomica: Kraken2
######################################


if [[ -d KRAKEN2 ]]; then
   # copiar resultados de Kraken2 a RESULTS
   cp -v KRAKEN2/*all* ${dir} 2> /dev/null
fi

#########################################
# identificacion taxonomica: KmerFinder
#########################################

if [[ -d KMERFINDER ]]; then
   # copiar resultados de KmerFinder a RESULTS
   cp -v KMERFINDER/*all* ${dir} 2> /dev/null
fi


# ------------------------------------------------------------------------------------------------



#############################################################################
# subtipado de Salmonella, Listeria, Eterococcus y Escherichia: stringMLST
#############################################################################

if [[ -d STRINGMLST ]]; then
   # copiar resultados de stringMLST a RESULTS
   cp -v STRINGMLST/* ${dir} 2> /dev/null
else
   for genero in Salmonella Escherichia Listeria Enterococcus; do
      if [[ -d STRINGMLST_${genero} ]]; then
         # copiar resultados de stringMLST a RESULTS
         cp -v $(ls STRINGMLST_${genero}/* | grep -v "results") ${dir} 2> /dev/null
      fi
   done
fi
######################################################################
# subtipado de Listeria por PCR serogrupo: script in house BIGSdb_Lm
######################################################################

if [[ -d SEROGROUP_LISTERIA ]]; then
   cp -v SEROGROUP_LISTERIA/Lm_PCRserogrupo* ${dir} 2> /dev/null
fi

######################################
# subtipado de Salmonella: SeqSero2
######################################

if [[ -d SEQSERO2 ]]; then
   # copiar resultados de SeqSero2 a RESULTS
   cp -v SEQSERO2/SeqSero2* ${dir} 2> /dev/null 2> /dev/null
fi

##################################
# subtipado de Salmonella: sistr
##################################

if [[ -d SISTR_CMD ]]; then
   # copiar resultados de sistr_cmd a RESULTS
   cp -v SISTR_CMD/sistr_resultados.csv ${dir} 2> /dev/null
   cp -v SISTR_CMD/serotipos_cgMLTS.csv ${dir} 2> /dev/null
fi

##################################
# subtipado de Salmonella: sistr
##################################

if [[ -d SEROTYPEFINDER ]]; then
   # copiar resultados de SeroTypeFinder a RESULTS
   cp -v SEROTYPEFINDER/serotypefinder_resultados* ${dir} 2> /dev/null
fi

# ---------------------------------------------------------------------------------------------


#########################################################
# identiificacion de genes RAM: ResFinder (PointFinder)
#########################################################

if [[ ! -d ${dir}/RAM/RESFINDER ]];then
   # si no esxiste el directorio, crealo
   mkdir -p ${dir}/RAM/RESFINDER
fi

# para resultados por run_ResFinder.sh
if [[ -d RES.POINT_FINDER ]]; then
   # copiar resultados de RES.POINT_FINDER a RESULTS
   cp -v RES.POINT_FINDER/*_all.csv ${dir} 2> /dev/null
   # copiar resultados filtrados para reporte de resultados (sin genes especiales ni mutaciones puntuales)
   cp -v RES.POINT_FINDER/RAMcol_*.txt ${dir} 2> /dev/null
   # copiar resultados de ResFinder a RESULTS
   cp -v RES.POINT_FINDER/ResPointFinder*_gen_*all.csv ${dir} 2> /dev/null
   cp -v RES.POINT_FINDER/ResPointFinder*_categoria_*all.csv ${dir} 2> /dev/null
   # copiar resultados filtrados para reporte de resultados (sin genes especiales ni mutaciones puntuales)
   cp RES.POINT_FINDER/RAMcol_*.txt ${dir} 2> /dev/null
   # copiar resultados mas detallados a una carpeta unica
   cp -v RES.POINT_FINDER/RF_*/*filtered* ${dir}/RAM/RESFINDER/ 2> /dev/null
else
   # incluir resultados obtenidos por run_ResFinder_solo.sh
   for genero in Salmonella Escherichia Listeria Enterococcus Citrobacter; do
      if [[ -d RES.POINT_FINDER_${genero} ]]; then
         # copiar resultados de RES.POINT_FINDER_${genero} a RESULTS
         cp -v RES.POINT_FINDER_${genero}/*_all.csv ${dir} 2> /dev/null
         # copiar resultados filtrados para reporte de resultados (sin genes especiales ni mutaciones puntuales)
         cp -v RES.POINT_FINDER/RAMcol_*.txt ${dir} 2> /dev/null
         # copiar resultados de ResFinder a RESULTS
         cp -v RES.POINT_FINDER/ResPointFinder*_gen_*all.csv ${dir} 2> /dev/null
         cp -v RES.POINT_FINDER/ResPointFinder*_categoria_*all.csv ${dir} 2> /dev/null
         # copiar resultados mas detallados a una carpeta unica
         cp -v RES.POINT_FINDER/RF_*/*filtered* ${dir}/RAM/RESFINDER/ 2> /dev/null
      fi
   done
fi

# borrar archivos vacios
for file in ${dir}/ResPointFinder_*; do
   if [[ -s ${file} ]];then
      echo "filename: ${file} EXISTE Y ES MAYOR A > 0 BITES"
   else
      echo "filename: ${file} NO EXISTE O TIENE TAMAÑO DE 0"
      rm ${file}
   fi
done

<<<<<<< HEAD

##############################################
# remover genes de estres y categoria estres #
##############################################


=======
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
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
