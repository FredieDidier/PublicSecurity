# I use Base dos Dados package to extract Human Development Index Data 
# In their website (https://basedosdados.org) you will get information on how to download the data

library(basedosdados)
library(data.table)
library(tidyverse)
library(janitor)

query <- "SELECT * FROM `basedosdados.mundo_onu_adh.municipio`"

idh <- download(query, path = paste0(DROPBOX_PATH, "build/idh/input/idh.csv"),
                   billing_project_id = "sodium-surf-307721")

# Loading Data
idh = fread(paste0(DROPBOX_PATH, "build/idh/input/idh.csv"))

# Filtering to only have 2010
idh = idh %>%
  filter(ano == 2010)

# Renaming columns
idh = idh %>%
  rename(year = ano, municipality_code = id_municipio)

# Filtering data to include only relevant municipalities for the analysis
idh <- idh %>%
  filter(startsWith(as.character(municipality_code), "21") |
           startsWith(as.character(municipality_code), "22") |
           startsWith(as.character(municipality_code), "23") |
           startsWith(as.character(municipality_code), "24") |
           startsWith(as.character(municipality_code), "27") |
           startsWith(as.character(municipality_code), "28") |
           startsWith(as.character(municipality_code), "29"))

idh = idh %>%
  filter(!is.nan(idhm))

# Saving Clean Dataset
save(idh, file = paste0(DROPBOX_PATH, "build/idh/output/clean_idh.RData"))
