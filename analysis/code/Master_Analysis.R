# Script to run codes that generate results
# Structure:
#
# 1. Generate Homicide Rate Graph.
# 2. Generate Police Stations Map.
# 3. Generate Main Data Dataset in .dta.
# 4. Generate Residuals Homicide Rate Graph.
# 5.  Generate All Municipalities Map.
# 6. Generate Descriptive Statistics Table.
# 7. Generate Public Employees Map.
# 8. Generate Descriptive Statistics Table - Local Capacity and Police Acessibility.
# 9. Generate Treated Municipalities Homicide Rate Map.

###########
#  Setup  #
###########

# Cleaning Environment

rm(list = ls())

# Loading libraries
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

###########################################
#                                         #
# 1) Generate Homicide Rate Graph
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_figure2a.R"))

###########################################
#                                         #
# 2) Generate Police Stations Map
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_figure3b.R"))

###########################################
#                                         #
# 3) Generate Main Data Dataset in .dta
#                                         #
###########################################

source(paste0(GITHUB_PATH, "analysis/code/_main_data_dta.R"))

######################################################
#                                         
# 4) Generate Residuals Homicide Rate Graph           #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_figure2b.R"))

######################################################
#                                         
# 5) Generate All Municipalities Map                 #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_figure1.R"))

######################################################
#                                         
# 6) Generate Descriptive Statistics Table           #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_tableA.3.R"))

######################################################
#                                         
# 7) Generate Public Employees Map                   #
#                                         
######################################################

source(paste0(GITHUB_PATH, "analysis/code/_figure3a.R"))


########################################################################################
#                                         
# 8) Generate Descriptive Statistics Table - Local Capacity and Police Acessibility 
#                                         
########################################################################################

source(paste0(GITHUB_PATH, "analysis/code/_tableA.2.R"))

########################################################################################
#                                         
# 9) Generate Treated Municipalities Homicide Rate Map
#                                         
########################################################################################

source(paste0(GITHUB_PATH, "analysis/code/_figureA.1.R"))
