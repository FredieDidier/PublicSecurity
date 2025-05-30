# Script to run codes that produce results
# Structure:
# 1) Code that cleans Datasus data
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
inpdir <- paste0(DROPBOX_PATH, "build/datasus/input")
outdir <- paste0(DROPBOX_PATH, "build/datasus/output")
codedir <- paste0(GITHUB_PATH, "build/datasus/code")

##################################
#                                #
#   1) Cleaning Datasus Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/datasus/code/datasus.R"))
