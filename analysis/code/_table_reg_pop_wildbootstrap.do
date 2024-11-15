* Clear environment and set seed
set seed 12345

* Create treatment variables
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007
replace treated = 1 if state == "BA" & year >= 2011
replace treated = 1 if state == "PB" & year >= 2011
replace treated = 1 if state == "CE" & year >= 2015
replace treated = 1 if state == "MA" & year >= 2016

* Remove NAs and create variables
drop if missing(population_2000_muni)

* Create current population variables
gen treated_population = treated * population_muni
egen pop_median = median(population_muni)
gen population_median = population_muni > pop_median
gen treated_population_median = treated * population_median
gen log_population_muni = log(population_muni)
gen treated_log_population = treated * log_population_muni

* Create 2000 population variables
gen treated_population_2000 = treated * population_2000_muni
egen pop_2000_median = median(population_2000_muni)
gen population_2000_median = population_2000_muni > pop_2000_median
gen treated_population_2000_median = treated * population_2000_median
gen log_population_2000_muni = log(population_2000_muni)
gen treated_log_population_2000 = treated * log_population_2000_muni

* Create log homicide rate
gen log_tx_homicidio = log(taxa_homicidios_total_por_100m_1 + 1)

* Initialize matrix for storing p-values
matrix p_values = J(12, 2, .) // 12 models x 2 p-values (treatment, interaction)
matrix rownames p_values = A1 A2 A3 B1 B2 B3 A1_2000 A2_2000 A3_2000 B1_2000 B2_2000 B3_2000
matrix colnames p_values = p_treat p_int

local row = 0 // Counter for matrix rows

* Run regressions for current population
foreach depvar in "taxa_homicidios_total_por_100m_1" "log_tx_homicidio" {
    local panel = cond("`depvar'" == "taxa_homicidios_total_por_100m_1", "A", "B")
    
    * Level specification
    reg `depvar' treated treated_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
    boottest treated, reps(10000) cluster(state_code) weighttype(webb)
    local row = `row' + 1
    matrix p_values[`row', 1] = r(p)
    boottest treated_population, reps(10000) cluster(state_code) weighttype(webb)
    matrix p_values[`row', 2] = r(p)

    * Median specification
    reg `depvar' treated treated_population_median i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
    boottest treated, reps(10000) cluster(state_code) weighttype(webb)
    local row = `row' + 1
    matrix p_values[`row', 1] = r(p)
    boottest treated_population_median, reps(10000) cluster(state_code) weighttype(webb)
    matrix p_values[`row', 2] = r(p)

    * Log specification
    reg `depvar' treated treated_log_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
    boottest treated, reps(10000) cluster(state_code) weighttype(webb)
    local row = `row' + 1
    matrix p_values[`row', 1] = r(p)
    boottest treated_log_population, reps(10000) cluster(state_code) weighttype(webb)
    matrix p_values[`row', 2] = r(p)
}

* Run regressions for 2000 population
foreach depvar in "taxa_homicidios_total_por_100m_1" "log_tx_homicidio" {
    local panel = cond("`depvar'" == "taxa_homicidios_total_por_100m_1", "A", "B")
    
    * Level specification
    reg `depvar' treated treated_population_2000 i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
    boottest treated, reps(10000) cluster(state_code) weighttype(webb)
    local row = `row' + 1
    matrix p_values[`row', 1] = r(p)
    boottest treated_population_2000, reps(10000) cluster(state_code) weighttype(webb)
    matrix p_values[`row', 2] = r(p)

    * Median specification
    reg `depvar' treated treated_population_2000_median i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
    boottest treated, reps(10000) cluster(state_code) weighttype(webb)
    local row = `row' + 1
    matrix p_values[`row', 1] = r(p)
    boottest treated_population_2000_median, reps(10000) cluster(state_code) weighttype(webb)
    matrix p_values[`row', 2] = r(p)

    * Log specification
    reg `depvar' treated treated_log_population_2000 i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
    boottest treated, reps(10000) cluster(state_code) weighttype(webb)
    local row = `row' + 1
    matrix p_values[`row', 1] = r(p)
    boottest treated_log_population_2000, reps(10000) cluster(state_code) weighttype(webb)
    matrix p_values[`row', 2] = r(p)
}

* Display the matrix with p-values
matrix list p_values
