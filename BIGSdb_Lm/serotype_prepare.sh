#!/bin/bash

#
# produce un formato tabulado legible de perfiles alelicos de Listeria monocytogenes
#

for file in *allele*; do
   echo -e "$(echo $file | cut -d '_' -f 3 | cut -d '.' -f 1) \t $(cat $file)" > $file
done

cat lmo0737* > lmo0737
cat lmo1118* > lmo1118
cat ORF2110* > ORF2110
cat ORF2819* > ORF2819
cat prs* > prs

