
* Load data
use "/Users/fredie/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000 

* Create treatment variables
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007
replace treated = 1 if state == "BA" & year >= 2011
replace treated = 1 if state == "PB" & year >= 2011
replace treated = 1 if state == "CE" & year >= 2015
replace treated = 1 if state == "MA" & year >= 2016

* Criar a variável de ano de adoção (staggered treatment)
gen treatment_year = 0
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"
replace treatment_year = 2007 if state == "PE"

* Criar a variável de tempo relativo ao tratamento
gen rel_year = year - treatment_year

* 1. Pooled DID
* Generate treatment variables for each state
gen pe_treat = (state == "PE")
gen pe_post = (year >= 2007)
gen pe_did = pe_treat * pe_post

gen ba_pb_treat = (state == "BA" | state == "PB")
gen ba_pb_post = (year >= 2011)
gen ba_pb_did = ba_pb_treat * ba_pb_post

gen ce_treat = (state == "CE")
gen ce_post = (year >= 2015)
gen ce_did = ce_treat * ce_post

gen ma_treat = (state == "MA")
gen ma_post = (year >= 2016)
gen ma_did = ma_treat * ma_post

* Primeira regressão
eststo: reg taxa_homicidios_total_por_100m_1 pe_post ba_pb_post ce_post ma_post pe_did ba_pb_did ce_did ma_did pe_treat ba_pb_treat ce_treat ma_treat i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* F-test e p-value convencional para teste conjunto
test pe_did ba_pb_did ce_did ma_did
scalar f_stat = r(F)
scalar p_value = r(p)

* Wild bootstrap p-value para cada coeficiente
boottest pe_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_pe = r(p)

boottest ba_pb_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_bapb = r(p)

boottest ce_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_ce = r(p)

boottest ma_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_ma = r(p)

outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_pooled_did.tex", tex replace ///
    ctitle("Homicide Rate" \ "Pooled DID") keep(pe_did ba_pb_did ce_did ma_did) nocons ///
    addtext(Municipality FE, Yes, Year FE, Yes, Controls, No) ///
    addstat("F-statistic", f_stat, "Joint p-value", p_value, ///
            "Wild Bootstrap p-value PE", wild_p_pe, ///
            "Wild Bootstrap p-value BA-PB", wild_p_bapb, ///
            "Wild Bootstrap p-value CE", wild_p_ce, ///
            "Wild Bootstrap p-value MA", wild_p_ma)

* Segunda regressão
gen log_population = log(population_muni)
eststo: reg taxa_homicidios_total_por_100m_1 pe_post ba_pb_post ce_post ma_post pe_did ba_pb_did ce_did ma_did pe_treat ba_pb_treat ce_treat ma_treat i.municipality_code i.year log_population [weight=population_2000_muni], cluster(state_code)

* F-test e p-value convencional para teste conjunto
test pe_did ba_pb_did ce_did ma_did
scalar f_stat = r(F)
scalar p_value = r(p)

* Wild bootstrap p-value para cada coeficiente
boottest pe_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_pe = r(p)

boottest ba_pb_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_bapb = r(p)

boottest ce_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_ce = r(p)

boottest ma_did, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
scalar wild_p_ma = r(p)

outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_pooled_did.tex", tex append ///
    ctitle("Homicide Rate" \ "Pooled DID with Controls") keep(pe_did ba_pb_did ce_did ma_did) nocons ///
    addtext(Municipality FE, Yes, Year FE, Yes, Controls, Yes) ///
    addstat("F-statistic", f_stat, "Joint p-value", p_value, ///
            "Wild Bootstrap p-value PE", wild_p_pe, ///
            "Wild Bootstrap p-value BA-PB", wild_p_bapb, ///
            "Wild Bootstrap p-value CE", wild_p_ce, ///
            "Wild Bootstrap p-value MA", wild_p_ma)
			
* 1.1 Group-Specific Event Study 

* Define treatment groups and years
local treatments "pe bapb ce ma"
local treatment_years "2007 2011 2015 2016"

* Loop through each treatment group
local graph_list ""
local i = 1

