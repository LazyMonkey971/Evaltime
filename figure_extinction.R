extinction <- dbGetQuery(connect,babybel)

install.packages("ggplot2")
library(ggplot2)

ggplot(extinction, aes(x = decennie, y = nb_extinctions)) +
  geom_col(fill = "#E4572E", width = 8) +  # couleur et largeur sympa
   labs(
    title = "Nombre d'espèces de papillons non réobservées par décennie",
    x = "Décennie",
    y = "Nombre d'espèces"
  ) +
  scale_x_continuous(breaks = seq(min(extinction$decennie),
                                  max(extinction$decennie), by = 10)) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

