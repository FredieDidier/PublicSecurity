# Script to run codes that produce results
# Structure:
# 1) Code that cleans vacina data
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
inpdir <- file.path(DROPBOX_PATH, "build", "vacina", "input")
outdir <- file.path(DROPBOX_PATH, "build", "vacina", "output")
codedir <- file.path(GITHUB_PATH, "build",  "vacina", "code")
workfile_dir <- file.path(GITHUB_PATH, "build",  "workfile")
workfile_dir_out <- file.path(DROPBOX_PATH, "build",  "workfile", "output")

##################################
#                                #
#   1) Cleaning vacina Data 
#                                #
##################################

source(paste0(GITHUB_PATH, "build/vacina/code/vacina.R"))
