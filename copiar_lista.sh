#!/bin/bash

cat lista*.txt | while read ID; do
   locate ${ID} | grep "fastq.gz" > ${ID}.txt
   grep "_R..fastq.gz" ${ID}.txt > pares.txt
   sed -n '1p' pares.txt > R1.txt
   sed -n '2p' pares.txt > R2.txt
   cp -v $(cat R1.txt) .
   cp -v $(cat R2.txt) .
done