foreach treat of local treatments {
    local treat_year: word `i' of `treatment_years'
    
    * Define sample conditions and intervals for each group
    if "`treat'" == "pe" {
        local condition "(inlist(state_code, 26)) | (inlist(state_code, 29, 25) & year <= 2011) | (inlist(state_code, 23) & year <= 2015) | (inlist(state_code, 21) & year <= 2016)"
        local states "26"
        local title "Pernambuco (Group 2007) vs Not Yet Treated"
        local lags "7"
        local leads "12"
    }
    else if "`treat'" == "bapb" {
        local condition "(inlist(state_code, 29, 25)) | (inlist(state_code, 23) & year <= 2015) | (inlist(state_code, 21) & year <= 2016)"
        local states "29 25"
        local title "Bahia and Paraíba (Group 2011) vs Not Yet Treated"
        local lags "11"
        local leads "8"
    }
    else if "`treat'" == "ce" {
        local condition "(inlist(state_code, 23)) | (inlist(state_code, 21) & year <= 2016)"
        local states "23"
        local title "Ceará (Group 2015) vs Not Yet Treated"
        local lags "15"
        local leads "4"
    }
    else {
        local condition "inlist(state_code, 21)"
        local states "21"
        local title "Maranhão (Group 2016)"
        local lags "16"
        local leads "3"
    }
    
    * Generate relative time variable
    gen relative_year_`treat' = .
    foreach state of local states {
        replace relative_year_`treat' = year - `treat_year' if state_code == `state'
    }
    
    * Create event time dummies
    forvalues l = 0/`leads' {
        gen L`l'event_`treat' = relative_year_`treat'==`l'
    }
    forvalues l = 1/`lags' {
        gen F`l'event_`treat' = relative_year_`treat'==-`l'
    }
    drop F1event_`treat'
    
    * Run regression
    reghdfe taxa_homicidios_total_por_100m_1 F*event_`treat' L*event_`treat' log_population ///
        if `condition' [aw = population_2000_muni], ///
        absorb(municipality_code year) cluster(state_code)
    
    * Store coefficients and CIs
    matrix b = e(b)
    matrix V = e(V)
    
    * Generate plotting data
    preserve
    clear
    set obs `=`leads'+`lags'+1'
    gen period = _n - `lags' - 1
    
    gen coef = .
    gen ci_low = .
    gen ci_high = .
    
    forval j = 2/`lags' {
        local pos = `lags' - `j' + 1
        replace coef = b[1,`pos'] if period == -`j'
        replace ci_low = b[1,`pos'] - 1.96*sqrt(V[`pos',`pos']) if period == -`j'
        replace ci_high = b[1,`pos'] + 1.96*sqrt(V[`pos',`pos']) if period == -`j'
    }
    
    forval j = 0/`leads' {
        local pos = `j' + `lags'
        replace coef = b[1,`pos'] if period == `j'
        replace ci_low = b[1,`pos'] - 1.96*sqrt(V[`pos',`pos']) if period == `j'
        replace ci_high = b[1,`pos'] + 1.96*sqrt(V[`pos',`pos']) if period == `j'
    }
    
    * Create event study plot
    twoway (rcap ci_high ci_low period, lcolor(navy)) ///
           (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
           (connect coef period, lcolor(navy) lpattern(dash) lstyle(line)), ///
           xline(-1, lpattern(dash) lcolor(red)) ///
           yline(0, lcolor(black) lpattern(solid)) ///
           xlabel(-`lags'(2)`leads', grid) ///
           ylabel(, grid) ///
           xtitle("Years Relative to Treatment") ///
           ytitle("Coefficient") ///
           title("`title'", size(medium)) ///
           graphregion(color(white)) ///
           bgcolor(white) ///
           legend(off) ///
           name(graph_`treat', replace) ///
           scheme(s2color)
    
    restore
    
    local graph_list "`graph_list' graph_`treat'"
    
    drop relative_year_`treat' F*event_`treat' L*event_`treat'
    
    local ++i
}

* Combine all graphs
graph combine graph_pe graph_bapb graph_ce graph_ma, ///
    rows(2) cols(2)
    
* Export combined graph
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/group_specific_event_studies.pdf", replace

* Clean up
foreach treat of local treatments {
    graph drop graph_`treat'
}

* 2. Event study

* Create dummies for each relative time period
* Using -7/+12 window given your time span (2000-2019) and first treatment (2007)

forvalues l = 0/12 {
    gen L`l'event = rel_year==`l'
}
forvalues l = 1/7 {
    gen F`l'event = rel_year==-`l'
}
drop F1event // normalize rel_year = -1 to zero

* Regressão com efeitos fixos usando reghdfe
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event [aw = population_2000_muni], a(municipality_code year) cluster(state_code)

* Store coefficients and CIs
matrix b = e(b)
matrix V = e(V)

* Generate plotting data
clear
set obs 20  // Total periods: 7 leads + 1 reference + 12 lags
gen period = _n - 8  // Centers at 0, ranging from -7 to 12

* Initialize variables
gen coef = .
gen ci_low = .
gen ci_high = .

* Fill leads (F's)
forval i = 2/7 {
    local pos = 8 - `i'
    replace coef = b[1,`pos'] if period == -`i'
    replace ci_low = b[1,`pos'] - 1.96*sqrt(V[`pos',`pos']) if period == -`i'
    replace ci_high = b[1,`pos'] + 1.96*sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's)
forval i = 0/12 {
    local pos = `i' + 7
    replace coef = b[1,`pos'] if period == `i'
    replace ci_low = b[1,`pos'] - 1.96*sqrt(V[`pos',`pos']) if period == `i'
    replace ci_high = b[1,`pos'] + 1.96*sqrt(V[`pos',`pos']) if period == `i'
}


* Create event study plot
twoway (rcap ci_high ci_low period, lcolor(navy)) /// Intervalos de confiança como linhas
       (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) /// Pontos dos coeficientes
       (connect coef period, lcolor(navy) lpattern(dash) lstyle(line)), /// Linha conectando pontos
       xline(-1, lpattern(dash) lcolor(red)) /// Linha vertical no período do tratamento
       yline(0, lcolor(black) lpattern(solid)) /// Linha horizontal no zero
       xlabel(-7(1)12, grid) /// Grid nas marcações do eixo x
       ylabel(, grid) /// Grid nas marcações do eixo y
       xtitle("Years Relative to Treatment") ///
       ytitle("Coefficient") ///
       title("Event Study: Homicide Rate", size(medium)) ///
       graphregion(color(white)) /// Fundo branco
       bgcolor(white) /// Área do gráfico branca
       legend(off) /// Sem legenda
       scheme(s2color)  

* Export the graph
graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_event_study_homicide_rate.pdf", as(pdf) replace
	
*************
**************
	
* Regressão com efeitos fixos e controles usando reghdfe
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event log_pop_density_municipality log_formal_emp log_pib_municipal_per_capita [aw = population_2000_muni], a(municipality_code year) cluster(state_code)

* Store coefficients and CIs
matrix b = e(b)
matrix V = e(V)

* Generate plotting data
clear
set obs 20  // Total periods: 7 leads + 1 reference + 13 lags
gen period = _n - 8  // Centers at 0, ranging from -7 to 12

* Initialize variables
gen coef = .
gen ci_low = .
gen ci_high = .

* Fill leads (F's)
forval i = 2/7 {
    local pos = 8 - `i'
    replace coef = b[1,`pos'] if period == -`i'
    replace ci_low = b[1,`pos'] - 1.96*sqrt(V[`pos',`pos']) if period == -`i'
    replace ci_high = b[1,`pos'] + 1.96*sqrt(V[`pos',`pos']) if period == -`i'
}

* Fill lags (L's)
forval i = 0/12 {
    local pos = `i' + 7
    replace coef = b[1,`pos'] if period == `i'
    replace ci_low = b[1,`pos'] - 1.96*sqrt(V[`pos',`pos']) if period == `i'
    replace ci_high = b[1,`pos'] + 1.96*sqrt(V[`pos',`pos']) if period == `i'
}


* Create event study plot
twoway (rcap ci_high ci_low period, lcolor(navy)) /// Intervalos de confiança como linhas
       (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) /// Pontos dos coeficientes
       (connect coef period, lcolor(navy) lpattern(dash) lstyle(line)), /// Linha conectando pontos
       xline(-1, lpattern(dash) lcolor(red)) /// Linha vertical no período do tratamento
       yline(0, lcolor(black) lpattern(solid)) /// Linha horizontal no zero
       xlabel(-7(1)12, grid) /// Grid nas marcações do eixo x
       ylabel(, grid) /// Grid nas marcações do eixo y
       xtitle("Years Relative to Treatment") ///
       ytitle("Coefficient") ///
       title("Event Study: Homicide Rate", size(medium)) ///
       graphregion(color(white)) /// Fundo branco
       bgcolor(white) /// Área do gráfico branca
       legend(off) /// Sem legenda
       scheme(s2color)  
	graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_event_study_controls_homicide_rate.pdf", as(pdf) replace

  