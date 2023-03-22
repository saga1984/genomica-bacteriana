#!/bin/bash

#--------------------------------------------------------------------------------------------------
# correr snippy en modo de una sola secuencia sobre elementos en una parpeta
#---------------------------------------------------------------------------------------------------

########### referencias ############################
ref=$1
###############################################

DIR="SNIPPY"

if [[ ! -d ${DIR} ]]; then
  mkdir ${DIR}
fi

mensaje() {
echo "Error: no se ha introducido una referencia, por favor introduce una como argumento"
}

if [[ $1 -eq 0 ]]; then
   mensaje
   exit 2
fi

for ensamble in *.fa; do
   ensamble_name="$(basename $ensamble | cut -d '-' -f '1')"
   echo -e "\n"
   echo ${ensamble}
   snippy --cpus $(nproc) --force --ref ${ref} --outdir ${DIR}/coreSNP_${ensamble_name} --ctgs ${ensamble} \
   --ram $(grep "MemTotal" /proc/meminfo | awk '{print $2/(1024 * 1024)}' | cut -d "." -f "1") # info de la ram, se divide para Gigas y se eliminan decimales
done

