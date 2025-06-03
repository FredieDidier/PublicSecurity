# Policing and Social Prevention: Dynamic Responses of Integrated Public Security Policies on Violent Crime in Brazil - Replication Package

**Author:** Fredie Didier

## Overview

You will be able to download the research data (raw and cleaned files) at Zenodo soon.

The code in this replication package constructs the cleaned datasets, figures, tables and maps using data from DATASUS-SIM ("DATASUS Mortality System"), RAIS ("Annual Report of Social Information"), IBGE (Brazilian Institute of Geography and Statistics), OpenStreetMap and ATLAS ("Human Development Atlas") using R and Stata 18.

All data are publicly available, and to download DATASUS-SIM, RAIS, and ATLAS data you just need to follow the steps provided in **[Base dos Dados](https://basedosdados.org)**.

## Build

**build**: This folder contains all code files necessary to clean the datasets in order to obtain the cleaned data files `main_data.RData`.

The data construction in the `build` folder follows a modular approach with separate processing for each data source:

### Core Datasets:

1. **area/code** - Geographic and Spatial Data
  - Municipality boundaries and area calculations
  - Latitude/longitude coordinates (centroids)
  - Distance calculations to state borders

2. **datasus/code** - Mortality Data (Primary Outcome)
  - Homicide records by municipality and year
  - Demographic breakdowns (age, race, gender)
  - Location of occurrence vs. residence

3. **population/code** - Demographic Data
  - Municipality population estimates (2000-2019)

4. **pib_municipal/code** - Economic Data
  - Municipality GDP
  - Municipality GDP per capita calculations

5. **idh/code** - Human Development Index
  - Municipality HDI (2010)

6. **rais/code** - Formal Labor Market Data
  - Employment in municipality public sector
  - Education and health sector establishments
  - Municipality public employee educational status

7. **delegacias/code** - Police Stations
  - Distance to nearest police station

### Processing Pipeline

Each dataset has its own processing pipeline:

**Master_Build_[dataset].R → [dataset].R → clean_[dataset].RData**

All Master_Build_[dataset].R and [dataset].R code files are located within the appropriate [dataset/code] folder.

### Data Integration

`workfile/merge_data.R` - Master script that:
- Combines all cleaned datasets
- Calculates homicide rates per 100,000 inhabitants
- Creates state-level and municipality-level indicators
- Generates final dataset in .RData

**Therefore: merge_data.R → main_data.RData**

### Usage Instructions
 
 1. *Setup Environment*

```r
# Install required packages
install.packages(c("data.table", "tidyverse", "sf", "basedosdados", 
                  "datazoom.amazonia", "ribge", "osmdata", "janitor"))

# Load libraries
library(data.table)
library(tidyverse)
library(sf)
library(basedosdados)
library(datazoom.amazonia)
library(ribge)
library(osmdata)
library(janitor)
   ```
2. *Configure Paths*
   
Update path variables in each Master_Build_*.R script to match your local directory structure.

4. *Run Data Processing*
   
Execute master scripts in any order (each is independent):

```r
source(paste0(YOUR_PATH, "build/area/code/Master_Build_area.R"))
source(paste0(YOUR_PATH, "build/datasus/code/Master_Build_datasus.R"))
source(paste0(YOUR_PATH, "build/population/code/Master_Build_population.R"))
# ... continue for all datasets
```
4. Create Final Dataset

```
source(paste0(YOUR_PATH, "build/workfile/merge_data.R"))

```

## Analysis
