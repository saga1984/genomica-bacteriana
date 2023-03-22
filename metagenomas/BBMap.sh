  GNU nano 4.9.2                                                BBMap.sh                                                           
#!/bin/bash

for ensamble in 01.Ensamble/*-megahit.fa; do
   for hq in 00.Datos/*.HQ.*fastq.gz; do
      nombre_corto_ensamble=$(basename ${ensamble} -megahit.fa)
      nombre_corto_interleaved=$(basename ${hq} .HQ.fastq.gz)

      if [[ ${nombre_corto_ensamble}  == ${nombre_corto_interleaved} ]];then

         echo -e "\nEnsamble=${nombre_corto_ensamble}"
         echo -e "\nInterleaved=${nombre_corto_interleaved}\n"

         bbmap.sh ref=${ensamble} \
         in1=${hq} \
         out=02.Mapeo/${nombre_corto_ensamble}.pulque.sam \
         kfilter=22 subfilter=15 maxindel=80 threads=10
      else
         continue
      fi
   done
done
