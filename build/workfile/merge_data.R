# Clear the environment
rm(list = ls())

####################
# Folder Path
####################

GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurityBahia/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurityBahia/"

# Loading Datasus data
load(paste0(DROPBOX_PATH, "build/datasus/output/clean_datasus.RData"))

# Adjusting dataset name
datasus = painel_homicidios
rm(painel_homicidios)

# Getting list of states from datasus
state_list = unique(datasus$state)

# Loading Population data
load(paste0(DROPBOX_PATH, "build/population/output/clean_population.RData"))

# Loading Pib Municipal data
load(paste0(DROPBOX_PATH, "build/pib municipal/output/clean_pib_munic.RData"))

# Merging datasets
pop_pib = merge(population, pib_munic, by = c("year", "municipality_code"), all.x = T)

# Creating pop_2000 and pop_2010. columns
pop_pib[, population_2000 := population[year == 2000][1], by = municipality_code]
pop_pib[, population_2010 := population[year == 2010][1], by = municipality_code]

# Filtering
pop_pib = pop_pib %>%
  filter(state %in% state_list)

# Merge
main_data = merge(datasus, pop_pib, by = c("year", "municipality_code", "state"), all.x = T)

# Calculando a taxa de homicídio total por 100.000 habitantes por estado e ano
homicide_rate <- main_data %>%
  group_by(state, year) %>%
  summarise(
    homicidios_total = sum(homicidios_total, na.rm = TRUE),
    population = sum(population, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  mutate(taxa_homicidios_por_100mil_total = homicidios_total / population * 100000) %>%
  select(state, year, taxa_homicidios_por_100mil_total)

# Merge
main_data = merge(main_data, homicide_rate, by = c("year", "state"), all.x = T)

# Function to calculate homicide rate per 100 mil habitantes
calcular_taxa <- function(homicidios, populacao) {
  (sum(homicidios, na.rm = TRUE) / sum(populacao, na.rm = TRUE)) * 100000
}

# Calculating homicide rates per 100.000 habitants for Bahia State
bahia <- main_data %>%
  filter(state == "BA") %>%
  group_by(year) %>%
  summarise(across(starts_with("homicidios_"), ~ calcular_taxa(., population)),
            population = sum(population, na.rm = TRUE),
            .groups = "drop") %>%
  rename_with(~ paste0(., "_BA"), -year)

# Calculating homicide rates aggregated per 100.000 habitants for the other states
other_states <- main_data %>%
  filter(state != "BA") %>%
  group_by(year) %>%
  summarise(across(starts_with("homicidios_"), ~ calcular_taxa(., population)),
            population = sum(population, na.rm = TRUE),
            .groups = "drop") %>%
  rename_with(~ paste0(., "_other_states"), -year)

# Merging results
full_states <- full_join(bahia, other_states, by = "year")

# Renaming columns for better understanding
full_states <- full_states %>%
  rename_with(
    ~ gsub("homicidios_", "taxa_homicidios_por_100mil_", .),
    starts_with("homicidios_")
  )

# Merge
main_data = merge(main_data, full_states, by = "year", all.x = T)

# Saving
save(main_data, file = paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))
