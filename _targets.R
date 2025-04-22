library(targets)
library(tarchetypes)

source(file.path("fonctions_libidoptères", "Fonctions.R"))

taxonomie <- read.csv("taxonomie.csv")




tar_option_set(packages = c(
  "ggplot2",
  "leaflet",
  "dplyr",
  "data.table",
  "RSQLite",
  "DBI"
))


tar_plan(
  tar_target(data, data_base()),
  tar_target(donnees_brutes, fusion_csv_lep(data)),
  tar_target(invalid_names, verify_lep_names(donnees_brutes, taxonomie)),
  tar_target(donnees_unif, uniformiser_val_nul(donnees_brutes, "time_obs")),
  tar_target(donnees_plus_unif, uniformiser_val_nul(donnees_unif, "license")),
  tar_target(donnees_pas_dheure, retirer_heure_dwc_event_date(donnees_plus_unif, "dwc_event_date")),
  tar_target(donnees_correction_obs, uniformiser_obs_variable(donnees_pas_dheure)),
  tar_target(correction_jour_mois, renommer_col_day_obs_en_month(donnees_correction_obs)),
  tar_target(donnees_moins_colonne_na, retirer_colonne_na(correction_jour_mois, "obs_unit")),
  tar_target(Donnees_propre, uniformiser_year_obs(donnees_moins_colonne_na, "year_obs")),
  tar_target(bd_observations, bd_obs(Donnees_propre)),
  tar_target(bd_dates, bd_date(Donnees_propre)),
  tar_target(bd_sources, bd_source(Donnees_propre)),
  tar_target(req_1, requete1()),
  tar_target(req_2, requete2()),
  tar_target(req_3, requete3()),
  tar_target(req_4, requete4()),
  tar_target(req_5, requete5()),
  tar_target(req_6, requete6()),
  tar_target(pre_1, pre_figure(req_1)),
  tar_target(pre_2, pre_figure(req_2)),
  tar_target(pre_3, pre_figure(req_3)),
  tar_target(pre_4, pre_figure(req_4)),
  tar_target(pre_5, pre_figure(req_5)),
  tar_target(pre_6, pre_figure(req_6)),
  tar_target(figure_1, fct_nb_obs_qbc(pre_1)),
  tar_render(rmarkdown, path= "Rapport_libidoptères.Rmd", output_file = "rapport_libidotères")
)
  
