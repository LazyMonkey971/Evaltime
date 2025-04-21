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

  
  
#10

bd_obs <- function(data) {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  #Créer les bases de données à injecter
  bd_observations <- as.data.frame(data[, c("observed_scientific_name","dwc_event_date","obs_variable","creator","lat","lon")])
  
  #Injection des données
  dbWriteTable(connect, append = TRUE, name = "observations", value = bd_observations, row.names = FALSE)
}  


#11

bd_date <- function(data) {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  #Créer les bases de données à injecter
  bd_dates <- as.data.frame(data[, c("year_obs","month_obs","time_obs","dwc_event_date")])
  
  #Injection des données
  dbWriteTable(connect, append = TRUE, name = "dates", value = bd_dates, row.names = FALSE)
  
  
}

#12

bd_source <- function(data) {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  #Créer les bases de données à injecter
  bd_sources <- as.data.frame(data[,c("original_source","creator","title","publisher","intellectual_rights","license","owner")])
  
  #Injection des données
  dbWriteTable(connect, append = TRUE, name = "sources", value = bd_sources, row.names = FALSE)
  
}

#13

requete1 <- function() {
   
    "SELECT 
  (dates.year_obs / 10) * 10 AS decennie, COUNT(observations.id_obs) AS nb_observations
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY decennie
  ORDER BY decennie;"
}

#14

requete2 <- function() {
  
    "SELECT (dates.year_obs / 10) * 10 AS decennie, COUNT(DISTINCT observations.observed_scientific_name) AS nb_especes
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE observations.observed_scientific_name LIKE '% %'
    AND lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY decennie
  ORDER BY decennie;"
  
}


#15 

requete3 <- function() {
  
    "SELECT lat, lon, COUNT(DISTINCT observed_scientific_name) AS nb_especes
  FROM observations
  WHERE lat >= 44 AND lat <= 66
  AND lon >= -80 AND lon <= -57
  GROUP BY lat, lon"
  
}


#16

requete4 <- function() { 
  
    "SELECT 
  CASE 
    WHEN lat >= 44 AND lat < 49.5 THEN '[44, 49.5['
    WHEN lat >= 49.5 AND lat < 55 THEN '[49.5, 55['
    WHEN lat >= 55 AND lat < 60.5 THEN '[55, 60.5['
    WHEN lat >= 60.5 AND lat <= 66 THEN '[60.5, 66]'
    ELSE 'hors_zone'
  END AS classe_latitude,
  COUNT(DISTINCT observed_scientific_name) AS nb_especes
  FROM observations
  WHERE lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY classe_latitude
  ORDER BY classe_latitude;"
  
}


#17

requete5 <- function() {
  
  "SELECT 
  (derniere_annee / 10) * 10 AS decennie,
  COUNT(*) AS nb_extinctions
  FROM (
  SELECT 
    o.observed_scientific_name,
    MAX(d.year_obs) AS derniere_annee
  FROM 
    observations o
  JOIN 
    dates d ON o.dwc_event_date = d.dwc_event_date
  WHERE lat >= 44 AND lat <= 66
  AND lon >= -80 AND lon <= -57
  GROUP BY 
    o.observed_scientific_name
  HAVING 
    derniere_annee < 2020
)
GROUP BY 
  decennie
ORDER BY 
  decennie ASC;"
}

#18

requete6 <- function() {
  
  "SELECT 
  (premiere_annee / 10) * 10 AS decennie,
  COUNT(*) AS nb_premieres_observations
FROM (
  SELECT 
    o.observed_scientific_name,
    MIN(d.year_obs) AS premiere_annee
  FROM 
    observations o
  JOIN 
    dates d ON o.dwc_event_date = d.dwc_event_date
  WHERE lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY 
    o.observed_scientific_name
)
GROUP BY 
  decennie
ORDER BY 
  decennie ASC;"
}


#19

pre_figure <- function(requete) {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  dbGetQuery(connect, requete)
}

#20

fct_nb_obs_qbc <- function(data) {
  barplot(
    height = data$nb_observations,
    names.arg = data$decennie,
    col = "lightblue",
    main = "Nombre d'observations par décennie au Québec",
    xlab = "Décennie",
    ylab = "Nombre d'observations"
  )
}