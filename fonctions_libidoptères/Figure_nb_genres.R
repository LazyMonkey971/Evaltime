#figure nb genres


# Requête : afficher le nb de genre par an 
sql_requete_3 <- 
  "SELECT dates.year_obs,COUNT(DISTINCT SUBSTR(observations.observed_scientific_name, 1, INSTR(observations.observed_scientific_name, ' ') - 1)) AS nb_genres
FROM observations
JOIN dates ON observations.id_obs = dates.id_obs
WHERE INSTR(observations.observed_scientific_name, ' ') > 0
AND lat >= 44 AND lat <= 66
AND lon >= -80 AND lon <= -57
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