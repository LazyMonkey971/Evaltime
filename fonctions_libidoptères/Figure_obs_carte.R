#figure positionnant les obs

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
  setView(lng = -70, lat = 54, zoom = 4)  # Centré sur le Québec