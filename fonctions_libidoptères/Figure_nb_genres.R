#figure nb genres

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