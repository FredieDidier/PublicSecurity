library(basedosdados)
library(data.table)
library(tidyverse)

query = "SELECT *
FROM basedosdados.br_ms_imunizacoes.municipio
WHERE ano BETWEEN 2000 AND 2019"

vacina = download(query, path = paste0(DROPBOX_PATH, "build/vacina/input/vacina.csv"),
                billing_project_id = "teste-320002")

vacina = fread(paste0(DROPBOX_PATH, "build/vacina/input/vacina.csv"))

vacina = vacina %>%
  filter(sigla_uf %in% c("PB", "PE", "BA", "RN", "PI", "CE", "MA", "SE", "AL")) %>%
  select(c(1:3, 5)) %>%
  rename(year = ano,
         municipality_code = id_municipio,
         state = sigla_uf)

# Saving Clean Dataset
save(vacina, file = paste0(DROPBOX_PATH, "build/vacina/output/clean_vacina.RData"))
