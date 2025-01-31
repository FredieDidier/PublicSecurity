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

* Criar variável de controle
gen log_pop = log(population_muni)

* Rodar regressões para cada medida de capacidade e com/sem controles
eststo clear
foreach var in log_func_pc high_cap_pc {
    foreach control in 0 1 {
        if `control' == 0 {
            local control_text "No"
            eststo: reg taxa_homicidios_total_por_100m_1 F*event L*event F*event_`var' L*event_`var' i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
        } 
        else {
            local control_text "Yes"
            eststo: reg taxa_homicidios_total_por_100m_1 F*event L*event F*event_`var' L*event_`var' log_pop i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
        }
        
        * Teste de significância conjunta dos coeficientes pré-tratamento
        test F7event F6event F5event F4event F3event F2event
        scalar f_stat_pre = r(F)
        scalar p_value_pre = r(p)
        
        test F7event_`var' F6event_`var' F5event_`var' F4event_`var' F3event_`var' F2event_`var'
        scalar f_stat_pre_interaction = r(F)
        scalar p_value_pre_interaction = r(p)
        
        * Wild bootstrap p-values para eventos pré-tratamento
        forvalues l = 2/7 {
            boottest F`l'event, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
            scalar wild_p_F`l' = r(p)
            boottest F`l'event_`var', reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
            scalar wild_p_F`l'_int = r(p)
        }
        
        * Wild bootstrap p-values para eventos pós-tratamento
        forvalues l = 0/12 {
            boottest L`l'event, reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
            scalar wild_p_L`l' = r(p)
            boottest L`l'event_`var', reps(9999) cluster(state_code) boottype(wild) weighttype(webb)
            scalar wild_p_L`l'_int = r(p)
        }
        
        * Exportar resultados
        outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/simple_capacity_event_study_results.tex", tex append ///
            ctitle("Homicide Rate" \ "Event Study - `var' - Controls: `control_text'") ///
            keep(F*event L*event F*event_`var' L*event_`var') nocons ///
            addtext(Municipality FE, Yes, Year FE, Yes, Controls, `control_text') ///
            addstat("F-statistic (Pre-treatment)", f_stat_pre, ///
                   "P-value (Pre-treatment)", p_value_pre, ///
                   "F-statistic Interaction (Pre-treatment)", f_stat_pre_interaction, ///
                   "P-value Interaction (Pre-treatment)", p_value_pre_interaction, ///
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
                   "Wild Bootstrap p-value L12", wild_p_L12, ///
                   "Wild Bootstrap p-value F7 (Interaction)", wild_p_F7_int, ///
                   "Wild Bootstrap p-value F6 (Interaction)", wild_p_F6_int, ///
                   "Wild Bootstrap p-value F5 (Interaction)", wild_p_F5_int, ///
                   "Wild Bootstrap p-value F4 (Interaction)", wild_p_F4_int, ///
                   "Wild Bootstrap p-value F3 (Interaction)", wild_p_F3_int, ///
                   "Wild Bootstrap p-value F2 (Interaction)", wild_p_F2_int, ///
                   "Wild Bootstrap p-value L0 (Interaction)", wild_p_L0_int, ///
                   "Wild Bootstrap p-value L1 (Interaction)", wild_p_L1_int, ///
                   "Wild Bootstrap p-value L2 (Interaction)", wild_p_L2_int, ///
                   "Wild Bootstrap p-value L3 (Interaction)", wild_p_L3_int, ///
                   "Wild Bootstrap p-value L4 (Interaction)", wild_p_L4_int, ///
                   "Wild Bootstrap p-value L5 (Interaction)", wild_p_L5_int, ///
                   "Wild Bootstrap p-value L6 (Interaction)", wild_p_L6_int, ///
                   "Wild Bootstrap p-value L7 (Interaction)", wild_p_L7_int, ///
                   "Wild Bootstrap p-value L8 (Interaction)", wild_p_L8_int, ///
                   "Wild Bootstrap p-value L9 (Interaction)", wild_p_L9_int, ///
                   "Wild Bootstrap p-value L10 (Interaction)", wild_p_L10_int, ///
                   "Wild Bootstrap p-value L11 (Interaction)", wild_p_L11_int, ///
                   "Wild Bootstrap p-value L12 (Interaction)", wild_p_L12_int)
    }
}
