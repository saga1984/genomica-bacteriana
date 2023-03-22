#!/bin/bash

cat lista_enteritidis.tab | while read ID; do
   locate ${ID} | grep "spades-assembly.fa" > ${ID}.txt
   grep "${ID}-spades-assembly.fa" ${ID}.txt > ${ID}_hit.txt
   cp -v $(cat ${ID}_hit.txt) .
   rm *.txt
done
