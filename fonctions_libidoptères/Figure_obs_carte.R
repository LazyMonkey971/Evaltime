#figure positionnant les obs

obs_geo<- dbGetQuery(connect, sql_requete_4)
print(obs_geo)

install.packages("leaflet")  # si ce n’est pas encore fait
library(leaflet)

leaflet(data = obs_geo) %>%
  addProviderTiles(providers$Esri.WorldTerrain) %>%  # Utilisation de la carte terrain
  addCircleMarkers(
    lng = ~lon,
    lat = ~lat,
    radius = 1,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.5
  ) %>%
  setView(lng = -80, lat = 50, zoom = 4)  # Centré sur le Québec