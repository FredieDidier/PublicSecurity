# Load required libraries
library(datazoom.amazonia)
library(data.table)
library(tidyverse)
library(sf)
library(lubridate)
library(janitor)
library(stringi)
library(progress)
library(ribge)

# Function to download data for a specific year
download_population_data <- function(year) {
  data <- load_population(
    raw_data = FALSE,
    geo_level = "municipality",
    time_period = year
  )
  data$year <- year
  return(data)
}

# Set up progress bar
years <- 2001:2021
pb <- progress_bar$new(
  format = "Downloading data for year :what [:bar] :percent eta: :eta",
  total = length(years)
)

# Download and combine data for years 2001-2021 with progress bar
combined_data <- map_dfr(years, function(year) {
  pb$tick(tokens = list(what = year))
  download_population_data(year)
})

# Fill NA values in 'estimated_population_v9324' with values from 'population_v93'
combined_data <- combined_data %>%
  mutate(estimated_population_v9324 = ifelse(is.na(estimated_population_v9324), population_v93, estimated_population_v9324))

# Excluding irrelevant column
combined_data = combined_data %>%
  rename(population = estimated_population_v9324) %>%
  select(-population_v93)

# Renaming to match
combined_data = combined_data %>%
  rename(municipality_code = geo_id)

# Convert to data.table for efficiency
setDT(combined_data)
population = combined_data

# Now download year 2000 population using ribge package
pop_2000 = populacao_municipios(2000, dir = paste0(DROPBOX_PATH, "build/population/input"))

# Harmonizing names
pop_2000 = pop_2000 %>%
  select(cod_municipio, populacao) %>%
  rename(municipality_code = cod_municipio,
         population = populacao) %>%
  mutate(year = 2000)

# Joining dataframes
population = bind_rows(population, pop_2000)

population = population %>%
  mutate(municipality_code = as.numeric(municipality_code))

# Loading State data
state = read.csv(paste0(DROPBOX_PATH, "build/municipios_codibge.csv"))
state = state %>%
  clean_names() %>%
  rename(municipality_code = codigo,
         state = uf) %>%
  select(municipality_code, state)

# Merge
population = merge(population, state, by = "municipality_code", all.x = T)

population = population %>%
  arrange(year) %>%
  filter(year %in% c(2000, 2007:2019))

# Saving Clean Data
save(population, file = paste0(DROPBOX_PATH, "build/population/output/clean_population.RData"))
