#Toutes les fonctions



#1 Fonction pour faire la liste de csv
data_base <- function(chemin) {
  list.files(chemin, pattern = "*.csv", full.names = TRUE, include.dirs = TRUE)
}


#2 Fonction pour fusionner tous les fichiers CSV de lépidoptères en un gros data frame

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

#3 Fonction pour la colonne "observed_scientific_name", vérifier que les noms scientifiques sont correctement écrits et valides

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

#4 Fonction pour la colonne "time_obs" et "license", uniformiser les valeurs (remplacer les valeurs vides ou inscrit 00:00:000 par NA)

uniformiser_val_nul <- function(dataframe, colonne) {
  # Vérifier combien de time_obs sont vides ou égaux à "00:00:00"
  time_obs_vide_ou_0 <- subset(dataframe, dataframe[[colonne]] == "" | dataframe[[colonne]] == "00:00:00")
  message(paste("Nombre de valeurs remplacées par NA qui étaient vides ou égales à '00:00:00' dans", colonne, ":", nrow(time_obs_vide_ou_0)))
  
  # Remplacer ces valeurs par NA dans la colonne spécifiée
  dataframe[[colonne]][dataframe[[colonne]] == "" | dataframe[[colonne]] == "00:00:00"] <- NA
  
  # Retourner le dataframe modifié
  return(dataframe)
}


#5 Fonction pour la colonne "dwc_event_date", uniformiser les valeurs (retirer l'heure en supprimant ce qui suit le 'T')

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


#6 Fonction pour la colonne "obs_variable", vérifier et uniformiser les noms (changer "ocurrence" par "presence", considérant que ces valeurs signifient la même chose, et en changeant "pr@#sence (écris ainsi en 2012) par "presence")

uniformiser_obs_variable <- function(dataframe) {
  
  # Appliquer les transformations sur obs_variable en changeant "ocurrence" par "presence" (considérant que ces valeurs signifient la même chose) et en changeant "pr@#sence (écris ainsi en 2012) par "presence"
  dataframe <- dataframe %>%
    mutate(obs_variable = recode(obs_variable, 
                                 "occurrence" = "presence",
                                 "pr@#sence" = "presence"))
  # Retourner le dataframe modifié
  return(dataframe)
}

#7 Renommer le nom de la colonne day_obs pour qu'elle s'appelle month_obs

renommer_col_day_obs_en_month <- function(fleur){
  fleur %>%
    rename("month_obs"="day_obs")
}


#8 Pour la colonne "obs_unit", la supprimer (car ce ne sont que des NA)

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


#9 Pour la colonne "year_obs", uniformiser les valeurs (retirer l'heure en supprimant ce qui suit le 'T' et convertir les valeurs YYYY-MM-DD en YYYY)

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

#10 Fonction pour effacer les tables de la db SQL afin de permettre aux autres étapes de fonctionner

efface_lep <- function() {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  dbSendQuery(connect, "DROP TABLE sources")
  dbSendQuery(connect, "DROP TABLE observations")
  dbSendQuery(connect, "DROP TABLE dates")
  
  dbDisconnect(connect)
  
}


#11 Fonction pour créer les tables SQL et préparer les données pour la figure 1

pre_figure_1 <- function(data) {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  creer_observations <- "
  CREATE TABLE observations (
  id_obs                    INTEGER PRIMARY KEY AUTOINCREMENT,
  observed_scientific_name  TEXT,
  dwc_event_date            DATE,
  obs_variable              VARCHAR (20),
  creator                   VARCHAR (150),
  lat                       REAL,
  lon                       REAL
  );"
  
  RSQLite::dbSendQuery(connect,creer_observations) 
  
  base_obs <- as.data.frame(data[, c("observed_scientific_name","dwc_event_date","obs_variable","creator","lat","lon")])
  
  #Injection des données
  dbWriteTable(connect, append = TRUE, name = "observations", value = base_obs, row.names = FALSE)
  
  creer_date <-"
  CREATE TABLE dates (
  id_obs          INTEGER, 
  year_obs        INTEGER,
  month_obs         INTEGER,
  time_obs        TIME,
  dwc_event_date  DATE,
  PRIMARY KEY     (id_obs)
  FOREIGN KEY     (id_obs) REFERENCES observations(id_obs)
 );"
  
  RSQLite::dbSendQuery(connect,creer_date)
  
  base_date <- as.data.frame(data[, c("year_obs","month_obs","time_obs","dwc_event_date")])
  
  #Injection des données
  dbWriteTable(connect, append = TRUE, name = "dates", value = base_date, row.names = FALSE)
  
  creer_sources <- "
  CREATE TABLE sources (
  id_obs                INTEGER,
  original_source       VARCHAR(20),
  creator               VARCHAR(150),
  title                 VARCHAR(150),
  publisher             VARCHAR(100),
  intellectual_rights   VARCHAR(100),
  license               VARCHAR(20),
  owner                 VARCHAR(100),
  PRIMARY KEY           (id_obs)
  FOREIGN KEY           (id_obs) REFERENCES observations(id_obs)
  );"
  
  RSQLite::dbSendQuery(connect, creer_sources)
  
  base_source <- as.data.frame(data[,c("original_source","creator","title","publisher","intellectual_rights","license","owner")])
  
  #Injection des données
  dbWriteTable(connect, append = TRUE, name = "sources", value = base_source, row.names = FALSE)
  
  req <- "SELECT 
  (dates.year_obs / 10) * 10 AS decennie, COUNT(observations.id_obs) AS nb_observations
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY decennie
  ORDER BY decennie;"

  dbGetQuery(connect, req)
  
  dbDisconnect(connect)
  
}

