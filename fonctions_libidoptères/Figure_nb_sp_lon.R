#Figure nb sp par longitude au qbc

barplot(
  nb_especes_par_lon$nb_especes,
  names.arg = nb_especes_par_lon$classe_longitude,
  col = "lightgreen",
  main = "Nombre d'espèces par classe de longitude au Québec",
  xlab = "Classe de longitude",
  ylab = "Nombre d'espèces",
  las = 0  # Rotation des labels de l'axe X pour meilleure lisibilité
)