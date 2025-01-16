
* Limpeza inicial
drop if municipality_code == 2300000 | municipality_code == 2600000

* Criar variáveis necessárias
gen log_population = log(population_muni)

* Criar variáveis de tratamento
gen treated = 0
replace treated = 1 if state == "PE" & year >= 2007
replace treated = 1 if state == "BA" & year >= 2011
replace treated = 1 if state == "PB" & year >= 2011
replace treated = 1 if state == "CE" & year >= 2015
replace treated = 1 if state == "MA" & year >= 2016

// Primeira regressão
reg taxa_homicidios_total_por_100m_1 treated i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

// Calculando wild bootstrap p-value para treated
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue1 = r(p)

// Salvando primeira regressão
outreg2 using "/Users/fredie/Downloads/simple_twfe_did.tex", tex replace ///
    ctitle("Homicide Rate - TWFE") ///
    keep(treated) ///
    addstat(WildBootstrap_pvalue_treated, pvalue1) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons

// Segunda regressão
reg taxa_homicidios_total_por_100m_1 treated log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

// Calculando wild bootstrap p-values
boottest treated, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue2 = r(p)

boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
scalar pvalue3 = r(p)

// Adicionando segunda regressão à tabela
outreg2 using "/Users/fredie/Downloads/simple_twfe_did.tex", tex append ///
    ctitle("Homicide Rate - TWFE") ///
    keep(treated log_population) ///
    addstat(WildBootstrap_pvalue_treated, pvalue2, ///
            WildBootstrap_pvalue_logpop, pvalue3) ///
    addtext(Municipality FE, Yes, Year FE, Yes) ///
    nocons
