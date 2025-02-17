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
* Criar programa para processar resultados e gerar gráficos que mostre treated e interação
capture program drop process_results_combined
program define process_results_combined
    preserve
    clear
    set obs 20
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    
    * Para treated
    gen coef_treated = .
    gen se_treated = .
    
    * Para interação
    gen coef_int = .
    gen se_int = .
    
    * Pegar coeficientes treated
    forval i = 2/7 {
        local pos = `i' - 1  // Posição para eventos treated
        replace coef_treated = b[1,`pos'] if period == -`i'
        replace se_treated = sqrt(V[`pos',`pos']) if period == -`i'
    }
    forval i = 0/12 {
        local pos = `i' + 7  // Posição para eventos treated
        replace coef_treated = b[1,`pos'] if period == `i'
        replace se_treated = sqrt(V[`pos',`pos']) if period == `i'
    }
    
    * Pegar coeficientes das interações
    forval i = 2/7 {
        local pos = `i' + 18  // Posição ajustada para interações
        replace coef_int = b[1,`pos'] if period == -`i'
        replace se_int = sqrt(V[`pos',`pos']) if period == -`i'
    }
    forval i = 0/12 {
        local pos = `i' + 26  // Posição ajustada para interações
        replace coef_int = b[1,`pos'] if period == `i'
        replace se_int = sqrt(V[`pos',`pos']) if period == `i'
    }
    
    * Gerar intervalos de confiança
    gen ci_lb_treated = coef_treated - 1.96*se_treated
    gen ci_ub_treated = coef_treated + 1.96*se_treated
    
    gen ci_lb_int = coef_int - 1.96*se_int
    gen ci_ub_int = coef_int + 1.96*se_int
    
    * Criar o gráfico combinado
    twoway (rcap ci_ub_treated ci_lb_treated period, lcolor(navy)) ///
        (scatter coef_treated period, mcolor(navy) msymbol(circle) msize(medium)) ///
        (connect coef_treated period, lcolor(navy) lpattern(dash)) ///
        (rcap ci_ub_int ci_lb_int period, lcolor(maroon)) ///
        (scatter coef_int period, mcolor(maroon) msymbol(circle) msize(medium)) ///
        (connect coef_int period, lcolor(maroon) lpattern(dash)), ///
        xline(-1, lpattern(dash) lcolor(red)) ///
        yline(0, lcolor(black)) ///
        xlabel(-7(1)12, angle(45) labsize(small)) ///
        ylabel(, grid) ///
        xtitle("Years Relative to Treatment") ///
        ytitle("Coefficient") ///
        graphregion(color(white)) ///
        bgcolor(white) ///
        legend(order(2 5) label(2 "Low Capacity") label(5 "High Capacity") position(6)) ///
        title(`2', size(medium)) ///
        name(`1', replace)
    restore
end

* Rodar regressões e gerar gráficos para cada medida
* Log per capita
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_log_func_pc L*event_log_func_pc log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
process_results_combined event_log_pc ""

* Exportar gráfico log per capita
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_capacity_event_study.png", replace

* Dummy log per capita
reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_high_cap_pc L*event_high_cap_pc log_population [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
process_results_combined event_high_pc ""

* Exportar gráfico dummy
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_capacity_event_study_2.png", replace
