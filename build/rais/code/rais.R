# I use Base dos Dados package to extract RAIS (formal labor market) Data 
# In their website (https://basedosdados.org) you will get information on how to download the data

library(basedosdados)
library(data.table)
library(tidyverse)

query = "SELECT *
FROM basedosdados.br_me_rais.microdados_estabelecimentos
WHERE ano BETWEEN 2003 AND 2022"

rais = download(query, path = paste0(DROPBOX_PATH, "build/rais/input/rais.csv"),
                   billing_project_id = "teste-320002")

# Loading Data
rais = fread(paste0(DROPBOX_PATH, "build/rais/input/rais.csv"))

# Selecting Northeastern States that will compose the analysis (PB and PE had similar programs going on simultaneously)
rais = rais[sigla_uf %in% c("BA", "MA", "PI", "CE", "RN", "AL", "SE")]

# Selecting years
rais = rais[ano %in% c(2007:2015)]

# 1. Quantidade de vínculos por município e ano
vinculos_municipio_ano = rais[, .(total_vinculos = sum(quantidade_vinculos_ativos)), 
                               by = .(ano, id_municipio)]

# 2. Quantidade de vínculos por estado e ano
vinculos_estado_ano = rais[, .(total_vinculos = sum(quantidade_vinculos_ativos)), 
                            by = .(ano, sigla_uf)]

# 3. Quantidade de estabelecimentos por município e ano (ajustado)
estabelecimentos_municipio_ano = rais[tipo_estabelecimento %in% c(1, 3), 
                                       .(total_estabelecimentos = .N), 
                                       by = .(ano, id_municipio)]

# 4. Quantidade de estabelecimentos por estado e ano (ajustado)
estabelecimentos_estado_ano = rais[tipo_estabelecimento %in% c(1, 3), 
                                    .(total_estabelecimentos = .N), 
                                    by = .(ano, sigla_uf)]

# Criando uma tabela de referência município-estado
municipio_estado_ref = unique(rais[, .(id_municipio, sigla_uf)])

# Merge das bases
# Primeiro, vamos mesclar as informações por município
clean_rais_municipio = merge(vinculos_municipio_ano, estabelecimentos_municipio_ano, 
                              by = c("ano", "id_municipio"), all = TRUE)

# Adicionando a informação do estado aos dados municipais
clean_rais_municipio = merge(clean_rais_municipio, municipio_estado_ref, 
                              by = "id_municipio", all.x = TRUE)

# Agora, vamos mesclar as informações por estado
clean_rais_estado = merge(vinculos_estado_ano, estabelecimentos_estado_ano, 
                           by = c("ano", "sigla_uf"), all = TRUE)

# Renaming
clean_rais_estado = clean_rais_estado %>%
  rename(total_vinculos_state = total_vinculos,
         total_estabelecimentos_state = total_estabelecimentos)

# Finalmente, vamos juntar as informações de município e estado
clean_rais = merge(clean_rais_municipio, clean_rais_estado, 
                    by = c("ano", "sigla_uf"), all = TRUE)

# Renaming
clean_rais = clean_rais %>%
  rename(year = ano,
         state = sigla_uf,
         municipality_code = id_municipio,
         total_vinculos_munic = total_vinculos,
         total_estabelecimentos_munic = total_estabelecimentos)

# Saving Clean Dataset
save(clean_rais, file = paste0(DROPBOX_PATH, "build/rais/output/clean_rais.RData"))
