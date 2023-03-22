#!/bin/bash

#
# script para corres blastn usando multiples bases de datos y multiples ensambles
#

for name in *.fasta; do
   for file in *.fa; do
      blastn -query $name -db $file -sorthits 1 -out blast_$(basename $name .fasta)_$(basename $file .fa)
   done
done
