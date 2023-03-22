#!/bin/bash
#
# script que cambia el nombre de los ensambles provenientes de sorting_hat.sh
#

# remueve todo lo que viene despues del nombre del aislado, para todos los aislados
for file in ASSEMBLY/*spades-assembly*; do
   cp -v ${file} ./$(basename ${file}  -spades-assembly.fa).fa
done




