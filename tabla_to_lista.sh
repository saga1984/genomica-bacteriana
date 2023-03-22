#!/bin/bash
# --------------
#    Ubuntu
# --------------
CRAM_1="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Tetra.csv"
CRAM_2="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Amino.csv"
CRAM_3="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Beta.csv"
CRAM_4="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Feni.csv"
CRAM_5="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Sulfo.csv"
CRAM_6="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Rifa.csv"
CRAM_7="/home/senasica2/Documentos/2022/PVRAM_Junio/Gen_Cat/CRAM_Fluoro.csv"

for ((x = 1; x < 8; x++)); do
   var="CRAM_${x}"
   for category in $(cat ${var}); do
      echo -e "$category"
   done
done > filtrar_${var}.txt

