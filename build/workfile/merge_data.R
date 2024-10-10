# Clear environment and set paths
rm(list = ls())
GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurityBahia/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurityBahia/"

# Load necessary libraries
library(data.table)
library(dplyr)

# Load data
load(paste0(DROPBOX_PATH, "build/datasus/output/clean_datasus.RData"))
load(paste0(DROPBOX_PATH, "build/population/output/clean_population.RData"))
load(paste0(DROPBOX_PATH, "build/pib municipal/output/clean_pib_munic.RData"))

# Adjusting dataset name
datasus = painel_homicidios
rm(painel_homicidios)

# Prepare population and GDP data
setDT(population)
setDT(pib_munic)
pop_pib <- merge(population, pib_munic, by = c("year", "municipality_code"), all.x = TRUE)
pop_pib[, `:=`(
  population_2000 = population[year == 2000],
  population_2010 = population[year == 2010]
), by = municipality_code]

# Filter relevant states
state_list <- unique(datasus$state)
pop_pib <- pop_pib[state %in% state_list]

# Merge main data
main_data <- merge(datasus, pop_pib, by = c("year", "municipality_code", "state"), all.x = TRUE)

# Calculate homicide rates per 100,000 inhabitants for different categories by municipality and year
main_data[, `:=`(
  taxa_homicidios_por_100mil_total_munic = (homicidios_total / population) * 1e5,
  taxa_homicidios_por_100mil_homem_munic = (homicidios_homem / population) * 1e5,
  taxa_homicidios_por_100mil_mulher_munic = (homicidios_mulher / population) * 1e5,
  taxa_homicidios_por_100mil_homem_jovem_munic = (homicidios_homem_jovem / population) * 1e5,
  taxa_homicidios_por_100mil_mulher_jovem_munic = (homicidios_mulher_jovem / population) * 1e5,
  taxa_homicidios_por_100mil_negro_munic = (homicidios_negro / population) * 1e5,
  taxa_homicidios_por_100mil_branco_munic = (homicidios_branco / population) * 1e5,
  taxa_homicidios_por_100mil_negro_jovem_munic = (homicidios_negro_jovem / population) * 1e5,
  taxa_homicidios_por_100mil_branco_jovem_munic = (homicidios_branco_jovem / population) * 1e5
), by = .(municipality_code, year)]

# Calculate homicide rate per state and year
homicide_rate <- main_data[, .(
  homicidios_total = sum(homicidios_total, na.rm = TRUE),
  population = sum(population, na.rm = TRUE)
), by = .(state, year)][, taxa_homicidios_por_100mil_total_states := (homicidios_total / population) * 1e5]

main_data <- merge(main_data, homicide_rate[, .(state, year, taxa_homicidios_por_100mil_total_states)], by = c("year", "state"), all.x = TRUE)

# Function to calculate homicide rate
calcular_taxa <- function(homicidios, populacao) {
  (sum(homicidios, na.rm = TRUE) / sum(populacao, na.rm = TRUE)) * 1e5
}

# Calculate rates for Bahia and other states
bahia <- main_data[state == "BA", lapply(.SD, calcular_taxa, populacao = population), 
                   by = year, .SDcols = patterns("^homicidios_")]
setnames(bahia, names(bahia)[-1], paste0(names(bahia)[-1], "_BA"))

other_states <- main_data[state != "BA", lapply(.SD, calcular_taxa, populacao = population), 
                          by = year, .SDcols = patterns("^homicidios_")]
setnames(other_states, names(other_states)[-1], paste0(names(other_states)[-1], "_other_states"))

# Merge results
full_states <- merge(bahia, other_states, by = "year", all = TRUE)
setnames(full_states, names(full_states)[-1], sub("homicidios_", "taxa_homicidios_por_100mil_", names(full_states)[-1]))

# Merge with main data
main_data <- merge(main_data, full_states, by = "year", all.x = TRUE)

# Save result
save(main_data, file = paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))