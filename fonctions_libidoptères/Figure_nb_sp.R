#Figure_nb_sp

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
