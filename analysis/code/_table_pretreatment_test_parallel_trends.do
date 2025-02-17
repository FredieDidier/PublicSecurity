drop if municipality_code == 2300000 | municipality_code == 2600000 

* Preparar dados para 2006 (pré-tratamento)
keep if year == 2006

* Criar indicadores de tratamento
gen ever_treated = 0
replace ever_treated = 1 if inlist(state, "BA", "PB", "CE", "MA", "PE")

gen cohort_2007 = 0
replace cohort_2007 = 1 if state == "PE"

gen log_population = log(population_muni)

* Armazenar média dos não tratados
sum taxa_homicidios_total_por_100m_1 if ever_treated == 0 [aw=population_2000_muni]
scalar untreated_mean = r(mean)

* Regressão para todos os tratados
reg taxa_homicidios_total_por_100m_1 ever_treated log_population [aw=population_2000_muni], cluster(state_code)
boottest ever_treated, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
scalar wild_p_all = r(p)

outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/parallel_trends.tex", ///
    tex replace ///
    keep(ever_treated) nocons ///
    ctitle("Homicide Rate") ///
    addstat("Untreated Mean", untreated_mean, ///
            "Wild Bootstrap p-value All", wild_p_all)

* Regressão para coorte 2007
reg taxa_homicidios_total_por_100m_1 cohort_2007 log_population if !inlist(state, "BA", "PB", "CE", "MA") [aw=population_2000_muni], cluster(state_code)
boottest cohort_2007, cluster(state_code) reps(9999) boottype(wild) weighttype(webb) nograph
scalar wild_p_2007 = r(p)

outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/parallel_trends.tex", ///
    tex append ///
    keep(cohort_2007) nocons ///
    ctitle("2007 Cohort") ///
    addstat("Untreated Mean", untreated_mean, ///
            "Wild Bootstrap p-value 2007", wild_p_2007) ///
    addnote("Notes: The coefficients are obtained from a simple regression on an indicator of the treatment group using population weights. Sample restricted to 2006. Cluster robust standard errors (state level) in parentheses, and p-value from wild-cluster bootstrap in brackets.")
