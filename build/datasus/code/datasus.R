# I use Base dos Dados package to extract Datasus Mortality Data 
# In their website (https://basedosdados.org) you will get information on how to download the data

library(basedosdados)
library(data.table)
library(tidyverse)
library(janitor)

query <- "SELECT * FROM `basedosdados.br_ms_sim.microdados`"
sim_do <- download(query, path = "/Users/Fredie/Downloads/SIM DO/sim.do.csv",
                 billing_project_id = "sodium-surf-307721")

# Saving Input Data
sim_do = write.csv(paste0(DROPBOX_PATH, "build/datasus/input/sim.do.csv"))

rm(sim_do)

# Loading Data
sim_do = fread(paste0(DROPBOX_PATH, "build/datasus/input/sim.do.csv"))

# Selecting Northeastern States that will compose the analysis (PB and PE had similar programs going on simultaneously)
sim_do = sim_do[sigla_uf %in% c("BA", "MA", "PI", "CE", "RN", "AL", "SE")]

# Ensure the 'data_obito' column is in date format
sim_do$data_obito <- as.Date(sim_do$data_obito, format = "%Y-%m-%d")

# Define the cutoff date for Ceará (similar program started in August 2015)
data_corte_ceara <- as.Date("2015-08-01")

# Define the cutoff date for Maranhão (similar program started in 2016)
data_corte_maranhao <- as.Date("2016-01-01")

# Selecting Years that will compose the analysis
sim_do = sim_do[ano %in% c(2007:2019)]

# Create sequence of homicide codes
codigos_homicidio <- c(paste0("X", 85:99), paste0("Y0", 0:9))

# Create column to identify homicides
sim_do[, homicidio := as.integer(substr(causa_basica, 1, 3) %in% codigos_homicidio)]

# Create a new column 'sigla_uf_code' that contains the first two digits of 'id_municipio_ocorrencia'
sim_do$sigla_uf_code_residencia <- as.numeric(substr(sim_do$id_municipio_residencia, 1, 2))

sim_do = sim_do %>%
  relocate(ano, sigla_uf, sigla_uf_code_residencia)

# Criar o dicionário de correspondência entre o código da UF e a sigla da UF
uf_dict <- c("21" = "MA", "22" = "PI", "23" = "CE", 
             "24" = "RN", "27" = "AL", "28" = "SE", 
             "29" = "BA")

sim_do <- sim_do %>%
  mutate(
    # Extrair os dois primeiros dígitos de 'id_municipio_ocorrencia'
    code_ocorrencia = substr(id_municipio_ocorrencia, 1, 2),
    # Verificar se o 'id_municipio_ocorrencia' é válido e diferente do código de residência
    sigla_uf_code_ocorrencia = ifelse(
      !is.na(id_municipio_ocorrencia), 
      uf_dict[code_ocorrencia],  # Associar ao UF correto se existir código
      NA_character_  # Manter como NA caso não exista
    )
  )

sim_do = sim_do %>%
  relocate(ano, sigla_uf, sigla_uf_code_residencia, id_municipio_residencia,
           sigla_uf_code_ocorrencia, id_municipio_ocorrencia, homicidio)

# Remove observations from Ceará after August 2015
sim_do = sim_do[!(sigla_uf_code_ocorrencia == "CE" & sim_do$data_obito >= data_corte_ceara),]

# Remove observations from Maranhão after 2016
sim_do = sim_do[!(sigla_uf_code_ocorrencia == "MA" & sim_do$data_obito >= data_corte_maranhao),]

# Creating Gender, Race and Young Individuals columns
sim_do[, `:=`(
  negro = ifelse(raca_cor %in% c(2, 4, 5), 1, 0),
  negro_jovem = ifelse(raca_cor %in% c(2, 4, 5) & idade <= 25, 1, 0),
  branco = ifelse(raca_cor %in% c(1, 3), 1, 0),
  branco_jovem = ifelse(raca_cor %in% c(1, 3) & idade <= 25, 1, 0),
  mulher = ifelse(sexo == 2, 1, 0),
  mulher_jovem = ifelse(sexo == 2 & idade <= 25, 1, 0),
  homem = ifelse(sexo == 1, 1, 0),
  homem_jovem = ifelse(sexo == 1 & idade<= 25, 1, 0)
)]

# Create Panel
painel_homicidios = sim_do[, .(
  homicidios_total = sum(homicidio, na.rm = TRUE),
  homicidios_negro = sum(homicidio * negro, na.rm = TRUE),
  homicidios_negro_jovem = sum(homicidio * negro_jovem, na.rm = TRUE),
  homicidios_branco = sum(homicidio * branco, na.rm = TRUE),
  homicidios_branco_jovem = sum(homicidio * branco_jovem, na.rm = TRUE),
  homicidios_mulher = sum(homicidio * mulher, na.rm = TRUE),
  homicidios_mulher_jovem  = sum(homicidio * mulher_jovem, na.rm = TRUE),
  homicidios_homem = sum(homicidio * homem, na.rm = TRUE),
  homicidios_homem_jovem  = sum(homicidio * homem_jovem, na.rm = TRUE)
), by = .(ano, sigla_uf_code_ocorrencia, id_municipio_ocorrencia)]

# Changing names
painel_homicidios = painel_homicidios %>%
  rename(year = ano,
         state = sigla_uf_code_ocorrencia,
         municipality_code = id_municipio_ocorrencia)

# Excluding NAs in municipality
painel_homicidios = painel_homicidios %>%
  filter(!is.na(municipality_code))

# Excluding NAs in state
painel_homicidios = painel_homicidios %>%
  filter(!is.na(state))

# Saving Clean Dataset
save(painel_homicidios, file = paste0(DROPBOX_PATH, "build/datasus/output/clean_datasus.RData"))
 