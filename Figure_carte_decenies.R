cheddar <- "
SELECT 
  o.lat,
  o.lon,
  d.year_obs,
  (d.year_obs / 10) * 10 AS decennie
FROM 
  observations o
JOIN 
  dates d ON o.dwc_event_date = d.dwc_event_date
WHERE 
  o.lat IS NOT NULL AND o.lon IS NOT NULL
"

carte_decennie <- dbGetQuery(connect, cheddar)

