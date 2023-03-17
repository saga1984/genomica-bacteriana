#!/usr/bin/python3

# importar librerias
import argparse

# encontrar mismatches
def mismatch(query, subject, number):

    """ compara dos scuencias de nucleotidos o aminoacidos y devuelve
    posiciones con mismatch """

    for i in range(len(query)):
        if query[i].upper() == subject[i].upper(): # query y subject como mayusculas
           continue
        else:
            print(subject[i].upper(), i + number, query[i].upper()) # query y subject como mayusculas

# parsear argumentos
parser = argparse.ArgumentParser(description = " Encuentra mismatches (mutaciones puntuales) entre dos secuencias")
parser.add_argument("-q", "--query", type = str, help = "Secuencia de referencia")
parser.add_argument("-s", "--subject", type = str, help = "Secuencia problema")
parser.add_argument("-n", "--number", type = int, help = "numero de inicio de secuencia de Subject")

# asignar los argumentos: query, subject y number
args = parser.parse_args()

# llamar la funcion mismatches
mismatch(args.query, args.subject, args.number)
