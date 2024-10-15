
map = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp"))
map = map %>%
  rename(distancia_delegacia_km = dstnc__)

# Criar o mapa
map = ggplot() +
  geom_sf(data = delegacias, aes(fill = distancia_delegacia_km), color = "white", size = 0.1) +
  scale_fill_viridis_c(option = "plasma", name = "Distance to \nPolice Station (km)", 
                       direction = -1, 
                       breaks = seq(0, max(delegacias$distancia_delegacia_km, na.rm = TRUE), length.out = 5),
                       labels = function(x) sprintf("%.0f", x)) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
    legend.position = "right",
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  ) +
  labs(
    title = "Proximity of Northeast Municipalities to Police Stations"
  )

# Salvar o mapa como um arquivo PDF
ggsave(paste0(GITHUB_PATH, "analysis/output/maps/map_police_station_proximity.pdf"), mapa, width = 12, height = 8, dpi = 300)
