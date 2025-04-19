#Fonction enlevant les valeurs trop abberrantes de obs_value
#Nom de la fonction: nettoyer_obs_value
nettoyer_obs_value <- function(dataframe, colonne, seuil = 500) {
  # Vérifier si la colonne existe
  if (!(colonne %in% colnames(dataframe))) {
    stop(paste("La colonne", colonne, "n'existe pas dans le dataframe."))
  }
  
  # Afficher un message avant de procéder
  message(paste("Suppression des lignes de obs_value où la valeur de", colonne, "est supérieure à", seuil))
  
  # Appliquer le filtrage en enlevant les valeurs supérieures à 500 dans la colonne spécifiée
  dataframe <- dataframe[dataframe[[colonne]] <= seuil, ]
  
  # Retourner le dataframe modifié
  return(dataframe)
}

