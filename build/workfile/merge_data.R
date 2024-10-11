# Clear environment and set paths
rm(list = ls())
GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurityBahia/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurityBahia/"

# Load necessary libraries
library(data.table)
library(dplyr)
library(janitor)

# Load data
load(paste0(DROPBOX_PATH, "build/datasus/output/clean_datasus.RData"))
load(paste0(DROPBOX_PATH, "build/population/output/clean_population.RData"))
load(paste0(DROPBOX_PATH, "build/pib municipal/output/clean_pib_munic.RData"))
load(paste0(DROPBOX_PATH, "build/idh/output/clean_idh.RData"))
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

# Prepare population and GDP data
setDT(population)
setDT(pib_munic)
pop_pib <- merge(population, pib_munic, by = c("year", "municipality_code"), all.x = TRUE)
pop_pib[, `:=`(
  population_2010 = population[year == 2010]
), by = municipality_code]

# Filter relevant states
state_list <- unique(datasus$state)
pop_pib <- pop_pib[state %in% state_list]

# Merge main data
main_data <- merge(datasus, pop_pib, by = c("year", "municipality_code", "state"), all.x = TRUE)

# Calculating homicide rate for  per 100,000 inhabitants for different categories by state and year
homicide_rate_state <- main_data[, .(
  homicidios_total = sum(homicidios_total, na.rm = TRUE),
  population = sum(population, na.rm = TRUE),
  homicidios_homem = sum(homicidios_homem, na.rm = TRUE),
  homicidios_mulher = sum(homicidios_mulher, na.rm = TRUE),
  homicidios_homem_jovem = sum(homicidios_homem_jovem, na.rm = TRUE),
  homicidios_mulher_jovem = sum(homicidios_mulher_jovem, na.rm = TRUE),
  homicidios_negro = sum(homicidios_negro, na.rm = TRUE),
  homicidios_branco = sum(homicidios_branco, na.rm = TRUE),
  homicidios_negro_jovem = sum(homicidios_negro_jovem, na.rm = TRUE),
  homicidios_branco_jovem = sum(homicidios_branco_jovem, na.rm = TRUE)
), by = .(state, year)][, `:=` (
  taxa_homicidios_por_100mil_total_states = (homicidios_total / population) * 1e5,
  taxa_homicidios_homem_por_100mil_total_states = (homicidios_homem / population) * 1e5,
  taxa_homicidios_mulher_por_100mil_total_states = (homicidios_mulher / population) * 1e5,
  taxa_homicidios_homem_jovem_por_100mil_total_states = (homicidios_homem_jovem / population) * 1e5,
  taxa_homicidios_mulher_jovem_por_100mil_total_states = (homicidios_mulher_jovem / population) * 1e5,
  taxa_homicidios_negro_por_100mil_total_states = (homicidios_negro / population) * 1e5,
  taxa_homicidios_branco_por_100mil_total_states = (homicidios_branco / population) * 1e5,
  taxa_homicidios_negro_jovem_por_100mil_total_states = (homicidios_negro_jovem / population) * 1e5,
  taxa_homicidios_branco_jovem_por_100mil_total_states = (homicidios_branco_jovem / population) * 1e5
)]

main_data <- merge(main_data, homicide_rate_state[, .(state, year, taxa_homicidios_por_100mil_total_states,
                                                taxa_homicidios_homem_por_100mil_total_states,
                                                taxa_homicidios_mulher_por_100mil_total_states,
                                                taxa_homicidios_homem_jovem_por_100mil_total_states,
                                                taxa_homicidios_mulher_jovem_por_100mil_total_states,
                                                taxa_homicidios_negro_por_100mil_total_states,
                                                taxa_homicidios_branco_por_100mil_total_states,
                                                taxa_homicidios_negro_jovem_por_100mil_total_states,
                                                taxa_homicidios_branco_jovem_por_100mil_total_states)], by = c("year", "state"), all.x = TRUE)

# Calculate homicide rates per 100,000 inhabitants for different categories by municipality and year
homicide_rate_municipality = main_data[, .(
  homicidios_total = sum(homicidios_total, na.rm = TRUE),
  population = sum(population, na.rm = TRUE),
  homicidios_homem = sum(homicidios_homem, na.rm = TRUE),
  homicidios_mulher = sum(homicidios_mulher, na.rm = TRUE),
  homicidios_homem_jovem = sum(homicidios_homem_jovem, na.rm = TRUE),
  homicidios_mulher_jovem = sum(homicidios_mulher_jovem, na.rm = TRUE),
  homicidios_negro = sum(homicidios_negro, na.rm = TRUE),
  homicidios_branco = sum(homicidios_branco, na.rm = TRUE),
  homicidios_negro_jovem = sum(homicidios_negro_jovem, na.rm = TRUE),
  homicidios_branco_jovem = sum(homicidios_branco_jovem, na.rm = TRUE)
), by = .(municipality_code, year)] [, `:=` (
  taxa_homicidios_por_100mil_total_munic = (homicidios_total / population) * 1e5,
  taxa_homicidios_homem_por_100mil_total_munic = (homicidios_homem / population) * 1e5,
  taxa_homicidios_mulher_por_100mil_total_munic = (homicidios_mulher / population) * 1e5,
  taxa_homicidios_homem_jovem_por_100mil_total_munic = (homicidios_homem_jovem / population) * 1e5,
  taxa_homicidios_mulher_jovem_por_100mil_total_munic = (homicidios_mulher_jovem / population) * 1e5,
  taxa_homicidios_negro_por_100mil_total_munic = (homicidios_negro / population) * 1e5,
  taxa_homicidios_branco_por_100mil_total_munic = (homicidios_branco / population) * 1e5,
  taxa_homicidios_negro_jovem_por_100mil_total_munic = (homicidios_negro_jovem / population) * 1e5,
  taxa_homicidios_branco_jovem_por_100mil_total_munic = (homicidios_branco_jovem / population) * 1e5
)]

main_data <- merge(main_data, homicide_rate_municipality[, .(municipality_code, year, taxa_homicidios_por_100mil_total_munic,
                                                      taxa_homicidios_homem_por_100mil_total_munic,
                                                      taxa_homicidios_mulher_por_100mil_total_munic,
                                                      taxa_homicidios_homem_jovem_por_100mil_total_munic,
                                                      taxa_homicidios_mulher_jovem_por_100mil_total_munic,
                                                      taxa_homicidios_negro_por_100mil_total_munic,
                                                      taxa_homicidios_branco_por_100mil_total_munic,
                                                      taxa_homicidios_negro_jovem_por_100mil_total_munic,
                                                      taxa_homicidios_branco_jovem_por_100mil_total_munic)], by = c("year", "municipality_code"), all.x = TRUE)


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

# Calculating PIB per capita
main_data[, `:=`(pib_municipal_per_capita = pib_municipal/population)]

# Merging Main Data with IDH data
main_data <- merge(main_data, idh, by = c("year", "municipality_code"), all.x = TRUE)

# Excluding unecessary column
main_data$populacao = NULL

# Merging Main Data with mun_codes
main_data = merge(main_data, mun_codes, by = c("municipality_code", "state"), all.x = T)

main_data = main_data %>%
  relocate(year, municipality_code, municipality, state, taxa_homicidios_por_100mil_total_states,
           taxa_homicidios_homem_por_100mil_total_munic)

# Save result
save(main_data, file = paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))
