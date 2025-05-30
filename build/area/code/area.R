# I download municipal area information of 2010 from IBGE website: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html?edicao=27421

library(sf)
library(dplyr)
library(purrr)
library(janitor)
library(units)

# Dictionary for states
uf_dict <- c("21" = "MA", "22" = "PI", "23" = "CE", 
             "24" = "RN", "25" = "PB", "26" = "PE", 
             "27" = "AL", "28" = "SE", "29" = "BA")

# Function to read a single shapefile
read_uf_shapefile <- function(uf_code, uf_abbr) {
  file_path <- file.path(paste0(DROPBOX_PATH, "build/area/input"), 
                         uf_abbr, 
                         paste0(uf_code, "MUE250GC_SIR.shp"))
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

# Cleaning and selecting columns
area <- area %>% 
  clean_names() %>%
  select(cd_geocodm) %>%
  rename(municipality_code = cd_geocodm)

# Turning Municipality code into numeric format
area$municipality_code <- as.integer(area$municipality_code)

# Calculating area, lat and lon
area <- area %>%
  mutate(
    area_km2 = as.numeric(units::set_units(st_area(.), km^2))
  )

# Extracting centroids
centroides <- st_centroid(area)
coords_centroides <- st_coordinates(centroides)

# Adding lat and lon to dataset
area <- area %>%
  mutate(
    longitude = coords_centroides[, 1],
    latitude = coords_centroides[, 2]
  )

# Read states dataset
s <- st_read(paste0(DROPBOX_PATH,"build/area/input/BR_UF_2022/BR_UF_2022.shp"))

# Verifying and harmonizing CRS
if (st_crs(area) != st_crs(s)) {
  area <- st_transform(area, st_crs(s))
}

# Create treated states polygon
treated_states <- s %>%
  filter(CD_UF %in% c("21", "23", "25", "26", "29")) %>%
  st_union() %>%
  st_make_valid()

# Create treated states border
treated_border <- st_boundary(treated_states)

# Function to calculate distance to every state
calculate_state_distance <- function(data, state_data, cd_uf) {
  state_border <- state_data %>%
    filter(CD_UF == cd_uf) %>%
    st_union() %>%
    st_make_valid() %>%
    st_boundary()
  
  data %>%
    mutate(
      centroid = st_centroid(geometry),
      !!paste0("dist_", uf_dict[cd_uf]) := as.numeric(st_distance(centroid, state_border)) / 1000,
      centroid = NULL
    )
}

# Calculate distance to treated states
area_final <- area %>%
  mutate(
    centroid = st_centroid(geometry),
    dist_treated = as.numeric(st_distance(centroid, treated_border)) / 1000,
    centroid = NULL
  )

# Calculate individually distance to every treated state
area_final <- area_final %>%
  calculate_state_distance(s, "26") %>%  # PE
  calculate_state_distance(s, "29") %>%  # BA
  calculate_state_distance(s, "25") %>%  # PB
  calculate_state_distance(s, "23") %>%  # CE
  calculate_state_distance(s, "21")      # MA

# Selecting columns
area_final <- area_final %>%
  select(municipality_code, geometry, area_km2, longitude, latitude, 
         dist_treated, dist_PE, dist_BA, dist_PB, dist_CE, dist_MA)
area = area_final
area = st_drop_geometry(area)

# Saving clean dataset
save(area, file = paste0(DROPBOX_PATH, "build/area/output/clean_area.RData"))
