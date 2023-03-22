#!/bin/bash

#------------------------------------------------
#  pedir input al usuario para checar resultados
# -----------------------------------------------

# correr fastqc y obtener estadisticas
echo -e "hacer analisis de calidad de lecturas: FASTQC"
estadisticas_lecturas.sh

# pedir input a usuario
echo "quieres continuar: "

# leer input de usuario
read var

# toma de decision
if [[ $var == "si" ]]; then
   echo -e "\ncontinuar ensamble_con_estadisticas.sh"
   # correr trimmomatic (filtro por calidad)
   echo -e "\nhacer filtrado por calidad de lecturas: Trimmomatic"
   TrimmomaticPE.sh
   # correr spades (ensamblador)
   echo -e "\ncontinuar con ensamble: SPAdes"
   conda activate SPAdes
   SPAdes.sh
   # BWA y SAMtools (estadisticas de ensambles)
   echo -e "\ncontinuar con obtención de estadísticas de ensamble: BWA y SAMtools"
   estadisticas_ensambles.sh
else
   echo "detenerse"
   break
fi

# correr kraken2 para hacer identificación taxonómica
echo -e "\ncontinuar con identificación taxonomica: Kraken2"
kraken2.sh
