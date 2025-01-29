# I use Base dos Dados package to extract RAIS (formal labor market) Data 
# In their website (https://basedosdados.org) you will get information on how to download the data

library(basedosdados)
library(data.table)
library(tidyverse)

query = "SELECT *
FROM basedosdados.br_me_rais.microdados_estabelecimentos
WHERE ano BETWEEN 1996 AND 2002"

rais_1996_2002 = download(query, path = paste0(DROPBOX_PATH, "build/rais/input/rais_1996_2002.csv"),
                          billing_project_id = "teste-320002")

query = "SELECT *
FROM basedosdados.br_me_rais.microdados_estabelecimentos
WHERE ano BETWEEN 2003 AND 2022"

rais = download(query, path = paste0(DROPBOX_PATH, "build/rais/input/rais.csv"),
                billing_project_id = "teste-320002")

query = "SELECT 
    ano,
    id_municipio,
    vinculo_ativo_3112,
    CASE 
        WHEN ano <= 2005 THEN grau_instrucao_1985_2005
        ELSE grau_instrucao_apos_2005
    END as grau_instrucao,
    natureza_juridica,
    cnae_1
FROM `basedosdados.br_me_rais.microdados_vinculos`
WHERE ano BETWEEN 2000 AND 2019
    AND sigla_uf IN ('PE', 'BA', 'CE', 'MA', 'RN', 'PI', 'AL', 'SE', 'PB')
    AND natureza_juridica IN ('1031', '1066', '1120', '1155', '1180')
    AND cnae_1 IN ('75116', '75140', 
                   '80136', '80144', '80152', '80209',
                   '85111', '85120', '85138', '85146',
                   '74110',
                   '92517', '92525')
    AND CAST(vinculo_ativo_3112 AS STRING) = '1'"

rais_worker = download(query, 
                       path = paste0(DROPBOX_PATH, "build/rais/input/rais_worker.csv"),
                       billing_project_id = "teste-320002")

# Loading Data
rais = fread(paste0(DROPBOX_PATH, "build/rais/input/rais.csv"))
rais_1996_2002 = fread(paste0(DROPBOX_PATH, "build/rais/input/rais_1996_2002.csv"))
rais_worker = fread(paste0(DROPBOX_PATH, "build/rais/input/rais_worker.csv"))

# Binding
rais_list = list(rais, rais_1996_2002)
rais_full = rbindlist(rais_list, fill = T)
rm(rais_list, rais_1996_2002, rais)

rais = rais_full
rm(rais_full)

# Selecting Northeastern States that will compose the analysis
rais = rais[sigla_uf %in% c("BA", "MA", "PI", "CE", "RN", "AL", "SE", "PE", "PB")]

# Selecting years
rais = rais[ano %in% c(2000:2019)]

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

# Naturezas jurídicas municipais (inclui todos órgãos, autarquias e fundações municipais)
naturezas_municipais = c("1031", # Órgão Executivo Municipal
                         "1066", # Órgão Legislativo Municipal
                         "1120", # Autarquia Municipal
                         "1155", # Fundação Municipal
                         "1180") # Órgão Público Autônomo Municipal

# Estabelecimentos locais públicos (agências estatais)
estabelecimentos_locais = rais[tipo_estabelecimento %in% c(1, 3) & 
                                 natureza_juridica %in% naturezas_municipais &
                                 cnae_1 %in% c(
                                   # Administração pública municipal
                                   "75116",  # Administração pública geral
                                   "75140",  # Atividades de apoio à administração pública
                                   
                                   # Educação
                                   "80136",  # Creches
                                   "80144",  # Pré-escola
                                   "80152",  # Ensino fundamental
                                   "80209",  # Ensino médio
                                   
                                   # Saúde
                                   "85111",  # Hospitais
                                   "85120",  # Atendimento urgência/emergência
                                   "85138",  # Ambulatórios/centros de saúde
                                   "85146",  # Complementares diagnóstico/terapia
                                   
                                   # Serviços públicos diversos
                                   "74110",  # Cartórios
                                   
                                   # Cultura
                                   "92517",  # Bibliotecas
                                   "92525"   # Museus e patrimônio histórico
                                 ),
                               .(total_estabelecimentos_locais = .N),
                               by = .(ano, id_municipio)]

estabelecimentos_locais = estabelecimentos_locais %>%
  rename(year = ano,
         municipality_code = id_municipio)

# Funcionários públicos municipais e proporção com ensino superior
funcionarios_publicos_municipais = rais_worker[
  # Aplicando os mesmos filtros que usamos em estabelecimentos
  vinculo_ativo_3112 == 1,
  .(total_func_pub_munic = .N,
    funcionarios_superior = sum(grau_instrucao == 9)),
  by = .(ano, id_municipio)
][, perc_superior := funcionarios_superior/total_func_pub_munic * 100]

funcionarios_publicos_municipais = funcionarios_publicos_municipais %>%
  rename(year = ano,
         municipality_code = id_municipio)

# Estabelecimentos Educação
estabelecimentos_educ = rais[tipo_estabelecimento %in% c(1, 3) & 
                               cnae_1 %in% c("80136", "80144", "80152", "80209", "80314"), 
                             .(total_estabelecimentos_educ = .N), 
                             by = .(ano, id_municipio)]

# Estabelecimentos Saúde
estabelecimentos_saude = rais[tipo_estabelecimento %in% c(1, 3) & 
                                cnae_1 %in% c("85111", "85120", "85138", "85146"), 
                              .(total_estabelecimentos_saude = .N), 
                              by = .(ano, id_municipio)]

# Vínculos Educação
vinculos_educ = rais[cnae_1 %in% c("80136", "80144", "80152", "80209"), 
                     .(total_vinculos_educ = sum(quantidade_vinculos_ativos)), 
                     by = .(ano, id_municipio)]

# Vínculos Saúde
vinculos_saude = rais[cnae_1 %in% c("85111", "85120", "85138", "85146"), 
                      .(total_vinculos_saude = sum(quantidade_vinculos_ativos)), 
                      by = .(ano, id_municipio)]

# Renomeando colunas
estabelecimentos_educ = estabelecimentos_educ %>%
  rename(year = ano,
         municipality_code = id_municipio)

estabelecimentos_saude = estabelecimentos_saude %>%
  rename(year = ano,
         municipality_code = id_municipio)

vinculos_educ = vinculos_educ %>%
  rename(year = ano,
         municipality_code = id_municipio)

vinculos_saude = vinculos_saude %>%
  rename(year = ano,
         municipality_code = id_municipio)

# Merge final
clean_rais = clean_rais %>%
  # Merge com estabelecimentos da administração pública
  left_join(estabelecimentos_locais, 
            by = c("year", "municipality_code")) %>%
  # Merge com dados dos funcionários públicos
  left_join(funcionarios_publicos_municipais,
            by = c("year", "municipality_code")) %>%
  # Merge com demais dados
  left_join(estabelecimentos_educ, by = c("year", "municipality_code")) %>%
  left_join(estabelecimentos_saude, by = c("year", "municipality_code")) %>%
  left_join(vinculos_educ, by = c("year", "municipality_code")) %>%
  left_join(vinculos_saude, by = c("year", "municipality_code"))

# Saving Clean Dataset
save(clean_rais, file = paste0(DROPBOX_PATH, "build/rais/output/clean_rais.RData"))
