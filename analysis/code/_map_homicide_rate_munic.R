# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(viridis)
library(janitor)

# Filtrar códigos específicos e preparar dados de tratamento
main_data <- main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000)

# Definir os anos de tratamento e os estados correspondentes
treatment_info <- data.frame(
  treatment_year = c(2007, 2011, 2011, 2015, 2016),
  state = c("PE", "BA", "PB", "CE", "MA")
)

# Ler dados das delegacias e preparar para merge
delegacias <- st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Integrar dados de homicídio com dados geográficos e informações de tratamento
map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  left_join(treatment_info, by = "state")

# Configuração dos anos de interesse: um ano antes de cada tratamento
mapas_por_estado <- list(
  "PE" = 2006,
  "BA" = 2010,
  "PB" = 2010,
  "CE" = 2014,
  "MA" = 2015
)

# Loop para criar e salvar o mapa para cada estado no ano específico
for (estado in names(mapas_por_estado)) {
  
  ano <- mapas_por_estado[[estado]]
  
  # Filtrar dados para o estado e ano específicos
  map_data_estado <- map_data %>%
    filter(state == estado, year == ano)
  
  # Criar o mapa com a paleta de intensidade para o estado e ano especificados
  mapa <- ggplot() +
    geom_sf(data = map_data_estado, aes(fill = taxa_homicidios_total_por_100mil_munic), color = "white", size = 0.1) +
    scale_fill_viridis_c(
      option = "plasma",  # Paleta de intensidade para dados de homicídio
      name = "Homicide Rate per 100,000 inhabitants",
      na.value = "grey80"
    ) +
    theme_minimal() +
    theme(
      plot.title = element_text(size = 14, face = "bold"),
      legend.position = "bottom",
      axis.text = element_blank(),
      axis.ticks = element_blank()
    )
  
  # Salvar o mapa como PDF
  ggsave(paste0(GITHUB_PATH, "analysis/output/maps/map_homicide_rate_", estado, "_munic", "_", ano, ".pdf"), mapa, width = 10, height = 8, dpi = 300)
}
