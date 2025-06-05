# Load necessary packages
library(dplyr)
library(sf)
library(ggplot2)
library(RColorBrewer)
library(janitor)
library(patchwork)
library(cowplot)
library(gridExtra)

# Load and prepare main data
main_data <- main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000)

# Define treatment years and corresponding states
treatment_info <- data.frame(
  treatment_year = c(2007, 2011, 2011, 2015, 2016),
  state = c("PE", "BA", "PB", "CE", "MA")
)

# Read police station data and prepare for merge
delegacias <- st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Integrate homicide data with geographic data and treatment information
map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  left_join(treatment_info, by = "state")

# Define the specific color palette for the map
cores_homicidios <- c(
  "#FFFFFF",  # No Information (white)
  "#FFE5E5",  # ≤ 15
  "#FF9999",  # ≤ 30
  "#FF4D4D",  # ≤ 45
  "#CC0000",  # ≤ 60
  "#800000"   # ≥ 60
)

# Define breaks and labels
breaks_homicidios <- c(-Inf, 15, 30, 45, 60, Inf)
labels_homicidios <- c("≤ 15", "≤ 30", "≤ 45", "≤ 60", "> 60")

# Map configuration by state with titles
mapas_estados <- list(
  "PE" = list(ano = 2006, titulo = "Pernambuco 2006"),
  "BA" = list(ano = 2010, titulo = "Bahia 2010"),
  "PB" = list(ano = 2010, titulo = "Paraíba 2010"),
  "CE" = list(ano = 2014, titulo = "Ceará 2014"),
  "MA" = list(ano = 2015, titulo = "Maranhão 2015")
)

# Updated function to create map
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

# Create individual state maps (without individual legend)
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

# Create separate legend
legenda <- criar_mapa(map_data, 2006) +
  theme(legend.position = "right")
legenda_grob <- cowplot::get_legend(legenda)

# Create a 2 columns x 3 rows layout
# The first 5 elements are the maps and the last one is the legend
layout_matrix <- rbind(
  c(1, 2),    # First row: PE and BA
  c(3, 4),    # Second row: PB and CE
  c(5, 6)     # Third row: MA and legend
)

# Combine maps using the new layout
combined_states_plot <- gridExtra::grid.arrange(
  mapas_individuais$PE,  # 1
  mapas_individuais$BA,  # 2
  mapas_individuais$PB,  # 3
  mapas_individuais$CE,  # 4
  mapas_individuais$MA,  # 5
  legenda_grob,         # 6
  layout_matrix = layout_matrix,
  widths = c(1, 1),     # Two columns of equal width
  heights = c(1, 1, 1)  # Three rows of equal height
)

# Save the combined plot with adjusted dimensions for the new layout
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/figure_A1.png"),
  plot = combined_states_plot,
  width = 12,  # Adjusted for the new layout
  height = 15, # Taller to accommodate 3 rows
  dpi = 400
)