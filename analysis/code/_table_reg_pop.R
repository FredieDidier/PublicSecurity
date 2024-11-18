library(data.table)
library(tidyverse)
library(fixest)
library(fwildclusterboot)

# Remover municípios específicos
main_data <- main_data[!(main_data$municipality_code == 2300000 | 
                           main_data$municipality_code == 2600000), ]

# Remover NAs
main_data <- main_data[!is.na(main_data$population_2000_muni), ]

# Criar variável de tratamento
main_data$treated <- 0
main_data$treated[main_data$state == "PE" & main_data$year >= 2007] <- 1
main_data$treated[main_data$state == "BA" & main_data$year >= 2011] <- 1
main_data$treated[main_data$state == "PB" & main_data$year >= 2011] <- 1
main_data$treated[main_data$state == "CE" & main_data$year >= 2015] <- 1
main_data$treated[main_data$state == "MA" & main_data$year >= 2016] <- 1

# Criar variável de ano de tratamento
main_data[, treatment_year := 0] 
main_data$treatment_year[main_data$state == "BA" | main_data$state == "PB"] <- 2011
main_data$treatment_year[main_data$state == "CE"] <- 2015
main_data$treatment_year[main_data$state == "MA"] <- 2016
main_data$treatment_year[main_data$state == "PE"] <- 2007

# Criar variável de tempo relativo ao tratamento
main_data$rel_year <- main_data$year - main_data$treatment_year
# Criar variaveis
main_data$treated_population = main_data$treated * main_data$population_muni
main_data$log_population_muni = log(main_data$population_muni)
main_data$treated_log_population =  main_data$treated * main_data$log_population_muni
main_data$population_median = main_data$population_muni > median(main_data$population_muni, na.rm = TRUE)
main_data$treated_population_median =  main_data$treated * main_data$population_median

# Criar dummy para municípios acima da mediana populacional em 2000
main_data$treated_population_2000 =  main_data$treated * main_data$population_2000_muni
main_data$population_2000_median = main_data$population_2000_muni > median(main_data$population_2000_muni, na.rm = TRUE)
main_data$treated_population_2000_median =  main_data$treated * main_data$population_2000_median
main_data$log_population_2000_muni = log(main_data$population_2000_muni)
main_data$treated_log_population_2000 =  main_data$treated * main_data$log_population_2000_muni
main_data$log_tx_homicidio = log(main_data$taxa_homicidios_total_por_100mil_munic + 1)

