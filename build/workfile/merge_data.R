# Clear environment and set paths
rm(list = ls())
GITHUB_PATH <- "/Users/fredie/Documents/GitHub/PublicSecurity/"
DROPBOX_PATH <- "/Users/fredie/Library/CloudStorage/Dropbox/PublicSecurity/"

# Set macro global
outdir <- paste0(DROPBOX_PATH, "build/workfile/output")

# Load necessary libraries
library(data.table)
library(janitor)

# Load all data files at once using a vectorized approach
data_files <- c(
  "datasus" = "build/datasus/output/clean_datasus.RData",
  "population" = "build/population/output/clean_population.RData", 
  "pib_munic" = "build/pib municipal/output/clean_pib_munic.RData",
  "idh" = "build/idh/output/clean_idh.RData",
  "area" = "build/area/output/clean_area.RData",
  "rais" = "build/rais/output/clean_rais.RData",
  "delegacias" = "build/delegacias/output/delegacias.RData"
)

# Load data efficiently
invisible(lapply(paste0(DROPBOX_PATH, data_files), load, envir = .GlobalEnv))

# Load and clean municipality codes
mun_codes <- fread(paste0(DROPBOX_PATH, "build/municipios_codibge.csv")) %>%
  clean_names() %>%
  setnames(c("codigo", "nome", "uf"), c("municipality_code", "municipality", "state")) %>%
  .[, .(municipality_code, municipality, state)]

# Rename datasus dataset efficiently
datasus <- painel_mortalidade
rm(painel_mortalidade)

# Calculate population 2010 by state efficiently
clean_population[year == 2010, population_2010_state := sum(population), by = state]
clean_population[, population_2010_state := population_2010_state[year == 2010][1], by = state]

# Prepare population and GDP data with efficient joins
pop_pib <- merge(clean_population, pib_munic, by = c("year", "municipality_code"), all.x = TRUE)

# Add lagged population variables efficiently
pop_pib[, `:=`(
  population_2000_muni = population[year == 2000][1],
  population_2010_muni = population[year == 2010][1]
), by = municipality_code]

# Filter relevant states early to reduce data size
state_list <- unique(datasus$state)
pop_pib <- pop_pib[state %in% state_list]

# Main merge
main_data <- merge(datasus, pop_pib, by = c("year", "municipality_code", "state"), all.x = TRUE)

# Optimized rate calculation function
calcular_taxa <- function(x, population) {
  (sum(x, na.rm = TRUE) / sum(population, na.rm = TRUE)) * 1e5
}

# Variables for rate calculation
vars_to_calculate <- c(
  "homicidios_total", "homicidios_fora_casa", "homicidios_homem", "homicidios_mulher", 
  "homicidios_homem_jovem", "homicidios_mulher_jovem", 
  "homicidios_negro", "homicidios_branco", 
  "homicidios_negro_jovem", "homicidios_branco_jovem"
)

# Calculate all rates at once using efficient data.table operations
# State rates
rate_state <- main_data[, 
                        lapply(.SD, calcular_taxa, population = population),
                        by = .(state, year), 
                        .SDcols = vars_to_calculate
]
setnames(rate_state, vars_to_calculate, paste0("taxa_", vars_to_calculate, "_por_100mil_state"))

# Municipality rates  
rate_municipality <- main_data[, 
                               lapply(.SD, calcular_taxa, population = population),
                               by = .(municipality_code, year), 
                               .SDcols = vars_to_calculate
]
setnames(rate_municipality, vars_to_calculate, paste0("taxa_", vars_to_calculate, "_por_100mil_munic"))

# Merge rates back to main data
main_data <- merge(main_data, rate_municipality, by = c("year", "municipality_code"), all.x = TRUE)
main_data <- merge(main_data, rate_state, by = c("year", "state"), all.x = TRUE)

# Calculate specific state rates more efficiently
target_states <- c("BA", "PE", "PB", "MA", "CE")

# Create all state rates at once using reshape operations
state_rates_long <- main_data[state %in% target_states, 
                              lapply(.SD, calcular_taxa, population = population), 
                              by = .(state, year), 
                              .SDcols = vars_to_calculate
]

# Reshape to wide format
state_rates_wide <- dcast(melt(state_rates_long, id.vars = c("state", "year")), 
                          year ~ state + variable, 
                          value.var = "value")

# Fix column names
new_names <- names(state_rates_wide)[-1]
new_names <- gsub("_homicidios", "_taxa_homicidios", new_names)
new_names <- paste0(new_names, "_por_100mil")
setnames(state_rates_wide, names(state_rates_wide)[-1], new_names)

# Calculate other states rates
other_states <- main_data[!state %in% target_states, 
                          lapply(.SD, calcular_taxa, population = population), 
                          by = year, 
                          .SDcols = vars_to_calculate
]
setnames(other_states, vars_to_calculate, paste0("taxa_", vars_to_calculate, "_por_100mil_other_states"))

# Merge state-specific rates
main_data <- merge(main_data, state_rates_wide, by = "year", all.x = TRUE)
main_data <- merge(main_data, other_states, by = "year", all.x = TRUE)

# Calculate PIB per capita efficiently
main_data[, pib_municipal_per_capita := pib_municipal / population]

# Merge additional datasets
main_data <- merge(main_data, idh, by = c("year", "municipality_code"), all.x = TRUE)
main_data[, populacao := NULL] # Remove unnecessary column

main_data <- merge(main_data, mun_codes, by = c("municipality_code", "state"), all.x = TRUE)
main_data <- merge(main_data, area, by = "municipality_code", all.x = TRUE)

# Calculate density efficiently using data.table operations
main_data[, `:=`(
  population_state = sum(population, na.rm = TRUE),
  area_km2_state = sum(area_km2, na.rm = TRUE)
), by = .(state, year)]

main_data[, pop_density_state := population_state / area_km2_state]
main_data[, pop_density_municipality := population / area_km2]

# Clean up temporary columns
main_data[, `:=`(population_state = NULL, area_km2_state = NULL, area_km2 = NULL)]

# Create log variable
main_data[, log_pib_municipal_per_capita := log(pib_municipal_per_capita)]
main_data[, state_code := as.numeric(substr(municipality_code, 1, 2))]

# Merge remaining datasets
main_data <- merge(main_data, clean_rais, by = c("year", "municipality_code", "state"), all.x = TRUE)

# Prepare delegacias data
delegacias[, `:=`(state = NULL, municipality_code = as.integer(municipality_code))]
main_data <- merge(main_data, delegacias, by = "municipality_code", all.x = TRUE)

# Column ordering and final cleaning
key_cols <- c("year", "municipality_code", "municipality", "state", 
              "taxa_homicidios_total_por_100mil_state", "taxa_homicidios_total_por_100mil_munic",
              "pop_density_municipality", "total_vinculos_munic", "total_estabelecimentos_locais", 
              "total_func_pub_munic", "funcionarios_superior", "perc_superior",
              "log_pib_municipal_per_capita", "population_2000_muni", "population_2010_muni",
              "id_delegacia", "distancia_delegacia_km")

# Reorder columns efficiently
setcolorder(main_data, c(key_cols, setdiff(names(main_data), key_cols)))

# Replace NA with 0 in specific columns (if they exist)
na_cols <- intersect(names(main_data)[7:9], names(main_data))
if(length(na_cols) > 0) {
  main_data[, (na_cols) := lapply(.SD, function(x) fifelse(is.na(x), 0, x)), .SDcols = na_cols]
}

# Save result
save(main_data, file = paste0(outdir, "/main_data.RData"))
