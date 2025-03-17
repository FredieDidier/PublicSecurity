# Ler dados das delegacias
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp"))
delegacias = delegacias %>%
  rename(distancia_delegacia_km = dstnc__)

# Definir intervalos mais apropriados para a legenda
# Analisando o contexto de distâncias até delegacias em municípios
breaks_dist <- c(0, 5, 10, 20, 30, max(delegacias$distancia_delegacia_km, na.rm = TRUE))
labels_dist <- c("< 5 km", "5-10 km", "10-20 km", "20-30 km", "> 30 km")

# Criar variável categórica para as distâncias
delegacias <- delegacias %>%
  mutate(dist_categoria = cut(distancia_delegacia_km, 
                              breaks = breaks_dist,
                              labels = labels_dist,
                              include.lowest = TRUE))

# Definindo paleta de cores personalizada do claro ao roxo escuro
cores_roxo <- c(
  "#F3E5F5",  # Muito claro
  "#D1C4E9",  # Claro
  "#9575CD",  # Médio
  "#673AB7",  # Escuro
  "#4A148C"   # Muito escuro
)

# Criar o mapa
map = ggplot() +
  geom_sf(data = delegacias,
          aes(fill = dist_categoria),
          color = "white",
          size = 0.1) +
  # Usando paleta de cores personalizada com categorias
  scale_fill_manual(
    values = cores_roxo,
    name = "Distance to Nearest Police Station\nin Straight Line",
    na.value = "#D3D3D3"
  ) +
  theme_minimal() +
  theme(
    legend.position = "left",
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  ) +
  coord_sf()

# Salvar o mapa como um arquivo PNG com alta resolução
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/map_police_station_proximity.png"),
  plot = map,
  width = 8,  # Largura em polegadas
  height = 7,  # Altura em polegadas
  dpi = 600,
  bg = "white"  # Fundo branco para publicação
)
