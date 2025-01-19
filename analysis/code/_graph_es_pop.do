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
    
    * Generate interaction terms for both current and 2000 population
    foreach type in "" "_2000" {
        local pop_var = cond("`type'" == "", "population_muni", "population_2000_muni")
        
        * Basic interactions
        gen `treat_var'_pop`type' = `treat_var' * `pop_var'
        gen `treat_var'_pop_med`type' = `treat_var' * (`pop_var' > pop_median`type')
        gen `treat_var'_log_pop`type' = `treat_var' * log_pop`type'
    }
    
    * Run regressions and store estimates
    foreach spec in "pop" "pop_med" "log_pop" {
        foreach type in "" "_2000" {
            local var_name "`treat_var'_`spec'`type'"
            
            reghdfe taxa_homicidios_total_por_100m_1 ///
                F*event L*event `var_name' ///
                [aw=population_2000_muni], ///
                absorb(municipality_code year) ///
                cluster(state_code municipality_code)
                
            estimates store `spec'`type'
        }
    }
    
    * Create coefplot
    coefplot ///
        (pop, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
        (pop_med, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
        (log_pop, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
        (pop_2000, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5))) ///
        (pop_med_2000, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
        (log_pop_2000, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
        vertical ///
        keep(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L*event*) ///
        order(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L*event*) ///
        coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
                   L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
                   L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
        yline(0, lwidth(thick) lcolor(gs8)) xline(6.5, lcolor(gs12)) ///
        xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
        legend(position(6) rows(2) region(color(none)) cols(3) ring(1) size(small) symxsize(4) keygap(2) rowgap(1)) ///
        name(event_study_`analysis_type', replace) ///
        graphregion(color(white) margin(medium)) bgcolor(white)
        
    * Export graph
    graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/event_study_pop_no_interaction_`analysis_type'.pdf", replace
    
    * Clean up
    cap drop `treat_var'* rel_year F*event L*event treatment_year
end

* Run analysis for each type
foreach type in treated neighbor spillover {
    preserve
    run_analysis, analysis_type("`type'")
    restore
}
