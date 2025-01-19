* Load and prepare base data
use "/Users/fredie/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

* Basic data cleaning
drop if municipality_code == 2300000 | municipality_code == 2600000

* Population variables setup
foreach type in "" "_2000" {
    local pop_var = cond("`type'" == "", "population_muni", "population_2000_muni")
    egen pop_median`type' = median(`pop_var')
    gen log_pop`type' = log(`pop_var')
}

* Program to generate treatment variables and run analysis
capture program drop run_analysis
program define run_analysis
    syntax, analysis_type(string)
    
    * Treatment assignment based on type
    if "`analysis_type'" == "spillover" {
        gen spillover = 0
        * 2007-2010: Only PE spillovers
        replace spillover = 1 if year >= 2007 & year <= 2010 & dist_PE < 50
        * 2011-2014: PE, BA, PB spillovers
        replace spillover = 1 if year >= 2011 & year <= 2014 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50)
        * 2015: PE, BA, PB, CE spillovers
        replace spillover = 1 if year == 2015 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50 | dist_CE < 50)
        * 2016 onwards: All treated states spillovers
        replace spillover = 1 if year >= 2016 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50 | dist_CE < 50 | dist_MA < 50)
        local treat_var "spillover"
    }
    else {
        gen `analysis_type' = 0
        replace `analysis_type' = 1 if state == "PE" & year >= 2007
        replace `analysis_type' = 1 if state == "BA" & year >= 2011
        replace `analysis_type' = 1 if state == "PB" & year >= 2011
        replace `analysis_type' = 1 if state == "CE" & year >= 2015
        replace `analysis_type' = 1 if state == "MA" & year >= 2016
        local treat_var "`analysis_type'"
        
        * Keep only relevant sample for neighbor analysis
        if "`analysis_type'" == "neighbor" {
            keep if dist_treated < 50
        }
    }

    * Treatment year assignment
    gen treatment_year = .
    if "`analysis_type'" == "spillover" {
        replace treatment_year = 2007 if dist_PE < 50
        replace treatment_year = 2011 if dist_BA < 50 | dist_PB < 50
        replace treatment_year = 2015 if dist_CE < 50
        replace treatment_year = 2016 if dist_MA < 50
    }
    else {
        replace treatment_year = 2011 if state == "BA" | state == "PB"
        replace treatment_year = 2015 if state == "CE"
        replace treatment_year = 2016 if state == "MA"
        replace treatment_year = 2007 if state == "PE"
    }
    
    * Generate event study variables
    gen rel_year = year - treatment_year
    
    * Event dummies
    forvalues l = 0/12 {
        gen L`l'event = rel_year == `l'
    }
    forvalues l = 2/7 {
        gen F`l'event = rel_year == -`l'
    }
    
    * Generate population interactions for both current and 2000 population
    foreach type in "" "_2000" {
        local pop_var = cond("`type'" == "", "population_muni", "population_2000_muni")
        
        * Create all population interactions
        gen `treat_var'_population`type' = `treat_var' * `pop_var'
        gen pop_above_median`type' = `pop_var' > pop_median`type'
        gen `treat_var'_pop_above_median`type' = `treat_var' * pop_above_median`type'
        gen `treat_var'_log_pop`type' = `treat_var' * log_pop`type'
        
        * Event study interactions
        foreach var of varlist F*event L*event {
            gen `var'_pop`type' = `var' * `pop_var'
            gen `var'_pop_med`type' = `var' * pop_above_median`type'
            gen `var'_log_pop`type' = `var' * log_pop`type'
        }
    }
    
    * Run regressions for each specification
    foreach spec in "pop" "pop_med" "log_pop" {
        foreach pop in "" "_2000" {
            reghdfe taxa_homicidios_total_por_100m_1 F*event_`spec'`pop' L*event_`spec'`pop' `treat_var' [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
            estimates store `spec'`pop'
        }
    }
    
    * Create and combine graphs for each specification
    foreach spec in "pop" "pop_med" "log_pop" {
        process_estimates, spec(`spec') analysis(`analysis_type')
    }
    
    * Combine graphs
    graph combine g1 g2 g3, ///
    rows(3) xsize(8.5) ysize(11) ///
    graphregion(color(white) margin(zero)) ///
    imargin(small) ///
    scale(0.9) ///
    name(combined_`analysis_type', replace)
    
    * Export combined graph
    graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/combined_`analysis_type'.pdf", replace
end

* Processing estimates and creating individual graphs
capture program drop process_estimates
program define process_estimates
    syntax, spec(string) analysis(string)
    
    preserve
    clear
    set obs 20
    gen period = _n - 8
    
    foreach pop in "" "_2000" {
        estimates restore `spec'`pop'
        matrix b`pop' = e(b)
        matrix V`pop' = e(V)
        
        gen b`pop' = .
        gen se`pop' = .
        
        * Process pre-treatment periods
        forval i = 2/7 {
            local pos = 8 - `i'
            replace b`pop' = b`pop'[1,`pos'] if period == -`i'
            replace se`pop' = sqrt(V`pop'[`pos',`pos']) if period == -`i'
        }
        
        * Process post-treatment periods
        forval i = 0/12 {
            local pos = `i' + 7
            replace b`pop' = b`pop'[1,`pos'] if period == `i'
            replace se`pop' = sqrt(V`pop'[`pos',`pos']) if period == `i'
        }
        
        * Generate confidence intervals
        gen ci_lb`pop' = b`pop' - 1.96*se`pop'
        gen ci_ub`pop' = b`pop' + 1.96*se`pop'
    }
    
    * Graph settings based on specification
    local color = cond("`spec'" == "pop", "navy", cond("`spec'" == "pop_med", "maroon", "forest_green"))
    local title1 = cond("`spec'" == "pop", "Current Population (Level)", ///
                       cond("`spec'" == "pop_med", "Current Population > Median", "Current Log Population"))
    local title2 = cond("`spec'" == "pop", "2000 Population (Level)", ///
                       cond("`spec'" == "pop_med", "2000 Population > Median", "2000 Log Population"))
    
    * Create graph
    twoway ///
        (rcap ci_ub ci_lb period, lcolor(`color')) ///
        (connected b period, lcolor(`color') mcolor(`color') msymbol(circle)) ///
        (rcap ci_ub_2000 ci_lb_2000 period, lcolor(`color'*0.5)) ///
        (connected b_2000 period, lcolor(`color'*0.5) mcolor(`color'*0.5) msymbol(circle)), ///
        yline(0, lwidth(thick) lcolor(gs8)) xline(-1, lcolor(gs12) lpattern(dash)) ///
        xlabel(-7(1)12, labsize(small)) /// 
        xtitle("Years Relative to Treatment", size(small)) ///
        ytitle("Coefficient", size(small)) ///
        ylabel(,format(%9.2f) angle(horizontal) labsize(small)) ///
        legend(order(2 "`title1'" 4 "`title2'") rows(2) region(style(none)) size(small) position(6)) ///
        graphregion(color(white) margin(small)) bgcolor(white) ///
        name(g`=cond("`spec'"=="pop",1,cond("`spec'"=="pop_med",2,3))', replace)
    
    restore
end

* Run all analyses
foreach analysis in treated neighbor spillover {
    preserve
    run_analysis, analysis_type(`analysis')
    restore
}
