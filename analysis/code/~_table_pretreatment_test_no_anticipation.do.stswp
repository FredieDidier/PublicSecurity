use "/Users/fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

drop if municipality_code == 2300000 | municipality_code == 2600000 

* Gerar variáveis de tempo relativo para cada tratamento
* PE 2007
gen relative_year_2007 = .
replace relative_year_2007 = year - 2007 if state == "PE"

* BA e PB 2011
gen relative_year_2011 = .
replace relative_year_2011 = year - 2011 if state == "BA" | state == "PB"

* CE 2015
gen relative_year_2015 = .
replace relative_year_2015 = year - 2015 if state == "CE"

* MA 2016
gen relative_year_2016 = .
replace relative_year_2016 = year - 2016 if state == "MA"

gen log_population = log(population_muni)

* Criar dummies de event-time para cada tratamento
foreach treat in 2007 2011 2015 2016 {
    * Leads (períodos pré-tratamento)
    forvalues l = 1/7 {
        gen F`l'event_`treat' = relative_year_`treat' == -`l'
    }
    
    * Lags (períodos pós-tratamento)
    forvalues l = 0/12 {
        gen L`l'event_`treat' = relative_year_`treat' == `l'
    }
}

* Regressão para cada coorte
foreach treat in 2007 2011 2015 2016 {
    * Estimar modelo
    reg taxa_homicidios_total_por_100m_1 F*event_`treat' L*event_`treat' log_population i.municipality_code i.year [aw=population_2000_muni], cluster(state_code)
        
    * F-test para coeficientes pré-tratamento (F1 incluído agora)
    test F7event_`treat' F6event_`treat' F5event_`treat' F4event_`treat' F3event_`treat' F2event_`treat' F1event_`treat'
    scalar f_stat_`treat' = r(F)
    scalar p_value_`treat' = r(p)
    
    * Wild bootstrap para cada coeficiente
    foreach var of varlist F*event_`treat' L*event_`treat' {
        capture: boottest `var', reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
        if _rc == 0 {
            local vname = substr("`var'", 1, strpos("`var'", "event")-1)
            scalar wild_p_`treat'_`vname' = r(p)
        }
    }
    
    * Armazenar resultados
    estimates store cohort_`treat'
    
    * Calcular média pré-tratamento
    sum taxa_homicidios_total_por_100m_1 if relative_year_`treat' == -1
    scalar avg_`treat' = r(mean)
}

* Exportar resultados - primeiro tratamento (2007) com replace
outreg2 [cohort_2007] using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/noanticipation_test.tex", ///
    tex replace ///
    keep(F*event_2007 L*event_2007) nocons ///
    ctitle("2007 Cohort") ///
    addstat("F-statistic", f_stat_2007, ///
            "P-value", p_value_2007, ///
            "Wild P-value F7", wild_p_2007_F7, ///
            "Wild P-value F6", wild_p_2007_F6, ///
            "Wild P-value F5", wild_p_2007_F5, ///
            "Wild P-value F4", wild_p_2007_F4, ///
            "Wild P-value F3", wild_p_2007_F3, ///
            "Wild P-value F2", wild_p_2007_F2, ///
            "Wild P-value F1", wild_p_2007_F1, ///
            "Average", avg_2007)

* Demais tratamentos com append
foreach treat in 2011 2015 2016 {
    outreg2 [cohort_`treat'] using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/noanticipation_test.tex", ///
        tex append ///
        keep(F*event_`treat' L*event_`treat') nocons ///
        ctitle("`treat' Cohort") ///
        addstat("F-statistic", f_stat_`treat', ///
                "P-value", p_value_`treat', ///
                "Wild P-value F7", wild_p_`treat'_F7, ///
                "Wild P-value F6", wild_p_`treat'_F6, ///
                "Wild P-value F5", wild_p_`treat'_F5, ///
                "Wild P-value F4", wild_p_`treat'_F4, ///
                "Wild P-value F3", wild_p_`treat'_F3, ///
                "Wild P-value F2", wild_p_`treat'_F2, ///
                "Wild P-value F1", wild_p_`treat'_F1, ///
                "Average", avg_`treat')
}
