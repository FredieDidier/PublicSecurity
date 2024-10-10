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

# Saving
save(main_data, file = paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))
