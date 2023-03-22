#!/bin/bash

#
# Predice el serotipo de E coli en todos los ensambles en un directorio
#

conteo=0
for ensamble in *.fa; do
   conteo=$[ $conteo + 1 ]
   echo -e "$conteo: \t$(basename $ensamble -spades-assembly.fa)"
   serotypefinder.py -i ./$ensamble -p $serotypefinder_db  -mp /home/vangie/miniconda3/envs/Blast/bin/blastn > SF_$(basename $ensamble -spades-assembly.fa).txt
   grep "serotype" SF_$(basename $ensamble -spades-assembly.fa).txt | grep -v "serotypefinder" | awk '{print $1$2}' | tr -d ",''" | uniq
   echo -e "\n"
done > Serotipos.txt

rm -r -f ./SF_* data.json tmp
