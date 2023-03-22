#!/bin/bash

#
# producir el perfil de los 5 genes de Listeria monocytogenes
#

# ---------------------------------------------------------------------------
#   hacer la base de datos. NOTA: solo se corre una vez si es que no existe
# ---------------------------------------------------------------------------

#for file in $BIGSdb_Lm/*.fa; do
#   makeblastdb -in $file -input_type fasta -dbtype nucl
#done


# -----------------
#   hacer blastn
# -----------------

echo "# 10%"
for ensamble in ./*.fa; do
   blastn -query $ensamble -db $BIGSdb_Lm/lmo0737.fa > $(basename ${ensamble} .fa)_lmo0737.txt
done

echo "### 20%"
for ensamble in ./*.fa; do
   blastn -query $ensamble -db $BIGSdb_Lm/lmo1118.fa > $(basename ${ensamble} .fa)_lmo1118.txt
done

echo "##### 30%"
for ensamble in ./*.fa; do
   blastn -query $ensamble -db $BIGSdb_Lm/ORF2110.fa > $(basename ${ensamble} .fa)_ORF2110.txt
done

echo "####### 40%"
for ensamble in ./*.fa; do
   blastn -query $ensamble -db $BIGSdb_Lm/ORF2819.fa > $(basename ${ensamble} .fa)_ORF2819.txt
done

echo "######### 50%"
for ensamble in ./*.fa; do
   blastn -query $ensamble -db $BIGSdb_Lm/prs.fa > $(basename ${ensamble} .fa)_prs.txt
done
