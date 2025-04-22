#Ouvrir la connexion
connect <- dbConnect(SQLite(),dbname = "lepidopteres.db")

creer_observations <- "
  CREATE TABLE observations (
  id_obs                    INTEGER PRIMARY KEY AUTOINCREMENT,
  observed_scientific_name  TEXT,
  dwc_event_date            DATE,
  obs_variable              VARCHAR (20),
  creator                   VARCHAR (150),
  lat                       REAL,
  lon                       REAL
  );"

dbSendQuery(connect,creer_observations) 

creer_date <-"
  CREATE TABLE dates (
  id_obs          INTEGER, 
  year_obs        INTEGER,
  month_obs         INTEGER,
  time_obs        TIME,
  dwc_event_date  DATE,
  PRIMARY KEY     (id_obs)
  FOREIGN KEY     (id_obs) REFERENCES observations(id_obs)
);"

dbSendQuery(connect,creer_date)

creer_sources <- "
  CREATE TABLE sources (
  id_obs                INTEGER,
  original_source       VARCHAR(20),
  creator               VARCHAR(150),
  title                 VARCHAR(150),
  publisher             VARCHAR(100),
  intellectual_rights   VARCHAR(100),
  license               VARCHAR(20),
  owner                 VARCHAR(100),
  PRIMARY KEY           (id_obs)
  FOREIGN KEY           (id_obs) REFERENCES observations(id_obs)
  );"

dbSendQuery(connect, creer_sources)


#Créer les bases de données à injecter
bd_observations <- as.data.frame(lep[, c("observed_scientific_name","dwc_event_date","obs_variable","creator","lat","lon")])
bd_dates <- as.data.frame(lep[, c("year_obs","month_obs","time_obs","dwc_event_date")])
bd_sources <- as.data.frame(lep[,c("original_source","creator","title","publisher","intellectual_rights","license","owner")])

#Injection des données
dbWriteTable(connect, append = TRUE, name = "observations", value = bd_observations, row.names = FALSE)
dbWriteTable(connect, append = TRUE, name = "dates", value = bd_dates, row.names = FALSE)
dbWriteTable(connect, append = TRUE, name = "sources", value = bd_sources, row.names = FALSE)

