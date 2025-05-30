# Script to run codes that produce results
# Structure:
# 1) Code that cleans Delegacias data
# Delegacias = Police Stations in Portuguese


###########
#  Setup  #
###########

# Clear the environment
rm(list = ls())

####################
# Folder Path
####################

GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurity/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/"

# Make sure to set all macro globals
outdir <- paste0(DROPBOX_PATH, "build/delegacias/output")
codedir <- paste0(GITHUB_PATH, "build/delegacias/code")


##################################
#                                #
#   1) Cleaning delegacias Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/delegacias/code/delegacias.R"))
