# Load necessary packages
library(dplyr)
library(sf)
library(ggplot2)
library(tidyr)
library(janitor)

# Loading Main Data
load(paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))

# Filter specific codes (these are wrong codes - represent states rather than municipalities. Don't know why they are in the dataset)
main_data <- main_data %>%
  filter(municipality_code != 2300000) %>%
  filter(municipality_code != 2600000)

# Create dataframe with treatment information
treatment_info <- data.frame(
  treatment_year = c(2007, 2011, 2011, 2015, 2016),
  state = c("PE", "BA", "PB", "CE", "MA")
)

# Read police station data
delegacias = st_read(paste0(DROPBOX_PATH, "build/delegacias/output/map_delegacias.shp")) %>%
  select(CD_GEOC) %>%
  clean_names() %>%
  rename(municipality_code = cd_geoc) %>%
  mutate(municipality_code = as.integer(municipality_code))

# Create map_data
map_data <- delegacias %>%
  left_join(main_data, by = "municipality_code") %>%
  left_join(treatment_info, by = "state") %>%
  mutate(
    treatment_status = case_when(
      is.na(treatment_year) ~ "Not Treated",
      TRUE ~ paste("Treated since", treatment_year)
    )
  )

# Create dataframe with manual positions for state abbreviations
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

# Create the map
map = ggplot() +
  # Base map layer
  geom_sf(data = map_data, 
          aes(fill = treatment_status), 
          color = "white", 
          size = 0.2) +
  # Add state borders
  geom_sf(data = estados_agregados,
          fill = NA,
          color = "black",
          size = 0.5) +
  # Add state labels manually
  geom_text(data = state_labels,
            aes(x = x, y = y, label = state),
            color = "black",
            size = 6,  # Increased size for better readability
            fontface = "bold") +
  # Customize colors
  scale_fill_manual(
    values = c(
      "Not Treated" = "grey80",
      "Treated since 2007" = "#1a9850",
      "Treated since 2011" = "#91cf60",
      "Treated since 2015" = "#d9ef8b",
      "Treated since 2016" = "#fee08b"
    ),
    name = "Treatment Status"
  ) +
  # Customize theme
  theme_minimal() +
  theme(
    # Remove axis elements
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    axis.title = element_blank(),
    
    # Customize legend
    legend.position = "left",
    legend.title = element_text(size = 15, face = "bold"),
    legend.text = element_text(size = 13),
    legend.key.size = unit(1, "cm"),
    
    # Remove panel elements
    panel.grid = element_blank(),
    panel.border = element_blank(),
    
    # Adjust plot margins
    plot.margin = margin(1, 1, 1, 1, "cm")
  )

# Save the map as PNG with high resolution
ggsave(
  paste0(GITHUB_PATH, "analysis/output/maps/map_all_municipalities_treated_not_treated.png"), 
  map, 
  width = 12, 
  height = 8, 
  dpi = 300,
  bg = "white"
)