#Fonction retirant la colonne obs_unit (car ce ne sont que des NA)
#Nom de la fonction: retire_colonne_na

#Vérifier que ce ne sont que des NA dans obs_variable
unique(lep$obs_unit)

retirer_colonne_na <- function(dataframe, colonne) {
  # Vérifier si la colonne existe dans le dataframe
  library(dplyr )
  if(colonne %in% colnames(dataframe)) {
    # Vérifier si la colonne contient uniquement des NA
    if(all(is.na(dataframe[[colonne]]))) {
      # Retirer la colonne si elle contient uniquement des NA
      dataframe <- dataframe %>%
        select(-all_of(colonne))
      message(paste("La colonne", colonne, "a été retirée car elle contenait uniquement des NA."))
    } else {
      message(paste("La colonne", colonne, "ne contient pas uniquement des NA, elle n'a pas été retirée."))
    }
  } else {
    message(paste("La colonne", colonne, "n'existe pas dans le dataframe."))
  }
   
  # Retourner le dataframe modifié
  return(dataframe)
}
