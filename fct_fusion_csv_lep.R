# Fonction qui rassemble tous les fichiers de lépidoptères CSV en un gros data frame (lep)
#Nom de la fonction: fusion_csv_lep
library(data.table)

fusion_csv_lep <- function(data1) {
  
  # Vérifier s'il y a des fichiers CSV
  if (length(data1) == 0) {
    stop("Aucun fichier CSV trouvé dans le dossier spécifié.")
  }
  
  # Lire tous les fichiers CSV dans une liste de dataframes
  named.list <- lapply(data1[1:154], read.csv)
  
  # Fusionner les dataframes en un seul grand tableau
  lep <- rbindlist(named.list, use.names = FALSE)
  
  message("Fusion des fichiers terminée")
  
  #Afficher le dataframe 
  View(lep)
  
  # Retourner le dataframe fusionné
  return(lep)
}



