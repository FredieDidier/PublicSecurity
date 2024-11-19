************************************

**** Treated 

************************************

* Excluir municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

* Criar variável de tratamento
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007
replace treated = 1 if state == "BA" & year >= 2011
replace treated = 1 if state == "PB" & year >= 2011
replace treated = 1 if state == "CE" & year >= 2015
replace treated = 1 if state == "MA" & year >= 2016

* Criar variável de ano de tratamento
gen treatment_year = .
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"
replace treatment_year = 2007 if state == "PE"

* Criar variável de tempo relativo ao tratamento
gen rel_year = year - treatment_year

* Criar variáveis auxiliares
gen treated_population = treated * population_muni
gen log_population_muni = log(population_muni)
gen treated_log_population = treated * log_population_muni
egen population_median = median(population_muni)
gen population_above_median = population_muni > population_median
gen treated_population_median = treated * population_above_median

* Criar variável para população 2000
gen treated_population_2000 = treated * population_2000_muni
egen population_2000_median = median(population_2000_muni)
gen population_2000_above_median = population_2000_muni > population_2000_median
gen treated_population_2000_median = treated * population_2000_above_median
gen log_population_2000_muni = log(population_2000_muni)
gen treated_log_population_2000 = treated * log_population_2000_muni
gen log_tx_homicidio = log(taxa_homicidios_total_por_100m_1 + 1)

* Criar variáveis dummies para estudo de evento
forvalues l = 0/12 {
    gen L`l'event = rel_year == `l'
}
forvalues l = 1/7 {
    gen F`l'event = rel_year == -`l'
}
drop F1event 

* Panel A: Level
* Current Population
reghdfe taxa_homicidios_total_por_100m_1  F*event L*event treated_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_a

reghdfe taxa_homicidios_total_por_100m_1  F*event L*event treated_population_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_a

reghdfe taxa_homicidios_total_por_100m_1  F*event L*event treated_log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_a

* Population 2000
reghdfe taxa_homicidios_total_por_100m_1  F*event L*event L0event-L12event treated_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_a

reghdfe taxa_homicidios_total_por_100m_1  F*event L*event treated_population_2000_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_a

reghdfe taxa_homicidios_total_por_100m_1  F*event L*event treated_log_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_a

* Panel B: Log
* Current Population
reghdfe log_tx_homicidio  F*event L*event treated_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_b

reghdfe log_tx_homicidio  F*event L*event treated_population_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_b

reghdfe log_tx_homicidio  F*event L*event treated_log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_b

* Population 2000
reghdfe log_tx_homicidio  F*event L*event treated_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_b

reghdfe log_tx_homicidio  F*event L*event treated_population_2000_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_b

reghdfe log_tx_homicidio  F*event L*event treated_log_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_b

