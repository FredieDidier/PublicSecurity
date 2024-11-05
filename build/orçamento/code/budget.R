library(dplyr)     # Para manipulação de dados
library(stringr)   # Para manipulação de strings
library(haven)     # Para salvar o dataframe no formato .dta (Stata)
library(tidyverse)
library(ggplot2)
library(sf)
library(data.table)
library(basedosdados)

query <- "SELECT * FROM basedosdados.br_me_siconfi.uf_despesas_funcao WHERE ano BETWEEN 2013 AND 2019"
fin_state <- download(query, path = paste0(DROPBOX_PATH, "build/orçamento/input/fin_state.csv"),
                billing_project_id = "sodium-surf-307721")

fin_state = fread(paste0(DROPBOX_PATH, "build/orçamento/input/fin_state.csv"))

fin_state = fin_state %>%
  select(ano, sigla_uf, id_uf, estagio, conta, valor) %>%
  filter(estagio == "Despesas Pagas" & sigla_uf %in% c("BA", "PE", "PB", "RN", "PI", "CE", "MA", "AL", "SE"))

fin_state_final <- fin_state %>%
  filter(grepl("Segurança Pública", conta)) %>%  # Filtra segurança pública e subfunções
  group_by(sigla_uf, ano) %>%                    # Agrupa por estado e ano
  summarise(total_valor = sum(valor, na.rm = TRUE))  # Soma os valores de segurança pública

fin_state_final = fin_state_final %>%
  rename(state = sigla_uf, year = ano, security_value_state = total_valor)

# Saving Clean Dataset
save(fin_state_final, file = paste0(DROPBOX_PATH, "build/orçamento/output/clean_state_finances.RData"))
