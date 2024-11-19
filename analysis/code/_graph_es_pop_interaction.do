* Load and prepare base data
capture program drop run_analysis
program define run_analysis
    syntax, analysis_type(string)
    
    * Load data and basic setup
    use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
    drop if municipality_code == 2300000 | municipality_code == 2600000 
    
    * Filter data based on analysis type
    if "`analysis_type'" == "neighbor" {
        keep if dist_treated < 50
    }
    else if "`analysis_type'" == "spillover" {
        drop if state == "PE" | state == "BA" | state == "PB" | state == "CE" | state == "MA"
    }
    
    * Treatment/spillover assignment
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
    }
    
    * Treatment year assignment based on analysis type
    gen treatment_year = .
    if "`analysis_type'" == "spillover" {
        replace treatment_year = 2007 if dist_PE < 50
        replace treatment_year = 2011 if dist_BA < 50 | dist_PB < 50
        replace treatment_year = 2015 if dist_CE < 50
        replace treatment_year = 2016 if dist_MA < 50
        replace treatment_year = 2007 if dist_PE < 50
    }
    else {
        replace treatment_year = 2011 if state == "BA" | state == "PB"
        replace treatment_year = 2015 if state == "CE"
        replace treatment_year = 2016 if state == "MA"
        replace treatment_year = 2007 if state == "PE"
    }
    
    gen rel_year = year - treatment_year
    gen log_tx_homicidio = log(taxa_homicidios_total_por_100m_1 + 1)
    
    * Generate event time dummies first
    forvalues l = 0/12 {
        gen L`l'event = rel_year == `l'
    }
    forvalues l = 2/7 {
        gen F`l'event = rel_year == -`l'
    }
    
    * Create all population interactions
    foreach type in "" "_2000" {
        local popvar = cond("`type'"=="", "population_muni", "population_2000_muni")
        
        * Basic population interactions
        gen `treat_var'_population`type' = `treat_var' * `popvar'
        egen pop_median`type' = median(`popvar')
        gen pop_above_median`type' = `popvar' > pop_median`type'
        gen `treat_var'_pop_above_median`type' = `treat_var' * pop_above_median`type'
        gen log_pop`type' = log(`popvar')
        gen `treat_var'_log_pop`type' = `treat_var' * log_pop`type'
        
        * Event study interactions
        foreach var of varlist F*event L*event {
            gen `var'_pop`type' = `var' * `popvar'
            gen `var'_pop_med`type' = `var' * pop_above_median`type'
            gen `var'_log_pop`type' = `var' * log_pop`type'
        }
    }
    
    * Run regressions and create graphs for both panels
    foreach panel in "level" "log" {
        local depvar = cond("`panel'" == "level", "taxa_homicidios_total_por_100m_1", "log_tx_homicidio")
        
        foreach spec in "pop" "pop_med" "log_pop" {
            foreach pop in "" "_2000" {
                reghdfe `depvar' F*event_`spec'`pop' L*event_`spec'`pop' `treat_var' [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
                estimates store `spec'`pop'_`panel'
            }
        }
        
        * Create and combine graphs
        foreach spec in "pop" "pop_med" "log_pop" {
            process_estimates, spec(`spec') panel(`panel') analysis(`analysis_type')
        }
        
        graph combine g1_`panel' g2_`panel' g3_`panel', ///
        rows(3) xsize(8.5) ysize(11) ///
        graphregion(color(white) margin(zero)) ///
        imargin(small) ///
        scale(0.9) ///
        name(combined_`analysis_type'_`panel', replace)
    }
end

* Processing estimates and creating graphs
capture program drop process_estimates
program define process_estimates
    syntax, spec(string) panel(string) analysis(string)
    
    preserve
    clear
    set obs 20
    gen period = _n - 8
    
    foreach pop in "" "_2000" {
        estimates restore `spec'`pop'_`panel'
        matrix b`pop' = e(b)
        matrix V`pop' = e(V)
        
        gen b`pop' = .
        gen se`pop' = .
        
        forval i = 2/7 {
            local pos = 8 - `i'
            replace b`pop' = b`pop'[1,`pos'] if period == -`i'
            replace se`pop' = sqrt(V`pop'[`pos',`pos']) if period == -`i'
        }
        
        forval i = 0/12 {
            local pos = `i' + 7
            replace b`pop' = b`pop'[1,`pos'] if period == `i'
            replace se`pop' = sqrt(V`pop'[`pos',`pos']) if period == `i'
        }
        
        gen ci_lb`pop' = b`pop' - 1.96*se`pop'
        gen ci_ub`pop' = b`pop' + 1.96*se`pop'
    }
    
    * Graph settings
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
        name(g`=cond("`spec'"=="pop",1,cond("`spec'"=="pop_med",2,3))'_`panel', replace)
        
    restore
end

* Run all analyses
foreach analysis in treated neighbor spillover {
    run_analysis, analysis_type(`analysis')
}
