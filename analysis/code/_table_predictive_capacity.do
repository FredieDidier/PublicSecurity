* Configurações iniciais
clear all
set more off

********************************************************************************
* 1. Preparação dos dados básicos
********************************************************************************
* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

********************************************************************************
* 2. Criar variáveis dependentes (capacidade em 2006)
********************************************************************************
* 2.1 Log absoluto
preserve
keep if year == 2006
gen log_func = log(total_func_pub_munic) if total_func_pub_munic > 0
keep municipality_code log_func
save "temp_log_func.dta", replace
restore
merge m:1 municipality_code using "temp_log_func.dta", nogenerate
erase "temp_log_func.dta"

* 2.2 Dummy baseada no log absoluto
preserve
keep if year == 2006
gen log_func_temp = log(total_func_pub_munic) if total_func_pub_munic > 0
sum log_func_temp, detail
gen high_cap = (log_func_temp > r(p50)) if !missing(log_func_temp)
keep municipality_code high_cap
save "temp_high_cap.dta", replace
restore
merge m:1 municipality_code using "temp_high_cap.dta", nogenerate
erase "temp_high_cap.dta"

* 2.3 Log per capita
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
* 3. Criar variáveis de controle (médias 2004-2005)
********************************************************************************
* Criar médias por município para 2004-2005
preserve
keep if year == 2004 | year == 2005

* População
bysort municipality_code: egen pop_0405 = mean(population_muni)
gen log_pop_0405 = log(pop_0405)

* PIB per capita
bysort municipality_code: egen pib_pc_0405 = mean(pib_municipal_per_capita)
gen log_pib_pc_0405 = log(pib_pc_0405)

* Escolas
bysort municipality_code: egen schools_0405 = mean(total_estabelecimentos_educ)
gen log_schools_0405 = log(schools_0405)

* Estabelecimentos de saúde
bysort municipality_code: egen health_0405 = mean(total_estabelecimentos_saude)
gen log_health_0405 = log(health_0405)

keep municipality_code log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405
duplicates drop municipality_code, force
save "temp_controls.dta", replace
restore

merge m:1 municipality_code using "temp_controls.dta", nogenerate
erase "temp_controls.dta"

********************************************************************************
* 3.1 Criar variável de controle adicional: Log da média das variáveis dependentes em 2004-2005
********************************************************************************
preserve
keep if year == 2004 | year == 2005

* Log absoluto
bysort municipality_code: egen mean_log_func_0405 = mean(log(total_func_pub_munic)) if total_func_pub_munic > 0
gen log_mean_log_func_0405 = log(mean_log_func_0405) if mean_log_func_0405 > 0

* Log per capita
gen func_per_1000 = (total_func_pub_munic/population_muni)*1000
bysort municipality_code: egen mean_log_func_pc_0405 = mean(log(func_per_1000)) if func_per_1000 > 0
gen log_mean_log_func_pc_0405 = log(mean_log_func_pc_0405) if mean_log_func_pc_0405 > 0

keep municipality_code log_mean_log_func_0405 log_mean_log_func_pc_0405
duplicates drop municipality_code, force
save "temp_additional_controls.dta", replace
restore

merge m:1 municipality_code using "temp_additional_controls.dta", nogenerate
erase "temp_additional_controls.dta"

********************************************************************************
* 4. Panel A: Regressões com medidas absolutas
********************************************************************************
* Log absoluto de funcionários
* Especificação 1: Só população
reg log_func log_pop_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex replace ///
    ctitle("Log(Employees)") keep(log_pop_0405) nocons

* Especificação 2: População e PIB
reg log_func log_pop_0405 log_pib_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("Log(Employees)") keep(log_pop_0405 log_pib_pc_0405) nocons

* Especificação 3: Todos os controles
reg log_func log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("Log(Employees)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405) nocons
	
* Especificação 4: Todos os controles + log da média das variáveis dependentes
reg log_func log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("Log(Employees)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_0405) nocons

* High Capacity (dummy)
* Especificação 1: Só população
reg high_cap log_pop_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity") keep(log_pop_0405) nocons

* Especificação 2: População e PIB
reg high_cap log_pop_0405 log_pib_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity") keep(log_pop_0405 log_pib_pc_0405) nocons

* Especificação 3: Todos os controles
reg high_cap log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405) nocons
	
* Especificação 4: Todos os controles + log da média das variáveis dependentes
reg high_cap log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_0405) nocons


********************************************************************************
* 5. Panel B: Regressões com medidas per capita
********************************************************************************
* Log funcionários per capita
* Especificação 1: Só população
reg log_func_pc log_pop_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex replace ///
    ctitle("Log(Employees per 1,000)") keep(log_pop_0405) nocons

* Especificação 2: População e PIB
reg log_func_pc log_pop_0405 log_pib_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("Log(Employees per 1,000)") keep(log_pop_0405 log_pib_pc_0405) nocons

* Especificação 3: Todos os controles
reg log_func_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("Log(Employees per 1,000)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405) nocons
	
* Especificação 4: Todos os controles + log da média das variáveis dependentes
reg log_func_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("Log(Employees per 1,000)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_pc_0405) nocons


* High Capacity per capita
* Especificação 1: Só população
reg high_cap_pc log_pop_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("High Capacity per Capita") keep(log_pop_0405) nocons

* Especificação 2: População e PIB
reg high_cap_pc log_pop_0405 log_pib_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("High Capacity per Capita") keep(log_pop_0405 log_pib_pc_0405) nocons

* Especificação 3: Todos os controles
reg high_cap_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("High Capacity per Capita") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405) nocons
	
* Especificação 4: Todos os controles + log da média das variáveis dependentes
reg high_cap_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity_V2.tex", tex append ///
    ctitle("High Capacity per Capita") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_log_func_pc_0405) nocons
