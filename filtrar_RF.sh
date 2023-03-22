#!/bin/bash

#
#
#

for file in *.txt; do
grep -E "Saving:" RF_L_monocytogenes_2b_UAS-5_BB80.txt | cut -d ":" -f "4,5" > $(basename $file .txt)_filtrado.txt
done
