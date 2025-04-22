library(targets)
library(tarchetypes)

#Trucs à avoir avant le pipeline
source(file.path("fonctions_libidoptères", "Fonctions.R"))
taxonomie <- read.csv("taxonomie.csv")


#Package utile

tar_option_set(packages = c(
  "ggplot2",
  "leaflet",
  "dplyr",
  "data.table",
  "RSQLite",
  "DBI"
))


<<<<<<< HEAD
#Pipeline

list(
  tar_target(     #Créer une dépendance aux données
    name = path,
    command = "./Libidoptères",
    format = "file"
  ),
  
  tar_target(name = data,                #Créer la liste de csv
             command = data_base(path)),
  
  tar_target(name = donnees_brutes,          #Créer la base de données brutes
             command = fusion_csv_lep(data)),
  
  tar_target(name = invalid_names,                                  #Vérifier s'il y a des noms invalides
             command = verify_lep_names(donnees_brutes, taxonomie)), 
  
  tar_target(name = donnees_unif,                                       #Uniformiser la colonne time_obs
             command = uniformiser_val_nul(donnees_brutes, "time_obs")), 
  
  tar_target(name = donnees_plus_unif,                               #Uniformiser la colonne license
             command = uniformiser_val_nul(donnees_unif, "license")),

  tar_target(name = donnees_pas_dheure,                                                    #Retirer les heure d'observations
             command = retirer_heure_dwc_event_date(donnees_plus_unif, "dwc_event_date")),

  tar_target(name = donnees_correction_obs,                              #Uniformiser la variable observation
             command = uniformiser_obs_variable(donnees_pas_dheure)),
 
  tar_target(name = correction_jour_mois,                                      #Corriger le titre de colonne day_obs en month_obs
             command = renommer_col_day_obs_en_month(donnees_correction_obs)),

  tar_target(name = donnees_moins_colonne_na,                                  #Retirer la colonne de NA
             command = retirer_colonne_na(correction_jour_mois, "obs_unit")),

  tar_target(name = Donnees_propre,                                                #Uniformiser la colonne year_obs
             command = uniformiser_year_obs(donnees_moins_colonne_na, "year_obs")),

  #Jusqu'ici, tout va bien, par contre, ça par en vrille maintenant
  
  
  tar_force(name = efface,                            #Effacer le dossier libidopteres.db s'il existe déjà
            command = efface_lep(), force = TRUE),

  tar_target(name = pre_1,                            #Préparer les données pour les figures en général et plus particulièrement la première
             command = pre_figure_1(Donnees_propre)),

  tar_target(name = pre_2,              #Préparer les données pour la figure 2
             command = pre_figure_2()),
  
  tar_target(name = pre_3,               #Préparer les données pour la figure 3
             command = pre_figure_3()), 
  
  tar_target(name = pre_4,               #Préparer les données pour la figure 4
             command = pre_figure_4()),
  
  tar_target(name = pre_5,               #Préparer les données pour la figure 5
             command = pre_figure_5()),
  
  tar_target(name = pre_6,               #Préparer les données pour la figure 6
             command = pre_figure_6()),
  
  tar_target(name = figure_1,                   #Faire la figure 1
             command = fct_nb_obs_qbc(pre_1)),
  
  tar_target(name = figure_2,                    #Faire la figure 2
             command = fct_voir_sp_par_decennie(pre_2)),
  
  tar_target(name = figure_3,                    #Faire la figure 3
             command = fct_voir_obs_carte(pre_3, -70, 54, 4)),
  
  tar_target(name = figure_4,                    #Faire la figure 4
             command = fct_fig_nb_sp_lat(pre_4)),
  
  tar_target(name = figure_5,                    #Faire la figure 5
             command = tracer_dernières_observations(pre_5)),
  
  tar_target(name = figure_6,                    #Faire la figure 6
             command = tracer_premieres_observations(pre_6)),
  
  tarchetypes::tar_render(name = Projet,        #Render le tout dans un markdown
                          path = "Rapport.Rmd")

  )
=======
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
  
>>>>>>> b752218fc7e0e5cb37f1f3934dfd4472f1261b55
