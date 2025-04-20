#Figure nb sp par latitude au qbc
barplot(
  nb_especes_par_lat$nb_especes,
  names.arg = nb_especes_par_lat$classe_latitude,
  col = "skyblue",
  main = "Nombre d'espèces par classe de latitude au Québec",
  xlab = "Classe de latitude",
  ylab = "Nombre d'espèces",
  las = 1
)