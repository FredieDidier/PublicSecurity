* Configurações iniciais
clear all
set more off

********************************************************************************
* 1. Preparação dos dados básicos
********************************************************************************
* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

********************************************************************************
* 2. Dummy baseada na proporção de funcionários com ensino superior (Variavel Dependente)
********************************************************************************
preserve
keep if year == 2006
* Calculando a porcentagem de funcionários com ensino superior em relação ao total
gen porc_func_superior = (funcionarios_superior / total_func_pub_munic) * 100
* Calculando a estatística descritiva para identificar a mediana
sum porc_func_superior, detail
* Criando a dummy high_cap_pc que é 1 se proporção > mediana, 0 caso contrário
gen high_cap_pc = (porc_func_superior > r(p50))
* Mantendo apenas as variáveis necessárias para o merge
keep municipality_code high_cap_pc
save "temp_high_cap_pc.dta", replace
restore
* Fazendo o merge com o dataset principal
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
* 3.1 Criar variável de controle adicional: Média da proporção de funcionários com ensino superior em 2004-2005
********************************************************************************
preserve
keep if year == 2004 | year == 2005

* Calculando a proporção de funcionários com ensino superior para 2004-2005
gen porc_func_superior_0405 = (funcionarios_superior / total_func_pub_munic) * 100 if funcionarios_superior > 0 & total_func_pub_munic > 0

* Calculando a média por município
bysort municipality_code: egen mean_porc_func_superior_0405 = mean(porc_func_superior_0405) if porc_func_superior_0405 > 0
gen log_mean_porc_func_superior_0405 = log(mean_porc_func_superior_0405) if mean_porc_func_superior_0405 > 0

keep municipality_code mean_porc_func_superior_0405 log_mean_porc_func_superior_0405
duplicates drop municipality_code, force
save "temp_additional_controls.dta", replace
restore

merge m:1 municipality_code using "temp_additional_controls.dta", nogenerate
erase "temp_additional_controls.dta"

********************************************************************************
* 4. Panel B: Regressões com a dummy de capacidade (high_cap_pc)
********************************************************************************
* Especificação 1: Só população
reg high_cap_pc log_pop_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex replace ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405) nocons

* Especificação 2: População e PIB
reg high_cap_pc log_pop_0405 log_pib_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405 log_pib_pc_0405) nocons

* Especificação 3: Todos os controles
reg high_cap_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405) nocons
	
* Especificação 4: Todos os controles + média da proporção de funcionários com ensino superior 2004-2005
reg high_cap_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 mean_porc_func_superior_0405 if year == 2006, cluster(municipality_code)
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/predictive_capacity.tex", tex append ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 mean_porc_func_superior_0405) nocons
