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