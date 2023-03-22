#!/bin/bash

#
#
#

for file in *.txt; do
    grep -E "'identity':|'plasmid':" $file | tr -d " \t" | tr -d "," > $(basename $file .txt)_filtrado.txt
done
