# I use Base dos Dados package to extract Datasus Mortality Data 
# In their website (https://basedosdados.org) you will get information on how to download the data
library(basedosdados)
library(data.table)
library(tidyverse)
library(janitor)

query <- "SELECT * FROM `basedosdados.br_ms_sim.microdados`"
sim_do <- download(query, path = paste0(DROPBOX_PATH, "build/datasus/input/sim.do.csv"),
                   billing_project_id = "sodium-surf-307721")

# Loading Data
sim_do = fread(paste0(DROPBOX_PATH, "build/datasus/input/sim.do.csv"))

# Selecting Northeastern States that will compose the analysis
sim_do = sim_do[sigla_uf %in% c("BA", "MA", "PI", "CE", "RN", "AL", "SE", "PB", "PE")]

# Selecting years
sim_do = sim_do[ano %in% c(2000:2019)]

# Create sequences of codes for different categories
codigos_homicidio <- c(paste0("X", 85:99), paste0("Y0", 0:9), "Y35", "Y36")

# Create column to identify homicides and outside of home homicides
sim_do[, `:=`(
  homicidio = as.integer(substr(causa_basica, 1, 3) %in% codigos_homicidio),
  homicidio_fora_casa = as.integer(
    substr(causa_basica, 1, 3) %in% codigos_homicidio & 
      as.integer(substr(causa_basica, 4, 4)) != 0
  )
)]

# Create a new column 'sigla_uf_code_residencia' that contains the first two digits of 'id_municipio_residencia'
sim_do$sigla_uf_code_residencia <- as.numeric(substr(sim_do$id_municipio_residencia, 1, 2))

sim_do = sim_do %>%
  relocate(ano, sigla_uf, sigla_uf_code_residencia)

# Matching state code to state abbreviation
uf_dict <- c("21" = "MA", "22" = "PI", "23" = "CE", 
             "24" = "RN", "25" = "PB", "26" = "PE", "27" = "AL", "28" = "SE", 
             "29" = "BA")

sim_do <- sim_do %>%
  mutate(
    # Extract first two digits of 'id_municipio_ocorrencia' (municipality that happened the homicide)
    code_ocorrencia = substr(id_municipio_ocorrencia, 1, 2),
    # Verify if 'id_municipio_ocorrencia' is valid and different from code of residency (municipality where the victim lived)
    sigla_uf_code_ocorrencia = ifelse(
      !is.na(id_municipio_ocorrencia), 
      uf_dict[code_ocorrencia],  # Associate to correct state if code exists
      NA_character_  # Maintain NA in case code does not exist
    )
  )

sim_do = sim_do %>%
  relocate(ano, sigla_uf, sigla_uf_code_residencia, id_municipio_residencia,
           sigla_uf_code_ocorrencia, id_municipio_ocorrencia, homicidio, homicidio_fora_casa)

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
painel_mortalidade = sim_do[, .(
  homicidios_total = sum(homicidio, na.rm = TRUE), # Total homicides
  homicidios_fora_casa = sum(homicidio_fora_casa, na.rm = TRUE), # Outside of home homicides
  homicidios_negro = sum(homicidio * negro, na.rm = TRUE), # Non-white people homicides
  homicidios_negro_jovem = sum(homicidio * negro_jovem, na.rm = TRUE), # Young non-white people homicides
  homicidios_branco = sum(homicidio * branco, na.rm = TRUE), # White people homicides
  homicidios_branco_jovem = sum(homicidio * branco_jovem, na.rm = TRUE), # Young white people homicides
  homicidios_mulher = sum(homicidio * mulher, na.rm = TRUE), # Women homicides
  homicidios_mulher_jovem = sum(homicidio * mulher_jovem, na.rm = TRUE), # Young women homicides
  homicidios_homem = sum(homicidio * homem, na.rm = TRUE), # Men homicides
  homicidios_homem_jovem = sum(homicidio * homem_jovem, na.rm = TRUE) # Young men homicides
), by = .(ano, sigla_uf_code_ocorrencia, id_municipio_ocorrencia)]

# Changing names
painel_mortalidade = painel_mortalidade %>%
  rename(year = ano,
         state = sigla_uf_code_ocorrencia,
         municipality_code = id_municipio_ocorrencia)

# Excluding NAs in municipality
painel_mortalidade = painel_mortalidade %>%
  filter(!is.na(municipality_code))

# Excluding NAs in state
painel_mortalidade = painel_mortalidade %>%
  filter(!is.na(state))

# Saving Clean Dataset
save(painel_mortalidade, file = paste0(DROPBOX_PATH, "build/datasus/output/clean_datasus.RData"))
