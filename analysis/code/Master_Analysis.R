# Script para rodar os codigos que geram as bases prontas para produzir resultados
# Estrutura:
#
# 1. Gerar gráficos de taxa de homicidio.

###########
#  Setup  #
###########

# Limpeza do environnment

rm(list = ls())

# Pacotes utilizados
library(tidyverse)
library(ggplot2)

####################
# Folder Path
####################

GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurityBahia/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurityBahia/"

# Make sure to set all macro globals
codedir <- file.path(GITHUB_PATH, "analysis",  "code")
outdir <- file.path(GITHUB_PATH, "analysis",  "output")

###########################################
#                                         #
# 1) Gerar Graficos de taxa de homicidio
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_graph_homicide_rate.R"))

