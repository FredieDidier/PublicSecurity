* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
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

* Criar variável para população em 2000
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

* Criar interações
foreach var of varlist F*event L*event {
    gen `var'_pop = `var' * population_muni
    gen `var'_pop_med = `var' * population_above_median
    gen `var'_log_pop = `var' * log_population_muni
    gen `var'_pop2000 = `var' * population_2000_muni
    gen `var'_pop2000_med = `var' * population_2000_above_median
    gen `var'_log_pop2000 = `var' * log_population_2000_muni
}

******************************

*** PANEL A *******************

****************************

* Regressões para População em Nível
reghdfe taxa_homicidios_total_por_100m_1 F*event_pop L*event_pop treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_a
reghdfe taxa_homicidios_total_por_100m_1 F*event_pop2000 L*event_pop2000 treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_a

* Criar dataset base com períodos
clear
set obs 20  // -7 a 12
gen period = _n - 8  // Gera períodos de -7 a 12

* Extrair dados Current Population
estimates restore pop_level_curr_a
matrix b = e(b)
matrix V = e(V)

gen b1 = .
gen se1 = .
gen ci_lb1 = .
gen ci_ub1 = .

* Fill leads (F's) para current
forval i = 2/7 {
    local pos = 8 - `i'
    replace b1 = b[1,`pos'] if period == -`i'
    replace se1 = sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para current
forval i = 0/12 {
    local pos = `i' + 7
    replace b1 = b[1,`pos'] if period == `i'
    replace se1 = sqrt(V[`pos',`pos']) if period == `i'
}

* Extrair dados 2000 Population
estimates restore pop_level_2000_a
matrix b2 = e(b)
matrix V2 = e(V)

gen b2 = .
gen se2 = .
gen ci_lb2 = .
gen ci_ub2 = .

* Fill leads (F's) para 2000
forval i = 2/7 {
    local pos = 8 - `i'
    replace b2 = b2[1,`pos'] if period == -`i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para 2000
forval i = 0/12 {
    local pos = `i' + 7
    replace b2 = b2[1,`pos'] if period == `i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
replace ci_lb1 = b1 - 1.96*se1
replace ci_ub1 = b1 + 1.96*se1
replace ci_lb2 = b2 - 1.96*se2
replace ci_ub2 = b2 + 1.96*se2

* Criar gráfico
twoway ///
    (rcap ci_ub1 ci_lb1 period, lcolor(navy)) ///
    (connected b1 period, lcolor(navy) mcolor(navy) msymbol(circle)) ///
    (rcap ci_ub2 ci_lb2 period, lcolor(navy*0.5)) ///
    (connected b2 period, lcolor(navy*0.5) mcolor(navy*0.5) msymbol(circle)), ///
    yline(0) xline(-1, lcolor(gs12) lpattern(dash)) ///
    xlabel(-7(1)12) ylabel(,format(%9.5f) angle(horizontal)) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficient") ///
    legend(order(2 "Current Population (Level)" 4 "2000 Population (Level)") ///
    rows(2) region(style(none))) ///
    graphregion(color(white)) bgcolor(white)
	
	
	
* Regressões para População Mediana
reghdfe taxa_homicidios_total_por_100m_1 F*event_pop_med L*event_pop_med treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_a
reghdfe taxa_homicidios_total_por_100m_1 F*event_pop2000_med L*event_pop2000_med treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_a

* Criar dataset base com períodos
clear
set obs 20  // -7 a 12
gen period = _n - 8  // Gera períodos de -7 a 12

* Extrair dados Current Population Mediana
estimates restore pop_median_curr_a
matrix b = e(b)
matrix V = e(V)

gen b1 = .
gen se1 = .
gen ci_lb1 = .
gen ci_ub1 = .

* Fill leads (F's) para current
forval i = 2/7 {
    local pos = 8 - `i'
    replace b1 = b[1,`pos'] if period == -`i'
    replace se1 = sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para current
forval i = 0/12 {
    local pos = `i' + 7
    replace b1 = b[1,`pos'] if period == `i'
    replace se1 = sqrt(V[`pos',`pos']) if period == `i'
}

* Extrair dados 2000 Population Mediana
estimates restore pop_median_2000_a
matrix b2 = e(b)
matrix V2 = e(V)

gen b2 = .
gen se2 = .
gen ci_lb2 = .
gen ci_ub2 = .

* Fill leads (F's) para 2000
forval i = 2/7 {
    local pos = 8 - `i'
    replace b2 = b2[1,`pos'] if period == -`i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para 2000
forval i = 0/12 {
    local pos = `i' + 7
    replace b2 = b2[1,`pos'] if period == `i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
replace ci_lb1 = b1 - 1.96*se1
replace ci_ub1 = b1 + 1.96*se1
replace ci_lb2 = b2 - 1.96*se2
replace ci_ub2 = b2 + 1.96*se2

* Criar gráfico
twoway ///
    (rcap ci_ub1 ci_lb1 period, lcolor(maroon)) ///
    (connected b1 period, lcolor(maroon) mcolor(maroon) msymbol(circle)) ///
    (rcap ci_ub2 ci_lb2 period, lcolor(maroon*0.5)) ///
    (connected b2 period, lcolor(maroon*0.5) mcolor(maroon*0.5) msymbol(circle)), ///
    yline(0) xline(-1, lcolor(gs12) lpattern(dash)) ///
    xlabel(-7(1)12) ylabel(#10, format(%3.0f)) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Effect on Homicide Rate") ///
    legend(order(2 "Current Population > Median" 4 "2000 Population > Median") ///
    rows(2) region(style(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(g2, replace)
	
	
	* Regressões para Log Population
reghdfe taxa_homicidios_total_por_100m_1 F*event_log_pop L*event_log_pop treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_a
reghdfe taxa_homicidios_total_por_100m_1 F*event_log_pop2000 L*event_log_pop2000 treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_a

* Criar dataset base com períodos
clear
set obs 20  // -7 a 12
gen period = _n - 8  // Gera períodos de -7 a 12

* Extrair dados Current Log Population
estimates restore pop_log_curr_a
matrix b = e(b)
matrix V = e(V)

gen b1 = .
gen se1 = .
gen ci_lb1 = .
gen ci_ub1 = .

* Fill leads (F's) para current
forval i = 2/7 {
    local pos = 8 - `i'
    replace b1 = b[1,`pos'] if period == -`i'
    replace se1 = sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para current
forval i = 0/12 {
    local pos = `i' + 7
    replace b1 = b[1,`pos'] if period == `i'
    replace se1 = sqrt(V[`pos',`pos']) if period == `i'
}

* Extrair dados 2000 Log Population
estimates restore pop_log_2000_a
matrix b2 = e(b)
matrix V2 = e(V)

gen b2 = .
gen se2 = .
gen ci_lb2 = .
gen ci_ub2 = .

* Fill leads (F's) para 2000
forval i = 2/7 {
    local pos = 8 - `i'
    replace b2 = b2[1,`pos'] if period == -`i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para 2000
forval i = 0/12 {
    local pos = `i' + 7
    replace b2 = b2[1,`pos'] if period == `i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
replace ci_lb1 = b1 - 1.96*se1
replace ci_ub1 = b1 + 1.96*se1
replace ci_lb2 = b2 - 1.96*se2
replace ci_ub2 = b2 + 1.96*se2

* Criar gráfico
twoway ///
    (rcap ci_ub1 ci_lb1 period, lcolor(forest_green)) ///
    (connected b1 period, lcolor(forest_green) mcolor(forest_green) msymbol(circle)) ///
    (rcap ci_ub2 ci_lb2 period, lcolor(forest_green*0.5)) ///
    (connected b2 period, lcolor(forest_green*0.5) mcolor(forest_green*0.5) msymbol(circle)), ///
    yline(0) xline(-1, lcolor(gs12) lpattern(dash)) ///
    xlabel(-7(1)12) ylabel(#10, format(%3.0f)) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Effect on Homicide Rate") ///
    legend(order(2 "Current Log Population" 4 "2000 Log Population") ///
    rows(2) region(style(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(g3, replace)

* Combinar os três gráficos
graph combine g1 g2 g3, ///
    rows(3) ///
    xsize(8) ysize(12) ///
    graphregion(color(white))

* Salvar gráfico combinado
graph export "event_study_population_combined.png", replace width(2000)




******************************
*** PANEL B - LOG HOMICIDE ***
******************************

* População em Nível
reghdfe log_tx_homicidio F*event_pop L*event_pop treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_curr_b
reghdfe log_tx_homicidio F*event_pop2000 L*event_pop2000 treated_population_2000 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_level_2000_b

* Criar dataset base com períodos
clear
set obs 20  // -7 a 12
gen period = _n - 8  // Gera períodos de -7 a 12

* Extrair dados Current Population
estimates restore pop_level_curr_b
matrix b = e(b)
matrix V = e(V)

gen b1 = .
gen se1 = .
gen ci_lb1 = .
gen ci_ub1 = .

* Fill leads (F's) para current
forval i = 2/7 {
    local pos = 8 - `i'
    replace b1 = b[1,`pos'] if period == -`i'
    replace se1 = sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para current
forval i = 0/12 {
    local pos = `i' + 7
    replace b1 = b[1,`pos'] if period == `i'
    replace se1 = sqrt(V[`pos',`pos']) if period == `i'
}

* Extrair dados 2000 Population
estimates restore pop_level_2000_b
matrix b2 = e(b)
matrix V2 = e(V)

gen b2 = .
gen se2 = .
gen ci_lb2 = .
gen ci_ub2 = .

* Fill leads (F's) para 2000
forval i = 2/7 {
    local pos = 8 - `i'
    replace b2 = b2[1,`pos'] if period == -`i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para 2000
forval i = 0/12 {
    local pos = `i' + 7
    replace b2 = b2[1,`pos'] if period == `i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
replace ci_lb1 = b1 - 1.96*se1
replace ci_ub1 = b1 + 1.96*se1
replace ci_lb2 = b2 - 1.96*se2
replace ci_ub2 = b2 + 1.96*se2

* Criar gráfico
twoway ///
    (rcap ci_ub1 ci_lb1 period, lcolor(navy)) ///
    (connected b1 period, lcolor(navy) mcolor(navy) msymbol(circle)) ///
    (rcap ci_ub2 ci_lb2 period, lcolor(navy*0.5)) ///
    (connected b2 period, lcolor(navy*0.5) mcolor(navy*0.5) msymbol(circle)), ///
    yline(0) xline(-1, lcolor(gs12) lpattern(dash)) ///
    xlabel(-7(1)12) ///
    ylabel(-.0000015(.0000005).0000005, angle(horizontal) format(%12.7f) grid) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficient") ///
    legend(order(2 "Current Population (Level)" 4 "2000 Population (Level)") ///
    rows(2) region(style(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(g1, replace)

* População Mediana
reghdfe log_tx_homicidio F*event_pop_med L*event_pop_med treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_curr_b
reghdfe log_tx_homicidio F*event_pop2000_med L*event_pop2000_med treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_median_2000_b

* Criar dataset base com períodos
clear
set obs 20  // -7 a 12
gen period = _n - 8  // Gera períodos de -7 a 12

* Extrair dados Current Population Mediana
estimates restore pop_median_curr_b
matrix b = e(b)
matrix V = e(V)

gen b1 = .
gen se1 = .
gen ci_lb1 = .
gen ci_ub1 = .

* Fill leads (F's) para current
forval i = 2/7 {
    local pos = 8 - `i'
    replace b1 = b[1,`pos'] if period == -`i'
    replace se1 = sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para current
forval i = 0/12 {
    local pos = `i' + 7
    replace b1 = b[1,`pos'] if period == `i'
    replace se1 = sqrt(V[`pos',`pos']) if period == `i'
}

* Extrair dados 2000 Population Mediana
estimates restore pop_median_2000_b
matrix b2 = e(b)
matrix V2 = e(V)

gen b2 = .
gen se2 = .
gen ci_lb2 = .
gen ci_ub2 = .

* Fill leads (F's) para 2000
forval i = 2/7 {
    local pos = 8 - `i'
    replace b2 = b2[1,`pos'] if period == -`i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para 2000
forval i = 0/12 {
    local pos = `i' + 7
    replace b2 = b2[1,`pos'] if period == `i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
replace ci_lb1 = b1 - 1.96*se1
replace ci_ub1 = b1 + 1.96*se1
replace ci_lb2 = b2 - 1.96*se2
replace ci_ub2 = b2 + 1.96*se2

* Criar gráfico
twoway ///
    (rcap ci_ub1 ci_lb1 period, lcolor(maroon)) ///
    (connected b1 period, lcolor(maroon) mcolor(maroon) msymbol(circle)) ///
    (rcap ci_ub2 ci_lb2 period, lcolor(maroon*0.5)) ///
    (connected b2 period, lcolor(maroon*0.5) mcolor(maroon*0.5) msymbol(circle)), ///
    yline(0) xline(-1, lcolor(gs12) lpattern(dash)) ///
    xlabel(-7(1)12) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficent") ///
    legend(order(2 "Current Population > Median" 4 "2000 Population > Median") ///
    rows(2) region(style(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(g2, replace)

* Log População
reghdfe log_tx_homicidio F*event_log_pop L*event_log_pop treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_curr_b
reghdfe log_tx_homicidio F*event_log_pop2000 L*event_log_pop2000 treated [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code municipality_code)
estimates store pop_log_2000_b

* Criar dataset base com períodos
clear
set obs 20  // -7 a 12
gen period = _n - 8  // Gera períodos de -7 a 12

* Extrair dados Current Log Population
estimates restore pop_log_curr_b
matrix b = e(b)
matrix V = e(V)

gen b1 = .
gen se1 = .
gen ci_lb1 = .
gen ci_ub1 = .

* Fill leads (F's) para current
forval i = 2/7 {
    local pos = 8 - `i'
    replace b1 = b[1,`pos'] if period == -`i'
    replace se1 = sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para current
forval i = 0/12 {
    local pos = `i' + 7
    replace b1 = b[1,`pos'] if period == `i'
    replace se1 = sqrt(V[`pos',`pos']) if period == `i'
}

* Extrair dados 2000 Log Population
estimates restore pop_log_2000_b
matrix b2 = e(b)
matrix V2 = e(V)

gen b2 = .
gen se2 = .
gen ci_lb2 = .
gen ci_ub2 = .

* Fill leads (F's) para 2000
forval i = 2/7 {
    local pos = 8 - `i'
    replace b2 = b2[1,`pos'] if period == -`i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == -`i'
}

* Fill lags (L's) para 2000
forval i = 0/12 {
    local pos = `i' + 7
    replace b2 = b2[1,`pos'] if period == `i'
    replace se2 = sqrt(V2[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
replace ci_lb1 = b1 - 1.96*se1
replace ci_ub1 = b1 + 1.96*se1
replace ci_lb2 = b2 - 1.96*se2
replace ci_ub2 = b2 + 1.96*se2

* Criar gráfico
twoway ///
    (rcap ci_ub1 ci_lb1 period, lcolor(forest_green)) ///
    (connected b1 period, lcolor(forest_green) mcolor(forest_green) msymbol(circle)) ///
    (rcap ci_ub2 ci_lb2 period, lcolor(forest_green*0.5)) ///
    (connected b2 period, lcolor(forest_green*0.5) mcolor(forest_green*0.5) msymbol(circle)), ///
    yline(0) xline(-1, lcolor(gs12) lpattern(dash)) ///
    xlabel(-7(1)12) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficent") ///
    legend(order(2 "Current Log Population" 4 "2000 Log Population") ///
    rows(2) region(style(none))) ///
    graphregion(color(white)) bgcolor(white) ///
    name(g3, replace)

* Combinar os três gráficos
graph combine g1 g2 g3, ///
    rows(3) ///
    xsize(8) ysize(12) ///
    graphregion(color(white))

* Salvar gráfico combinado
graph export "event_study_log_population_combined.png", replace width(2000)
