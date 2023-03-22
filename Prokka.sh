#!/bin/bash

#
# correr prokka con varias caracteristicas sobre todos los ensables en una carpeta
#

dir="ASSEMBLY/PROKKA"
if [[ ! -d ${dir} ]]; then
   mkdir ${dir}
fi

for ensamble in ASSEMBLY/*.fa; do
   ename=$(basename ${ensamble})
   ensamble_name="${ename%%-unicycler-assembly.fa}"
   echo ${ensamble_name}
   prokka \
         --outdir ${dir}/prokka_${ensamble_name} \
         --cpus $(nproc) \
         --addgenes \
         --genus Myroides \
         --usegenus \
         --prefix ${ensamble_name} \
   ${ensamble}
done
<<<<<<< HEAD


#         --genus Listeria \          # no existe Listeria en la base de datos
#         --usegenus \                # no existe Listeria en la base de datos
=======
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
