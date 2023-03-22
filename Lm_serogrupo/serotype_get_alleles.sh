#!/bin/bash

#
# Obtiene los el ID de la variante alelica de los diferentes genes para predecir el serotipo (PCR serogrop) de Listeria monocytogenes 
#

echo "########### 60%"
for file in *ORF2110.txt; do
   grep -n "Sequences producing significant alignments:" $file | cut -d ":" -f 1 > n1
   sed -n "$(echo $[ $(cat n1) + 2 ]) p" $file | cut -d "_" -f 2 | cut -d " " -f 1 > ORF2110_allele_${file}
done

rm n1

echo "############# 70%"
for file in *ORF2819.txt; do
   grep -n "Sequences producing significant alignments:" $file | cut -d ":" -f 1 > n1
   sed -n "$(echo $[ $(cat n1) + 2 ]) p" $file | cut -d "_" -f 2 | cut -d " " -f 1 > ORF2819_allele_${file}
done

rm n1

echo "############### 80%"
for file in *lmo0737.txt; do
   grep -n "Sequences producing significant alignments:" $file | cut -d ":" -f 1 > n1
   sed -n "$(echo $[ $(cat n1) + 2 ]) p" $file | cut -d "_" -f 2 | cut -d " " -f 1 > lmo0737_allele_${file}
done

rm n1

echo "################# 90%"
for file in *lmo1118.txt; do
   grep -n "Sequences producing significant alignments:" $file | cut -d ":" -f 1 > n1
   sed -n "$(echo $[ $(cat n1) + 2 ]) p" $file | cut -d "_" -f 2 | cut -d " " -f 1 > lmo1118_allele_${file}
done

rm n1

echo "################### 100%"
for file in *prs.txt; do
   grep -n "Sequences producing significant alignments:" $file | cut -d ":" -f 1 > n1
   sed -n "$(echo $[ $(cat n1) + 2 ]) p" $file | cut -d "_" -f 2 | cut -d " " -f 1 > prs_allele_${file}
done

rm n1

