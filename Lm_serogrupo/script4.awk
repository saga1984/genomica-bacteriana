#!/bin/awk -f

BEGIN {
print "mi lista de ususarios y shells"
print "Usuario \t Shell"
print "------- \t -------"
FS=":"
}

{
print $1 "         \t   " $7
}

END {
print "Fin de la lista"
}
