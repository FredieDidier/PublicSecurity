********************************************************************************
* 1. Load and prepare base data
********************************************************************************
use "/Users/fredie/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

********************************************************************************
* 2. Initial data preparation
********************************************************************************
* Remove specific municipalities
drop if municipality_code == 2300000 | municipality_code == 2600000

* Create base variables
gen treat_year = 0
replace treat_year = 2011 if inlist(state, "BA", "PB")
replace treat_year = 2015 if state == "CE"
replace treat_year = 2016 if state == "MA"
replace treat_year = 2007 if state == "PE"

* Generate relative year
gen rel_year = year - treat_year

********************************************************************************
* 3. Generate event time dummies and interactions
********************************************************************************
* Create event time dummies
forvalues l = 2/7 {
    gen F`l'event = rel_year == -`l'
}

forvalues l = 0/12 {
    gen L`l'event = rel_year == `l'
}

* Population variables setup
foreach type in "" "_2000" {
    * Define population variable name
    local pop_name = cond("`type'" == "", "population_muni", "population_2000_muni")
    
    * Generate population metrics
    gen pop`type' = `pop_name'                                    // Nível
    egen pop_median`type' = median(`pop_name')
    gen pop_above_median`type' = `pop_name' > pop_median`type'    // Above median
    gen log_pop`type' = log(`pop_name')                          // Log
    
    * Create interactions for all population metrics
    foreach metric in pop`type' pop_above_median`type' log_pop`type' {
        * Lead interactions
        forvalues l = 2/7 {
            gen F`l'event_`metric' = F`l'event * `metric'
        }
        * Lag interactions
        forvalues l = 0/12 {
            gen L`l'event_`metric' = L`l'event * `metric'
        }
    }
}

********************************************************************************
* 4. Regression analysis and plotting
********************************************************************************
capture program drop process_results
program define process_results
    preserve
    clear
    set obs 20
    
    * Setup base variables
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    gen coef = .
    gen se = .
    
    * Process coefficients for leads
    forvalues i = 2/7 {
        local pos = `i' + 18
        replace coef = b[1,`pos'] if period == -`i'
        replace se = sqrt(V[`pos',`pos']) if period == -`i'
    }
    
    * Process coefficients for lags
    forvalues i = 0/12 {
        local pos = `i' + 24
        replace coef = b[1,`pos'] if period == `i'
        replace se = sqrt(V[`pos',`pos']) if period == `i'
    }
    
    * Generate confidence intervals
    gen ci_lb = coef - 1.96 * se
    gen ci_ub = coef + 1.96 * se
    
    * Create event study plot
    twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
           (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
           (connect coef period, lcolor(navy) lpattern(dash)), ///
           xline(-1, lpattern(dash) lcolor(red)) ///
           yline(0, lcolor(black)) ///
           xlabel(-7(1)12, angle(45) labsize(small)) ///
           ylabel(, grid) ///
           xtitle("Years Relative to Treatment") ///
           ytitle("Coefficient of Interaction") ///
           graphregion(color(white)) ///
           bgcolor(white) ///
           legend(off) ///
           name(`1', replace)
    restore
end

* Run regressions for each population metric
foreach metric in pop pop_above_median log_pop {
    * Run regression
    reghdfe taxa_homicidios_total_por_100m_1 ///
            F*event L*event F*event_`metric' L*event_`metric' ///
            [aw=population_2000_muni], ///
            absorb(municipality_code year) ///
            cluster(state_code)
            
    * Generate plot
    process_results event_`metric' "`metric' Effects"
}

graph combine event_pop event_pop_above_median event_log_pop, ///
    cols(2) rows(2) xsize(11) ysize(10) ///
    graphregion(color(white) margin(zero))
	
	graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/event_study_pop_interaction.pdf", replace

********************************************************************************
* 5. Generate treated effects plots (without interactions)
********************************************************************************
capture program drop process_results_treated
program define process_results_treated
    preserve
    clear
    set obs 20
    
    * Setup base variables
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    gen coef = .
    gen se = .
    
    * Process coefficients for leads (treated effects only)
    forvalues i = 2/7 {
        local pos = `i'
        replace coef = b[1,`pos'] if period == -`i'
        replace se = sqrt(V[`pos',`pos']) if period == -`i'
    }
    
    * Process coefficients for lags (treated effects only)
    forvalues i = 0/12 {
        local pos = `i' + 6
        replace coef = b[1,`pos'] if period == `i'
        replace se = sqrt(V[`pos',`pos']) if period == `i'
    }
    
    * Generate confidence intervals
    gen ci_lb = coef - 1.96 * se
    gen ci_ub = coef + 1.96 * se
    
    * Create event study plot
    twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
           (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
           (connect coef period, lcolor(navy) lpattern(dash)), ///
           xline(-1, lpattern(dash) lcolor(red)) ///
           yline(0, lcolor(black)) ///
           xlabel(-7(1)12, angle(45) labsize(small)) ///
           ylabel(, grid) ///
           xtitle("Years Relative to Treatment") ///
           ytitle("Treatment Effect") ///
           graphregion(color(white)) ///
           bgcolor(white) ///
           legend(off) ///
           name(`1', replace)
    restore
end

* Run regressions for each population metric and get treated effects
foreach metric in pop pop_above_median log_pop {
    * Run regression with interactions
    reghdfe taxa_homicidios_total_por_100m_1 ///
            F*event L*event F*event_`metric' L*event_`metric' ///
            [aw=population_2000_muni], ///
            absorb(municipality_code year) ///
            cluster(state_code)
            
    * Generate plot for treated effects (base effects for low population)
    process_results_treated event_treated_`metric' "Treatment Effects (`metric')"
}

graph combine event_treated_pop event_treated_pop_above_median event_treated_log_pop, ///
    cols(2) rows(2) xsize(11) ysize(10) ///
    graphregion(color(white) margin(zero))

		
	graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/event_study_pop_no_interaction.pdf", replace
