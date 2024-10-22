library(data.table)
library(tidyverse)
library(janitor)
library(stringi)
library(stringr)


bf = fread(paste0(DROPBOX_PATH, "build/bolsa familia/input/bolsa_familia.csv"), encoding = "Latin-1")

bf = bf %>%
clean_names()

bf = bf %>%
  rename(municipality = unidade_territorial,
         state = uf,
         year = referencia,
         families_bf = familias_pbf_ate_out_2021,
         bf_value_families = valor_repassado_as_familias_pbf_ate_out_2021,
         average_value_bf = valor_do_beneficio_medio_ate_out_2021) %>%
  select(municipality, year, state, families_bf, bf_value_families, average_value_bf) %>%
  filter(year <= 2019)

formatar_municipio <- function(texto) {
  # Primeiro converte tudo para o formato título
  texto_formatado <- stringr::str_to_title(tolower(texto))
  
  # Lista de preposições que devem ficar em minúsculo
  preposicoes <- c("De", "Do", "Da", "Dos", "Das")
  
  # Substitui cada preposição pela versão em minúsculo
  for(prep in preposicoes) {
    texto_formatado <- gsub(paste0("\\b", prep, "\\b"), 
                            tolower(prep), 
                            texto_formatado)
  }
  
  return(texto_formatado)
}

# Aplicar a função na coluna
bf$municipality <- formatar_municipio(bf$municipality)

mun_codes = fread(paste0(DROPBOX_PATH, "build/municipios_codibge.csv")) %>%
  clean_names() %>%
  select(codigo, nome, uf) %>%
  rename(municipality = nome,
         state = uf,
         municipality_code = codigo)

bf = merge(bf, mun_codes, by = c("municipality", "state"), all.x = T)

bf$bf_value_families <- as.numeric(gsub(",", ".", gsub("[[:space:]]", "", bf$bf_value_families)))
bf$average_value_bf <- as.numeric(gsub(",", ".", gsub("[[:space:]]", "", bf$average_value_bf)))

# Save
save(bf, file = paste0(DROPBOX_PATH, "build/bolsa familia/output/clean_bf.RData"))
