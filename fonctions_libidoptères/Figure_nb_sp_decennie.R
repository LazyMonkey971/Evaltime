#Figure nombre d'espèces observée par décennie au Québec 

barplot(
  nb_sp_par_decennie$nb_especes,
  names.arg = nb_sp_par_decennie$decennie,
  col = "orange",
  main = "Nombre d'espèces observées par décennie au Québec",
  xlab = "Décennie",
  ylab = "Nombre d'espèces"
)

