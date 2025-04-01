library(RSQLite)

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
  day_obs         INTEGER,
  time_obs        TIME,
  dwc_event_date  DATE,
  PRIMARY KEY     (id_obs)
  FOREIGN KEY     (dwc_event_date) REFERENCES observations(dwc_event_date)
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
  FOREIGN KEY           (creator) REFERENCES observations(creator)
  );"

dbSendQuery(connect, creer_sources)

df_observations <- lep[, c("observed_scientific_name","dwc_event_date","obs_variable","creator","lat","lon")]
df_dates <- lep[, c("year_obs","day_obs","time_obs","dwc_event_date")]
df_sources <- lep[,c("original_source","creator","title","publisher","intellectual_rights","license","owner")]

#Sauvegarder les données retournées par une requête
write.csv(df_observations, file = "df_observations.csv", row.names = FALSE)
write.csv(df_dates, file = "df_dates.csv", row.names = FALSE)
write.csv(df_sources, file = "df_sources.csv", row.names = FALSE)

#Lecture des fichiers CSV
bd_observations <- read.csv(file = "df_observations.csv")
bd_dates <- read.csv(file = "df_dates.csv")
bd_sources <-read.csv(file = "df_sources.csv")

#Injection des données
dbWriteTable(connect, append = TRUE, name = "observations", value = bd_observations, row.names = FALSE)
dbWriteTable(connect, append = TRUE, name = "dates", value = bd_dates, row.names = FALSE)
dbWriteTable(connect, append = TRUE, name = "sources", value = bd_sources, row.names = FALSE)

