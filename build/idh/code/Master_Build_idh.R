# Script to run codes that produce results
# Structure:
# 1) Code that cleans IDH data
# IDH = Human Development Index in Portuguese


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
inpdir <- paste0(DROPBOX_PATH, "build/idh/input")
outdir <- paste0(DROPBOX_PATH, "build/idh/output")
codedir <- paste0(GITHUB_PATH, "build/idh/code")


##################################
#                                #
#   1) Cleaning idh Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/idh/code/idh.R"))
