* Limpeza inicial
drop if municipality_code == 2300000 | municipality_code == 2600000

drop if inlist(state, "PE", "BA", "PB", "CE", "MA")

* Criar variável de primeiro ano de spillover
gen spill_year = .
replace spill_year = 2007 if dist_PE < 50
replace spill_year = 2011 if spill_year==. & (min(dist_PE, dist_BA, dist_PB) < 50)
replace spill_year = 2015 if spill_year==. & (min(dist_PE, dist_BA, dist_PB, dist_CE) < 50)
replace spill_year = 2016 if spill_year==. & (min(dist_PE, dist_BA, dist_PB, dist_CE, dist_MA) < 50)

* Gerar relative time
gen rel_year = year - spill_year


forvalues l = 0/12 {
    gen L`l'event = rel_year==`l'
}
forvalues l = 1/7 {
    gen F`l'event = rel_year==-`l'
}
drop F1event // normalize rel_year = -1 to zero

* Rodar regressões event study sem controles
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
estimates store est_no_controls

mat list e(b)

* Processar resultados sem controles
preserve
clear
set obs 20
gen period = _n - 8

matrix b = e(b)
matrix V = e(V)

gen coef = .
gen se = .

* Preencher coeficientes e erros padrão
forval i = 2/7 {
    local pos = `i' - 1
    replace coef = b[1,`pos'] if period == -`i'
    replace se = sqrt(V[`pos',`pos']) if period == -`i'
}
forval i = 0/12 {
    local pos = `i' + 7
    replace coef = b[1,`pos'] if period == `i'
    replace se = sqrt(V[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
gen ci_lb = coef - 1.96*se
gen ci_ub = coef + 1.96*se

* Criar e salvar gráfico sem controles
twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
    (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
    (connect coef period, lcolor(navy) lpattern(dash)), ///
    xline(-1, lpattern(dash) lcolor(red)) ///
    yline(0, lcolor(black)) ///
    xlabel(-7(1)12, grid) ///
    ylabel(, grid) ///
    xtitle("Years Relative to Treatment") ///
    ytitle("Coefficient") ///
    graphregion(color(white)) ///
    bgcolor(white) ///
    legend(off) ///
    name(event_no_controls, replace)
	
* Salvar primeiro gráfico
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/spillover_event_study_no_controls.pdf", replace

restore
gen log_pop = log(population_muni)

* Rodar regressões event study com controles
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event log_pop [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
estimates store est_with_controls

mat list e(b)

* Processar resultados com controles
preserve
clear
set obs 20
gen period = _n - 8

matrix b = e(b)
matrix V = e(V)

gen coef = .
gen se = .

* Preencher coeficientes e erros padrão
forval i = 2/7 {
    local pos = `i' - 1
    replace coef = b[1,`pos'] if period == -`i'
    replace se = sqrt(V[`pos',`pos']) if period == -`i'
}
forval i = 0/12 {
    local pos = `i' + 7
    replace coef = b[1,`pos'] if period == `i'
    replace se = sqrt(V[`pos',`pos']) if period == `i'
}

* Gerar intervalos de confiança
gen ci_lb = coef - 1.96*se
gen ci_ub = coef + 1.96*se

* Criar e salvar gráfico com controles
twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
    (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
    (connect coef period, lcolor(navy) lpattern(dash)), ///
    xline(-1, lpattern(dash) lcolor(red)) ///
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
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/spillover_event_study_with_controls.pdf", replace

restore
