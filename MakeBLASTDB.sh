#!/bin/bash

#
# crear bases de datos para cada gen o genoma presente en el directorio
#

for file in *.fa; do
   makeblastdb -in $file -input_type "fasta" -dbtype "nucl"
done
