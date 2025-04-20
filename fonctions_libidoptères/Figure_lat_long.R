#figure positionnant les obs

obs_geo<- dbGetQuery(connect, sql_requete_4)
print(obs_geo)

install.packages("leaflet")  # si ce n’est pas encore fait
library(leaflet)

leaflet(data = obs_geo) %>%
  addTiles() %>%  # Fond de carte OpenStreetMap (pas besoin d'API)
  addCircleMarkers(
    lng = ~lon,
    lat = ~lat,
    radius = 3,
    color = "red",
    stroke = FALSE,
    fillOpacity = 0.5
  ) %>%
  setView(lng = -71, lat = 52, zoom = 5)  # Centré sur le Québec

