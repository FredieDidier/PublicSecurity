use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

* Limpeza inicial
drop if municipality_code == 2300000 | municipality_code == 2600000
gen treatment_year = 0
replace treatment_year = 2007 if inlist(state, "AL", "PI", "RN", "SE")
drop if inlist(state, "PE", "BA", "PB", "CE", "MA")
gen t2007 = (treatment_year == 2007)
gen trend = year - 2000 // Tendência linear começando em 2000
gen partrend2007 = trend * t2007
gen post = 1 if year >= 2007
replace post = 0 if year < 2007
gen log_pop = log(population_muni)

* Criar variáveis necessárias
gen spillover50 = (dist_PE < 50)
gen spillover75 = (dist_PE < 75)
gen spillover50_post = spillover50 * post
gen spillover75_post = spillover75 * post

* Configurar painel
xtset municipality_code year

* Para a regressão com dist_PE < 50
preserve
keep if dist_PE < 50 | dist_PE >= 50
xtreg taxa_homicidios_total_por_100m_1 spillover50 spillover50_post log_pop partrend2007 i.year i.municipality_code [aw=population_2000_muni], fe vce(cluster state_code)
 
* Calcular wild bootstrap p-values
boottest spillover50_post, seed(1234) weighttype(webb) cluster(state_code) noci nograph
local p_spillover50_post = r(p)

* Salvar resultados para tabela
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_PE.tex", replace tex label ///
keep(spillover50 spillover50_post log_pop) ///
addstat("Wild p-value spillover50_post", `p_spillover50_post') ///
title("") ctitle("Distance to PE border < 50")
restore

* Para a regressão com dist_PE < 75
preserve
keep if dist_PE < 75 | dist_PE >= 75
xtreg taxa_homicidios_total_por_100m_1 spillover75 spillover75_post log_pop partrend2007 i.year i.municipality_code [aw=population_2000_muni], fe vce(cluster state_code)
 
* Calcular wild bootstrap p-values
boottest spillover75_post, boottype(wild) weighttype(webb) cluster(state_code) noci nograph
local p_spillover75_post = r(p)

* Adicionar à tabela
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_PE.tex", append tex label ///
keep(spillover75 spillover75_post log_pop) ///
addstat("Wild p-value spillover75_post", `p_spillover75_post') ///
title("") ctitle("Distance to PE border < 75")
restore

* Para personalizar a tabela final com os p-values em colchetes, será necessário editar o arquivo tex
* gerado pelo outreg2, adicionando os p-values entre colchetes abaixo dos erros padrão
