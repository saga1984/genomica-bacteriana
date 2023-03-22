#!/bin/bash

#
# Filtrar resultados de VirulenceFinder
#

for file in *.txt; do
   grep -E "accession|identity|virulence_gene" $file | tr -d " \t" | tr -d "}" | tr -d "," > $(basename $file .txt)_filtrado.txt
done
