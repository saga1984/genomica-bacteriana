  GNU nano 4.9.2                                                Reformat.sh                                                          
#!/bin/bash

#
# Ejecuta reformat en archivos trimmeados y guarda el resultado en carpeta de archivos fastq
#

para todos los archivos trimmeados, ejecuta reformat.sh
for r1 in 00.Datos/*_1.trimm*; do
   # asiganr variables
   r2=${r1/_1./_2.} # sustitutir para asignar r2
   short_name=${r1%%_1.trimm.fastq.gz}

   echo -e \n"R1=${r1}"                    # CONTROL
   echo "R2=${r2}"                         # CONTROL
   echo -e "nombre_corto=${short_name}\n"  # CONTROL

   # ejecutar reformat.sh
   reformat.sh threads=10 in1=${r1} in2=${r2} out=${short_name}.HQ.fastq.gz
done
