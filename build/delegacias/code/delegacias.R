# I use OpenStreetMap in order to download most close police station in municipalities in Brazil

# Carregar as bibliotecas necessárias
library(sf)
library(osmdata)
library(tidyverse)
library(units)
library(janitor)

# Carregar os dados dos municípios
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

# Verificar e definir CRS se necessário
if (is.na(st_crs(area))) {
  warning("CRS dos municípios não definido. Assumindo EPSG:4326 (WGS84).")
  st_crs(area) <- 4326
}

# Obter a extensão (bounding box) dos municípios
bbox <- st_bbox(area)

# Baixar as estações de polícia do OpenStreetMap
delegacias <- opq(bbox) %>%
  add_osm_feature(key = "amenity", value = "police") %>%
  osmdata_sf()

# Extrair os pontos das delegacias
delegacias_pontos <- delegacias$osm_points

# Garantir que os sistemas de coordenadas sejam os mesmos
if (!is.na(st_crs(delegacias_pontos)) && !is.na(st_crs(area))) {
  delegacias_pontos <- st_transform(delegacias_pontos, st_crs(area))
} else {
  stop("Não foi possível definir o mesmo CRS para delegacias e municípios. Verifique os dados de entrada.")
}
# Função para encontrar a delegacia mais próxima e calcular a distância em km
encontrar_delegacia_mais_proxima <- function(municipio_geom, delegacias) {
  if (is.null(delegacias) || nrow(delegacias) == 0) {
    return(c(id_delegacia = NA, distancia_km = NA))
  }
  
  distances <- st_distance(st_centroid(municipio_geom), delegacias)
  nearest_index <- which.min(distances)
  
  if (length(nearest_index) == 0) {
    return(c(id_delegacia = NA, distancia_km = NA))
  }
  
  # Converter a distância para km
  distancia_km <- set_units(min(distances), "km")
  
  return(c(
    id_delegacia = delegacias$osm_id[nearest_index],
    distancia_km = as.numeric(distancia_km)
  ))
}

# Aplicar a função a cada município
delegacias <- area %>%
  rowwise() %>%
  mutate(
    delegacia_mais_proxima = list(encontrar_delegacia_mais_proxima(geometry, delegacias_pontos))
  ) %>%
  ungroup() %>%
  mutate(
    id_delegacia = sapply(delegacia_mais_proxima, `[`, 1),
    distancia_delegacia_km = sapply(delegacia_mais_proxima, `[`, 2)
  )

delegacias$distancia_delegacia_km <- as.numeric(delegacias$distancia_delegacia_km)

# Arredondar a distância para 2 casas decimais
delegacias$distancia_delegacia_km <- round(delegacias$distancia_delegacia_km, 2)

# Save map version of the data
delegacias$delegacia_mais_proxima = NULL
st_write(delegacias, paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp"), append = F)

delegacias = delegacias %>%
  rename(municipality_code = CD_GEOCODM,
         state = UF) %>%
  clean_names() %>%
  select(municipality_code, state, id_delegacia, distancia_delegacia_km) %>%
  st_drop_geometry() %>%
  as.data.table()

# Salvar os delegacias
save(delegacias, file = paste0(DROPBOX_PATH, "build/delegacias/output/delegacias.RData"))
