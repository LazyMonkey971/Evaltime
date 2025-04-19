#Fonction uniformisant les valeurs de la colonne "year_obs" (Retirer l'heure en supprimant ce qui suit le 'T' et mettre par exemple les formats 1985-05-30 en format 1985)
#Nom de la fonction:uniformiser_year_obs

uniformiser_year_obs <- function(df, colonne) {
  # Assurer que year_obs est bien une chaîne de caractères
  df$year_obs <- as.character(df$year_obs)
  
  # Extraire uniquement les 4 premiers chiffres (pour garantir que ce sont bien des années)
  df$year_obs <- gsub("\\D", "", df$year_obs)  # Supprimer tout ce qui n'est pas un chiffre
  
  # Garder uniquement les 4 premiers chiffres (au cas où il y aurait des valeurs avec plus de chiffres)
  df$year_obs <- substr(df$year_obs, 1, 4)
  
  # Convertir en entier (en format année)
  df$year_obs <- as.integer(df$year_obs)
  
  # Afficher un message indiquant ce qui a été fait
  message(paste("Les valeurs de la colonne", colonne, "ont été uniformisées en format YYYY"))
  
  # Retourner le dataframe modifié
  return(df)
}

