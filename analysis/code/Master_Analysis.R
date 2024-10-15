# Script para rodar os codigos que geram as bases prontas para produzir resultados
# Estrutura:
#
# 1. Gerar gráficos de taxa de homicidio.
# 2. Gerar mapa de proximidade a delegacias.

###########
#  Setup  #
###########

# Limpeza do environnment

rm(list = ls())
# Carregar pacotes
library(dplyr)     # Para manipulação de dados
library(stringr)   # Para manipulação de strings
library(haven)     # Para salvar o dataframe no formato .dta (Stata)
library(tidyverse)
library(ggplot2)
library(sf)

####################
# Folder Path
####################

GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurity/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/"

# Make sure to set all macro globals
codedir <- file.path(GITHUB_PATH, "analysis",  "code")
outdir <- file.path(GITHUB_PATH, "analysis",  "output")

# Loading Main Data
load(paste0(DROPBOX_PATH, "build/workfile/output/main_data.RData"))

# Função para encurtar os nomes das variáveis
encurtar_nome <- function(nome, sufixo = "") {
  # Limitar o nome a 32 caracteres (Stata) já contando com o sufixo
  limite <- 32 - nchar(sufixo)
  nome <- substr(nome, 1, limite)
  # Concatenar o sufixo, se houver
  nome <- paste0(nome, sufixo)
  return(nome)
}

# Função para transformar os nomes em válidos para Stata
ajustar_nomes_stata <- function(nome, sufixo = "") {
  # Substituir caracteres não permitidos por underscores
  nome <- str_replace_all(nome, "[^a-zA-Z0-9_]", "_")
  
  # Garantir que o nome comece com uma letra (Stata exige isso)
  if (!grepl("^[a-zA-Z]", nome)) {
    nome <- paste0("v_", nome)  # Prefixo 'v_' caso o nome comece com número ou símbolo
  }
  
  # Encurtar o nome para 32 caracteres incluindo o sufixo
  nome <- encurtar_nome(nome, sufixo)
  
  return(nome)
}

# Função para garantir que os nomes sejam únicos
garantir_nomes_unicos <- function(nomes) {
  # Criar vetor para armazenar os novos nomes únicos
  nomes_unicos <- character(length(nomes))
  
  # Contador para adicionar sufixos numéricos
  contador <- integer(length(nomes))
  
  for (i in seq_along(nomes)) {
    nome_atual <- nomes[i]
    sufixo <- ""
    
    # Garantir que o nome seja único
    while (nome_atual %in% nomes_unicos) {
      contador[i] <- contador[i] + 1
      sufixo <- paste0("_", contador[i])
      nome_atual <- ajustar_nomes_stata(nomes[i], sufixo)
    }
    
    # Atribuir o nome único ajustado ao vetor de nomes
    nomes_unicos[i] <- nome_atual
  }
  
  return(nomes_unicos)
}

# Função para identificar e ajustar os nomes das colunas problemáticas
ajustar_colunas <- function(df) {
  # Gerar novos nomes aplicando a função ajustar_nomes_stata a cada nome de coluna
  novos_nomes <- names(df) %>%
    sapply(ajustar_nomes_stata, USE.NAMES = FALSE)
  
  # Garantir que os nomes sejam únicos, adicionando sufixos numéricos se necessário
  novos_nomes <- garantir_nomes_unicos(novos_nomes)
  
  # Verificar quais nomes foram modificados
  colunas_modificadas <- names(df) != novos_nomes
  
  # Exibir colunas que foram renomeadas
  if (any(colunas_modificadas)) {
    cat("Colunas renomeadas:\n")
    print(data.frame(Antigo = names(df)[colunas_modificadas], Novo = novos_nomes[colunas_modificadas]))
  }
  
  # Substituir os nomes antigos pelos novos no dataframe
  names(df) <- novos_nomes
  
  return(df)
}


# Exemplo de uso com o seu dataframe chamado "data"
main_data_stata <- ajustar_colunas(main_data)

# Agora você pode salvar o dataframe no formato .dta (Stata)
write_dta(main_data_stata, paste0(DROPBOX_PATH, "build/workfile/output/main_data_stata.dta"))

###########################################
#                                         #
# 1) Gerar Graficos de taxa de homicidio
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_graph_homicide_rate.R"))

###########################################
#                                         #
# 1) Gerar mapa de proximidade a delegacias
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_map_police_station_proximity.R"))

