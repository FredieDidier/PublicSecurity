use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

* Limpeza inicial
drop if municipality_code == 2300000 | municipality_code == 2600000

* Definir anos de tratamento para diferentes estados
gen treatment_year = 0
replace treatment_year = 2007 if inlist(state, "AL", "PI", "RN", "SE")
replace treatment_year = 2011 if inlist(state, "BA", "PB")
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"

* Excluir PE, que é o estado focal para análise de spillover
drop if state == "PE"

* Gerar variáveis para a análise
gen t2007 = (treatment_year == 2007)
gen trend = year - 2000 // Tendência linear começando em 2000
gen partrend2007 = trend * t2007

* Criar variáveis para limitar a amostra por período de tratamento
gen sample_state = 1
replace sample_state = 0 if inlist(state, "BA", "PB") & year > 2010
replace sample_state = 0 if state == "CE" & year > 2014
replace sample_state = 0 if state == "MA" & year > 2015

* Variáveis necessárias
gen log_pop = log(population_muni)
gen spillover50 = (dist_PE < 50)

* Configurar painel
xtset municipality_code year

* Gerar variáveis de event study para spillover50
* Definir 2007 como ano de início do spillover para municípios próximos a PE
gen spill_year = .
replace spill_year = 2007 if spillover50 == 1

* Gerar relative time
gen rel_year = year - spill_year

* Gerar dummies de event time (agora inclui L0event)
forvalues l = 0/12 {
    gen L`l'event = rel_year==`l'
}
forvalues l = 1/7 {
    gen F`l'event = rel_year==-`l'
}

drop L0event

* Aplicar a restrição de amostra para incluir estados apenas até seus anos de tratamento
keep if sample_state == 1

* Rodar regressão event study sem controles (usando drop(L0event) para omitir período 0)
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
estimates store est_no_controls

* Processar resultados sem controles
preserve
clear
set obs 20
gen period = _n - 8
matrix b = e(b)
matrix V = e(V)
gen coef = .
gen se = .

* Preencher coeficientes e erros padrão (ajustado para o período de referência ser 0)
forval i = 1/7 {
    local pos = `i'
    replace coef = b[1,`pos'] if period == -`i'
    replace se = sqrt(V[`pos',`pos']) if period == -`i'
}
forval i = 1/12 {
    * Pular L0event (que foi omitido) e ajustar os índices
    if `i' == 1 {
        local pos = 8 
    }
    else {
        local pos = `i' + 7  
    }
    replace coef = b[1,`pos'] if period == `i'
    replace se = sqrt(V[`pos',`pos']) if period == `i'
}
* Definir coeficiente e erro padrão para o período de referência (0) como zero
replace coef = 0 if period == 0
replace se = 0 if period == 0

* Gerar intervalos de confiança
gen ci_lb = coef - 1.96*se
gen ci_ub = coef + 1.96*se

* Criar e salvar gráfico sem controles
twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
    (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
    (connect coef period, lcolor(navy) lpattern(dash)), ///
    xline(0, lpattern(dash) lcolor(red)) ///
    yline(0, lcolor(black)) ///
    xlabel(-7(1)12, grid) ///
    ylabel(, grid) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficient") ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    legend(off) ///
    name(event_no_controls, replace)

graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/PE_spillover_event_study_no_controls.pdf", replace
restore

* Rodar regressão event study com controles (usando drop(L0event) para omitir período 0)
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event log_pop partrend2007 [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
estimates store est_with_controls

* Processar resultados com controles
preserve
clear
set obs 20
gen period = _n - 8
matrix b = e(b)
matrix V = e(V)
gen coef = .
gen se = .

* Preencher coeficientes e erros padrão (ajustado para o período de referência ser 0)
forval i = 1/7 {
    local pos = `i'
    replace coef = b[1,`pos'] if period == -`i'
    replace se = sqrt(V[`pos',`pos']) if period == -`i'
}
forval i = 1/12 {
    * Pular L0event (que foi omitido) e ajustar os índices
    if `i' == 1 {
        local pos = 8  
    }
    else {
        local pos = `i' + 7 
    }
    replace coef = b[1,`pos'] if period == `i'
    replace se = sqrt(V[`pos',`pos']) if period == `i'
}
* Definir coeficiente e erro padrão para o período de referência (0) como zero
replace coef = 0 if period == 0
replace se = 0 if period == 0

* Gerar intervalos de confiança
gen ci_lb = coef - 1.96*se
gen ci_ub = coef + 1.96*se

* Criar e salvar gráfico com controles
twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
    (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
    (connect coef period, lcolor(navy) lpattern(dash)), ///
    xline(0, lpattern(dash) lcolor(red)) ///
    yline(0, lcolor(black)) ///
    xlabel(-7(1)12, grid) ///
    ylabel(, grid) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficient") ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    legend(off) ///
    name(event_with_controls, replace)
    
* Salvar segundo gráfico
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/PE_spillover_event_study_with_controls.pdf", replace
restore
