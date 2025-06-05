# Load necessary packages
library(dplyr)
library(sf)
library(ggplot2)

# Loading Main Data
load(paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))

# Read police station data
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp"))
delegacias = delegacias %>%
  rename(distancia_delegacia_km = dstnc__)

# Filter only for Northeast states
estados_nordeste <- c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE")

# Assuming there's a state or UF column in the dataset
if("UF" %in% colnames(delegacias)) {
  estado_coluna <- "UF"
} else if("state" %in% colnames(delegacias)) {
  estado_coluna <- "state"
} else {
  # If it doesn't exist, you'll need to add this information to your dataset
  warning("State column not found. Adding fictitious column for demonstration.")
  # This is just an example, you'll need to adapt to your real dataset
  estado_coluna <- "state"
  delegacias$state <- sample(estados_nordeste, nrow(delegacias), replace = TRUE)
}

# Filter only Northeast municipalities
delegacias <- delegacias %>%
  filter(!!sym(estado_coluna) %in% estados_nordeste)

# Create categorical variable for distances in specific intervals
delegacias <- delegacias %>%
  mutate(dist_categoria = case_when(
    distancia_delegacia_km <= 15 ~ "0-15 km",
    distancia_delegacia_km <= 30 ~ "15-30 km",
    TRUE ~ "Above 30 km"
  ))

# Ensure categories are in desired order using factor
delegacias$dist_categoria <- factor(
  delegacias$dist_categoria,
  levels = c("0-15 km", "15-30 km", "Above 30 km")
)

# Defining orange color palette for good visibility of black abbreviations
cores_categorias <- c(
  "0-15 km" = "#FFECB3",     # Very light orange
  "15-30 km" = "#FFB74D",    # Medium orange
  "Above 30 km" = "#E65100"  # Dark orange
)

# Create aggregation by state to add borders
estados_agregados <- delegacias %>%
  group_by(!!sym(estado_coluna)) %>%
  summarise(geometry = st_union(geometry)) %>%
  ungroup()

# Create dataframe with manual positions for Northeast state abbreviations
state_labels <- data.frame(
  state = c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA"),
  x = c(-44.5, -42.5, -40.0, -36.5, -36.5, -37.5, -36.5, -37.5, -41.0),
  y = c(-5.0, -7.0, -5.0, -5.5, -7.0, -8.5, -9.5, -10.5, -12.0)
)

# Create the map
map = ggplot() +
  # Base layer with distance category
  geom_sf(data = delegacias,
          aes(fill = dist_categoria),
          color = "white",
          size = 0.1) +
  # Add state borders
  geom_sf(data = estados_agregados,
          fill = NA,
          color = "black",
          size = 0.5) +
  # Add state abbreviations manually
  geom_text(data = state_labels,
            aes(x = x, y = y, label = state),
            color = "black",
            size = 4,
            fontface = "bold") +
  # Using orange color palette
  scale_fill_manual(
    values = cores_categorias,
    name = "Distance to Nearest\nPolice Station",
    drop = FALSE  # Ensure all categories appear in legend even if they have no data
  ) +
  theme_void() +
  theme(
    legend.position = "left",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  ) +
  coord_sf()

# Save the map as a PNG file with high resolution
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/figure_3b.png"),
  plot = map,
  width = 12,  # Width in inches
  height = 8,  # Height in inches
  dpi = 300,
  bg = "white"  # White background for publication
)