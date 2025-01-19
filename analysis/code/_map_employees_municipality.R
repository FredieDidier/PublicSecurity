# Carregar pacotes necessários
library(dplyr)
library(sf)
library(ggplot2)
library(viridis)
library(janitor)

# Ler dados das delegacias
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Criar map_data com as novas métricas
map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  group_by(year) %>%
  mutate(
    # Funcionários per capita (por 1000 habitantes)
    func_pub_per_capita = (total_func_pub_munic / population_muni) * 1000,
    # Mediana dos funcionários per capita em 2006
    mediana_per_capita_2006 = median(func_pub_per_capita[year == 2006], na.rm = TRUE),
    # Mediana dos funcionários totais em 2006
    mediana_total_2006 = median(total_func_pub_munic[year == 2006], na.rm = TRUE),
    # Indicadores acima da mediana
    acima_mediana_per_capita = func_pub_per_capita > mediana_per_capita_2006,
    acima_mediana_total = total_func_pub_munic > mediana_total_2006
  ) %>%
  ungroup()

# Nova paleta de cores com cinza para "Sem Informações"
cores_empregos <- c(
  "#D3D3D3",  # Sem Informações (cinza claro)
  "#E6F0FF",  # Menor valor
  "#99CCFF",
  "#4D94FF",
  "#0066CC",
  "#003366"   # Maior valor
)

# Função para criar mapas
criar_mapa <- function(data, variable, breaks, labels, titulo) {
  ggplot() +
    geom_sf(data = data,
            aes(fill = cut({{variable}}, 
                           breaks = breaks,
                           labels = labels,
                           include.lowest = TRUE)),
            color = "white",
            size = 0.1) +
    scale_fill_manual(
      values = cores_empregos[-1],
      name = NULL,
      na.value = cores_empregos[1],
      labels = c(labels, "Not Available"),
      drop = FALSE
    ) +
    ggtitle(titulo) +
    theme_minimal() +
    theme(
      legend.position = "right",
      legend.text = element_text(size = 8),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid = element_blank(),
      plot.title = element_text(size = 10, face = "bold")
    ) +
    coord_sf()
}

# Dados de 2006
data_2006 <- map_data %>% filter(year == 2006)

# 1. Mapa original (total de funcionários)
breaks_total <- c(-Inf, 100, 300, 500, 700, Inf)
labels_total <- c("≤ 100", "≤ 300", "≤ 500", "≤ 700", "≥ 1000")
mapa1 <- criar_mapa(data_2006, total_func_pub_munic, breaks_total, labels_total,
                    "")

# 2. Mapa per capita
breaks_per_capita <- c(-Inf, 20, 30, 40, 50, Inf)
labels_per_capita <- c("≤ 20", "≤ 30", "≤ 40", "≤ 50", "≥ 60")
mapa2 <- criar_mapa(data_2006, func_pub_per_capita, breaks_per_capita, labels_per_capita,
                    "")

# 3. Mapa per capita acima da mediana
mapa3 <- ggplot() +
  geom_sf(data = data_2006,
          aes(fill = acima_mediana_per_capita),
          color = "white",
          size = 0.1) +
  scale_fill_manual(
    values = c("#99CCFF", "#003366"),
    name = NULL,
    labels = c("Below Median", "Above Median", "Not Available"),
    na.value = "#D3D3D3"
  ) +
  ggtitle("") +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.text = element_text(size = 8),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 10, face = "bold")
  ) +
  coord_sf()

# 4. Mapa total acima da mediana
mapa4 <- ggplot() +
  geom_sf(data = data_2006,
          aes(fill = acima_mediana_total),
          color = "white",
          size = 0.1) +
  scale_fill_manual(
    values = c("#99CCFF", "#003366"),
    name = NULL,
    labels = c("Below Median", "Above Median", "Not Available"),
    na.value = "#D3D3D3"
  ) +
  ggtitle("") +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.text = element_text(size = 8),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.title = element_text(size = 10, face = "bold")
  ) +
  coord_sf()

# Combinar os quatro mapas em uma única figura
combined_plot <- gridExtra::grid.arrange(
  mapa1, mapa4, mapa2, mapa3,
  ncol = 2,
  nrow = 2)

# Salvar o plot combinado
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/map_combined_capacity_var.pdf"),
  plot = combined_plot,
  width = 12,
  height = 10,
  dpi = 300
)


# Salvar os mapas
ggsave("/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/maps/map_municipality_employees_2006_total.pdf", 
       mapa1, width = 12, height = 8, dpi = 300)
ggsave("/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/maps/map_municipality_employees_2006_per_capita.pdf", 
       mapa2, width = 12, height = 8, dpi = 300)
ggsave("/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/maps/map_municipality_employees_2006_above_median_per_capita.pdf", 
       mapa3, width = 12, height = 8, dpi = 300)
ggsave("/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/maps/map_municipality_employees_2006_above_median_total.pdf", 
       mapa4, width = 12, height = 8, dpi = 300)