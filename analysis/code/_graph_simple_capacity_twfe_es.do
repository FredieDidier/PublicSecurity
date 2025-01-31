
********************************************************************************
* 1. Preparação inicial dos dados
********************************************************************************
* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

* Criar variáveis base
gen treat_year = 0
replace treat_year = 2011 if state == "BA" | state == "PB"
replace treat_year = 2015 if state == "CE"
replace treat_year = 2016 if state == "MA"
replace treat_year = 2007 if state == "PE"

gen rel_year = year - treat_year
gen log_population = log(population_muni)

* 2.3 Log dos funcionários por 1000 habitantes
preserve
keep if year == 2006
gen func_per_1000 = (total_func_pub_munic/population_muni)*1000
gen log_func_pc = log(func_per_1000) if func_per_1000 > 0
keep municipality_code log_func_pc
save "temp_log_func_pc.dta", replace
restore
merge m:1 municipality_code using "temp_log_func_pc.dta", nogenerate
erase "temp_log_func_pc.dta"

* 2.4 Dummy baseada no log per capita
preserve
keep if year == 2006
gen func_per_1000 = (total_func_pub_munic/population_muni)*1000
gen log_func_temp = log(func_per_1000) if func_per_1000 > 0
sum log_func_temp, detail
gen high_cap_pc = (log_func_temp > r(p50)) if !missing(log_func_temp)
keep municipality_code high_cap_pc
save "temp_high_cap_pc.dta", replace
restore
merge m:1 municipality_code using "temp_high_cap_pc.dta", nogenerate
erase "temp_high_cap_pc.dta"

********************************************************************************
* 3. Gerar dummies de event time e interações
********************************************************************************
* Primeiro, criar todas as dummies de event time
forvalues l = 0/12 {
    gen L`l'event = rel_year==`l'
}
forvalues l = 1/7 {
    gen F`l'event = rel_year==-`l'
}

* Segundo, criar todas as interações para cada medida de capacidade
foreach var in log_func_pc high_cap_pc {
    forvalues l = 1/7 {
        gen F`l'event_`var' = F`l'event * `var'
    }
    forvalues l = 0/12 {
        gen L`l'event_`var' = L`l'event * `var'
    }
}

* Por último, dropar as variáveis de normalização
drop F1event
foreach var in log_func_pc high_cap_pc {
    drop F1event_`var'
}


********************************************************************************
* 4. Rodar regressões e criar gráficos
********************************************************************************
* Criar programa para processar resultados e gerar gráficos
capture program drop process_results
program define process_results
    preserve
    clear
    set obs 20
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    gen coef = .
    gen se = .
    
    * Ajuste para pegar apenas os coeficientes das interações
    forval i = 2/7 {
        local pos = `i' + 18  // Posição ajustada para pegar apenas interações
        replace coef = b[1,`pos'] if period == -`i'
        replace se = sqrt(V[`pos',`pos']) if period == -`i'
    }
    forval i = 0/12 {
        local pos = `i' + 26  // Posição ajustada para pegar apenas interações
        replace coef = b[1,`pos'] if period == `i'
        replace se = sqrt(V[`pos',`pos']) if period == `i'
    }
    
    gen ci_lb = coef - 1.96*se
    gen ci_ub = coef + 1.96*se
    
    twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
        (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
        (connect coef period, lcolor(navy) lpattern(dash)), ///
        xline(-1, lpattern(dash) lcolor(red)) ///
        yline(0, lcolor(black)) ///
        xlabel(-7(1)12, angle(45) labsize(small)) ///
        ylabel(, grid) ///
        xtitle("Years Relative to Treatment") ///
        ytitle("Coefficient of Interaction") ///
        graphregion(color(white)) ///
        bgcolor(white) ///
        legend(off) ///
        title(`2', size(medium)) ///
        name(`1', replace)
    restore
end

* Rodar regressões e gerar gráficos para cada medida

* 3. Log per capita
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_log_func_pc L*event_log_func_pc log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
process_results event_log_pc ""

* 4. Dummy log per capita
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_high_cap_pc L*event_high_cap_pc log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
process_results event_high_pc ""

********************************************************************************
* 5. Combinar e salvar gráficos
********************************************************************************
graph combine event_log_pc event_high_pc, ///
    rows(2) xsize(11) ysize(10) ///
    graphregion(color(white) margin(zero)) ///
    name(combined_event, replace)

graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_capacity_event_study.pdf", replace

***********************

* Modificar o programa process_results para processar coeficientes treated
capture program drop process_results_treated
program define process_results_treated
    preserve
    clear
    set obs 20
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    gen coef = .
    gen se = .
    
    * Pegar coeficientes dos eventos (não das interações)
    forval i = 2/7 {
        local pos = `i' - 1  // Posição para eventos treated
        replace coef = b[1,`pos'] if period == -`i'
        replace se = sqrt(V[`pos',`pos']) if period == -`i'
    }
    forval i = 0/12 {
        local pos = `i' + 7  // Posição para eventos treated
        replace coef = b[1,`pos'] if period == `i'
        replace se = sqrt(V[`pos',`pos']) if period == `i'
    }
    
    gen ci_lb = coef - 1.96*se
    gen ci_ub = coef + 1.96*se
    
    twoway (rcap ci_ub ci_lb period, lcolor(navy)) ///
        (scatter coef period, mcolor(navy) msymbol(circle) msize(medium)) ///
        (connect coef period, lcolor(navy) lpattern(dash)), ///
        xline(-1, lpattern(dash) lcolor(red)) ///
        yline(0, lcolor(black)) ///
        xlabel(-7(1)12, angle(45) labsize(small)) ///
        ylabel(, grid) ///
        xtitle("Years Relative to Treatment") ///
        ytitle("Coefficient") ///
        graphregion(color(white)) ///
        bgcolor(white) ///
        legend(off) ///
        title(`2', size(medium)) ///
        name(`1', replace)
    restore
end

* Rodar regressões e gerar gráficos para treated

* 3. Log per capita
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_log_func_pc L*event_log_func_pc log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
process_results_treated treated_log_pc ""

* 4. Dummy log per capita
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_high_cap_pc L*event_high_cap_pc log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
process_results_treated treated_high_pc ""

* Combinar gráficos treated
graph combine treated_log_pc treated_high_pc, ///
    rows(2) xsize(11) ysize(10) ///
    graphregion(color(white) margin(zero)) ///
    name(combined_event_treated, replace)

* Exportar gráfico treated
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_treated_no_int_event_study.pdf", replace
