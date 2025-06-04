# Policing and Social Prevention: Dynamic Responses of Integrated Public Security Policies on Violent Crime in Brazil - Replication Package

**Author:** Fredie Didier

## Overview

You will be able to download the research data (raw and cleaned files) from my Zenodo repository soon: [DOI will be added upon publication].

The code in this replication package constructs the cleaned datasets, figures, tables and maps using data from DATASUS-SIM ("DATASUS Mortality System"), RAIS ("Annual Report of Social Information"), IBGE (Brazilian Institute of Geography and Statistics), OpenStreetMap and ATLAS ("Human Development Atlas") using R and Stata 18.

All data are publicly available, and to download DATASUS-SIM, RAIS, and ATLAS data you just need to follow the steps provided in **[Base dos Dados](https://basedosdados.org)**. They will explain how to set up their bigquery in your Google Account and how to properly download data. Notice that you will have to change the billing_project_id parameter from my code in order to be able to download because it is specific from my Google Account. Below I show an example of one of my codes to illustrate:

```r
query <- "SELECT * FROM `basedosdados.br_ms_sim.microdados`"
sim_do <- download(query, path = paste0(DROPBOX_PATH, "build/datasus/input/sim.do.csv"),
                   billing_project_id = "sodium-surf-307721")
```

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

3. *Run Data Processing*
   
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

**analysis:** The analysis folder is further subdivided into: a) **code**, b) **output**, described as follows:

- **code**: This folder is for storing the code used for the respective task.
- **output**: This folder is for storing the results according to the “code”. Results can be stored in the folders: i) **graphs**, ii) **tables**, and iii) **maps**.

To replicate the results that require R, please follow these steps:

1. Download and extract the replication package containing the raw and cleaned dataset files to a folder of your choice: [Replication Package] (DOI will be added upon publication).
2. Clone this Github repository into your computer device.
3. Open the code file (`Master_Analysis.R`) located in the folder (`./analysis/code`) using RStudio.
4. Change the path to the Github repository folder and the replication package folder at lines 40 and 41 respectively in the code file to the directory where the Github repository and the replication package are located in your computer device.
5. Run the `Master_Analysis.R` to generate the results. The `main_data.dta` file will be saved automatically in the folder (`./workfile/output`). The output files (both in PNG and TeX format) will be saved automatically in the folder (`./analysis/output`).

### Code and Corresponding Results (R)

Here is a detailed explanation of the codes within `Master_Analysis.R` and the results they generate:

**Figure 1:** Treatment Status across Municipalities
- `./analysis/code/_figure1.R`

**Figure 2 (a):** Homicide rates
- `./analysis/code/_figure2a.R`

**Figure 2 (b):** Residual homicide rates
- `./analysis/code/_figure2b.R`

**Figure 3 (a):** Percentage of Municipality Public Employees with Higher Education (2006)
- `./analysis/code/_figure3a.R`

**Figure 3 (b):** Distance to Nearest Police Station (km)
- `./analysis/code/_figure3b.R`

**Appendix Figure A.1:** Homicide Rates in Treated Northeastern Municipalities Prior to Program Implementation
- `./analysis/code/_figureA.1.R`

**Appendix Table A.2:** Distribution of Local Capacity and Police Presence by State
- `./analysis/code/_tableA.2.R`

**Appendix Table A.3:** Summary Statistics
- `./analysis/code/_tableA.3.R`

To replicate the results that require Stata, please follow these steps:

1. Open the code file (`Master_Analysis.do`) located in the folder (`./analysis/code`) using your preferred Stata software.
2. Change the path to the Github repository folder and the replication package folder at lines 10 and 11 respectively in the code file to the directory where the Github repository and the replication package are located in your computer device.
3. Install the boottest package with the following code:
   ```stata
   ssc install boottest, replace
   ```
4. Run the `Master_Analysis.do` to generate the results. The output files (both in PDF and TeX format) will be saved automatically in the folder (`./analysis/output`).

### Code and Corresponding Results (Stata)

Here is a detailed explanation of the codes within `Master_Analysis.do` and the results they generate:

**Figure 4:** Impact of Security Policy on Homicide Rates
- `./analysis/code/_figure4a_4b.do` (this code file also includes the code for **Table B.1**: Impact of Public Security Program on Homicide Rates by Cohort)

**Figure 5:** Impact of Security Policy on Homicide Rates by Local Capacity and Police Presence
- `./analysis/code/_figure5a_5b.do` (this code file also includes the code for **Table B.2**: Impact of Public Security Program for Pernambuco by Capacity and Distance to Police Stations)

**Figure 6:** Impact of Security Policy on Homicide Rate Among Young Non-White Population
- `./analysis/code/_figure6a_6b.do` (this code file also includes the code for **Table B.8**: Impact of Public Security Program on Homicide Rates for Pernambuco Cohort: Young Non-White Victims Only)

**Appendix Table A.1:** Determinants of Local Capacity (2006)
- `./analysis/code/_tableA.1.do`

**Appendix Figure B.1:** Spillover Homicide Rate Residuals by Proximity to Pernambuco’s Border
- `./analysis/code/_figureB.1.do`

**Appendix Table B.3:** Impact of Public Security Program on Homicide Rates for Pernambuco Cohort: Alternative Treatment and Control Groups
- `./analysis/code/_tableB.3.do`

**Appendix Table B.4:** Impact of Public Security Program on Homicide Rates for Pernambuco Cohort: Removing Spillover Municipalities
- `./analysis/code/_tableB.4.do`

**Appendix Table B.5:**  Impact of Public Security Program for Pernambuco by Capacity and Distance to Police Stations: Removing SE State From Sample
- `./analysis/code/_tableB.5.do`

**Appendix Table B.6:** Impact of Public Security Program for Pernambuco by Capacity and Distance to Police Stations: Removing MA and PI States From Sample
- `./analysis/code/_tableB.6.do`

**Appendix Table B.7:** Impact of Public Security Program for Pernambuco by Capacity and Distance to Police Stations: Removing BA and MA States From Sample
- `./analysis/code/_tableB.7.do`

## Contact

If you have any questions or issues replicating the analysis, please contact the author via [GitHub repository](https://github.com/FredieDidier/PublicSecurity) by raising an ISSUE.










