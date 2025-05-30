# Load necessary packages
library(dplyr)
library(sf)
library(ggplot2)
library(viridis)
library(janitor)

# Loading Main Data
load(paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))

# Read police station data
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Create map_data with the new metric: fraction of employees with higher education
# Filter only for Northeast states
estados_nordeste <- c("AL", "BA", "CE", "MA", "PB", "PE", "PI", "RN", "SE")

map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  filter(year == 2006) %>%
  filter(state %in% estados_nordeste) %>%  # Filter only Northeast states
  mutate(
    # Fraction of employees with higher education
    perc_superior = (funcionarios_superior / total_func_pub_munic) * 100
  )

# Classify municipalities into intervals
map_data <- map_data %>%
  mutate(
    categoria = case_when(
      is.na(perc_superior) ~ "Not Available",
      perc_superior > 60 ~ "Above 60%",
      perc_superior > 40 ~ "41-60%",
      perc_superior > 20 ~ "21-40%",
      TRUE ~ "0-20%"
    )
  )

# Define colors for different intervals
cores_categorias <- c(
  "0-20%" = "#E6F2FF",      # Very light blue
  "21-40%" = "#99CCFF",     # Light blue
  "41-60%" = "#4D94FF",     # Medium blue
  "Above 60%" = "#0066CC",  # Dark blue
  "Not Available" = "#D3D3D3"  # Gray for unavailable data
)

# Ensure that the category is a factor with defined levels (ascending order)
map_data$categoria <- factor(
  map_data$categoria, 
  levels = c("0-20%", "21-40%", "41-60%", "Above 60%", "Not Available")
)

# Create dataframe with manual positions for state abbreviations
# Using the same coordinates from the provided example
state_labels <- data.frame(
  state = c("MA", "PI", "CE", "RN", "PB", "PE", "AL", "SE", "BA"),
  x = c(-44.5, -42.5, -40.0, -36.5, -36.5, -37.5, -36.5, -37.5, -41.0),
  y = c(-5.0, -7.0, -5.0, -5.5, -7.0, -8.5, -9.5, -10.5, -12.0)
)

# Create aggregation by state to add borders
estados_agregados <- map_data %>%
  group_by(state) %>%
  summarise(geometry = st_union(geometry)) %>%
  ungroup()

# Create the map with categories based on intervals and state abbreviations
mapa_superior <- ggplot() +
  # Base layer with categories by interval
  geom_sf(data = map_data,
          aes(fill = categoria),
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
  # Scales
  scale_fill_manual(
    values = cores_categorias,
    name = "% Municipality Public Employees\nwith Higher Education (2006)",
    drop = FALSE  # Ensure all categories appear in the legend
  ) +
  # Map theme
  theme_void() +
  theme(
    legend.position = "left",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13),
    plot.margin = margin(t = 10, r = 10, b = 10, l = 10)
  ) +
  coord_sf()

# Save the map
ggsave(
  filename = paste0(GITHUB_PATH, "analysis/output/maps/map_public_employees_education_2006.png"),
  plot = mapa_superior,
  width = 12,  # Width in inches
  height = 8,   # Height in inches
  dpi = 300,
  bg = "white"  # White background
)