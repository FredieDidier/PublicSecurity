* Limpeza inicial
drop if municipality_code == 2300000 | municipality_code == 2600000

* Drop estados tratados
drop if inlist(state, "PE", "BA", "PB", "CE", "MA")

* Keep only observations within distance threshold
gen min_dist = min(dist_PE, dist_BA, dist_PB, dist_CE, dist_MA)
keep if min_dist < 50

********************************************************************************
* 2. Criar medidas de capacidade
********************************************************************************
* 2.1 Log do número absoluto de funcionários
preserve
keep if year == 2006
gen log_func_abs = log(total_func_pub_munic) if total_func_pub_munic > 0
keep municipality_code log_func_abs
tempfile temp_log_func_abs
save `temp_log_func_abs'
restore
merge m:1 municipality_code using `temp_log_func_abs', nogenerate

* 2.2 Dummy baseada no log absoluto
preserve
keep if year == 2006
gen log_func_temp = log(total_func_pub_munic) if total_func_pub_munic > 0
sum log_func_temp, detail
gen high_cap_abs = (log_func_temp > r(p50)) if !missing(log_func_temp)
keep municipality_code high_cap_abs
tempfile temp_high_cap_abs
save `temp_high_cap_abs'
restore
merge m:1 municipality_code using `temp_high_cap_abs', nogenerate

* 2.3 Log dos funcionários por 1000 habitantes
preserve
keep if year == 2006
gen func_per_1000 = (total_func_pub_munic/population_muni)*1000
gen log_func_pc = log(func_per_1000) if func_per_1000 > 0
keep municipality_code log_func_pc
tempfile temp_log_func_pc
save `temp_log_func_pc'
restore
merge m:1 municipality_code using `temp_log_func_pc', nogenerate

* 2.4 Dummy baseada no log per capita
preserve
keep if year == 2006
gen func_per_1000 = (total_func_pub_munic/population_muni)*1000
gen log_func_temp = log(func_per_1000) if func_per_1000 > 0
sum log_func_temp, detail
gen high_cap_pc = (log_func_temp > r(p50)) if !missing(log_func_temp)
keep municipality_code high_cap_pc
tempfile temp_high_cap_pc
save `temp_high_cap_pc'
restore
merge m:1 municipality_code using `temp_high_cap_pc', nogenerate

* Criar variável de primeiro ano de spillover
gen spill_year = .
replace spill_year = 2007 if dist_PE <= 50
replace spill_year = 2011 if spill_year==. & (min(dist_BA, dist_PB) <= 50)
replace spill_year = 2015 if spill_year==. & dist_CE <= 50
replace spill_year = 2016 if spill_year==. & dist_MA <= 50

* Gerar relative time
gen rel_year = year - spill_year

* Gerar dummies de event time
forvalues l = 2/7 {
    gen F`l'event = rel_year == -`l'
}
forvalues l = 0/12 {
    gen L`l'event = rel_year == `l'
}

* Criar interações com cada medida de capacidade
foreach var in log_func_abs high_cap_abs log_func_pc high_cap_pc {
    foreach event of varlist F*event L*event {
        gen `event'_`var' = `event' * `var'
    }
}

gen log_pop = log(population_muni)

* Programas para processar resultados
capture program drop process_results_direct
program define process_results_direct
    preserve
    clear
    set obs 20
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    gen coef = .
    gen se = .
    
    forval i = 2/7 {
        local pos = `i'
        replace coef = b[1,`pos'] if period == -`i'
        replace se = sqrt(V[`pos',`pos']) if period == -`i'
    }
    forval i = 0/12 {
        local pos = `i' + 6
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
        title(`2', size(medium)) ///
        graphregion(color(white)) ///
        bgcolor(white) ///
        legend(off) ///
        name(`1', replace)
    restore
end

capture program drop process_results_int
program define process_results_int
    preserve
    clear
    set obs 20
    gen period = _n - 8
    matrix b = e(b)
    matrix V = e(V)
    gen coef = .
    gen se = .
    
    forval i = 2/7 {
        local pos = `i' + 18
        replace coef = b[1,`pos'] if period == -`i'
        replace se = sqrt(V[`pos',`pos']) if period == -`i'
    }
    forval i = 0/12 {
        local pos = `i' + 24
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
        title(`2', size(medium)) ///
        graphregion(color(white)) ///
        bgcolor(white) ///
        legend(off) ///
        name(`1', replace)
    restore
end

* Rodar regressões e criar gráficos
foreach var in "log_func_abs" "high_cap_abs" "log_func_pc" "high_cap_pc" {
    local title = cond("`var'" == "log_func_abs", "", ///
                 cond("`var'" == "high_cap_abs", "", ///
                 cond("`var'" == "log_func_pc", "", "")))
    
    * Regressão com controles
    reghdfe taxa_homicidios_total_por_100m_1 F*event L*event F*event_`var' L*event_`var' log_pop [aw=population_2000_muni], absorb(municipality_code year) cluster(state_code)
    
    * Processar resultados diretos
    process_results_direct spillover_`var' "`title'"
    
    * Processar resultados interação
    process_results_int int_`var' "`title'"
}

* Combinar gráficos de spillover direto
graph combine spillover_log_func_abs spillover_high_cap_abs spillover_log_func_pc spillover_high_cap_pc, ///
    cols(2) rows(2) xsize(11) ysize(10) ///
    graphregion(color(white) margin(zero)) ///
    name(combined_spillover, replace)

* Combinar gráficos de interação
graph combine int_log_func_abs int_high_cap_abs int_log_func_pc int_high_cap_pc, ///
    cols(2) rows(2) xsize(11) ysize(10) ///
    graphregion(color(white) margin(zero)) ///
    name(combined_interaction, replace)

* Exportar os dois gráficos combinados
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_spillover_50km_no_int_event_study.pdf", replace name(combined_spillover)
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/simple_spillover_capacity_50km_event_study.pdf", replace name(combined_interaction)
