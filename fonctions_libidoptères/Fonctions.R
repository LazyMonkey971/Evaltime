#Toutes les fonctions

#1
data_base <- function() {
  list.files(path = "Libidoptères",pattern = "*.csv", full.names = TRUE, include.dirs = TRUE)
}


#2
fusion_csv_lep <- function(data) {
  
  # Vérifier s'il y a des fichiers CSV
  if (length(data) == 0) {
    stop("Aucun fichier CSV trouvé dans le dossier spécifié.")
  }
  
  # Lire tous les fichiers CSV dans une liste de dataframes
  named.list <- lapply(data, read.csv)
  
  # Fusionner les dataframes en un seul grand tableau
  lep <- rbindlist(named.list, use.names = FALSE)
  
  message("Fusion des fichiers terminée")
  
  #Afficher le dataframe 
  View(lep)
  
  # Retourner le dataframe fusionné
  return(lep)
}

#3
verify_lep_names <- function(lep, taxonomie) {
  
  # Vérifier que le fichier taxonomie existe
  if (!file.exists("taxonomie.csv")) {
    stop("Le fichier taxonomie.csv n'existe pas au chemin spécifié.")
  }
  
  # Vérifier que la colonne 'observed_scientific_name' existe dans les deux dataframes
  if (!"observed_scientific_name" %in% colnames(lep)) {
    stop("Erreur : La colonne 'observed_scientific_name' est absente de 'lep'.")
  }
  
  if (!"observed_scientific_name" %in% colnames(taxonomie)) {
    stop("Erreur : La colonne 'observed_scientific_name' est absente du fichier taxonomie.")
  }
  # Vérifier si chaque valeur de "observed_scientific_name" est dans la liste des noms valides
  valid_lep_names <- lep$observed_scientific_name %in% taxonomie$observed_scientific_name
  
  # Extraire les noms invalides
  invalid_names <- lep[!valid_lep_names, ]
  
  # Afficher les noms invalides (s'il y en a)
  if (nrow(invalid_names) > 0) {
    View(invalid_names)
    message("Il y a des noms invalides.")
  } else {
    message("Tous les noms sont valides.")
  }
  # Retourner la liste des noms invalides
  return(invalid_names)
}

#4
uniformiser_val_nul <- function(dataframe, colonne) {
  # Vérifier combien de time_obs sont vides ou égaux à "00:00:00"
  time_obs_vide_ou_0 <- subset(dataframe, dataframe[[colonne]] == "" | dataframe[[colonne]] == "00:00:00")
  message(paste("Nombre de valeurs remplacées par NA qui étaient vides ou égales à '00:00:00' dans", colonne, ":", nrow(time_obs_vide_ou_0)))
  
  # Remplacer ces valeurs par NA dans la colonne spécifiée
  dataframe[[colonne]][dataframe[[colonne]] == "" | dataframe[[colonne]] == "00:00:00"] <- NA
  
  # Retourner le dataframe modifié
  return(dataframe)
}


#5
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


#6
uniformiser_obs_variable <- function(dataframe) {
  
  # Appliquer les transformations sur obs_variable en changeant "ocurrence" par "presence" (considérant que ces valeurs signifient la même chose) et en changeant "pr@#sence (écris ainsi en 2012) par "presence"
  dataframe <- dataframe %>%
    mutate(obs_variable = recode(obs_variable, 
                                 "occurrence" = "presence",
                                 "pr@#sence" = "presence"))
  # Retourner le dataframe modifié
  return(dataframe)
}

#7
renommer_col_day_obs_en_month <- function(fleur){
  fleur %>%
    rename("month_obs"="day_obs")
}


#8
retirer_colonne_na <- function(dataframe, colonne) {
  # Vérifier si la colonne existe dans le dataframe
  library(dplyr )
  if(colonne %in% colnames(dataframe)) {
    # Vérifier si la colonne contient uniquement des NA
    if(all(is.na(dataframe[[colonne]]))) {
      # Retirer la colonne si elle contient uniquement des NA
      dataframe[, (colonne) := NULL]  # Syntaxe data.table pour supprimer une colonne
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


#9
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

