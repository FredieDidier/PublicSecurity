# Script to run codes that produce results
# Structure:
# 1) Code that cleans Pib Municipal data
# Pib Municipal = Municipality GDP in Portuguese


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
# Make sure to set all macro globals
inpdir <- paste0(DROPBOX_PATH, "build/pib municipal/input")
outdir <- paste0(DROPBOX_PATH, "build/pib municipal/output")
codedir <- paste0(GITHUB_PATH, "build/pib municipal/code")

##################################
#                                #
#   1) Cleaning pib municipal Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/pib municipal/code/pib municipal.R"))
