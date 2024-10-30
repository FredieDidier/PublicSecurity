
* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
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

gen log_formal_emp = log(total_vinculos_munic + 1)
gen log_formal_est = log(total_estabelecimentos_munic)

* 1. Manual TWFE
reg taxa_homicidios_total_por_100m_1 treated i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

outreg2 using "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/twfe_results.tex", tex replace ctitle("Homicide Rate - TWFE") keep(treated) addtext(Municipality FE, Yes, Year FE, Yes) nocons

* 2. Pooled DID
* Generate treatment variables for each state
gen pe_treat = (state == "PE")
gen pe_post = (year >= 2007)
gen pe_did = pe_treat * pe_post

gen ba_pb_post = (year >= 2011)
gen ba_pb_treat = (state == "BA" | state == "PB")
gen ba_pb_did = ba_pb_treat * ba_pb_post

gen ce_treat = (state == "CE")
gen ce_post = (year >= 2015)
gen ce_did = ce_treat * ce_post

gen ma_treat = (state == "MA")
gen ma_post = (year >= 2016)
gen ma_did = ma_treat * ma_post

* Pooled DiD with outreg output
eststo: reg taxa_homicidios_total_por_100m_1 pe_post ba_pb_post ce_post ma_post pe_did ba_pb_did ce_did ma_did pe_treat ba_pb_treat ce_treat ma_treat i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

test pe_did ba_pb_did ce_did ma_did
scalar f_stat = r(F)
scalar p_value = r(p)

outreg2 using "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/pooled_did.tex", tex replace ctitle("Homicide Rate - Pooled DID") keep(pe_did ba_pb_did ce_did ma_did) nocons addtext(Municipality FE, Yes, Year FE, Yes) addstat("F-statistic", f_stat, "p-value", p_value)

* 3. Event study

* Create dummies for each relative time period
* Using -7/+12 window given your time span (2000-2019) and first treatment (2007)

forvalues l = 0/12 {
	gen L`l'event = rel_year==`l'
}
forvalues l = 1/7 {
	gen F`l'event = rel_year==-`l'
}
drop F1event

* Regressão com efeitos fixos usando reghdfe
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event [aw = population_2000_muni], a(municipality_code year) cluster(state_code)

* Store coefficients and CIs
matrix b = e(b)
matrix V = e(V)

* Generate plotting data
clear
set obs 21  // Total periods: 7 leads + 1 reference + 13 lags
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

* Reference period (-1) remains at 0
replace coef = 0 if period == -1
replace ci_low = 0 if period == -1
replace ci_high = 0 if period == -1

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
       xline(0, lpattern(dash) lcolor(red)) /// Linha vertical no período do tratamento
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
	graph export "/Users/Fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_event_study_homicide_rate.pdf", as(pdf) replace
	
*************
**************
	
* Regressão com efeitos fixos e controles usando reghdfe
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event pop_density_municipality log_formal_emp log_formal_est log_pib_municipal_per_capita [aw = population_2000_muni], a(municipality_code year) cluster(state_code)

* Store coefficients and CIs
matrix b = e(b)
matrix V = e(V)

* Generate plotting data
clear
set obs 21  // Total periods: 7 leads + 1 reference + 13 lags
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

* Reference period (-1) remains at 0
replace coef = 0 if period == -1
replace ci_low = 0 if period == -1
replace ci_high = 0 if period == -1

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
       xline(0, lpattern(dash) lcolor(red)) /// Linha vertical no período do tratamento
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

  