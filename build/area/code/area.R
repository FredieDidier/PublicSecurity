# I download municipal area information of 2010 from IBGE website: https://www.ibge.gov.br/geociencias/organizacao-do-territorio/malhas-territoriais/15774-malhas.html?edicao=27421

library(sf)
library(dplyr)
library(purrr)
library(janitor)
library(units)

# Define o dicionário para códigos UF e abreviações
uf_dict <- c("21" = "MA", "22" = "PI", "23" = "CE", 
             "24" = "RN", "25" = "PB", "26" = "PE", 
             "27" = "AL", "28" = "SE", "29" = "BA")

# Função para ler um único shapefile
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

# Ler todos os shapefiles e combiná-los
area <- uf_dict %>%
  imap_dfr(~ read_uf_shapefile(uf_code = .y, uf_abbr = .x))

# Limpar nomes e selecionar colunas
area <- area %>% 
  clean_names() %>%
  select(cd_geocodm) %>%
  rename(municipality_code = cd_geocodm)

# Converter código do município para inteiro
area$municipality_code <- as.integer(area$municipality_code)

# Calculando área, longitude e latitude
area <- area %>%
  mutate(
    area_km2 = as.numeric(units::set_units(st_area(.), km^2))
  )

# Extraindo centroides para lat/long
centroides <- st_centroid(area)
coords_centroides <- st_coordinates(centroides)

# Adicionando lat/long à base
area <- area %>%
  mutate(
    longitude = coords_centroides[, 1],
    latitude = coords_centroides[, 2]
  )

# Ler a base de estados
s <- st_read(paste0(DROPBOX_PATH,"build/area/input/BR_UF_2022/BR_UF_2022.shp"))

# Verificar e padronizar CRS
if (st_crs(area) != st_crs(s)) {
  area <- st_transform(area, st_crs(s))
}

# Criar o polígono dos estados tratados
treated_states <- s %>%
  filter(CD_UF %in% c("21", "23", "25", "26", "29")) %>%
  st_union() %>%
  st_make_valid()

# Criar o contorno (borda) dos estados tratados
treated_border <- st_boundary(treated_states)

# Função para calcular distância para cada estado
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

# Calcular a distância inicial aos estados tratados
area_final <- area %>%
  mutate(
    centroid = st_centroid(geometry),
    dist_treated = as.numeric(st_distance(centroid, treated_border)) / 1000,
    centroid = NULL
  )

# Calcular distância para cada estado individual
area_final <- area_final %>%
  calculate_state_distance(s, "26") %>%  # PE
  calculate_state_distance(s, "29") %>%  # BA
  calculate_state_distance(s, "25") %>%  # PB
  calculate_state_distance(s, "23") %>%  # CE
  calculate_state_distance(s, "21")      # MA

# Selecionar e ordenar as colunas finais
area_final <- area_final %>%
  select(municipality_code, geometry, area_km2, longitude, latitude, 
         dist_treated, dist_PE, dist_BA, dist_PB, dist_CE, dist_MA)
area = area_final
area = st_drop_geometry(area)

# Saving clean dataset
save(area, file = paste0(DROPBOX_PATH, "build/area/output/clean_area.RData"))
