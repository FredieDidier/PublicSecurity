
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp"))
delegacias = delegacias %>%
  rename(distancia_delegacia_km = dstnc__)

map = ggplot() +
  geom_sf(data = delegacias, aes(fill = distancia_delegacia_km), color = "white", size = 0.1) +
  scale_fill_viridis_c(option = "plasma", 
                       name = "Distance to Police Station \nin Straight Line (km)", 
                       direction = -1, 
                       breaks = seq(0, max(delegacias$distancia_delegacia_km, na.rm = TRUE), length.out = 5),
                       labels = function(x) sprintf("%.0f", x),
                       guide = guide_colorbar(title.position = "top",
                                              title.hjust = 0.5,
                                              barwidth = 1,
                                              barheight = 10,
                                              draw.ulim = FALSE,
                                              draw.llim = FALSE,
                                              title.theme = element_text(margin = margin(b = 10)))) +
  theme_minimal() +
  theme(
    legend.position = "right",
    legend.box = "vertical",
    legend.margin = margin(t = 0, r = 0, b = 0, l = 10),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank()
  )

# Salvar o mapa como um arquivo PDF
ggsave(paste0(GITHUB_PATH, "analysis/output/maps/map_police_station_proximity.pdf"), map, width = 12, height = 8, dpi = 300)
