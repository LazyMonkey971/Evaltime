#Figure nb sp par latitude au qbc

fct_fig_nb_sp_lat <- function(data) {
  barplot(
    data$nb_especes,
    names.arg = data$classe_latitude,
    col = "skyblue",
    main = "Nombre d'espèces par classe de latitude au Québec",
    xlab = "Classe de latitude",
    ylab = "Nombre d'espèces",
    las = 1
  )
}
