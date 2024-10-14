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
codigos_homicidio <- c(paste0("X", 85:99), paste0("Y0", 0:9))
codigos_homicidio_arma_fogo <- c(paste0("X", 93:95))
codigos_homicidio_nao_determinado <- c(paste0("Y1", 0:9), paste0("Y2", 0:9), paste0("Y3", 0:4))
codigos_acidente_transito <- c(paste0("V0", 1:9), paste0("V1", 1:9), paste0("V2", 1:9),
                               paste0("V3", 1:9), paste0("V4", 1:9), paste0("V5", 1:9),
                               paste0("V6", 1:9), paste0("V7", 1:9), paste0("V8", 1:9),
                               paste0("V9", 1:9))
codigos_quedas <- paste0("W", sprintf("%02d", 0:19))
codigos_afogamento <- paste0("W", sprintf("%02d", 65:74))
codigos_exposicao_fogo <- paste0("X0", 0:9)
codigos_envenenamento <- paste0("X4", 0:9)
codigos_suicidio <- paste0("X", sprintf("%02d", 60:84))
codigos_suicidio_arma_fogo <- paste0("X7", 2:4)
codigos_intervencoes_legais <- c("Y35", "Y36")

# Create columns to identify each category
sim_do[, `:=`(
  homicidio = as.integer(substr(causa_basica, 1, 3) %in% codigos_homicidio),
  homicidio_arma_fogo = as.integer(substr(causa_basica, 1, 3) %in% codigos_homicidio_arma_fogo),
  homicidio_nao_determinado = as.integer(substr(causa_basica, 1, 3) %in% codigos_homicidio_nao_determinado),
  acidente_transito = as.integer(substr(causa_basica, 1, 3) %in% codigos_acidente_transito),
  quedas = as.integer(substr(causa_basica, 1, 3) %in% codigos_quedas),
  afogamento = as.integer(substr(causa_basica, 1, 3) %in% codigos_afogamento),
  exposicao_fogo = as.integer(substr(causa_basica, 1, 3) %in% codigos_exposicao_fogo),
  envenenamento = as.integer(substr(causa_basica, 1, 3) %in% codigos_envenenamento),
  suicidio = as.integer(substr(causa_basica, 1, 3) %in% codigos_suicidio),
  suicidio_arma_fogo = as.integer(substr(causa_basica, 1, 3) %in% codigos_suicidio_arma_fogo),
  intervencoes_legais = as.integer(substr(causa_basica, 1, 3) %in% codigos_intervencoes_legais)
)]

# Create a new column 'sigla_uf_code_residencia' that contains the first two digits of 'id_municipio_residencia'
sim_do$sigla_uf_code_residencia <- as.numeric(substr(sim_do$id_municipio_residencia, 1, 2))

sim_do = sim_do %>%
  relocate(ano, sigla_uf, sigla_uf_code_residencia)

