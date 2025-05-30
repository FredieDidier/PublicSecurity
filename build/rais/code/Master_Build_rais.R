# Script to run codes that produce results
# Structure:
# 1) Code that cleans Rais data
#


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
inpdir <- paste0(DROPBOX_PATH, "build/rais/input")
outdir <- paste0(DROPBOX_PATH, "build/rais/output")
codedir <- paste0(GITHUB_PATH, "build/rais/code")

##################################
#                                #
#   1) Cleaning rais Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/rais/code/rais.R"))
