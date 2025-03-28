# Script para rodar os codigos que geram as bases prontas para produzir resultados
# Estrutura:
#
# 1. Gerar gráficos de taxa de homicidio.
# 2. Gerar mapa de proximidade a delegacias.
# 3. Gerar Main Data em .dta
# 4. Gerar gráficos de residuos de taxa de homicidio
# 5. Gerar mapa de todos os municipios da amostra
# 6. Gerar tabela descritiva
# 7. Gerar mapa funcionários públicos
# 8. Gerar tabela descritiva de comparação de funcionários públicos em low e high states

###########
#  Setup  #
###########

# Limpeza do environnment

rm(list = ls())

# Carregar pacotes
library(dplyr)     
library(stringr)   
library(haven)    
library(tidyverse)
library(ggplot2)
library(sf)
library(scales)
library(RColorBrewer)
library(janitor)
library(patchwork)
library(cowplot)
library(gridExtra)

####################
# Folder Path
####################

GITHUB_PATH <- "/Users/fredie/Documents/GitHub/PublicSecurity/"
DROPBOX_PATH <- "/Users/fredie/Library/CloudStorage/Dropbox/PublicSecurity/"

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

source(paste0(GITHUB_PATH, "analysis/code/_table_descriptive_stats.R"))

######################################################
#                                         
# 7) Gerar mapa de funcionários públicos              #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_map_employees_municipality.R"))


########################################################################################
#                                         
# 8) Gerar tabela descritiva de comparação de funcionários públicos em low e high states 
#                                         
########################################################################################

source(paste0(GITHUB_PATH, "analysis/code/_table_capacity_comparison.R"))

