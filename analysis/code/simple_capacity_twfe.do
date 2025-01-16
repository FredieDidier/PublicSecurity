* Configurações iniciais
clear all
set more off

********************************************************************************
* 1. Preparação dos dados
********************************************************************************
* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

* Criar variável de tratamento
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007
replace treated = 1 if (state == "BA" | state == "PB") & year >= 2011
replace treated = 1 if state == "CE" & year >= 2015
replace treated = 1 if state == "MA" & year >= 2016

* Gerar log da população
gen log_population = log(population_muni)

********************************************************************************
* 2. Criar variáveis de capacidade
********************************************************************************
* Criar medida de log para 2006
preserve
keep if year == 2006

* Gerar log dos funcionários (apenas para não-zeros)
gen log_func = log(total_func_pub_munic) if total_func_pub_munic > 0

* Calcular mediana do log
summarize log_func, detail
scalar median_log_func = r(p50)

* Criar dummy baseada na mediana do log
gen high_cap = (log_func > median_log_func) if !missing(log_func)

* Guardar os valores para merge
keep municipality_code log_func high_cap
save "temp_capacity.dta", replace
restore

* Merge back
merge m:1 municipality_code using "temp_capacity.dta", keepusing(log_func high_cap) nogenerate
erase "temp_capacity.dta"

* Criar interações
gen treated_log_func = treated * log_func
gen treated_high_cap = treated * high_cap

********************************************************************************
* 3. Regressões e Bootstrap
********************************************************************************

* Primeira regressão - Log contínuo sem controle
reg taxa_homicidios_total_por_100m_1 treated treated_log_func i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg1
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue1_treated = r(p)
boottest treated_log_func, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue1_int = r(p)

* Salvar primeira regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe.tex", tex replace ///
    ctitle("Homicide Rate") ///
    keep(treated treated_log_func) ///
    addstat(WildBootstrap_pvalue_treated, pvalue1_treated, ///
            WildBootstrap_pvalue_int, pvalue1_int) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Segunda regressão - Log contínuo com controle
reg taxa_homicidios_total_por_100m_1 treated treated_log_func log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg2
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2_treated = r(p)
boottest treated_log_func, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2_int = r(p)
boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2_pop = r(p)

* Adicionar segunda regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe.tex", tex append ///
    ctitle("Homicide Rate") ///
    keep(treated treated_log_func log_population) ///
    addstat(WildBootstrap_pvalue_treated, pvalue2_treated, ///
            WildBootstrap_pvalue_int, pvalue2_int, ///
            WildBootstrap_pvalue_logpop, pvalue2_pop) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Terceira regressão - Dummy baseada no log sem controle
reg taxa_homicidios_total_por_100m_1 treated treated_high_cap i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg3
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue3_treated = r(p)
boottest treated_high_cap, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue3_int = r(p)

* Adicionar terceira regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe.tex", tex append ///
    ctitle("Homicide Rate") ///
    keep(treated treated_high_cap) ///
    addstat(WildBootstrap_pvalue_treated, pvalue3_treated, ///
            WildBootstrap_pvalue_int, pvalue3_int) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Quarta regressão - Dummy baseada no log com controle
reg taxa_homicidios_total_por_100m_1 treated treated_high_cap log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg4
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue4_treated = r(p)
boottest treated_high_cap, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue4_int = r(p)
boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue4_pop = r(p)

* Adicionar quarta regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe.tex", tex append ///
    ctitle("Homicide Rate") ///
    keep(treated treated_high_cap log_population) ///
    addstat(WildBootstrap_pvalue_treated, pvalue4_treated, ///
            WildBootstrap_pvalue_int, pvalue4_int, ///
            WildBootstrap_pvalue_logpop, pvalue4_pop) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Limpeza final
scalar drop _all

************
************

* Configurações iniciais
clear all
set more off

********************************************************************************
* 1. Preparação dos dados
********************************************************************************
* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

* Criar variável de tratamento
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007
replace treated = 1 if (state == "BA" | state == "PB") & year >= 2011
replace treated = 1 if state == "CE" & year >= 2015
replace treated = 1 if state == "MA" & year >= 2016

* Gerar log da população
gen log_population = log(population_muni)

********************************************************************************
* 2. Criar novas variáveis de capacidade
********************************************************************************
* Criar medida de funcionários por 1000 habitantes em 2006
preserve
keep if year == 2006

* Gerar funcionários por 1000 habitantes
gen func_per_1000 = (total_func_pub_munic/population_muni)*1000

* Calcular log desta medida
gen log_func_per_1000 = log(func_per_1000)

* Calcular mediana (p50)
summarize log_func_per_1000, detail
scalar p50_log_func = r(p50)

* Criar dummy para mediana
gen high_cap = (log_func_per_1000 > p50_log_func) if !missing(log_func_per_1000)

* Guardar os valores para merge
keep municipality_code log_func_per_1000 high_cap
save "temp_capacity.dta", replace
restore

* Merge back
merge m:1 municipality_code using "temp_capacity.dta", keepusing(log_func_per_1000 high_cap) nogenerate
erase "temp_capacity.dta"

* Criar interações
gen treated_log_func = treated * log_func_per_1000
gen treated_high_cap = treated * high_cap

********************************************************************************
* 3. Regressões e Bootstrap
********************************************************************************

* Primeira regressão - Log contínuo sem controle
reg taxa_homicidios_total_por_100m_1 treated treated_log_func i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg1
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue1_treated = r(p)
boottest treated_log_func, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue1_int = r(p)

* Salvar primeira regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe_V2.tex",tex replace /// 
    ctitle("Homicide Rate") ///
    keep(treated treated_log_func) ///
    addstat(WildBootstrap_pvalue_treated, pvalue1_treated, ///
            WildBootstrap_pvalue_int, pvalue1_int) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Segunda regressão - Log contínuo com controle
reg taxa_homicidios_total_por_100m_1 treated treated_log_func log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg2
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2_treated = r(p)
boottest treated_log_func, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2_int = r(p)
boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2_pop = r(p)

* Adicionar segunda regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe_V2.tex", tex append  ///
    ctitle("Homicide Rate") ///
    keep(treated treated_log_func log_population) ///
    addstat(WildBootstrap_pvalue_treated, pvalue2_treated, ///
            WildBootstrap_pvalue_int, pvalue2_int, ///
            WildBootstrap_pvalue_logpop, pvalue2_pop) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Terceira regressão - Dummy para mediana sem controle
reg taxa_homicidios_total_por_100m_1 treated treated_high_cap i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg3
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue3_treated = r(p)
boottest treated_high_cap, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue3_int = r(p)

* Adicionar terceira regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe_V2.tex", tex append  ///
    ctitle("Homicide Rate") ///
    keep(treated treated_high_cap) ///
    addstat(WildBootstrap_pvalue_treated, pvalue3_treated, ///
            WildBootstrap_pvalue_int, pvalue3_int) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Quarta regressão - Dummy para mediana com controle
reg taxa_homicidios_total_por_100m_1 treated treated_high_cap log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Bootstrap para reg4
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue4_treated = r(p)
boottest treated_high_cap, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue4_int = r(p)
boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue4_pop = r(p)

* Adicionar quarta regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_twfe_V2.tex", tex append  ///  
    ctitle("Homicide Rate") ///
    keep(treated treated_high_cap log_population) ///
    addstat(WildBootstrap_pvalue_treated, pvalue4_treated, ///
            WildBootstrap_pvalue_int, pvalue4_int, ///
            WildBootstrap_pvalue_logpop, pvalue4_pop) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

* Limpeza final
scalar drop _all
