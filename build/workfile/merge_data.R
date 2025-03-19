# Clear environment and set paths
rm(list = ls())
GITHUB_PATH <- "/Users/fredie/Documents/GitHub/PublicSecurity/"
DROPBOX_PATH <- "/Users/fredie/Library/CloudStorage/Dropbox/PublicSecurity/"

# Load necessary libraries
library(data.table)
library(dplyr)
library(janitor)

# Load data
load(paste0(DROPBOX_PATH, "build/datasus/output/clean_datasus.RData"))
load(paste0(DROPBOX_PATH, "build/population/output/clean_population.RData"))
load(paste0(DROPBOX_PATH, "build/pib municipal/output/clean_pib_munic.RData"))
load(paste0(DROPBOX_PATH, "build/idh/output/clean_idh.RData"))
load(paste0(DROPBOX_PATH, "build/area/output/clean_area.RData"))
load(paste0(DROPBOX_PATH, "build/rais/output/clean_rais.RData"))
load(paste0(DROPBOX_PATH, "build/delegacias/output/delegacias.RData"))
mun_codes = read.csv(paste0(DROPBOX_PATH, "build/municipios_codibge.csv"))

mun_codes = mun_codes %>%
  clean_names() %>%
  rename(municipality_code = codigo,
         municipality = nome,
         state = uf) %>%
  select(municipality_code, municipality, state)

# Adjusting dataset name
datasus = painel_mortalidade
rm(painel_mortalidade)

# Calculating population 2010 by state
clean_population[, population_2010_state := sum(population[year == 2010]), by = state]

# Prepare population and GDP data
pop_pib <- merge(clean_population, pib_munic, by = c("year", "municipality_code"), all.x = TRUE)
pop_pib[, `:=`(
  population_2000_muni = population[year == 2000],
  population_2010_muni = population[year == 2010]
), by = municipality_code]

# Filter relevant states
state_list <- unique(datasus$state)
pop_pib <- pop_pib[state %in% state_list]

# Merge main data
main_data <- merge(datasus, pop_pib, by = c("year", "municipality_code", "state"), all.x = TRUE)

# Function to calculate rate per 100,000 inhabitants
calcular_taxa <- function(x, population) {
  (sum(x, na.rm = TRUE) / sum(population, na.rm = TRUE)) * 1e5
}

# List of variables to calculate rates for
vars_to_calculate <- c(
  # Homicídios totais e suas categorias
  "homicidios_total", "homicidios_fora_casa", "homicidios_homem", "homicidios_mulher", 
  "homicidios_homem_jovem", "homicidios_mulher_jovem", 
  "homicidios_negro", "homicidios_branco", 
  "homicidios_negro_jovem", "homicidios_branco_jovem"
)

# Calculate rates by state and year
rate_state <- main_data[, c(lapply(.SD, calcular_taxa, population = population),
                            .(population = sum(population, na.rm = TRUE))),
                        by = .(state, year), 
                        .SDcols = vars_to_calculate
]

# Rename columns to indicate they are rates
setnames(rate_state, 
         vars_to_calculate, 
         paste0("taxa_", vars_to_calculate, "_por_100mil_state"))

# Calculate rates by municipality and year
rate_municipality <- main_data[, 
                               c(lapply(.SD, calcular_taxa, population = population),
                                 .(population = sum(population, na.rm = TRUE))),
                               by = .(municipality_code, year), 
                               .SDcols = vars_to_calculate
]

# Rename columns to indicate they are rates
setnames(rate_municipality, 
         vars_to_calculate, 
         paste0("taxa_", vars_to_calculate, "_por_100mil_munic"))

rate_municipality$population = NULL
rate_state$population = NULL

# Merge with main_data
main_data <- merge(main_data, rate_municipality, by = c("year", "municipality_code"), all.x = TRUE)

# Merge with main_data
main_data <- merge(main_data, rate_state, by = c("year", "state"), all.x = TRUE)

# List of states to calculate individual rates
target_states <- c("BA", "PE", "PB", "MA", "CE")

# Function to calculate rates for a specific state
calculate_state_rate <- function(state_code) {
  state_data <- main_data[state == state_code, 
                          lapply(.SD, calcular_taxa, population = population), 
                          by = year, 
                          .SDcols = vars_to_calculate
  ]
  setnames(state_data, names(state_data)[-1], paste0("taxa_", names(state_data)[-1], "_por_100mil_", state_code))
  return(state_data)
}

