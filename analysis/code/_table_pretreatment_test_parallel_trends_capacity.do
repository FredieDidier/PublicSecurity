drop if municipality_code == 2300000 | municipality_code == 2600000 

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

* Preparar dados para 2006 (pré-tratamento)
keep if year == 2006

* Criar indicadores de tratamento
gen ever_treated = 0
replace ever_treated = 1 if inlist(state, "BA", "PB", "CE", "MA", "PE")
gen cohort_2007 = 0
replace cohort_2007 = 1 if state == "PE"
gen log_population = log(population_muni)
gen treated_log_func_pc = ever_treated * log_func_pc
gen treated_high_cap_pc = ever_treated * high_cap_pc


* Armazenar média dos não tratados
sum taxa_homicidios_total_por_100m_1 if ever_treated == 0 [aw=population_2000_muni]
scalar untreated_mean = r(mean)

* Regressões para todos os tratados
* 1) Com log_func_pc
reg taxa_homicidios_total_por_100m_1 ever_treated treated_log_func_pc log_population [aw=population_2000_muni], cluster(state_code)
boottest ever_treated, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
scalar wild_p_all = r(p)
boottest treated_log_func_pc, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
scalar wild_p_log_func_pc = r(p)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/parallel_trends_capacity_twfe.tex", ///
    tex replace ///
    keep(ever_treated treated_log_func_pc) nocons ///
    ctitle("Homicide Rate") ///
    addstat("Untreated Mean", untreated_mean, ///
            "Wild Bootstrap p-value Low Log Func", wild_p_all, ///
			"Wild Bootstrap p-value Treated x log_func", wild_p_log_func_pc)

* 2) Com high_cap_pc
reg taxa_homicidios_total_por_100m_1 ever_treated treated_high_cap_pc log_population [aw=population_2000_muni], cluster(state_code)
boottest ever_treated, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
scalar wild_p_all_h = r(p)
boottest treated_high_cap_pc, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
scalar wild_p_high_cap_pc = r(p)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/parallel_trends_capacity_twfe.tex", ///
    tex append ///
    keep(ever_treated treated_high_cap_pc) nocons ///
    ctitle("Homicide Rate") ///
    addstat("Untreated Mean", untreated_mean, ///
            "Wild Bootstrap p-value Low High Cap", wild_p_all_h, ///
			"Wild Bootstrap p-value Treated x high_cap", wild_p_high_cap_pc)
			
drop if state == "BA"|state == "CE"| state == "MA"

* Regressões para coorte 2007
* 3) Com log_func_pc
*reg taxa_homicidios_total_por_100m_1 cohort_2007 treated_log_func_pc log_population if !inlist(state, "BA", "PB", "CE", "MA") [aw=population_2000_muni], cluster(state_code)
*boottest cohort_2007, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
*scalar wild_p_2007 = r(p)
*boottest treated_log_func_pc, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
*scalar wild_p_log_func_pc_2007 = r(p)

*outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/parallel_trends_capacity_twfe.tex", ///
    tex append ///
    keep(cohort_2007 treated_log_func_pc) nocons ///
    ctitle("2007 Cohort") ///
    addstat("Untreated Mean", untreated_mean, ///
            "Wild Bootstrap p-value 2007 Low Log Func", wild_p_2007, ///
			"Wild Bootstrap p-value 2007 interaction", wild_p_log_func_pc_2007)

* 4) Com high_cap_pc
*reg taxa_homicidios_total_por_100m_1 cohort_2007 treated_high_cap_pc log_population if !inlist(state, "BA", "PB", "CE", "MA") [aw=population_2000_muni], cluster(state_code)
*boottest cohort_2007, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
*scalar wild_p_2007_h = r(p)
*boottest treated_high_cap_pc, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
*scalar wild_p_high_cap_pc_2007 = r(p)

*outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/parallel_trends_capacity_twfe.tex", ///
    tex append ///
    keep(cohort_2007 treated_high_cap_pc) nocons ///
    ctitle("2007 Cohort") ///
    addstat("Untreated Mean", untreated_mean, ///
            "Wild Bootstrap p-value 2007 Low High Cap", wild_p_2007_h, ///
			"Wild Bootstrap p-value 2007 interaction", wild_p_high_cap_pc_2007) ///
    addnote("Notes: The coefficients are obtained from a simple regression on an indicator of the treatment group using population weights. Sample restricted to 2006. Cluster robust standard errors (state level) in parentheses, and p-value from wild-cluster bootstrap in brackets.")
