# Script to run codes that produce results
# Structure:
# 1) Code that cleans Area data
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
inpdir <- paste0(DROPBOX_PATH, "build/area/input")
outdir <- paste0(DROPBOX_PATH, "build/area/output")
codedir <- paste0(GITHUB_PATH, "build/area/code")

##################################
#                                #
#   1) Cleaning area Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/area/code/area.R"))
