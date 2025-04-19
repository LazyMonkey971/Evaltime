#Fonction uniformisant les valeurs de la colonne "dwc_event_date" (Retirer l'heure en supprimant ce qui suit le 'T')
#Nom de la fonction:retirer_heure_dwc_event_date

retirer_heure_dwc_event_date <- function(dataframe, colonne) {
  # Vérifier si la colonne existe
  if (!(colonne %in% colnames(dataframe))) {
    stop(paste("La colonne", colonne, "n'existe pas dans le dataframe."))
  }
  
  # Appliquer la transformation pour retirer l'heure
  dataframe[[colonne]] <- sub("T.*", "", dataframe[[colonne]])
  
  # Afficher un message indiquant ce qui a été fait
  message(paste("L'heure a été retirée de la colonne", colonne, "."))
  
  # Retourner le dataframe modifié
  return(dataframe)
}





