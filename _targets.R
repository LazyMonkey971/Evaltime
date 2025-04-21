library(targets)

source(file.path("fonctions_libidoptères", "Fonctions.R"))
taxonomie <- read.csv("taxonomie.csv")

tar_option_set(packages = c(
  "ggplot2",
  "leaflet",
  "dplyr",
  "data.table",
  "RSQLite"
))

list(
  tar_target(data, data_base()),
  tar_target(donnees_brutes, fusion_csv_lep(data)),
  tar_target(invalid_names, verify_lep_names(donnees_brutes, taxonomie)),
  tar_target(donnees_unif, uniformiser_val_nul(donnees_brutes, "time_obs")),
  tar_target(donnees_plus_unif, uniformiser_val_nul(donnees_unif, "license")),
  tar_target(donnees_pars_dheure, retirer_heure_dwc_event_date(donnees_plus_unif, "dwc_event_date")),
  tar_target(donnees_correction_obs, uniformiser_obs_variable(donnees_pas_dheure)),
  tar_target(correction_jour_mois, renommer_col_day_obs_en_month(donnees_correction_obs)),
  tar_target(donnees_moins_colonne_na, retirer_colonne_na(correction_jour_mois, "obs_unit")),
  tar_target(Donnees_propre, uniformiser_year_obs(donnees_moins_colonne_na, "year_obs")),
  tar_target(SQL, fct_table_sql(Donnees_propre, "lepidoptères"  ))
)