#12 Fonction pour préparer les données pour la figure 2

pre_figure_2 <- function() {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  req <- "SELECT (dates.year_obs / 10) * 10 AS decennie, COUNT(DISTINCT observations.observed_scientific_name) AS nb_especes
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE observations.observed_scientific_name LIKE '% %'
    AND lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY decennie
  ORDER BY decennie;"

  dbGetQuery(connect, req)

  dbDisconnect(connect)
}

#13 Fonction pour préparer les données pour la figure 3

pre_figure_3 <- function() {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  req <- "SELECT lat, lon, COUNT(DISTINCT observed_scientific_name) AS nb_especes
  FROM observations
  WHERE lat >= 44 AND lat <= 66
  AND lon >= -80 AND lon <= -57
  GROUP BY lat, lon"

  dbGetQuery(connect, req)

  dbDisconnect(connect)
}

#14 Fonction pour préparer les données pour la figure 4

pre_figure_4 <- function() {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  req <- "SELECT 
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

  dbGetQuery(connect, req)
  
  dbDisconnect(connect)
}

#15 Fonction pour préparer les données pour la figure 5

pre_figure_5 <- function() {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
  
  req <- "SELECT 
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

  dbGetQuery(connect, req)
  
  dbDisconnect(connect)
}

#16 Fonction pour préparer les données pour la figure 6

pre_figure_6 <- function() {
  
  connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")
 
  req <- "SELECT 
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
  
  dbGetQuery(connect, req)
  
  dbDisconnect(connect)
}

#17 Fonction pour créer la figure 1

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

#18 Fonction pour créer la figure 2

fct_voir_sp_par_decennie <- function(data, color = "orange", title = "Nombre d'espèces observées par décennie au Québec") {
  barplot(
    data$nb_especes,
    names.arg = data$decennie,
    col = color,
    main = title,
    xlab = "Décennie",
    ylab = "Nombre d'espèces"
  )
}


#19 Fonction pour créer la figure 3

fct_voir_obs_carte <- function(data, lng_center, lat_center, zoom_level) {
  leaflet(data) %>%
    addProviderTiles(providers$Esri.WorldTerrain) %>%
    addCircleMarkers(
      lng = ~lon,
      lat = ~lat,
      radius = 1,
      color = "red",
      stroke = FALSE,
      fillOpacity = 0.5
    ) %>%
    setView(lng = lng_center, lat = lat_center, zoom = zoom_level) %>%
    addLegend(
      position = "bottomright",
      colors = "red",
      labels = "Observation reportée",
      title = "Légende",
      opacity = 0.7
    )
}

#20 Fonction pour créer la figure 4

fct_fig_nb_sp_lat <- function(data) {
  barplot(
    data$nb_especes,
    names.arg = data$classe_latitude,
    col = "skyblue",
    main = "Nombre d'espèces par classe de latitude au Québec",
    xlab = "Classe de latitude",
    ylab = "Nombre d'espèces",
    las = 1
  )
}


#21 Fonction pour créer la figure 5

tracer_dernières_observations <- function (cheese){
  # Définir les couleurs et marges
  bar_colors <- "#E4572E"
  par(mar = c(5, 5, 4, 2))  # marges : bas, gauche, haut, droite
  
  # Créer le graphique
  barplot(height = cheese$nb_extinctions,
          names.arg = cheese$decennie,
          col = bar_colors,
          border = NA,
          space = 0.3,
          main = "Nombre d'espèces de papillons non réobservées par décennie",
          xlab = "Décennie",
          ylab = "Nombre d'espèces",
          cex.main = 1.2,
          cex.axis = 0.9,
          cex.lab = 1.1,
          las = 2)  # pour faire pivoter les étiquettes de l'axe x
}

#22 Fonction pour créer la figure 6

tracer_premieres_observations <- function(fromage) {
  # Définir les couleurs et marges
  bar_colors <- "#4C78A8"
  par(mar = c(5, 5, 4, 2))  # marges : bas, gauche, haut, droite
  
  # Créer le graphique en barres
  barplot(height = fromage$nb_premieres_observations,
          names.arg = fromage$decennie,
          col = bar_colors,
          border = NA,
          space = 0.3,
          main = "Nombre d'espèces de papillons observées pour la première fois par décennie",
          xlab = "Décennie",
          ylab = "Nombre d'espèces",
          cex.main = 1.2,
          cex.axis = 0.9,
          cex.lab = 1.1,
          las = 2)  # fait pivoter les étiquettes de l'axe x
}