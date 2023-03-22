#!/bin/bash

#
# descargar archivos SRA y convertirlos a FASTQ
#

# menu de ayuda
AYUDA="
\tUSO:\t $(basename ${0}) [lista que contiene IDs de SRA]

\tEjemplo:\t $(basename ${0}) lista.txt

\tDonde:
\tcat lista.txt
\tSRR15539048
\tSRR21624334
\tSRR22297994
\tSRR22882291
"
# definir lista de IDs de SRA
lista=${1}

# si no se introducen opciones, despliega el menu de ayuda sal con error
if [[ ${#} -eq 0 ]]; then
   echo -e "\n\tOlvidaste indicar la lista de IDs de SRA"
   echo -e "${AYUDA}"
   exit 1
fi

# funcion para descargar archivos SRA
<<<<<<< HEAD
download_data()
=======
fasterqd()
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
{
   cat ${lista} | while read sequence; do
      # asignar nombres de archivos de salida
      r1="${sequence}_1.fastq"
      r2="${sequence}_2.fastq"
      # asignar nombres de archivos de salida modificados
      r1n=${r1/_1/_R1}
      r2n=${r2/_2/_R2}
      # descargar y conconvertir archivos SRA a FASTQ
      echo -e "\nRunning fastq-dump to download $sequence.\n"
      fasterq-dump --progress --force --verbose --threads $(nproc) --split-files ${sequence} 2> fasterq-dump_${sequence}.log
      # comprimir archivos
      gzip ${r1}
      gzip ${r2}
      # modificar nombres de archivos de salida comprimidos
      mv ${r1}.gz ${r1n}.gz
      mv ${r2}.gz ${r2n}.gz
   done
}

<<<<<<< HEAD
# llamar a la funcion para descargar SRA
download_data

=======
# funcion para descargar archivos SRA
fastqd()
{
   cat ${lista} | while read sequence; do
      # asignar nombres de archivos de salida
      r="${sequence}.fastq"
      # asignar nombres de archivos de salida modificados
      r_n=${r2/_2/_R2}
      # descargar y conconvertir archivos SRA a FASTQ
      echo -e "\nRunning fastq-dump to download $sequence.\n"
      fastq-dump --split-files --gzip ${sequence} 2> fastq-dump_${sequence}.log
   done
}

# llamar a la funcion para descargar SRA
fasterqd # lecturas pareadas
if [[ ! -f ${r2}  ]]; then
   fastqd # lecturas no pareadas
fi
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
