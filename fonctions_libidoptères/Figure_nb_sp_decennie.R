#Figure nombre d'espèces observée par décennie au Québec 

fct_voir_sp_par_decennie <- function(data, color = "orange", title = "Nombre d'espèces observées par décennie au Québec") {
  barplot(
    data$nb_especes,
    names.arg = data$decennie,
    col = color,
    main = title,
    xlab = "Décennie",
    ylab = "Nombre d'espèces"
  )
}