# Rodar as regressões
reg1 <- feols(taxa_homicidios_total_por_100mil_munic ~ treated + treated_population | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg2 <- feols(log_tx_homicidio ~ treated + treated_population | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg3 <- feols(taxa_homicidios_total_por_100mil_munic ~ treated + treated_population_median | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg4 <- feols(log_tx_homicidio ~ treated + treated_population_median | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg5 <- feols(taxa_homicidios_total_por_100mil_munic ~ treated + treated_log_population | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg6 <- feols(log_tx_homicidio ~ treated + treated_log_population | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg7 <- feols(taxa_homicidios_total_por_100mil_munic ~ treated + treated_population_2000 | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg8 <- feols(log_tx_homicidio ~ treated + treated_population_2000 | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg9 <- feols(taxa_homicidios_total_por_100mil_munic ~ treated + treated_population_2000_median | 
                municipality_code + year,
              data = main_data,
              weights = ~ population_2000_muni,
              cluster = c("state_code"))

reg10 <- feols(log_tx_homicidio ~ treated + treated_population_2000_median | 
                 municipality_code + year,
               data = main_data,
               weights = ~ population_2000_muni,
               cluster = c("state_code"))

reg11 <- feols(taxa_homicidios_total_por_100mil_munic ~ treated + treated_log_population_2000 | 
                 municipality_code + year,
               data = main_data,
               weights = ~ population_2000_muni,
               cluster = c("state_code"))

reg12 <- feols(log_tx_homicidio ~ treated + treated_log_population_2000 | 
                 municipality_code + year,
               data = main_data,
               weights = ~ population_2000_muni,
               cluster = c("state_code"))

# Criar dicionário
dict <- c("taxa_homicidios_total_por_100mil_munic" = "Homicide Rate",
          "log_tx_homicidio" = "Log(Homicide Rate + 1)",
          "treated" = "Treated",
          "treated_population" = "Treated × Pop",
          "treated_population_median" = "Treated × Pop > Median",
          "treated_log_population" = "Treated × Log(Pop)",
          "treated_population_2000" = "Treated × Pop 2000",
          "treated_population_2000_median" = "Treated × Pop 2000 > Median",
          "treated_log_population_2000" = "Treated × Log(Pop 2000)",
          "municipality_code" = "Municipality",
          "year" = "Year")

regression_table = etable(reg1, reg2, reg3, reg4, reg5, reg6,
                          reg7, reg8, reg9, reg10, reg11, reg12,
                          cluster = ~ state_code + municipality_code,
                          signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
                          digits = 4,
                          fixef_sizes = TRUE,
                          title = "Impact of Policy on Homicide Rates by Population Size",
                          dict = dict,
                          file = paste0(GITHUB_PATH, "analysis/output/tables/pop_size.tex"))



############################################

# Robustness Analysis (Distance to Treated Border)

############################################

# Criar as três subamostras baseadas na distância e criar variável neighbor
main_data_100km <- main_data %>% 
  filter(dist_treated < 100) %>%
  rename(neighbor = treated,
         neighbor_population = treated_population,
         neighbor_population_median = treated_population_median,
         neighbor_log_population = treated_log_population,
         neighbor_population_2000 = treated_population_2000,
         neighbor_population_2000_median = treated_population_2000_median,
         neighbor_log_population_2000 = treated_log_population_2000)

main_data_75km <- main_data %>% 
  filter(dist_treated < 75) %>%
  rename(neighbor = treated,
         neighbor_population = treated_population,
         neighbor_population_median = treated_population_median,
         neighbor_log_population = treated_log_population,
         neighbor_population_2000 = treated_population_2000,
         neighbor_population_2000_median = treated_population_2000_median,
         neighbor_log_population_2000 = treated_log_population_2000)

main_data_50km <- main_data %>% 
  filter(dist_treated < 50) %>%
  rename(neighbor = treated,
         neighbor_population = treated_population,
         neighbor_population_median = treated_population_median,
         neighbor_log_population = treated_log_population,
         neighbor_population_2000 = treated_population_2000,
         neighbor_population_2000_median = treated_population_2000_median,
         neighbor_log_population_2000 = treated_log_population_2000)

# Função para rodar todas as regressões em uma subamostra
run_all_regressions <- function(data) {
  # Taxa de homicídio em nível
  reg1 <- feols(taxa_homicidios_total_por_100mil_munic ~ neighbor + neighbor_population | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg2 <- feols(log_tx_homicidio ~ neighbor + neighbor_population | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg3 <- feols(taxa_homicidios_total_por_100mil_munic ~ neighbor + neighbor_population_median | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg4 <- feols(log_tx_homicidio ~ neighbor + neighbor_population_median | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg5 <- feols(taxa_homicidios_total_por_100mil_munic ~ neighbor + neighbor_log_population | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg6 <- feols(log_tx_homicidio ~ neighbor + neighbor_log_population | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg7 <- feols(taxa_homicidios_total_por_100mil_munic ~ neighbor + neighbor_population_2000 | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg8 <- feols(log_tx_homicidio ~ neighbor + neighbor_population_2000 | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg9 <- feols(taxa_homicidios_total_por_100mil_munic ~ neighbor + neighbor_population_2000_median | 
                  municipality_code + year,
                data = data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg10 <- feols(log_tx_homicidio ~ neighbor + neighbor_population_2000_median | 
                   municipality_code + year,
                 data = data,
                 weights = ~ population_2000_muni,
                 cluster = c("state_code"))
  
  reg11 <- feols(taxa_homicidios_total_por_100mil_munic ~ neighbor + neighbor_log_population_2000 | 
                   municipality_code + year,
                 data = data,
                 weights = ~ population_2000_muni,
                 cluster = c("state_code"))
  
  reg12 <- feols(log_tx_homicidio ~ neighbor + neighbor_log_population_2000 | 
                   municipality_code + year,
                 data = data,
                 weights = ~ population_2000_muni,
                 cluster = c("state_code"))
  
  return(list(reg1, reg2, reg3, reg4, reg5, reg6,
              reg7, reg8, reg9, reg10, reg11, reg12))
}

# Rodar regressões para cada subamostra
regs_100km <- run_all_regressions(main_data_100km)
regs_75km <- run_all_regressions(main_data_75km)
regs_50km <- run_all_regressions(main_data_50km)

# Criar dicionário atualizado com os novos nomes
dict <- c("taxa_homicidios_total_por_100mil_munic" = "Homicide Rate",
          "log_tx_homicidio" = "Log(Homicide Rate + 1)",
          "neighbor" = "Neighbor",
          "neighbor_population" = "Neighbor × Pop",
          "neighbor_population_median" = "Neighbor × Pop > Median",
          "neighbor_log_population" = "Neighbor × Log(Pop)",
          "neighbor_population_2000" = "Neighbor × Pop 2000",
          "neighbor_population_2000_median" = "Neighbor × Pop 2000 > Median",
          "neighbor_log_population_2000" = "Neighbor × Log(Pop 2000)",
          "municipality_code" = "Municipality",
          "year" = "Year")

# Criar uma única tabela com todas as regressões
regression_table = etable(
  # 100km
  regs_100km[[1]], regs_100km[[2]], 
  regs_100km[[3]], regs_100km[[4]], 
  regs_100km[[5]], regs_100km[[6]],
  regs_100km[[7]], regs_100km[[8]], 
  regs_100km[[9]], regs_100km[[10]], 
  regs_100km[[11]], regs_100km[[12]],
  # 75km
  regs_75km[[1]], regs_75km[[2]], 
  regs_75km[[3]], regs_75km[[4]], 
  regs_75km[[5]], regs_75km[[6]],
  regs_75km[[7]], regs_75km[[8]], 
  regs_75km[[9]], regs_75km[[10]], 
  regs_75km[[11]], regs_75km[[12]],
  # 50km
  regs_50km[[1]], regs_50km[[2]], 
  regs_50km[[3]], regs_50km[[4]], 
  regs_50km[[5]], regs_50km[[6]],
  regs_50km[[7]], regs_50km[[8]], 
  regs_50km[[9]], regs_50km[[10]], 
  regs_50km[[11]], regs_50km[[12]],
  cluster = ~ state_code,
  signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  digits = 4,
  fixef_sizes = TRUE,
  title = "Impact of Policy on Homicide Rates by Distance from Border",
  dict = dict,
  headers = c(rep("100km", 12), rep("75km", 12), rep("50km", 12)),
  file = paste0(GITHUB_PATH, "analysis/output/tables/border_analysis.tex")
)


#################################
#.   SPILLOVER ANALYSIS
##################################

# Create spillover variables for different distance thresholds
distance_thresholds <- c(50, 75, 100)

# Filtrar apenas estados não tratados
main_data <- main_data[!state %in% c("PE", "BA", "PB", "CE", "MA")]

for(dist in distance_thresholds) {

  # Initialize spillover variable
  main_data[, paste0("spillover_", dist) := 0]
  
  # 2007-2010: Only PE spillovers
  main_data[year >= 2007 & year <= 2010 & 
              !state %in% c("PE", "BA", "PB", "CE", "MA") & 
              dist_PE <= dist, 
            paste0("spillover_", dist) := 1]
  
  # 2011-2014: PE, BA, PB spillovers (take minimum distance)
  main_data[year >= 2011 & year <= 2014 & 
              !state %in% c("PE", "BA", "PB", "CE", "MA") & 
              pmin(dist_PE, dist_BA, dist_PB) <= dist, 
            paste0("spillover_", dist) := 1]
  
  # 2015: PE, BA, PB, CE spillovers
  main_data[year == 2015 & 
              !state %in% c("PE", "BA", "PB", "CE", "MA") & 
              pmin(dist_PE, dist_BA, dist_PB, dist_CE) <= dist, 
            paste0("spillover_", dist) := 1]
  
  # 2016 onwards: All treated states spillovers
  main_data[year >= 2016 & 
              !state %in% c("PE", "BA", "PB", "CE", "MA") & 
              pmin(dist_PE, dist_BA, dist_PB, dist_CE, dist_MA) <= dist, 
            paste0("spillover_", dist) := 1]
  
  # Create population interaction terms (current and 2000)
  main_data[, paste0("spillover_", dist, "_population") := 
              get(paste0("spillover_", dist)) * population_muni]
  main_data[, paste0("spillover_", dist, "_population_median") := 
              get(paste0("spillover_", dist)) * population_median]
  main_data[, paste0("spillover_", dist, "_log_population") := 
              get(paste0("spillover_", dist)) * log_population_muni]
  
  # 2000 population interactions
  main_data[, paste0("spillover_", dist, "_population_2000") := 
              get(paste0("spillover_", dist)) * population_2000_muni]
  main_data[, paste0("spillover_", dist, "_population_2000_median") := 
              get(paste0("spillover_", dist)) * population_2000_median]
  main_data[, paste0("spillover_", dist, "_log_population_2000") := 
              get(paste0("spillover_", dist)) * log_population_2000_muni]
}

# Function to run regressions for each distance and specification
run_spillover_regressions <- function(dist) {
  # Linear specifications
  reg1 <- feols(taxa_homicidios_total_por_100mil_munic ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg2 <- feols(log_tx_homicidio ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  # Median specifications
  reg3 <- feols(taxa_homicidios_total_por_100mil_munic ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population_median")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg4 <- feols(log_tx_homicidio ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population_median")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  # Log specifications
  reg5 <- feols(taxa_homicidios_total_por_100mil_munic ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_log_population")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg6 <- feols(log_tx_homicidio ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_log_population")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  # 2000 population specifications
  reg7 <- feols(taxa_homicidios_total_por_100mil_munic ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population_2000")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg8 <- feols(log_tx_homicidio ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population_2000")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg9 <- feols(taxa_homicidios_total_por_100mil_munic ~ 
                  get(paste0("spillover_", dist)) + 
                  get(paste0("spillover_", dist, "_population_2000_median")) | 
                  municipality_code + year,
                data = main_data,
                weights = ~ population_2000_muni,
                cluster = c("state_code"))
  
  reg10 <- feols(log_tx_homicidio ~ 
                   get(paste0("spillover_", dist)) + 
                   get(paste0("spillover_", dist, "_population_2000_median")) | 
                   municipality_code + year,
                 data = main_data,
                 weights = ~ population_2000_muni,
                 cluster = c("state_code"))
  
  reg11 <- feols(taxa_homicidios_total_por_100mil_munic ~ 
                   get(paste0("spillover_", dist)) + 
                   get(paste0("spillover_", dist, "_log_population_2000")) | 
                   municipality_code + year,
                 data = main_data,
                 weights = ~ population_2000_muni,
                 cluster = c("state_code"))
  
  reg12 <- feols(log_tx_homicidio ~ 
                   get(paste0("spillover_", dist)) + 
                   get(paste0("spillover_", dist, "_log_population_2000")) | 
                   municipality_code + year,
                 data = main_data,
                 weights = ~ population_2000_muni,
                 cluster = c("state_code"))
  
  return(list(reg1, reg2, reg3, reg4, reg5, reg6, reg7, reg8, reg9, reg10, reg11, reg12))
}

# Run all regressions and create tables
all_regressions <- list()
for (dist in distance_thresholds) {
  all_regressions[[as.character(dist)]] <- run_spillover_regressions(dist)
}

dict_spillover <- c(
  # [Previous dictionary entries remain the same]
  "spillover_50_population_2000" = "Spillover (50km) × Pop 2000",
  "spillover_75_population_2000" = "Spillover (75km) × Pop 2000",
  "spillover_100_population_2000" = "Spillover (100km) × Pop 2000",
  "spillover_50_population_2000_median" = "Spillover (50km) × Pop 2000 > Median",
  "spillover_75_population_2000_median" = "Spillover (75km) × Pop 2000 > Median",
  "spillover_100_population_2000_median" = "Spillover (100km) × Pop 2000 > Median",
  "spillover_50_log_population_2000" = "Spillover (50km) × Log(Pop 2000)",
  "spillover_75_log_population_2000" = "Spillover (75km) × Log(Pop 2000)",
  "spillover_100_log_population_2000" = "Spillover (100km) × Log(Pop 2000)"
)
# Create single regression table with all specifications
regression_table = etable(
  # 50km specifications
  all_regressions[["50"]][[1]], all_regressions[["50"]][[2]], 
  all_regressions[["50"]][[3]], all_regressions[["50"]][[4]],
  all_regressions[["50"]][[5]], all_regressions[["50"]][[6]],
  all_regressions[["50"]][[7]], all_regressions[["50"]][[8]],
  all_regressions[["50"]][[9]], all_regressions[["50"]][[10]], 
  all_regressions[["50"]][[11]], all_regressions[["50"]][[12]],
  # 75km specifications  
  all_regressions[["75"]][[1]], all_regressions[["75"]][[2]],
  all_regressions[["75"]][[3]], all_regressions[["75"]][[4]],
  all_regressions[["75"]][[5]], all_regressions[["75"]][[6]],
  all_regressions[["75"]][[7]], all_regressions[["75"]][[8]],
  all_regressions[["75"]][[9]], all_regressions[["75"]][[10]],
  all_regressions[["75"]][[11]], all_regressions[["75"]][[12]],
  # 100km specifications
  all_regressions[["100"]][[1]], all_regressions[["100"]][[2]],
  all_regressions[["100"]][[3]], all_regressions[["100"]][[4]], 
  all_regressions[["100"]][[5]], all_regressions[["100"]][[6]],
  all_regressions[["100"]][[7]], all_regressions[["100"]][[8]],
  all_regressions[["100"]][[9]], all_regressions[["100"]][[10]],
  all_regressions[["100"]][[11]], all_regressions[["100"]][[12]],
  cluster = ~ state_code + municipality_code,
  signif.code = c("***" = 0.01, "**" = 0.05, "*" = 0.1),
  digits = 4,
  fixef_sizes = TRUE,
  title = "Spillover Effects by Distance and Population",
  dict = dict_spillover,
  file = paste0(GITHUB_PATH, "analysis/output/tables/spillover_all.tex"))
