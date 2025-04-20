#Figure nb sp par longitude au qbc
# Requête 5 :  nombre d'espèces selon différentes longitudes au Québec:  -80 à -74.25, -74.25 à -68.5, -68.5 à -62.75, -62.75 à -57
sql_nb_sp_lon <- 
  "SELECT 
  CASE 
    WHEN lon >= -80 AND lon < -74.25 THEN '[-80, -74.25['
    WHEN lon >= -74.25 AND lon < -68.5 THEN '[-74.25, -68.5['
    WHEN lon >= -68.5 AND lon < -62.75 THEN '[-68.5, -62.75['
    WHEN lon >= -62.75 AND lon < -57 THEN '[-62.75, -57['
    ELSE 'hors_zone'
  END AS classe_longitude,
  COUNT(DISTINCT observed_scientific_name) AS nb_especes
FROM observations
WHERE lat >= 44 AND lat <= 66
  AND lon >= -80 AND lon <= -57
GROUP BY classe_longitude
ORDER BY classe_longitude;
"
nb_sp_lon <- dbGetQuery(connect, sql_nb_sp_lon)
print(nb_sp_lon)


barplot(
  nb_sp_lon$nb_especes,
  names.arg = nb_sp_lon$classe_longitude,
  col = "lightgreen",
  main = "Nombre d'espèces par classe de longitude au Québec",
  xlab = "Classe de longitude",
  ylab = "Nombre d'espèces",
  las = 0  # Rotation des labels de l'axe X pour meilleure lisibilité
)