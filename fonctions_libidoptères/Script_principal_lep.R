#Projet BIO500
#Jeu de données: lépidoptères
#Par Maxence Comyn, Félix Laberge, Julianne Lemay-St-Laurent et Elsa Michel

#Question de recherche: comment les variations spatiales et temporelles influent-elles sur la structure des communautés? 

#------------libraries à télécharger:----------------------------
library(ggplot2)
library(leaflet)
#------------Script principal - Appel des fonctions--------------

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

#-------------------------- REQUÊTES--------------------------------

# Requête 1: nombre d'observations par decennie au Québec 
sql_nb_obs_par_decennie <- 
  "SELECT 
  (dates.year_obs / 10) * 10 AS decennie, COUNT(observations.id_obs) AS nb_observations
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY decennie
  ORDER BY decennie;"

nb_obs_par_decennie <- dbGetQuery(connect, sql_nb_obs_par_decennie)
print(nb_obs_par_decennie)

source("fonctions_libidoptères/Figure_nb_obs_decennie.R")
fct_nb_obs_qbc(nb_obs_par_decennie)

# Requête 2 : nombre d'espèces observée par année au Québec 
## Afin de sélectionner seulement les obs dont l'identification va jusqu'a l'espèce (et non les genres), utiliser  LIKE '% %' (on garde les noms scientifiques qui contiennent un espace)  

sql_nb_sp_par_an <- 
  "SELECT dates.year_obs, COUNT(DISTINCT observations.observed_scientific_name) AS nb_especes
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE observations.observed_scientific_name LIKE '% %' 
    AND lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY dates.year_obs
  ORDER BY dates.year_obs;"

nb_sp_par_an <- dbGetQuery(connect, sql_nb_sp_par_an)
print(nb_sp_par_an)

# Requête 2.0 : nombre d'espèces observée par décennie au Québec 
## Afin de sélectionner seulement les obs dont l'identification va jusqu'a l'espèce (et non les genres), utiliser  LIKE '% %' (on garde les noms scientifiques qui contiennent un espace)  

sql_nb_sp_par_decennie <- 
  "SELECT (dates.year_obs / 10) * 10 AS decennie, COUNT(DISTINCT observations.observed_scientific_name) AS nb_especes
  FROM observations
  JOIN dates ON observations.id_obs = dates.id_obs
  WHERE observations.observed_scientific_name LIKE '% %'
    AND lat >= 44 AND lat <= 66
    AND lon >= -80 AND lon <= -57
  GROUP BY decennie
  ORDER BY decennie;"

nb_sp_par_decennie <- dbGetQuery(connect, sql_nb_sp_par_decennie)
print(nb_sp_par_decennie)

# Requête 3 : carte visualisant les observations d'un point de vue géographique
sql_obs_carte <- 
 "SELECT lat, lon, COUNT(DISTINCT observed_scientific_name) AS nb_especes
  FROM observations
  WHERE lat >= 44 AND lat <= 66
  AND lon >= -80 AND lon <= -57
  GROUP BY lat, lon"

obs_geo<- dbGetQuery(connect, sql_obs_carte)
print(obs_geo)

source("fonctions_libidoptères/Figure_nb_obs_decennie.R")
fct_voir_obs_carte(obs_geo)

# Requête 4 : nombre d'espèces selon différentes latitudes au Québec: 44 à 49.5, 49.5 à 55, 55 à 60.5, 60.5 à 66
sql_nb_sp_lat <- 
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

nb_sp_lat <- dbGetQuery(connect, sql_nb_sp_lat)
print(nb_sp_lat)

# Requête 5: nombre d'espèce éteintes/qui ne sont plus observés
babybel <- "SELECT 
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

source("fonctions_libidoptères/Figure_extinction.R")
tracer_dernières_observations(extinction)

# Requête 6: pour voir les premières observations de chaque espèce (en quelle année l'espèce a été observée pour la première fois)
cheddar <- "SELECT 
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

source("fonctions_libidoptères/Figure_premieres_observations.R")
tracer_premieres_observations(premiere_observation)

#Se déconnecter de la base de données
dbDisconnect(connect)