# Criar o dicionário de correspondência entre o código da UF e a sigla da UF
uf_dict <- c("21" = "MA", "22" = "PI", "23" = "CE", 
             "24" = "RN", "25" = "PB", "26" = "PE", "27" = "AL", "28" = "SE", 
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
  homicidios_total = sum(homicidio, na.rm = TRUE),
  homicidios_negro = sum(homicidio * negro, na.rm = TRUE),
  homicidios_negro_jovem = sum(homicidio * negro_jovem, na.rm = TRUE),
  homicidios_branco = sum(homicidio * branco, na.rm = TRUE),
  homicidios_branco_jovem = sum(homicidio * branco_jovem, na.rm = TRUE),
  homicidios_mulher = sum(homicidio * mulher, na.rm = TRUE),
  homicidios_mulher_jovem = sum(homicidio * mulher_jovem, na.rm = TRUE),
  homicidios_homem = sum(homicidio * homem, na.rm = TRUE),
  homicidios_homem_jovem = sum(homicidio * homem_jovem, na.rm = TRUE),
  
  homicidios_arma_fogo_total = sum(homicidio_arma_fogo, na.rm = TRUE),
  homicidios_arma_fogo_negro = sum(homicidio_arma_fogo * negro, na.rm = TRUE),
  homicidios_arma_fogo_negro_jovem = sum(homicidio_arma_fogo * negro_jovem, na.rm = TRUE),
  homicidios_arma_fogo_branco = sum(homicidio_arma_fogo * branco, na.rm = TRUE),
  homicidios_arma_fogo_branco_jovem = sum(homicidio_arma_fogo * branco_jovem, na.rm = TRUE),
  homicidios_arma_fogo_mulher = sum(homicidio_arma_fogo * mulher, na.rm = TRUE),
  homicidios_arma_fogo_mulher_jovem = sum(homicidio_arma_fogo * mulher_jovem, na.rm = TRUE),
  homicidios_arma_fogo_homem = sum(homicidio_arma_fogo * homem, na.rm = TRUE),
  homicidios_arma_fogo_homem_jovem = sum(homicidio_arma_fogo * homem_jovem, na.rm = TRUE),
  
  homicidios_nao_determinado_total = sum(homicidio_nao_determinado, na.rm = TRUE),
  homicidios_nao_determinado_negro = sum(homicidio_nao_determinado * negro, na.rm = TRUE),
  homicidios_nao_determinado_negro_jovem = sum(homicidio_nao_determinado * negro_jovem, na.rm = TRUE),
  homicidios_nao_determinado_branco = sum(homicidio_nao_determinado * branco, na.rm = TRUE),
  homicidios_nao_determinado_branco_jovem = sum(homicidio_nao_determinado * branco_jovem, na.rm = TRUE),
  homicidios_nao_determinado_mulher = sum(homicidio_nao_determinado * mulher, na.rm = TRUE),
  homicidios_nao_determinado_mulher_jovem = sum(homicidio_nao_determinado * mulher_jovem, na.rm = TRUE),
  homicidios_nao_determinado_homem = sum(homicidio_nao_determinado * homem, na.rm = TRUE),
  homicidios_nao_determinado_homem_jovem = sum(homicidio_nao_determinado * homem_jovem, na.rm = TRUE),
  
  acidentes_transito_total = sum(acidente_transito, na.rm = TRUE),
  acidentes_transito_negro = sum(acidente_transito * negro, na.rm = TRUE),
  acidentes_transito_negro_jovem = sum(acidente_transito * negro_jovem, na.rm = TRUE),
  acidentes_transito_branco = sum(acidente_transito * branco, na.rm = TRUE),
  acidentes_transito_branco_jovem = sum(acidente_transito * branco_jovem, na.rm = TRUE),
  acidentes_transito_mulher = sum(acidente_transito * mulher, na.rm = TRUE),
  acidentes_transito_mulher_jovem = sum(acidente_transito * mulher_jovem, na.rm = TRUE),
  acidentes_transito_homem = sum(acidente_transito * homem, na.rm = TRUE),
  acidentes_transito_homem_jovem = sum(acidente_transito * homem_jovem, na.rm = TRUE),
  
  quedas_total = sum(quedas, na.rm = TRUE),
  quedas_negro = sum(quedas * negro, na.rm = TRUE),
  quedas_negro_jovem = sum(quedas * negro_jovem, na.rm = TRUE),
  quedas_branco = sum(quedas * branco, na.rm = TRUE),
  quedas_branco_jovem = sum(quedas * branco_jovem, na.rm = TRUE),
  quedas_mulher = sum(quedas * mulher, na.rm = TRUE),
  quedas_mulher_jovem = sum(quedas * mulher_jovem, na.rm = TRUE),
  quedas_homem = sum(quedas * homem, na.rm = TRUE),
  quedas_homem_jovem = sum(quedas * homem_jovem, na.rm = TRUE),
  
  afogamentos_total = sum(afogamento, na.rm = TRUE),
  afogamentos_negro = sum(afogamento * negro, na.rm = TRUE),
  afogamentos_negro_jovem = sum(afogamento * negro_jovem, na.rm = TRUE),
  afogamentos_branco = sum(afogamento * branco, na.rm = TRUE),
  afogamentos_branco_jovem = sum(afogamento * branco_jovem, na.rm = TRUE),
  afogamentos_mulher = sum(afogamento * mulher, na.rm = TRUE),
  afogamentos_mulher_jovem = sum(afogamento * mulher_jovem, na.rm = TRUE),
  afogamentos_homem = sum(afogamento * homem, na.rm = TRUE),
  afogamentos_homem_jovem = sum(afogamento * homem_jovem, na.rm = TRUE),
  
  exposicao_fogo_total = sum(exposicao_fogo, na.rm = TRUE),
  exposicao_fogo_negro = sum(exposicao_fogo * negro, na.rm = TRUE),
  exposicao_fogo_negro_jovem = sum(exposicao_fogo * negro_jovem, na.rm = TRUE),
  exposicao_fogo_branco = sum(exposicao_fogo * branco, na.rm = TRUE),
  exposicao_fogo_branco_jovem = sum(exposicao_fogo * branco_jovem, na.rm = TRUE),
  exposicao_fogo_mulher = sum(exposicao_fogo * mulher, na.rm = TRUE),
  exposicao_fogo_mulher_jovem = sum(exposicao_fogo * mulher_jovem, na.rm = TRUE),
  exposicao_fogo_homem = sum(exposicao_fogo * homem, na.rm = TRUE),
  exposicao_fogo_homem_jovem = sum(exposicao_fogo * homem_jovem, na.rm = TRUE),
  
  envenenamentos_total = sum(envenenamento, na.rm = TRUE),
  envenenamentos_negro = sum(envenenamento * negro, na.rm = TRUE),
  envenenamentos_negro_jovem = sum(envenenamento * negro_jovem, na.rm = TRUE),
  envenenamentos_branco = sum(envenenamento * branco, na.rm = TRUE),
  envenenamentos_branco_jovem = sum(envenenamento * branco_jovem, na.rm = TRUE),
  envenenamentos_mulher = sum(envenenamento * mulher, na.rm = TRUE),
  envenenamentos_mulher_jovem = sum(envenenamento * mulher_jovem, na.rm = TRUE),
  envenenamentos_homem = sum(envenenamento * homem, na.rm = TRUE),
  envenenamentos_homem_jovem = sum(envenenamento * homem_jovem, na.rm = TRUE),
  
  suicidios_total = sum(suicidio, na.rm = TRUE),
  suicidios_negro = sum(suicidio * negro, na.rm = TRUE),
  suicidios_negro_jovem = sum(suicidio * negro_jovem, na.rm = TRUE),
  suicidios_branco = sum(suicidio * branco, na.rm = TRUE),
  suicidios_branco_jovem = sum(suicidio * branco_jovem, na.rm = TRUE),
  suicidios_mulher = sum(suicidio * mulher, na.rm = TRUE),
  suicidios_mulher_jovem = sum(suicidio * mulher_jovem, na.rm = TRUE),
  suicidios_homem = sum(suicidio * homem, na.rm = TRUE),
  suicidios_homem_jovem = sum(suicidio * homem_jovem, na.rm = TRUE),
  
  suicidios_arma_fogo_total = sum(suicidio_arma_fogo, na.rm = TRUE),
  suicidios_arma_fogo_negro = sum(suicidio_arma_fogo * negro, na.rm = TRUE),
  suicidios_arma_fogo_negro_jovem = sum(suicidio_arma_fogo * negro_jovem, na.rm = TRUE),
  suicidios_arma_fogo_branco = sum(suicidio_arma_fogo * branco, na.rm = TRUE),
  suicidios_arma_fogo_branco_jovem = sum(suicidio_arma_fogo * branco_jovem, na.rm = TRUE),
  suicidios_arma_fogo_mulher = sum(suicidio_arma_fogo * mulher, na.rm = TRUE),
  suicidios_arma_fogo_mulher_jovem = sum(suicidio_arma_fogo * mulher_jovem, na.rm = TRUE),
  suicidios_arma_fogo_homem = sum(suicidio_arma_fogo * homem, na.rm = TRUE),
  suicidios_arma_fogo_homem_jovem = sum(suicidio_arma_fogo * homem_jovem, na.rm = TRUE),
  
  intervencoes_legais_total = sum(intervencoes_legais, na.rm = TRUE),
  intervencoes_legais_negro = sum(intervencoes_legais * negro, na.rm = TRUE),
  intervencoes_legais_negro_jovem = sum(intervencoes_legais * negro_jovem, na.rm = TRUE),
  intervencoes_legais_branco = sum(intervencoes_legais * branco, na.rm = TRUE),
  intervencoes_legais_branco_jovem = sum(intervencoes_legais * branco_jovem, na.rm = TRUE),
  intervencoes_legais_mulher = sum(intervencoes_legais * mulher, na.rm = TRUE),
  intervencoes_legais_mulher_jovem = sum(intervencoes_legais * mulher_jovem, na.rm = TRUE),
  intervencoes_legais_homem = sum(intervencoes_legais * homem, na.rm = TRUE),
  intervencoes_legais_homem_jovem = sum(intervencoes_legais * homem_jovem, na.rm = TRUE)
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
