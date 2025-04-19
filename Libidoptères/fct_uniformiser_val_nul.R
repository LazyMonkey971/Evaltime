#Fonction uniformisant les valeurs vides ou inscrit 00:00:000 de la colonne 'time_obs' par NA
#Nom de la fonction: uniformiser_time_obs
uniformiser_val_nul <- function(dataframe, colonne) {
  # Vérifier combien de time_obs sont vides ou égaux à "00:00:00"
  time_obs_vide_ou_0 <- subset(dataframe, dataframe[[colonne]] == "" | dataframe[[colonne]] == "00:00:00")
  message(paste("Nombre de valeurs remplacées par NA qui étaient vides ou égales à '00:00:00' dans", colonne, ":", nrow(time_obs_vide_ou_0)))
  
  # Remplacer ces valeurs par NA dans la colonne spécifiée
  dataframe[[colonne]][dataframe[[colonne]] == "" | dataframe[[colonne]] == "00:00:00"] <- NA
  
  # Retourner le dataframe modifié
  return(dataframe)
}



