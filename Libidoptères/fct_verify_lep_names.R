#Fonction qui valide que les noms de la colonne "observed_scientific_name" sont correctement écrits
#Nom de la fonction: verify_lep_names
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


