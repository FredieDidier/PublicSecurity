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


**************************************
*** Robustness Neighbors ****
**************************************
	
* Create Matrices
matrix results_100 = J(18, 2, .)
matrix results_75 = J(18, 2, .)
matrix results_50 = J(18, 2, .)

foreach dist in 100 75 50 {
    preserve
    
    * Keep only observations within distance
    keep if dist_treated < `dist'
    
    * Rename treatment variables to neighbor
    rename treated neighbor
    rename treated_population neighbor_population
    rename treated_population_median neighbor_population_median
    rename treated_log_population neighbor_log_population
    rename treated_population_2000 neighbor_population_2000
    rename treated_population_2000_median neighbor_population_2000_median
    rename treated_log_population_2000 neighbor_log_population_2000
    
    * Ajuste para matriz de 18 linhas (9 especificações x 2 painéis)
    matrix p_values_`dist'km = J(18, 2, .) 
    matrix rownames p_values_`dist'km = ///
        A_curr_level A_curr_median A_curr_log ///
        A_2000_level A_2000_median A_2000_log ///
        B_curr_level B_curr_median B_curr_log ///
        B_2000_level B_2000_median B_2000_log
    matrix colnames p_values_`dist'km = p_neighbor p_int
    
    local row = 0 
    
    * Run regressions for current population
    foreach depvar in "taxa_homicidios_total_por_100m_1" "log_tx_homicidio" {
        local panel = cond("`depvar'" == "taxa_homicidios_total_por_100m_1", "A", "B")
        
        * Level specification
        reg `depvar' neighbor neighbor_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest neighbor, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest neighbor_population, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Median specification
        reg `depvar' neighbor neighbor_population_median i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest neighbor, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest neighbor_population_median, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Log specification
        reg `depvar' neighbor neighbor_log_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest neighbor, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest neighbor_log_population, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
    }
    
    * Run regressions for 2000 population
    foreach depvar in "taxa_homicidios_total_por_100m_1" "log_tx_homicidio" {
        local panel = cond("`depvar'" == "taxa_homicidios_total_por_100m_1", "A", "B")
        
        * Level specification
        reg `depvar' neighbor neighbor_population_2000 i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest neighbor, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest neighbor_population_2000, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Median specification
        reg `depvar' neighbor neighbor_population_2000_median i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest neighbor, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest neighbor_population_2000_median, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Log specification
        reg `depvar' neighbor neighbor_log_population_2000 i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest neighbor, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest neighbor_log_population_2000, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
    }
    
    * Store results for each distance
    if `dist' == 100 {
        matrix results_100 = p_values_`dist'km
    }
    if `dist' == 75 {
        matrix results_75 = p_values_`dist'km
    }
    if `dist' == 50 {
        matrix results_50 = p_values_`dist'km
    }
    
    restore
}

* Display all results after loop
display as text _newline "Results for 100km:"
matrix list results_100
display as text _newline "Results for 75km:"
matrix list results_75
display as text _newline "Results for 50km:"
matrix list results_50


**************************************
*** Spillover Analysis ***
**************************************

* Create Matrices
matrix results_100 = J(24, 2, .)
matrix results_75 = J(24, 2, .)
matrix results_50 = J(24, 2, .)

foreach dist in 100 75 50 {
    preserve
    
    * Drop treated states
    drop if inlist(state, "PE", "BA", "PB", "CE", "MA")
    
    * Keep only observations within distance threshold
    gen min_dist = min(dist_PE, dist_BA, dist_PB, dist_CE, dist_MA)
    keep if min_dist < `dist'
    
    * Generate spillover variable
    gen spillover = 0
    
    * 2007-2010: Only PE spillovers
    replace spillover = 1 if year >= 2007 & year <= 2010 & dist_PE <= `dist'
    
    * 2011-2014: PE, BA, PB spillovers
    replace spillover = 1 if year >= 2011 & year <= 2014 & ///
        min(dist_PE, dist_BA, dist_PB) <= `dist'
    
    * 2015: PE, BA, PB, CE spillovers
    replace spillover = 1 if year == 2015 & ///
        min(dist_PE, dist_BA, dist_PB, dist_CE) <= `dist'
    
    * 2016 onwards: All treated states spillovers
    replace spillover = 1 if year >= 2016 & min_dist <= `dist'
    
    * Generate interaction terms
    gen spillover_population = spillover * population_muni
    gen spillover_population_median = spillover * population_median
    gen spillover_log_population = spillover * log_population_muni
    gen spillover_population_2000 = spillover * population_2000_muni
    gen spillover_population_2000_median = spillover * population_2000_median
    gen spillover_log_population_2000 = spillover * log_population_2000_muni
    
    * Initialize matrix for current distance
    matrix p_values_`dist'km = J(24, 2, .)
    matrix rownames p_values_`dist'km = ///
        A_curr_level A_curr_median A_curr_log ///
        A_2000_level A_2000_median A_2000_log ///
        B_curr_level B_curr_median B_curr_log ///
        B_2000_level B_2000_median B_2000_log
    matrix colnames p_values_`dist'km = p_spillover p_int
    
    local row = 0
    
    * Run regressions for current population
    foreach depvar in "taxa_homicidios_total_por_100m_1" "log_tx_homicidio" {
        local panel = cond("`depvar'" == "taxa_homicidios_total_por_100m_1", "A", "B")
        
        * Level specification
        reg `depvar' spillover spillover_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest spillover, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest spillover_population, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Median specification
        reg `depvar' spillover spillover_population_median i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest spillover, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest spillover_population_median, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Log specification
        reg `depvar' spillover spillover_log_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest spillover, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest spillover_log_population, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
    }
    
    * Run regressions for 2000 population
    foreach depvar in "taxa_homicidios_total_por_100m_1" "log_tx_homicidio" {
        local panel = cond("`depvar'" == "taxa_homicidios_total_por_100m_1", "A", "B")
        
        * Level specification
        reg `depvar' spillover spillover_population_2000 i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest spillover, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest spillover_population_2000, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Median specification
        reg `depvar' spillover spillover_population_2000_median i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest spillover, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest spillover_population_2000_median, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
        
        * Log specification
        reg `depvar' spillover spillover_log_population_2000 i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        boottest spillover, reps(10000) cluster(state_code) weighttype(webb)
        local row = `row' + 1
        matrix p_values_`dist'km[`row', 1] = r(p)
        boottest spillover_log_population_2000, reps(10000) cluster(state_code) weighttype(webb)
        matrix p_values_`dist'km[`row', 2] = r(p)
    }
    
    * Store results for each distance
    if `dist' == 100 {
        matrix results_100 = p_values_`dist'km
    }
    if `dist' == 75 {
        matrix results_75 = p_values_`dist'km
    }
    if `dist' == 50 {
        matrix results_50 = p_values_`dist'km
    }
    
    restore
}

* Display all results
display as text _newline "Results for 100km:"
matrix list results_100
display as text _newline "Results for 75km:"
matrix list results_75
display as text _newline "Results for 50km:"
matrix list results_50
