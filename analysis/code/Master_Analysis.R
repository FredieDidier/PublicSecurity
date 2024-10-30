# Script para rodar os codigos que geram as bases prontas para produzir resultados
# Estrutura:
#
# 1. Gerar gráficos de taxa de homicidio.
# 2. Gerar mapa de proximidade a delegacias.
# 3. Gerar Main Data em .dta
# 4. Gerar gráficos de residuos de taxa de homicidio
# 5. Gerar mapa de todos os municipios da amostra
# 6. Gerar tabela descritiva

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

###########################################
#                                         #
# 1) Gerar Graficos de taxa de homicidio
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_graph_homicide_rate.R"))

###########################################
#                                         #
# 2) Gerar mapa de proximidade a delegacias
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_map_police_station_proximity.R"))

###########################################
#                                         #
# 3) Gerar Main Data em .dta
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_main_data_dta.R"))

######################################################
#                                         
# 4) Gerar gráficos de residuos de taxa de homicidio #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_graph_residuals_homicide_rate.R"))

######################################################
#                                         
# 5) Gerar mapa de todos os municipios da amostra    #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_map_all_municipalities.R"))

######################################################
#                                         
# 6) Gerar tabela descritiva                         #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_map_all_municipalities.R"))

