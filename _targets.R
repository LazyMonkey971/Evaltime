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
  tar_target(lep, fusion_csv_lep(data)),
  tar_target(invalid_names, verify_lep_names(lep, taxonomie)),
  tar_target(lepi, uniformiser_val_nul(lep, "time_obs")),
  tar_target(lepid, uniformiser_val_nul(lepi, "license")),
  tar_target(lepido, retirer_heure_dwc_event_date(lepid, "dwc_event_date")),
  tar_target(lepidop, uniformiser_obs_variable(lepido)),
  tar_target(lepidopt, renommer_col_day_obs_en_month(lepidop)),
  tar_target(lepidopte, retirer_colonne_na(lepidopt, "obs_unit")),
  tar_target(lepidoptere, uniformiser_year_obs(lepidopte, "year_obs"))
)
