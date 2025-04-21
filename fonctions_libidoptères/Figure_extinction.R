tracer_dernières_observations <- function (cheese){
  # Définir les couleurs et marges
  bar_colors <- "#E4572E"
  par(mar = c(5, 5, 4, 2))  # marges : bas, gauche, haut, droite

  # Créer le graphique
  barplot(height = cheese$nb_extinctions,
         names.arg = cheese$decennie,
         col = bar_colors,
         border = NA,
         space = 0.3,
         main = "Nombre d'espèces de papillons observées pour la dernière fois par décennie",
         xlab = "Décennie",
         ylab = "Nombre d'espèces",
         cex.main = 1.2,
         cex.axis = 0.9,
         cex.lab = 1.1,
         las = 2)  # pour faire pivoter les étiquettes de l'axe x
}
