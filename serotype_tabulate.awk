#!/bin/awk -f

BEGIN {
f1=ARGV[1]; f2=ARGV[2]; f3=ARGV[3]; f4=ARGV[4]; f5=ARGV[5] # los nombres de los archivos 1, 2, 3, 4 y 5
}
{ a[$1][FILENAME]=$2 } # valores acumulativos

END {
     for (i in a) {
        printf("%-10s\t%d\t%d\t%d\t%s\t%s\n", i, a[i][f1], a[i][f2], a[i][f3], a[i][f4], a[i][f5])
    }
}
