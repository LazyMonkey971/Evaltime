tracer_premieres_observations <- function(fromage) {
  # Définir les couleurs et marges
  bar_colors <- "#4C78A8"
  par(mar = c(5, 5, 4, 2))  # marges : bas, gauche, haut, droite
  
  # Créer le graphique en barres
  barplot(height = fromage$nb_premieres_observations,
          names.arg = fromage$decennie,
          col = bar_colors,
          border = NA,
          space = 0.3,
          main = "Nombre d'espèces de papillons observées pour la première fois par décennie",
          xlab = "Décennie",
          ylab = "Nombre d'espèces",
          cex.main = 1.2,
          cex.axis = 0.9,
          cex.lab = 1.1,
          las = 2)  # fait pivoter les étiquettes de l'axe x
}

