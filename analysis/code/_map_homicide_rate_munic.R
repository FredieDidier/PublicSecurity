# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(janitor)
library(patchwork)
library(cowplot)
library(gridExtra)

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
  "#FFE5E5",  # ≤ 15
  "#FF9999",  # ≤ 30
  "#FF4D4D",  # ≤ 45
  "#CC0000",  # ≤ 60
  "#800000"   # ≥ 75
)

# Definir os breaks e labels
breaks_homicidios <- c(-Inf, 15, 30, 45, 60, Inf)
labels_homicidios <- c("≤ 15", "≤ 30", "≤ 45", "≤ 60", "≥ 75")

# Configuração dos mapas por estado com títulos
mapas_estados <- list(
  "PE" = list(ano = 2006, titulo = "Pernambuco 2006"),
  "BA" = list(ano = 2010, titulo = "Bahia 2010"),
  "PB" = list(ano = 2010, titulo = "Paraíba 2010"),
  "CE" = list(ano = 2014, titulo = "Ceará 2014"),
  "MA" = list(ano = 2015, titulo = "Maranhão 2015")
)

# Função atualizada para criar mapa
criar_mapa <- function(dados, ano, titulo = NULL, mostrar_legenda = TRUE) {
  p <- ggplot() +
    geom_sf(data = dados %>% filter(year == ano),
            aes(fill = cut(taxa_homicidios_total_por_100mil_munic, 
                           breaks = breaks_homicidios,
                           labels = labels_homicidios,
                           include.lowest = TRUE)),
            color = "white",
            size = 0.1) +
    scale_fill_manual(
      values = cores_homicidios[-1],
      name = "Homicide Rate \nper 100,000 inhabitants",
      na.value = cores_homicidios[1],
      drop = FALSE
    ) +
    theme_minimal() +
    theme(
      legend.position = if(mostrar_legenda) "right" else "none",
      legend.text = element_text(size = 10),
      legend.title = element_text(size = 11),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      plot.title = element_text(size = 12, face = "bold", hjust = 0.5)
    ) +
    coord_sf()
  
  if (!is.null(titulo)) {
    p <- p + ggtitle(titulo)
  }
  
  return(p)
}

# Criar os mapas individuais dos estados (sem legenda individual)
mapas_individuais <- list()
for (estado in names(mapas_estados)) {
  info <- mapas_estados[[estado]]
  
  map_data_estado <- map_data %>%
    filter(state == estado)
  
  mapas_individuais[[estado]] <- criar_mapa(
    map_data_estado, 
    info$ano, 
    titulo = info$titulo,
    mostrar_legenda = FALSE
  )
}

# Criar legenda separada
legenda <- criar_mapa(map_data, 2006) +
  theme(legend.position = "right")
legenda_grob <- cowplot::get_legend(legenda)

# Criar um layout de 2 colunas x 3 linhas
# Os primeiros 5 elementos são os mapas e o último é a legenda
layout_matrix <- rbind(
  c(1, 2),    # Primeira linha: PE e BA
  c(3, 4),    # Segunda linha: PB e CE
  c(5, 6)     # Terceira linha: MA e legenda
)

# Combinar os mapas usando o novo layout
combined_states_plot <- gridExtra::grid.arrange(
  mapas_individuais$PE,  # 1
  mapas_individuais$BA,  # 2
  mapas_individuais$PB,  # 3
  mapas_individuais$CE,  # 4
  mapas_individuais$MA,  # 5
  legenda_grob,         # 6
  layout_matrix = layout_matrix,
  widths = c(1, 1),     # Duas colunas de igual largura
  heights = c(1, 1, 1)  # Três linhas de igual altura
)

# Salvar o plot combinado com dimensões ajustadas para o novo layout
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/map_combined_homicide_states.png"),
  plot = combined_states_plot,
  width = 12,  # Ajustado para o novo layout
  height = 15, # Mais alto para acomodar 3 linhas
  dpi = 400
)
