# Figure nb obs qbc par décennie

barplot(
  nb_obs_par_decennie$nb_observations,
  names.arg = nb_obs_par_decennie$decennie,
  col = "lightblue",
  main = "Nombre d'observations par décennie au Québec",
  xlab = "Décennie",
  ylab = "Nombre d'observations"
)