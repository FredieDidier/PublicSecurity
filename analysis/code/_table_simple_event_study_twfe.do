* Configuração inicial
set seed 1234

* Limpeza inicial e geração de variáveis
drop if municipality_code == 2300000 | municipality_code == 2600000
gen treat_year = .
replace treat_year = 2011 if state == "BA" | state == "PB"
replace treat_year = 2015 if state == "CE"
replace treat_year = 2016 if state == "MA"
replace treat_year = 2007 if state == "PE"
gen rel_year = year - treat_year

* Gerar dummies de event time
forvalues l = 2/7 {
    gen F`l'event = rel_year == -`l'
}
forvalues l = 0/12 {
    gen L`l'event = rel_year == `l'
}

* Primeira regressão (sem controles)
eststo: reg taxa_homicidios_total_por_100m_1 F*event L*event i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Teste de significância conjunta dos coeficientes pré-tratamento
test F7event F6event F5event F4event F3event F2event
scalar f_stat_pre = r(F)
scalar p_value_pre = r(p)

* Wild bootstrap p-value para cada coeficiente
forvalues l = 2/7 {
    boottest F`l'event, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
    scalar wild_p_F`l' = r(p)
}
forvalues l = 0/12 {
    boottest L`l'event, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
    scalar wild_p_L`l' = r(p)
}

* Exportar primeira regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_event_study_results.tex", tex replace ///
    ctitle("Homicide Rate" \ "Event Study") keep(F*event L*event) nocons ///
    addtext(Municipality FE, Yes, Year FE, Yes, Controls, No) ///
    addstat("F-statistic", f_stat_pre, "P-value", p_value_pre, ///
            "Wild Bootstrap p-value F7", wild_p_F7, ///
            "Wild Bootstrap p-value F6", wild_p_F6, ///
            "Wild Bootstrap p-value F5", wild_p_F5, ///
            "Wild Bootstrap p-value F4", wild_p_F4, ///
            "Wild Bootstrap p-value F3", wild_p_F3, ///
            "Wild Bootstrap p-value F2", wild_p_F2, ///
            "Wild Bootstrap p-value L0", wild_p_L0, ///
            "Wild Bootstrap p-value L1", wild_p_L1, ///
            "Wild Bootstrap p-value L2", wild_p_L2, ///
            "Wild Bootstrap p-value L3", wild_p_L3, ///
            "Wild Bootstrap p-value L4", wild_p_L4, ///
            "Wild Bootstrap p-value L5", wild_p_L5, ///
            "Wild Bootstrap p-value L6", wild_p_L6, ///
            "Wild Bootstrap p-value L7", wild_p_L7, ///
            "Wild Bootstrap p-value L8", wild_p_L8, ///
            "Wild Bootstrap p-value L9", wild_p_L9, ///
            "Wild Bootstrap p-value L10", wild_p_L10, ///
            "Wild Bootstrap p-value L11", wild_p_L11, ///
            "Wild Bootstrap p-value L12", wild_p_L12)

* Segunda regressão (com controles)
gen log_pop = log(population_muni)
eststo: reg taxa_homicidios_total_por_100m_1 F*event L*event log_pop i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

* Teste de significância conjunta dos coeficientes pré-tratamento
test F7event F6event F5event F4event F3event F2event
scalar f_stat_pre = r(F)
scalar p_value_pre = r(p)

* Wild bootstrap p-value para cada coeficiente
forvalues l = 2/7 {
    boottest F`l'event, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
    scalar wild_p_F`l' = r(p)
}
forvalues l = 0/12 {
    boottest L`l'event, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
    scalar wild_p_L`l' = r(p)
}

* Exportar segunda regressão
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_event_study_results.tex", tex append ///
    ctitle("Homicide Rate" \ "Event Study with Controls") keep(F*event L*event) nocons ///
    addtext(Municipality FE, Yes, Year FE, Yes, Controls, Yes) ///
    addstat("F-statistic", f_stat_pre, "P-value", p_value_pre, ///
            "Wild Bootstrap p-value F7", wild_p_F7, ///
            "Wild Bootstrap p-value F6", wild_p_F6, ///
            "Wild Bootstrap p-value F5", wild_p_F5, ///
            "Wild Bootstrap p-value F4", wild_p_F4, ///
            "Wild Bootstrap p-value F3", wild_p_F3, ///
            "Wild Bootstrap p-value F2", wild_p_F2, ///
            "Wild Bootstrap p-value L0", wild_p_L0, ///
            "Wild Bootstrap p-value L1", wild_p_L1, ///
            "Wild Bootstrap p-value L2", wild_p_L2, ///
            "Wild Bootstrap p-value L3", wild_p_L3, ///
            "Wild Bootstrap p-value L4", wild_p_L4, ///
            "Wild Bootstrap p-value L5", wild_p_L5, ///
            "Wild Bootstrap p-value L6", wild_p_L6, ///
            "Wild Bootstrap p-value L7", wild_p_L7, ///
            "Wild Bootstrap p-value L8", wild_p_L8, ///
            "Wild Bootstrap p-value L9", wild_p_L9, ///
            "Wild Bootstrap p-value L10", wild_p_L10, ///
            "Wild Bootstrap p-value L11", wild_p_L11, ///
            "Wild Bootstrap p-value L12", wild_p_L12)
