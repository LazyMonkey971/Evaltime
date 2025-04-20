#Figure Lignes par an

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
