# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(viridis)

# Ler dados das delegacias
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Criar map_data mantendo a estrutura sf
map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code")

cores_empregos <- c(
  "#8B0000",  # Sem Informações (vermelho escuro)
  "#E6F0FF",  # ≤ 20 (azul muito claro)
  "#99CCFF",  # ≤ 30 (azul claro)
  "#4D94FF",  # ≤ 40 (azul médio)
  "#0066CC",  # ≤ 50 (azul escuro)
  "#003366"   # ≥ 60 (azul profundo)
)

# Definir os breaks e labels
breaks_empregos <- c(-Inf, 100, 300, 500, 700, Inf)
labels_empregos <- c("≤ 100", "≤ 300", "≤ 500", "≤ 700", "≥ 1000")

# Função para criar mapa
mapa =  ggplot() +
    geom_sf(data = map_data %>% filter(year == 2006),
            aes(fill = cut(total_func_pub_munic, 
                           breaks = breaks_empregos,
                           labels = labels_empregos,
                           include.lowest = TRUE)),
            color = "white",
            size = 0.1) +
    scale_fill_manual(
      values = cores_empregos[-1],
      name = NULL,
      na.value = cores_empregos[1],
      labels = c(labels_empregos, "Not Available"),
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

# Salvar o mapa
ggsave("/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/maps/map_municipality_employees_2006.pdf", mapa, width = 12, height = 8, dpi = 300)
