#Figure_nb_sp obs par an


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
# Graphique requete 2
library(ggplot2)

ggplot(nb_sp_par_an, aes(x = year_obs, y = nb_especes)) +
  geom_line(color = "darkblue", size = 1.2) +
  geom_point(color = "steelblue", size = 3) +
  labs(
    title = "Nombre d'espèces observées par année",
    x = "Année",
    y = "Nombre d'espèces"
  ) +
  theme_minimal()
