#!/usr/bin/Rscript

# 
# Crea hoja principal de resporte de resultados, conjuntando resultados de:
# stringMLST, SeqSero2 y ResFinder
#

########################################################
############### declarar la funcion ####################
########################################################
crear_columnas_RR <- function(corrida){

  ############# preparar el entorno ##############
  if ("tidyr" %in% installed.packages() == FALSE) {
    install.packages("tidyr")
  }
  
  
  library(tidyr) # funcion unite, unir todas las columnas en una
  
  ############### crear objetos (data frames) ################
  # stringMLST
  stringMLST <<- read.csv(paste(corrida,"RESULTS/stringMLSTcol.txt", 
                               sep = ""),
                         header = F)
  
  # SeqSero2
  SeqSero <<- read.csv(paste(corrida,"RESULTS/SeqSero2col.txt", 
                            sep = ""),
                      sep = "\t", header = F)
  
  # Genes RAM
  genesRAM <<- read.csv(
    paste(corrida,"RESULTS/RAMcol_genes_Salmonella_enterica.txt",
          sep = ""),
    sep = ",", header = F)
  
  # Categorias RAM
  categoriasRAM <<- read.csv(
  paste(corrida,"RESULTS/RAMcol_categorias_Salmonella_enterica.txt",
        sep = ""),
  sep = ",", header = F)

######### funcion para crear columnas ###########

  # remover nombres de columnas
  if (genesRAM[1,1] == "ID"){
    genesRAM <- genesRAM[-1,]
    }

  # remover nombres de columna´s
  if (categoriasRAM[1,1] == "ID"){
    categoriasRAM <- categoriasRAM[-1,]
    }

  # unir todas las columnas de genes
  genesRAM <- unite(data = genesRAM,
                    col = GenesRAM, 
                    paste("V", 2:ncol(genesRAM), sep = ""),
                    sep = ",")

  # unir todas las columnas de categorias
  categoriasRAM <- unite(categoriasRAM,
                         CategoriasRAM,
                         paste("V", 2:ncol(categoriasRAM), sep = ""),
                         sep = ",")

  # unir todos los campos de stringMLST
  stringMLST <- unite(stringMLST,
                      stringMLST,
                      paste("V", 2:ncol(stringMLST), sep = ""),
                      sep = ",")

  # unir todos los campos de SeqSero2
  SeqSero <- unite(SeqSero,
                   SeqSero,
                   paste("V", 2:ncol(SeqSero), sep = ""),
                   sep = ",")

  # remover cluster de comas (,,,)
  genesRAM$GenesRAM <- sub(",,.*", "", genesRAM$GenesRAM)
  categoriasRAM$CategoriasRAM <- sub(",,.*", "",categoriasRAM$CategoriasRAM)

  ########## unir archivos ############
  # obtener archivos unidos temporales
  string_seq <- merge(SeqSero,stringMLST,by = "V1")
  ram <- merge(genesRAM,categoriasRAM,by = "V1")
  # crear archivo final
  completo <- merge(string_seq,ram,by = "V1")

########### eliminar categorias duplicadas #############

completo$CategoriasRAM <- sapply(strsplit(as.character(completo$CategoriasRAM), split=","), function(x) {
    paste(unique(x), collapse = ',')
  })  

# volver global
completo <<- completo

########## funcion para guardar ##########

write.csv(completo, 
          paste(corrida, "/RESULTS/Columnas_ReporteResutados.csv", 
                sep = ""),
          row.names = F)

}

########################################################
################### llamar la funcion ##################
########################################################
crear_columnas_RR(paste(getwd(), "/", sep = ""))
