#!/bin/bash

##################################################################################################
# ejecuta Roary, para hacer análisis de pangenoma y filogenia de core genome                     #
# NOTA ESTE SCRIPT SE EJECUTA COMO SE MUESTRA A CONTINUACION:                                    #
#                                                                                                #
# parado en la ruta de archivos FASTQ y teniendo lista la carpeta de ensambles llamada ASSEMBLY: #
# source Prokka_Roary.sh                                                                         #
# el motivo del source es para que el script pueda llamar y cambiar entre entornos de conda      #
##################################################################################################

echo "#########################################################################################"
echo "# iniciando análisis de pangenoma y filogenia de core genome con pipeleine Prokka-Roary #"
echo "#########################################################################################"
echo ""

##################################
# Anotacion de genomas de Prooka #
##################################

#### activar entorno de Prokka ####
conda activate Prokka_Quast

# verificar el estado de la activacion del entorno
if [[ $? -eq 0 ]]; then
   echo -e "el entorno de conda con binarios de Prokka fue activado exitosamente \n"
else
   echo "el entorno de conda con binarios de Prokka no pudo ser activado con exit status: $?"
fi

echo "############################################"
echo "  Anotacion de genomas bacterianos usando:  "
echo "  $(prokka --version)                       "
echo "############################################"
echo ""

Prokka.sh

# mover archivos de genomas anotados GFF3 y GBK a carpetas individuales
GFF_GBK_move.sh

# desactivar entorno de Prokka #
conda deactivate

# verificar el estado de la activacion del entorno
if [[ $? -eq 0 ]]; then
   echo -e "el entorno de conda con binarios de Prokka fue desactivado exitosamente \n"
else
   echo "el entorno de conda con binarios de Prokka no pudo ser desactivado con exit status: $?"
fi

<<<<<<< HEAD
###################################
# Analisis de pangenoma con Roary #
###################################
=======
##################################
# Anotacion de genomas de Prooka #
##################################
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

#### activar entorno de roary ####
conda activate Roary

# verificar el estado de la activacion del entorno
if [[ $? -eq 0 ]]; then
   echo -e "el entorno de conda con binarios de Roary fue activado exitosamente \n"
else
   echo "el entorno de conda con binarios de Roary no pudo ser activado con exit status: $?"
fi

echo "##########################################################################################"
echo "  Generación de alineamiento de core genome y análisis de pan genoma usando: $(roary -w)  "
echo "##########################################################################################"
echo ""

# ejecutar Roary para obetener alineamiento de core genome y graficas de pan genoma
roary -e --mafft -r -v -p $(nproc) ASSEMBLY/PROKKA/GFF/*.gff -f ./ROARY

# ejecutar FastTree para obtener reconstruccion filogenetica, por maxima verosimilitud
FastTree -nt -gtr ./ROARY/core_gene_alignment.aln > ./ROARY/FastTree_Roary.newick

<<<<<<< HEAD
######################### roary_plots.py ####################################

##### con soporte de ramas #######
# generar primer grafico de calidad de publicacion PNG con soporte de ramas
roary_plots.py ./ROARY/FastTree_Roary.newick ./ROARY/gene_presence_absence.csv

# mover a ROARY y cambiar nombre
mv -v ./pangenome_matrix.png  ./ROARY/pangenome_matrix_confidence.png

# cambiar formato de imagen por defecto de PNG a TIFF
sed -i "s/default='png'/default='tiff'/g" ~/.bin/roary_plots.py

# generar primer grafico de calidad de publicacion TIFF con soporte de ramas
roary_plots.py ./ROARY/FastTree_Roary.newick ./ROARY/gene_presence_absence.csv

# mover a ROARY y cambiar nombre
mv -v ./pangenome_matrix.tiff  ./ROARY/pangenome_matrix_confidence.tiff

###### sin soporte de ramas #######
# no mostrar soporte de ramas, por defecto
sed -i "s/show_confidence=True/show_confidence=False/g" ~/.bin/roary_plots.py

# generar primer grafico de calidad de publicacion TIFF sin soporte de ramas
roary_plots.py ./ROARY/FastTree_Roary.newick ./ROARY/gene_presence_absence.csv

# mover a ROARY y cambiar nombre
mv -v ./pangenome_matrix.tiff  ./ROARY/pangenome_matrix.tiff

# cambiar formato de imagen
sed -i "s/default='tiff'/default='png'/g" ~/.bin/roary_plots.py

# generar primer grafico de calidad de publicacion PNG sin soporte de ramas
roary_plots.py ./ROARY/FastTree_Roary.newick ./ROARY/gene_presence_absence.csv

# mover a ROARY y cambiar nombre
mv -v ./pangenome_matrix.png  ./ROARY/pangenome_matrix.png

# revertir configuraciion para mostrar soporte de ramas, por defecto
sed -i "s/show_confidence=False/show_confidence=True/g" ~/.bin/roary_plots.py

# mover todas las imagenes a ROARY
mv -v ./pangenome_* ./ROARY/

###############################################################################
=======
# generar primer grafico de calidad de publicacion
roary_plots.py .ROARY/FastTree_Roary.newick ./ROARY/gene_presence_absence.csv
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf

#  generar segundo grafico de calidad de publicacion
roary2svg.pl --colour="blue" --sepcolour="green" ./ROARY/gene_presence_absence.csv > ./ROARY/pan_genome.svg

#### desactivar entorno de roary ####
conda deactivate

# verificar el estado de la activacion del entorno
if [[ $? -eq 0 ]]; then
   echo -e "el entorno de conda con binarios de Roary fue desactivado exitosamente \n"
else
   echo "el entorno de conda con binarios de Roary no pudo ser desactivado con exit status: $?"
fi
<<<<<<< HEAD

=======
>>>>>>> c06077f8fdbc5ae39d8bf72caaca6cccbe11fcaf
