# Script to run codes that produce results
# Structure:
# 1) Code that cleans Pib Municipal data
#


###########
#  Setup  #
###########

# Clear the environment
rm(list = ls())

####################
# Folder Path
####################

GITHUB_PATH <- "/Users/Fredie/Documents/GitHub/PublicSecurityBahia/"
DROPBOX_PATH <- "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurityBahia/"

# Make sure to set all macro globals
inpdir <- file.path(DROPBOX_PATH, "build", "pib municipal", "input")
outdir <- file.path(DROPBOX_PATH, "build", "pib municipal", "output")
codedir <- file.path(GITHUB_PATH, "build",  "pib municipal", "code")
workfile_dir <- file.path(GITHUB_PATH, "build",  "workfile")
workfile_dir_out <- file.path(DROPBOX_PATH, "build",  "workfile", "output")

##################################
#                                #
#   1) Cleaning pib municipal Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/pib municipal/code/pib municipal.R"))
