#Figure Lignes par an


# Requête : afficher le nb d'obs par an au quebec
sql_requete_1 <- 
  "SELECT dates.year_obs, COUNT(observations.id_obs) AS nb_obs
FROM observations
WHERE observations.id_obs = dates.id_obs
AND lat >= 44 AND lat <= 66
AND lon >= -80 AND lon <= -57
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
