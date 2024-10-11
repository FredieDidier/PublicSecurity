# Script to run codes that produce results
# Structure:
# 1) Code that cleans Population data
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
inpdir <- file.path(DROPBOX_PATH, "build", "population", "input")
outdir <- file.path(DROPBOX_PATH, "build", "population", "output")
codedir <- file.path(GITHUB_PATH, "build",  "population", "code")
workfile_dir <- file.path(GITHUB_PATH, "build",  "workfile")
workfile_dir_out <- file.path(DROPBOX_PATH, "build",  "workfile", "output")

##################################
#                                #
#   1) Cleaning population Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/population/code/population.R"))
