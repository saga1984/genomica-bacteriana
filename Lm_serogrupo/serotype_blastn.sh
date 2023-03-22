#!/bin/bash

#
# producir el perfil de los 5 genes de Listeria monocytogenes
#

echo "# 10%"
for ensamble in *.fa; do
   blastn -query $ensamble -db $serotipo_db/ORF2110.fa > ${ensamble}_ORF2110.txt
done

echo "### 20%"
for ensamble in *.fa; do
   blastn -query $ensamble -db $serotipo_db/ORF2819.fa > ${ensamble}_ORF2819.txt
done

echo "##### 30%"
for ensamble in *.fa; do
   blastn -query $ensamble -db $serotipo_db/lmo0737.fa > ${ensamble}_lmo0737.txt
done

echo "####### 40%"
for ensamble in *.fa; do
   blastn -query $ensamble -db $serotipo_db/lmo1118.fa > ${ensamble}_lmo1118.txt
done

echo "######### 50%"
for ensamble in *.fa; do
   blastn -query $ensamble -db $serotipo_db/prs.fa > ${ensamble}_prs.txt
done
