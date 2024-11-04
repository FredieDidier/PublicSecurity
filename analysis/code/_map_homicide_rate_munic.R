# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(janitor)

# Carregar e preparar dados principais
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

# Definir a paleta de cores específica do mapa
cores_homicidios <- c(
  "#FFFFFF",  # Sem Informações (branco)
  "#FFE5E5",  # ≤ 20 (rosa claro)
  "#FF9999",  # ≤ 30 (salmon)
  "#FF4D4D",  # ≤ 40 (vermelho médio)
  "#CC0000",  # ≤ 50 (vermelho escuro)
  "#800000"   # ≥ 60 (vinho)
)

# Definir os breaks e labels
breaks_homicidios <- c(-Inf, 20, 30, 40, 50, Inf)
labels_homicidios <- c("≤ 20", "≤ 30", "≤ 40", "≤ 50", "≥ 60")

# Anos para mapas do Nordeste inteiro
anos_nordeste <- c(2006, 2010, 2014, 2015)

# Configuração dos mapas por estado
mapas_estados <- list(
  "PE" = 2006,
  "BA" = 2010,
  "PB" = 2010,
  "CE" = 2014,
  "MA" = 2015 
)

# Função para criar mapa
criar_mapa <- function(dados, ano) {
  ggplot() +
    geom_sf(data = dados %>% filter(year == ano),
            aes(fill = cut(taxa_homicidios_total_por_100mil_munic, 
                           breaks = breaks_homicidios,
                           labels = labels_homicidios,
                           include.lowest = TRUE)),
            color = "white",
            size = 0.1) +
    scale_fill_manual(
      values = cores_homicidios[-1],
      name = NULL,
      na.value = cores_homicidios[1],
      drop = FALSE
    ) +
    theme_minimal() +
    theme(
      legend.position = "right",
      legend.text = element_text(size = 8),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank()
    ) +
    coord_sf()
}

# Filtrar estados do Nordeste
estados_ne <- c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA")
map_data_ne <- map_data %>%
  filter(state %in% estados_ne)

# 1. Criar e salvar mapas do Nordeste inteiro
for (ano in anos_nordeste) {
  mapa <- criar_mapa(map_data_ne, ano)
  
  ggsave(
    filename = paste0(GITHUB_PATH, "analysis/output/maps/map_homicide_rate_NE_", ano, ".pdf"),
    plot = mapa,
    width = 12,
    height = 10,
    dpi = 300
  )
}

# 2. Criar e salvar mapas individuais dos estados
for (estado in names(mapas_estados)) {
  ano <- mapas_estados[[estado]]
  
  # Filtrar dados para o estado específico
  map_data_estado <- map_data %>%
    filter(state == estado)
  
  mapa <- criar_mapa(map_data_estado, ano)
  
  ggsave(
    filename = paste0(GITHUB_PATH, "analysis/output/maps/map_homicide_rate_", estado, "_", ano, ".pdf"),
    plot = mapa,
    width = 10,
    height = 8,
    dpi = 300
  )
}

