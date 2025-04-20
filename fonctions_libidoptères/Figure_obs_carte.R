#figure positionnant les obs

library(leaflet)

fct_voir_obs_carte <- function(data, lng_center = -70, lat_center = 54, zoom_level = 4) {
  leaflet(data) %>%
    addProviderTiles(providers$Esri.WorldTerrain) %>%
    addCircleMarkers(
      lng = ~lon,
      lat = ~lat,
      radius = 1,
      color = "red",
      stroke = FALSE,
      fillOpacity = 0.5
    ) %>%
    setView(lng = lng_center, lat = lat_center, zoom = zoom_level) %>%
    addLegend(
      position = "bottomright",
      colors = "red",
      labels = "Observation reportée",
      title = "Légende",
      opacity = 0.7
    )
}