# Calculate rates for each target state
state_rates <- lapply(target_states, calculate_state_rate)

# Combine all state rates
all_state_rates <- Reduce(function(x, y) merge(x, y, by = "year", all = TRUE), state_rates)

# Calculate rates for other states
other_states <- main_data[!state %in% target_states, 
                          lapply(.SD, calcular_taxa, population = population), 
                          by = year, 
                          .SDcols = vars_to_calculate
]
setnames(other_states, names(other_states)[-1], paste0("taxa_", names(other_states)[-1], "_por_100mil_other_states"))


# Merge results for Bahia and other states
full_states <- merge(all_state_rates, other_states, by = "year", all = TRUE)

# Merge with main data
main_data <- merge(main_data, full_states, by = "year", all.x = TRUE)

# Calculating PIB per capita
main_data[, `:=`(pib_municipal_per_capita = pib_municipal/population)]

# Merging Main Data with IDH data
main_data <- merge(main_data, idh, by = c("year", "municipality_code"), all.x = TRUE)

# Excluding unecessary column
main_data$populacao = NULL

# Merging Main Data with mun_codes
main_data = merge(main_data, mun_codes, by = c("municipality_code", "state"), all.x = T)

# Merging Main Data with area data
main_data = merge(main_data, area, by = c("municipality_code"), all.x = T)

# Calculando a densidade populacional por estado e ano
density_by_state <- main_data %>%
  group_by(state, year) %>%
  summarise(
    population_state = sum(population, na.rm = TRUE),
    area_km2_state = sum(area_km2, na.rm = TRUE),
    pop_density_state = population_state / area_km2_state,
    .groups = "drop"
  )

# Calculando a densidade populacional por município e ano
density_by_municipality <- main_data %>%
  group_by(municipality_code, year) %>%
  summarise(
    population_muni = sum(population, na.rm = TRUE),
    area_km2_muni = sum(area_km2, na.rm = T),
    pop_density_municipality = population_muni / area_km2_muni,
    .groups = "drop"
  )

# Merge
main_data = merge(main_data, density_by_state, by = c( "year", "state"), all.x = T)

# Merge
main_data = merge(main_data, density_by_municipality, by = c( "year", "municipality_code"), all.x = T)

# Excluding unecessary column
main_data$area_km2 = NULL

# Criar a variável log(pib_municipal)
main_data$log_pib_municipal_per_capita <- log(main_data$pib_municipal_per_capita)

main_data$state_code <- as.numeric(substr(main_data$municipality_code, 1, 2))

# Merging Main Data with RAIS
main_data = merge(main_data, clean_rais, by = c("year", "municipality_code", "state"), all.x = T)

# Merging Main Data with Delegacias
delegacias$state = NULL
delegacias$municipality_code = as.integer(delegacias$municipality_code)
main_data = merge(main_data, delegacias, by = c("municipality_code"), all.x = T)

# Relocating columns
main_data = main_data %>%
  relocate(year, municipality_code, municipality, state, taxa_homicidios_total_por_100mil_state,
           taxa_homicidios_total_por_100mil_munic, pop_density_state, pop_density_municipality,
           total_vinculos_state, total_vinculos_munic, total_estabelecimentos_state, total_estabelecimentos_munic,
           log_pib_municipal_per_capita, population_2000_muni, population_2010_muni,
           id_delegacia, distancia_delegacia_km)

# Substituir NA por 0 em todas colunas que contêm "bf"
main_data[,7:9] <- lapply(main_data[,7:9], function(x) replace(x, is.na(x), 0))

# Relocating columns
main_data = main_data %>%
  relocate(year, municipality_code, municipality, state, taxa_homicidios_total_por_100mil_state,
           taxa_homicidios_total_por_100mil_munic, pop_density_municipality,
           total_vinculos_munic, total_estabelecimentos_locais, total_func_pub_munic, funcionarios_superior,
           perc_superior,
           log_pib_municipal_per_capita, population_2000_muni, population_2010_muni,
           id_delegacia, distancia_delegacia_km)

# Save result
save(main_data, file = paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))
