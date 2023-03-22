#!/bin/bash

#
# Automatizacion de pipeline de filtrado para alineamiento
#

# echo ""
# echo "Iniciando filtrado de alineamiento e identificación de mutaciones"
echo ""
for fname in ?????????????????????_contigs.fasta; do
   echo "Muestra $fname"
   grep -nw 'Score' $fname  >  hitList_$fname
   grep -nw  'Expect = 0.0'  hitList_$fname  | cut -d ':' -f 1 > num1_$fname
   expr $(cat num1_$fname) + 1 > num2_$fname
   cat hitList_$fname | sed -n "$(cat num1_$fname),$(cat num2_$fname) p" | cut -d " " -f 1 | tr -d ":" > lineas_$fname
   cat lineas_$fname | sed -n "1 p" > linea1_$fname
   cat lineas_$fname | sed -n "2 p" > linea2_$fname
   cat $fname | sed -n "$(cat linea1_$fname),$(cat linea2_$fname) p" > alineamiento_$fname
   awk '/Query/' alineamiento_$fname | awk '{print $3}' > Query_$fname
   awk '/Sbjct/' alineamiento_$fname | awk '{print $3}' > Subject_$fname
   mismatch.py "$(cat Query_$fname)" "$(cat Subject_$fname)" > mut_$fname
   echo "Resultado = $(cat mut_$fname) "
   echo ""
   rm hitList_$fname
   rm num1_$fname
   rm num2_$fname
   rm lineas_$fname
   rm linea1_$fname
   rm linea2_$fname
   rm Subject_$fname
done

# echo "Filtrado de alineamiento  e identificación de mutaciones finalizado"
echo ""

if [ ! -f resultados.txt ]; then
    Smutaciones.sh > resultados.txt
fi



