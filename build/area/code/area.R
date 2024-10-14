# I download municipal area information of 2010 from IBGE website: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html?edicao=27421

library(sf)
library(purrr)
library(dplyr)
library(janitor)
library(units)

# Define the dictionary for UF codes and abbreviations
uf_dict <- c("21" = "MA", "22" = "PI", "23" = "CE", 
             "24" = "RN", "25" = "PB", "26" = "PE", "27" = "AL", "28" = "SE", 
             "29" = "BA")

# Function to read a single shapefile
read_uf_shapefile <- function(uf_code, uf_abbr) {
  file_path <- file.path(paste0(DROPBOX_PATH, "build/area/input"), uf_abbr, paste0(uf_code, "MUE250GC_SIR.shp"))
  tryCatch({
    sf::read_sf(file_path) %>%
      mutate(UF = uf_abbr)
  }, error = function(e) {
    warning(paste("Error reading file for", uf_abbr, ":", e$message))
    return(NULL)
  })
}

# Read all shapefiles and combine them
area <- uf_dict %>%
  imap_dfr(~ read_uf_shapefile(uf_code = .y, uf_abbr = .x))

# Cleaning names and selecting columns
area = area %>% 
  clean_names()

area$nm_municip = NULL
area$id = NULL
area$UF = NULL

area = area %>% 
  rename(municipality_code = cd_geocodm)

# Extracting area in km^2 information
area = area %>%
  mutate(area_km2 = as.numeric(units::set_units(st_area(.), km^2)))

area$municipality_code = as.integer(area$municipality_code)

# Extraindo o centroide do polígono
centroides <- st_centroid(area)

# Extraindo as coordenadas de latitude e longitude do centroide
coords_centroides <- st_coordinates(centroides)

# Adicionando as colunas de latitude e longitude à base
area <- area %>%
  mutate(longitude = coords_centroides[, 1],  # Longitude é a 1ª coluna
         latitude = coords_centroides[, 2])   # Latitude é a 2ª coluna

# Removing geometry column
area = st_drop_geometry(area)

# Saving clean dataset
save(area, file = paste0(DROPBOX_PATH, "build/area/output/clean_area.RData"))