* Graph Panel A
coefplot ///
    (pop_level_curr_a, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
    (pop_median_curr_a, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
    (pop_log_curr_a, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
    (pop_level_2000_a, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5))) ///
    (pop_median_2000_a, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
    (pop_log_2000_a, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
    vertical ///
    keep(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    order(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
               L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
               L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
    yline(0, lcolor(gs12)) xline(6.5, lcolor(gs12)) ///
    xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
    legend(position(6) rows(2) region(color(none)) cols(3) ring(1) size(small) symxsize(4) keygap(2) rowgap(1)) ///
    name(panel_a, replace) ///
    graphregion(color(white) margin(medium)) bgcolor(white)


* Graph Panel B
coefplot ///
    (pop_level_curr_b, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
    (pop_median_curr_b, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
    (pop_log_curr_b, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
    (pop_level_2000_b, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5)))  ///
    (pop_median_2000_b, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
    (pop_log_2000_b, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
    vertical ///
    keep(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    order(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
               L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
               L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
    yline(0, lcolor(gs12)) xline(6.5, lcolor(gs12)) ///
    xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
    legend(position(6) rows(2) region(color(none)) cols(3) ring(1) size(small) symxsize(4) keygap(2) rowgap(1)) ///
    name(panel_b, replace) ///
    graphregion(color(white) margin(medium)) bgcolor(white)

* Combine graphs
graph combine panel_a panel_b, ///
    rows(2) ///
    graphregion(color(white) margin(medium)) ///
    name(combined, replace)
	
	
	
************************************

**** Robustness check (neighbors)

************************************

* Rename treatment variables to neighbor
    rename treated neighbor
    rename treated_population neighbor_population
    rename treated_population_median neighbor_population_median
    rename treated_log_population neighbor_log_population
    rename treated_population_2000 neighbor_population_2000
    rename treated_population_2000_median neighbor_population_2000_median
    rename treated_log_population_2000 neighbor_log_population_2000

* Keep only municipalities within 50km of treated border
keep if dist_treated < 50

* Panel A: Level
* Current Population
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event neighbor_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event neighbor_population_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event neighbor_log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_a

* Population 2000
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event neighbor_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event neighbor_population_2000_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event neighbor_log_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_a

* Panel B: Log
* Current Population
reghdfe log_tx_homicidio F*event L*event neighbor_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_b

reghdfe log_tx_homicidio F*event L*event neighbor_population_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_b

reghdfe log_tx_homicidio F*event L*event neighbor_log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_b

* Population 2000
reghdfe log_tx_homicidio F*event L*event neighbor_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_b

reghdfe log_tx_homicidio F*event L*event neighbor_population_2000_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_b

reghdfe log_tx_homicidio F*event L*event neighbor_log_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_b

* Graph Panel A
coefplot ///
    (pop_level_curr_a, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
    (pop_median_curr_a, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
    (pop_log_curr_a, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
    (pop_level_2000_a, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5))) ///
    (pop_median_2000_a, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
    (pop_log_2000_a, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
    vertical ///
    keep(F7event F6event F5event F4event F3event F2event L0event L1event L2event L3event L4event L5event L6event L7event L8event L9event L10event L11event L12event) ///
    coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
               L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
               L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
    yline(0, lcolor(gs12)) xline(6.5, lcolor(gs12)) ///
    xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
    legend(position(6) rows(2) region(color(none)) cols(3) size(small) symxsize(4)) ///
    name(panel_a_50km, replace) ///
    graphregion(color(white)) bgcolor(white)

* Graph Panel B
coefplot ///
    (pop_level_curr_b, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
    (pop_median_curr_b, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
    (pop_log_curr_b, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
    (pop_level_2000_b, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5))) ///
    (pop_median_2000_b, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
    (pop_log_2000_b, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
    vertical ///
    keep(F7event F6event F5event F4event F3event F2event L0event L1event L2event L3event L4event L5event L6event L7event L8event L9event L10event L11event L12event) ///
    coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
               L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
               L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
    yline(0, lcolor(gs12)) xline(6.5, lcolor(gs12)) ///
    xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
    legend(position(6) rows(2) region(color(none)) cols(3) size(small) symxsize(4)) ///
    name(panel_b_50km, replace) ///
    graphregion(color(white)) bgcolor(white)
	
	* Combine graphs
graph combine panel_a_50km panel_b_50km, ///
    rows(2) ///
    graphregion(color(white) margin(medium)) ///
    name(combined, replace)

	
	
******************************************

********** Spillover *******************

******************************************

* Create spillover variable
gen spillover = 0

* 2007-2010: Only PE spillovers
replace spillover = 1 if year >= 2007 & year <= 2010 & dist_PE < 50

* 2011-2014: PE, BA, PB spillovers
replace spillover = 1 if year >= 2011 & year <= 2014 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50)

* 2015: PE, BA, PB, CE spillovers 
replace spillover = 1 if year == 2015 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50 | dist_CE < 50)

* 2016 onwards: All treated states spillovers
replace spillover = 1 if year >= 2016 & (dist_PE < 50 | dist_BA < 50 | dist_PB < 50 | dist_CE < 50 | dist_MA < 50)

* Create interaction terms
gen spillover_population = spillover * population_muni
gen spillover_population_median = spillover * (population_muni > population_median)
gen spillover_log_population = spillover * log(population_muni)
gen spillover_population_2000 = spillover * population_2000_muni
gen spillover_population_2000_median = spillover * (population_2000_muni > population_2000_median)
gen spillover_log_population_2000 = spillover * log(population_2000_muni)


* Panel A: Level
* Current Population
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event spillover_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event spillover_population_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event spillover_log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_a

* Population 2000
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event spillover_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event spillover_population_2000_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_a

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event spillover_log_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_a

* Panel B: Log
* Current Population
reghdfe log_tx_homicidio F*event L*event spillover_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_b

reghdfe log_tx_homicidio F*event L*event spillover_population_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_b

reghdfe log_tx_homicidio F*event L*event spillover_log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_b

* Population 2000
reghdfe log_tx_homicidio F*event L*event spillover_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_b

reghdfe log_tx_homicidio F*event L*event spillover_population_2000_median [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_b

reghdfe log_tx_homicidio F*event L*event spillover_log_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_b

* Graph Panel A
coefplot ///
    (pop_level_curr_a, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
    (pop_median_curr_a, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
    (pop_log_curr_a, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
    (pop_level_2000_a, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5))) ///
    (pop_median_2000_a, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
    (pop_log_2000_a, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
    vertical ///
    keep(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    order(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
               L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
               L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
    yline(0, lcolor(gs12)) xline(6.5, lcolor(gs12)) ///
    xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
    legend(position(6) rows(2) region(color(none)) cols(3) ring(1) size(small) symxsize(4) keygap(2) rowgap(1)) ///
    name(panel_a, replace) ///
    graphregion(color(white) margin(medium)) bgcolor(white)

* Graph Panel B
coefplot ///
    (pop_level_curr_b, label("Current Population (Level)") mcolor(navy) msymbol(circle) ciopts(color(navy))) ///
    (pop_median_curr_b, label("Current Population > Median") mcolor(maroon) msymbol(circle) ciopts(color(maroon))) ///
    (pop_log_curr_b, label("Current Log Population") mcolor(forest_green) msymbol(circle) ciopts(color(forest_green))) ///
    (pop_level_2000_b, label("2000 Population (Level)") mcolor(navy*0.5) msymbol(circle) ciopts(color(navy*0.5))) ///
    (pop_median_2000_b, label("2000 Population > Median") mcolor(maroon*0.5) msymbol(circle) ciopts(color(maroon*0.5))) ///
    (pop_log_2000_b, label("2000 Log Population") mcolor(forest_green*0.5) msymbol(circle) ciopts(color(forest_green*0.5))), ///
    vertical ///
    keep(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    order(F7event* F6event* F5event* F4event* F3event* F2event* L0event* L1event* L2event* L3event* L4event* L5event* L6event* L7event* L8event* L9event* L10event* L11event* L12event*) ///
    coeflabels(F7event=-7 F6event=-6 F5event=-5 F4event=-4 F3event=-3 F2event=-2 ///
               L0event=0 L1event=1 L2event=2 L3event=3 L4event=4 L5event=5 ///
               L6event=6 L7event=7 L8event=8 L9event=9 L10event=10 L11event=11 L12event=12) ///
    yline(0, lcolor(gs12)) xline(6.5, lcolor(gs12)) ///
    xtitle("Years Relative to Treatment") ytitle("Coefficient") ///
    legend(position(6) rows(2) region(color(none)) cols(3) ring(1) size(small) symxsize(4) keygap(2) rowgap(1)) ///
    name(panel_b, replace) ///
    graphregion(color(white) margin(medium)) bgcolor(white)
	

	* Combine graphs
graph combine panel_a panel_b, ///
    rows(2) ///
    graphregion(color(white) margin(medium)) ///
    name(combined, replace)
