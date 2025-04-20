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

# Requête : afficher le nb de lignes par an 

sql_requete_1 <- 
"SELECT dates.year_obs, COUNT(observations.id_obs) AS nb_obs
FROM observations, dates
WHERE observations.id_obs = dates.id_obs
GROUP BY dates.year_obs
ORDER BY year_obs"

lignes_par_an <- dbGetQuery(connect, sql_requete_1)
print(lignes_par_an)

# Graphique requete 1
ggplot(lignes_par_an, aes(x = year_obs, y = nb_obs)) +
  geom_line(color = "darkblue", size = 1.2) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "Nombre d'observations par année",
    x = "Année",
    y = "Nombre d'observations"
  ) +
  theme_minimal()

# Requête : afficher le nb d'sp par an (where veut dire:on garde les noms scientifiques qui contiennent un espace, car certaines obs ont juste le genre)
# Afin de sélectionner seulement les obs dont l'identification va jusqua l'espèce (et non les genres), on met  LIKE '% %' 
sql_requete_2 <- 
"SELECT dates.year_obs, COUNT(DISTINCT observations.observed_scientific_name) AS nb_especes
FROM observations
JOIN dates ON observations.id_obs = dates.id_obs
WHERE observations.observed_scientific_name LIKE '% %'
GROUP BY dates.year_obs
ORDER BY dates.year_obs;"

nb_sp_par_an <- dbGetQuery(connect, sql_requete_2)
print(nb_sp_par_an)

<<<<<<< HEAD
# Graphique requete 2
library(ggplot2)
=======
>>>>>>> 34f2e7e1a2dcec6856a556c1f86329fcd5939306

ggplot(nb_sp_par_an, aes(x = year_obs, y = nb_especes)) +
  geom_line(color = "darkblue", size = 1.2) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "Nombre d'espèces observées par année",
    x = "Année",
    y = "Nombre d'espèces"
  ) +
  theme_minimal()

# Requête : afficher le nb de genre par an 
sql_requete_3 <- 
"SELECT dates.year_obs,COUNT(DISTINCT SUBSTR(observations.observed_scientific_name, 1, INSTR(observations.observed_scientific_name, ' ') - 1)) AS nb_genus
FROM observations
JOIN dates ON observations.id_obs = dates.id_obs
WHERE INSTR(observations.observed_scientific_name, ' ') > 0
GROUP BY dates.year_obs
ORDER BY dates.year_obs;"

nb_genre_par_an <- dbGetQuery(connect, sql_requete_3)
print(nb_genre_par_an)

# Graphique requete 3
ggplot(nb_genre_par_an, aes(x = year_obs, y = nb_genus)) +
  geom_line(color = "steelblue", size = 1.2) +  # Ligne bleue claire
  geom_point(color = "steelblue", size = 3) +   # Points bleus
  labs(
    title = "Nombre de Genres Observés Par Année",
    x = "Année",
    y = "Nombre de Genres"
  ) +
  theme_minimal()

# Requête : nb sp par latitude
sql_requete_4 <- 
"SELECT lat, COUNT(DISTINCT observed_scientific_name) AS nb_especes
FROM lep
GROUP BY lat
ORDER BY lat;"

# Requête : afficher le nb d'sp pour les latitudes élevées 

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

