#Projet BIO500
#Jeu de données: lépidoptères
#Question de recherche: comment les variations spatiales et temporelles influent-elles sur la structure des communautés? 

library(ggplot2)

#Script principal - Appel des fonctions

# Après avoir définir le dossier contenant les scripts, les fonctions peuvent être chargées:
data <- list.files(path = "Libidoptères",pattern = "*.csv", full.names = TRUE, include.dirs = TRUE)

# 1. Fusionner tous les fichiers CSV de lépidoptères en un gros data frame (lep)
source("fonctions_libidoptères/fct_fusion_csv_lep.R")
lep <- fusion_csv_lep(data)


# 2. Pour la colonne "observed_scientific_name", vérifier que les noms scientifiques sont correctement écrits et valides
source("fonctions_libidoptères/fct_verify_lep_names.R")
taxonomie <- read.csv("taxonomie.csv")
invalid_names <- verify_lep_names(lep, taxonomie)


# 3. Pour la colonne "time_obs" et "license", uniformiser les valeurs (remplacer les valeurs vides ou inscrit 00:00:000 par NA)
source("fonctions_libidoptères/fct_uniformiser_val_nul.R")
lep <- uniformiser_val_nul(lep, "time_obs")
lep <- uniformiser_val_nul(lep, "license")

# 4. Pour la colonne "dwc_event_date", uniformiser les valeurs (retirer l'heure en supprimant ce qui suit le 'T')
source("fonctions_libidoptères/fct_retirer_heure_dwc_event_date.R")
lep <- retirer_heure_dwc_event_date(lep, "dwc_event_date")


# 5. Pour la colonne "obs_variable", vérifier et uniformiser les noms (changer "ocurrence" par "presence", considérant que ces valeurs signifient la même chose, et en changeant "pr@#sence (écris ainsi en 2012) par "presence")
source("fonctions_libidoptères/fct_uniformiser_obs_variable.R")
lep <- uniformiser_obs_variable(lep)
    # Vérification des valeurs uniques dans obs_variable
unique_values <- unique(lep$obs_variable)


# 6. Renommer le nom de la colonne day_obs pour qu'elle s'appelle month_obs 
source("fonctions_libidoptères/fct_renommer_col_day_obs-month.R")
lep <- renommer_col_day_obs_en_month(fleur=lep)

#7. Pour la colonne "obs_unit", la supprimer (car ce ne sont que des NA)
source("fonctions_libidoptères/fct_retire_colonne_na.R")
lep <- retirer_colonne_na(lep, "obs_unit")

# 8. Pour la colonne "year_obs", uniformiser les valeurs (retirer l'heure en supprimant ce qui suit le 'T' et convertir les valeurs YYYY-MM-DD en YYYY)
source("fonctions_libidoptères/fct_uniformiser_year_obs.R")
lep <- uniformiser_year_obs(lep, "year_obs")

#9. (creation des tables sql (observations, dates et source)
source("fonctions_libidoptères/fct_table_sql.R")

View(lep)

# Avoit fait rouler les scripts de nettoyage de données pour avoir le df lep
# Mettre working directory sur données nettoyées
# Créer des tables et établir des relations (CREATE TABLE).


#Exemples de requêtes:

# Requête : afficher le nb d'obs par an au quebec
sql_requete_1 <- 
"SELECT dates.year_obs, COUNT(observations.id_obs) AS nb_obs
FROM observations, dates
WHERE observations.id_obs = dates.id_obs
AND lat >= 44 AND lat <= 66
AND lon >= -80 AND lon <= -57
GROUP BY dates.year_obs
ORDER BY year_obs"

lignes_par_an <- dbGetQuery(connect, sql_requete_1)
print(lignes_par_an)

# Requête : afficher le nb d'sp par an au quebec 
# Afin de sélectionner seulement les obs dont l'identification va jusqua l'espèce (et non les genres), on met  LIKE '% %' (on garde les noms scientifiques qui contiennent un espace)  

sql_requete_2 <- 
"SELECT dates.year_obs, COUNT(DISTINCT observations.observed_scientific_name) AS nb_especes
FROM observations
JOIN dates ON observations.id_obs = dates.id_obs
WHERE observations.observed_scientific_name LIKE '% %' 
AND lat >= 44 AND lat <= 66
AND lon >= -80 AND lon <= -57
GROUP BY dates.year_obs
ORDER BY dates.year_obs;"

nb_sp_par_an <- dbGetQuery(connect, sql_requete_2)
print(nb_sp_par_an)


# Requête : afficher le nb de genre par an 
sql_requete_3 <- 
"SELECT dates.year_obs,COUNT(DISTINCT SUBSTR(observations.observed_scientific_name, 1, INSTR(observations.observed_scientific_name, ' ') - 1)) AS nb_genres
FROM observations
JOIN dates ON observations.id_obs = dates.id_obs
WHERE INSTR(observations.observed_scientific_name, ' ') > 0
AND lat >= 44 AND lat <= 66
AND lon >= -80 AND lon <= -57
GROUP BY dates.year_obs
ORDER BY dates.year_obs;"

nb_genre_par_an <- dbGetQuery(connect, sql_requete_3)
print(nb_genre_par_an)

# Requête : nb obs sur une carte
sql_requete_4 <- 
"SELECT lat, lon, COUNT(DISTINCT observed_scientific_name) AS nb_especes
FROM observations
WHERE lat >= 44 AND lat <= 66
  AND lon >= -80 AND lon <= -57
GROUP BY lat, lon
"
obs_geo<- dbGetQuery(connect, sql_requete_4)
print(obs_geo)

# Requête pour le nombre d'espèce éteinte/plus observés
babybel <- "
SELECT 
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
  WHERE 
    o.lat BETWEEN 44 AND 66 AND
    o.lon BETWEEN -80 AND -57
  GROUP BY 
    o.observed_scientific_name
  HAVING 
    derniere_annee < 2020
)
GROUP BY 
  decennie
ORDER BY 
  decennie ASC;"


extinction <- dbGetQuery(connect,babybel)

# Mettre la figure dans une function 
#Sourcer cette function içi
source("fonctions_libidoptères/Figure_extinction.R")
tracer_dernières_observations(extinction)

# Requête pour voir les premières observations de chaque espèce
cheddar <- "
SELECT 
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
  WHERE 
    o.lat BETWEEN 44 AND 66 AND
    o.lon BETWEEN -80 AND -57
  GROUP BY 
    o.observed_scientific_name
)
GROUP BY 
  decennie
ORDER BY 
  decennie ASC;"

premiere_observation <- dbGetQuery(connect, cheddar)

#Sourcer cette function içi
source("fonctions_libidoptères/Figure_premieres_observations.R")
tracer_premieres_observations(premiere_observation)

# Requête : afficher le nb d'sp sur une carte

# Autres idées de requêtes à faire éventuellement 
# Requête : afficher le nb d'sp par an
# Requête : afficher toutes les sp
# Requête: afficher le nb d'individus par an
# Requête: afficher le nb de creator par an
# Requête : afficher le nb d'sp pour les latitudes élevées et faibles 
# Requête : est ce qu'il y a des espèces qui se sont éteinte?
# Requête : est ce qu'il y a de nouvelles espèces
# Requête : prendre une espèce à la fois et regarder comment elle varie 
# et après comparer toutes les obsservations entres elles

#Se déconnecter de la base de données
dbDisconnect(connect)


colnames(lep)

