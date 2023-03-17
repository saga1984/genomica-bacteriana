#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------------
#   Obtiene el MLST y ST de los diferentes generos bacterianos de analisis rutinarios: Salmonella, Listeria, Escherichia
# -------------------------------------------------------------------------------------------------------------------------

# variable que guarda el menu de ayuda
menu_ayuda="
 SINOPSIS:
\tObtiene el MLST y ST (y en algunos casos el C y el Linaje) de los diferentes generos bacterianos\n\t(Ej. Salmonella, Listeria, Escherichia, Enterococcus)
\n USO:
\t $(basename ${0}) [OPCIONES] <ESPECIE>
\t $(basename ${0}) -l
\t $(basename ${0}) -e Salmonella_enterica

\n OPCIONES:
\t e) \t\tEspecie de interes. (ver lista de especies disponibles).

\t l) \t\tLista de especies disponibles.

\t h) \t\tEste menu de ayuda
"

# si no se agregan argumentos u opciones al llamado de la funcion mostrar menu de ayuda y salir
if [[ ${#} -eq 0 ]]; then
   echo -e "${menu_ayuda}"
   exit 1
fi

# lista de especies disponibles
lista_especies="
LISTA DE ESPECIES TOMADA DE stringMLST (especies disponibles en pubMLST: https://pubmlst.org/)
Achromobacter_spp.
Acinetobacter_baumannii#1
Acinetobacter_baumannii#2
Aeromonas_spp.
Aggregatibacter_actinomycetemcomitans
Anaplasma_phagocytophilum
Arcobacter_spp.
Aspergillus_fumigatus
Bacillus_cereus
Bacillus_licheniformis
Bacillus_subtilis
Bacteroides_fragilis
Bartonella_bacilliformis
Bartonella_henselae
Bartonella_washoensis
Bordetella_spp.
Borrelia_spp.
Brachyspira_hampsonii
Brachyspira_hyodysenteriae
Brachyspira_intermedia
Brachyspira_pilosicoli
Brachyspira_spp.
Brucella_spp.
Burkholderia_cepacia_complex
Burkholderia_pseudomallei
Campylobacter_concisus/curvus
Campylobacter_fetus
Campylobacter_helveticus
Campylobacter_hyointestinalis
Campylobacter_insulaenigrae
Campylobacter_jejuni
Campylobacter_lanienae
Campylobacter_lari
Campylobacter_sputorum
Campylobacter_upsaliensis
Candida_albicans
Candida_glabrata
Candida_krusei
Candida_tropicalis
Candidatus_Liberibacter_solanacearum
Carnobacterium_maltaromaticum
Chlamydiales_spp.
Citrobacter_freundii
Clonorchis_sinensis
Clostridioides_difficile
Clostridium_botulinum
Clostridium_perfringens
Clostridium_septicum
Corynebacterium_diphtheriae
Cronobacter_spp.
Cutibacterium_acnes
Dichelobacter_nodosus
Edwardsiella_spp.
Enterobacter_cloacae
Enterococcus_faecalis
Enterococcus_faecium
Escherichia_coli#1
Escherichia_coli#2
Flavobacterium_psychrophilum
Gallibacterium_anatis
Geotrichum_spp.
Glaesserella_parasuis
Haemophilus_influenzae
Helicobacter_cinaedi
Helicobacter_pylori
Helicobacter_suis
Kingella_kingae
Klebsiella_aerogenes
Klebsiella_oxytoca
Klebsiella_pneumoniae
Kudoa_septempunctata
Lactobacillus_salivarius
Lactococcus_lactis_bacteriophage
Leptospira_spp.
Leptospira_spp.#2
Leptospira_spp.#3
Listeria_monocytogenes
Macrococcus_canis
Macrococcus_caseolyticus
Mammaliicoccus_sciuri
Mannheimia_haemolytica
Melissococcus_plutonius
Moraxella_catarrhalis
Mycobacteria_spp.
Mycobacteroides_abscessus
Mycoplasma_agalactiae
Mycoplasma_anserisalpingitidis
Mycoplasma_bovis
Mycoplasma_flocculare
Mycoplasma_gallisepticum#1
Mycoplasma_gallisepticum#2
Mycoplasma_hominis
Mycoplasma_hyopneumoniae
Mycoplasma_hyorhinis
Mycoplasma_iowae
Mycoplasma_pneumoniae
Mycoplasma_synoviae
Neisseria_spp.
Orientia_tsutsugamushi
Ornithobacterium_rhinotracheale
Paenibacillus_larvae
Pasteurella_multocida#1
Pasteurella_multocida#2
Pediococcus_pentosaceus
Photobacterium_damselae
Piscirickettsia_salmonis
Porphyromonas_gingivalis
Pseudomonas_aeruginosa
Pseudomonas_fluorescens
Pseudomonas_putida
Rhodococcus_spp.
Riemerella_anatipestifer
Salmonella_enterica
Saprolegnia_parasitica
Shewanella_spp.
Sinorhizobium_spp.
Staphylococcus_aureus
Staphylococcus_chromogenes
Staphylococcus_epidermidis
Staphylococcus_haemolyticus
Staphylococcus_hominis
Staphylococcus_lugdunensis
Staphylococcus_pseudintermedius
Stenotrophomonas_maltophilia
Streptococcus_agalactiae
Streptococcus_bovis/equinus_complex_(SBSEC)
Streptococcus_canis
Streptococcus_dysgalactiae_equisimilis
Streptococcus_gallolyticus
Streptococcus_oralis
Streptococcus_pneumoniae
Streptococcus_pyogenes
Streptococcus_suis
Streptococcus_thermophilus
Streptococcus_thermophilus#2
Streptococcus_uberis
Streptococcus_zooepidemicus
Streptomyces_spp
Taylorella_spp.
Tenacibaculum_spp.
Treponema_pallidum
Trichomonas_vaginalis
Ureaplasma_spp.
Vibrio_cholerae
Vibrio_cholerae#2
Vibrio_parahaemolyticus
Vibrio_spp.
Vibrio_tapetis
Vibrio_vulnificus
Wolbachia
Xylella_fastidiosa
Yersinia_pseudotuberculosis
Yersinia_ruckeri
"

# funcion que corre stringMLST con la especie seleccionada por el ususario (OPTARG)
run_stringmlst(){

   # definir genero y nombre de especie de un solo string
   genero=$(echo ${OPTARG} | cut -d '_' -f '1')
   echo -e "Genero: = ${genero}\n" # CONTROL

   # definir directorio
   dir="STRINGMLST_${genero}"

   # si el directorio no existe, crealo
   if [[ ! -d ${dir} ]]; then
      mkdir ${dir}
   fi

   # copiar la base de datos al directorio actual
   ln -s /disk1/Programas_bioinformaticos/stringMLST/${OPTARG}* $(pwd)

   # for loop para todos los archivos fastq comprimidos en la carpeta actual
   for file in TRIMMING/*_1P.*fastq.gz; do
      # si el archivo no existe crealo con stringMLST, de lo contrario continua sin hacer nada
      if [[ ! -f stringMLST_tmp_${genero}.tsv ]]; then
         stringMLST.py --predict -d ./ -P ${OPTARG} -o stringMLST_tmp_${genero}.tsv
         # remover filas con NAs y sin Sequence Typey  guardar resultado en otro archivo
         grep -v "NA" stringMLST_tmp_${genero}.tsv | awk '$9 != 0' > stringMLST_${genero}_results.tsv
         # eliminar filas duplicadas
         cat stringMLST_${genero}_results.tsv | sort -r | uniq > stringMLST_${genero}.tsv
         # convertir a formato CSV
         sed 's/\t/,/g' stringMLST_${genero}.tsv > stringMLST_${genero}.csv # CSV
      else
         continue
      fi
   done
   # mover resultados al directorio de stringMLST
   mv stringMLST* ${dir}
   # eliminar links suaves
   rm ${OPTARG}*
   # remover archivos temporales
   rm ${dir}/*tmp*

}


# ---------------------------------------------------------------------
#   crear un directorio para guardar resultados y mover archivos finales
# ---------------------------------------------------------------------

# parseo de opciones y llamado de funcion principal
while getopts ":e:lh" opciones; do
   case "${opciones}" in
      e)
           echo -e "\nIniciando subtipado por stringMLST MLST y ST (y en algunos casos Linaje, y CC), para la especie: ${OPTARG}"
           run_stringmlst
           echo -e "\nSubtipado (MLST, ST (y en algunos casos Linaje, y CC), por stringMLST)\n terminado."
           ;;
      l)
           echo -e "${lista_especies}"
           ;;
      h)
           echo -e "${menu_ayuda}"
           ;;
      ?)
           echo -e "La opcion: -${OPTARG}, no es una opcion valida."
           echo -e "${menu_ayuda}"
           ;;
   esac
done
