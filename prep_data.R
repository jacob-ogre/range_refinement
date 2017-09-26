library(dplyr)
library(DBI)
library(RSQLite)

#############################################################################
# Prep the GBIF data
esa_occ <- readRDS("data/ESA_spp_GBIF-2017-09-25.rds")

con <- dbConnect(RSQLite::SQLite(), "data/ESA_GBIF.sqlite3")
dbListTables(con)
dbWriteTable(con, "esa_gbif", esa_occ, overwrite = TRUE)

tmp <- dbSendQuery(con, "SELECT * FROM esa_gbif WHERE name = 'Setophaga kirtlandii'")
KIWA <- dbFetch(tmp)

#############################################################################
# Prep the geonames data
fiveyr_place <- readRDS("data/ESA_placenames_fiveyr.rds")

con <- dbConnect(RSQLite::SQLite(), "data/ESA_GBIF.sqlite3")
dbListTables(con)
dbWriteTable(con, "fiveyr_place", fiveyr_place)

tmp <- dbSendQuery(con, "SELECT * FROM fiveyr_place WHERE species = 'Setophaga kirtlandii (= Dendroica kirtlandii)'")
KIWA_plc <- dbFetch(tmp)

#############################################################################
# Prep the TECP table
TECP_table <- readRDS("data/TECP_table.rds") %>%
  filter_domestic() %>%
  filter_listed()

names(TECP_table)[1] <- "species"
TECP_table$names <- paste0(
  TECP_table$Common_Name,
  " (", TECP_table$species, ")"
)

saveRDS(TECP_table, file = "data/TECP_table.rds")

#############################################################################
# Prep document tables
load("data/ECOS_species_tables_2016-12-17.rda")
saveRDS(fiveyr_table, file = "data/five_year_table.rds")
saveRDS(recovery_table, file = "data/recovery_table.rds")
