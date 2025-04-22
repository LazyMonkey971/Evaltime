# Fct figure nb obs qbc par décennie
fct_nb_obs_qbc <- function(data) {
  options(scipen = 999)
  par(mgp = c(4, 1, 0))
  barplot(
    height = data$nb_observations,
    names.arg = data$decennie,
    col = "lightblue",
    main = "Nombre d'observations par décennie au Québec",
    xlab = "Décennie",
    ylab = "Nombre d'observations",
    las = 1
  )
}
