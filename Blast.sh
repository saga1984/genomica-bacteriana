#!/bin/bash

#
# correr un solo genoma (en este caso BB50.fa) contra muchas bases de datos
#

for file in *.fa; do
   blastn -query BB80.fa -db $file -sorthits 1 -out blast_$BB80_$(basename $file .fa)
done
