# Fonction pour vérifier et uniformiser les noms de la colonne "obs_variable"
# Nom de la fonction: uniformiser_obs_variable 
library(dplyr)

uniformiser_obs_variable <- function(dataframe) {
 
  # Appliquer les transformations sur obs_variable en changeant "ocurrence" par "presence" (considérant que ces valeurs signifient la même chose) et en changeant "pr@#sence (écris ainsi en 2012) par "presence"
   dataframe <- dataframe %>%
    mutate(obs_variable = recode(obs_variable, 
                                 "occurrence" = "presence",
                                 "pr@#sence" = "presence"))
  # Retourner le dataframe modifié
  return(dataframe)
}


