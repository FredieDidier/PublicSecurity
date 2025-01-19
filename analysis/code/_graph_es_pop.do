* Load and prepare base data
use "/Users/fredie/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

* Basic data cleaning
drop if municipality_code == 2300000 | municipality_code == 2600000

* Population variables setup
foreach type in "" "_2000" {
    local pop_var = cond("`type'" == "", "population_muni", "population_2000_muni")
    egen pop_median`type' = median(`pop_var')
    gen log_pop`type' = log(`pop_var')
    gen pop_above_median`type' = `pop_var' > pop_median`type'
}

* Program to generate treatment variables and run analysis
capture program drop run_analysis
program define run_analysis
    syntax, analysis_type(string)
    
    * Treatment assignment based on type
    if "`analysis_type'" == "spillover" {
        gen treatment = 0
        * 2007-2010: Only PE spillovers
        replace treatment = 1 if year >= 2007 & year <= 2010 & dist_PE < 50
        * 2011-2014: PE, BA, PB spillovers
        replace treatment = 1 if year >= 2011 & year <= 2014 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50)
        * 2015: PE, BA, PB, CE spillovers
        replace treatment = 1 if year == 2015 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50 | dist_CE < 50)
        * 2016 onwards: All treated states spillovers
        replace treatment = 1 if year >= 2016 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50 | dist_CE < 50 | dist_MA < 50)
    }
    else if "`analysis_type'" == "treated" {
        gen treatment = 0
        replace treatment = 1 if state == "PE" & year >= 2007
        replace treatment = 1 if state == "BA" & year >= 2011
        replace treatment = 1 if state == "PB" & year >= 2011
        replace treatment = 1 if state == "CE" & year >= 2015
        replace treatment = 1 if state == "MA" & year >= 2016
    }
    else if "`analysis_type'" == "neighbor" {
        gen treatment = 0
        replace treatment = 1 if state == "PE" & year >= 2007
        replace treatment = 1 if state == "BA" & year >= 2011
        replace treatment = 1 if state == "PB" & year >= 2011
        replace treatment = 1 if state == "CE" & year >= 2015
        replace treatment = 1 if state == "MA" & year >= 2016
        * Keep only municipalities within 50km of treated states
        keep if dist_treated < 50
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
    
    * Run regressions for each specification
    foreach spec in "pop" "pop_med" "log_pop" {
        foreach pop in "" "_2000" {
            if "`spec'" == "pop" {
                local weight = cond("`pop'"=="", "population_muni", "population_2000_muni")
            }
            else if "`spec'" == "pop_med" {
                local weight = "pop_above_median`pop'"
            }
            else {
                local weight = "log_pop`pop'"
            }
            
            reghdfe taxa_homicidios_total_por_100m_1 F*event L*event treatment [aw=`weight'], absorb(municipality_code year) cluster(state_code municipality_code)
            estimates store `spec'`pop'
        }
    }
    
    * Process results and create graphs
    foreach spec in "pop" "pop_med" "log_pop" {
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
                           cond("`spec'" == "pop_med", "Current Population < Median", "Current Log Population"))
        local title2 = cond("`spec'" == "pop", "2000 Population (Level)", ///
                           cond("`spec'" == "pop_med", "2000 Population < Median", "2000 Log Population"))
        
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
    }
    
    * Combine graphs for this analysis type
    graph combine g1 g2 g3, ///
    rows(3) xsize(8.5) ysize(11) ///
    graphregion(color(white) margin(zero)) ///
    imargin(small) ///
    scale(0.9) ///
    name(combined_`analysis_type', replace)
    
    * Export combined graph
    graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/event_study_pop_no_interaction_`analysis_type'.pdf", replace
end

* Run all analyses
foreach analysis in treated neighbor spillover {
    preserve
    run_analysis, analysis_type(`analysis')
    restore
}
