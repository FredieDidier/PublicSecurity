* Configurações iniciais
clear all
set more off

********************************************************************************
* 1. Preparação dos dados inicial
********************************************************************************
* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000

* Gerar log da população
gen log_population = log(population_muni)

* Definir thresholds de distância
local distances "100 75 50"

********************************************************************************
* 2. Análise Versão 1 - log absoluto
********************************************************************************
foreach dist of local distances {
    preserve
    
    * Drop treated states
    drop if inlist(state, "PE", "BA", "PB", "CE", "MA")
    
    * Keep only observations within distance threshold
    gen min_dist = min(dist_PE, dist_BA, dist_PB, dist_CE, dist_MA)
    keep if min_dist < `dist'
    
    * Generate spillover variable
    gen spillover = 0
    
    * 2007-2010: Only PE spillovers
    replace spillover = 1 if year >= 2007 & year <= 2010 & dist_PE <= `dist'
    
    * 2011-2014: PE, BA, PB spillovers
    replace spillover = 1 if year >= 2011 & year <= 2014 & ///
        min(dist_PE, dist_BA, dist_PB) <= `dist'
    
    * 2015: PE, BA, PB, CE spillovers
    replace spillover = 1 if year == 2015 & ///
        min(dist_PE, dist_BA, dist_PB, dist_CE) <= `dist'
    
    * 2016 onwards: All treated states spillovers
    replace spillover = 1 if year >= 2016 & min_dist <= `dist'
    
    * Criar medidas de capacidade (versão 1 - log absoluto)
    tempfile full_sample
    save `full_sample'
    
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
    tempfile capacity
    save `capacity'
    
    * Voltar para amostra completa
    use `full_sample', clear
    
    * Merge back
    merge m:1 municipality_code using `capacity', keepusing(log_func high_cap) nogenerate
    
    * Criar interações
    gen spillover_log_func = spillover * log_func
    gen spillover_high_cap = spillover * high_cap
    
    * Primeira regressão - Log contínuo sem controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_log_func i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)

    * Bootstrap para reg1
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue1_spill = r(p)
    boottest spillover_log_func, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue1_int = r(p)

    local append_replace = cond("`dist'" == "100", "replace", "append")
    
    * Salvar primeira regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity.tex", tex `append_replace' ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_log_func) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue1_spill, ///
                WildBootstrap_pvalue_int, pvalue1_int) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons

    * Segunda regressão - Log contínuo com controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_log_func log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg2
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue2_spill = r(p)
    boottest spillover_log_func, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue2_int = r(p)
    boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue2_pop = r(p)
    
    * Adicionar segunda regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity.tex", tex append ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_log_func log_population) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue2_spill, ///
                WildBootstrap_pvalue_int, pvalue2_int, ///
                WildBootstrap_pvalue_logpop, pvalue2_pop) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    * Terceira regressão - Dummy sem controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_high_cap i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg3
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue3_spill = r(p)
    boottest spillover_high_cap, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue3_int = r(p)
    
    * Adicionar terceira regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity.tex", tex append ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_high_cap) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue3_spill, ///
                WildBootstrap_pvalue_int, pvalue3_int) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    * Quarta regressão - Dummy com controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_high_cap log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg4
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue4_spill = r(p)
    boottest spillover_high_cap, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue4_int = r(p)
    boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue4_pop = r(p)
    
    * Adicionar quarta regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity.tex", tex append ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_high_cap log_population) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue4_spill, ///
                WildBootstrap_pvalue_int, pvalue4_int, ///
                WildBootstrap_pvalue_logpop, pvalue4_pop) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    restore
}

* Limpeza intermediária
scalar drop _all

********************************************************************************
* 3. Análise Versão 2 - log per capita
********************************************************************************
foreach dist of local distances {
    preserve
    
    * Drop treated states
    drop if inlist(state, "PE", "BA", "PB", "CE", "MA")
    
    * Keep only observations within distance threshold
    gen min_dist = min(dist_PE, dist_BA, dist_PB, dist_CE, dist_MA)
    keep if min_dist < `dist'
    
    * Generate spillover variable
    gen spillover = 0
    
    * 2007-2010: Only PE spillovers
    replace spillover = 1 if year >= 2007 & year <= 2010 & dist_PE <= `dist'
    
    * 2011-2014: PE, BA, PB spillovers
    replace spillover = 1 if year >= 2011 & year <= 2014 & ///
        min(dist_PE, dist_BA, dist_PB) <= `dist'
    
    * 2015: PE, BA, PB, CE spillovers
    replace spillover = 1 if year == 2015 & ///
        min(dist_PE, dist_BA, dist_PB, dist_CE) <= `dist'
    
    * 2016 onwards: All treated states spillovers
    replace spillover = 1 if year >= 2016 & min_dist <= `dist'
    
    * Criar medidas de capacidade (versão 2 - log per capita)
    tempfile full_sample
    save `full_sample'
    
    keep if year == 2006
    
    * Gerar funcionários por 1000 habitantes
    gen func_per_1000 = (total_func_pub_munic/population_muni)*1000
    
    * Calcular log desta medida
    gen log_func_per_1000 = log(func_per_1000)
    
    * Calcular mediana
    summarize log_func_per_1000, detail
    scalar p50_log_func = r(p50)
    
    * Criar dummy para mediana
    gen high_cap_v2 = (log_func_per_1000 > p50_log_func) if !missing(log_func_per_1000)
    
    * Guardar os valores para merge
    keep municipality_code log_func_per_1000 high_cap_v2
    tempfile capacity
    save `capacity'
    
    * Voltar para amostra completa
    use `full_sample', clear
    
    * Merge back
    merge m:1 municipality_code using `capacity', keepusing(log_func_per_1000 high_cap_v2) nogenerate
    
    * Criar interações
    gen spillover_log_func_per_1000 = spillover * log_func_per_1000
    gen spillover_high_cap_v2 = spillover * high_cap_v2
    
    * Primeira regressão - Log contínuo sem controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_log_func_per_1000 i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg1
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue1_spill = r(p)
    boottest spillover_log_func_per_1000, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue1_int = r(p)
    
    local append_replace = cond("`dist'" == "100", "replace", "append")
    
    * Salvar primeira regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity_v2.tex", tex `append_replace' ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_log_func_per_1000) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue1_spill, ///
                WildBootstrap_pvalue_int, pvalue1_int) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    * Segunda regressão - Log contínuo com controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_log_func_per_1000 log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg2
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue2_spill = r(p)
    boottest spillover_log_func_per_1000, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue2_int = r(p)
    boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue2_pop = r(p)
    
    * Adicionar segunda regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity_v2.tex", tex append ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_log_func_per_1000 log_population) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue2_spill, ///
                WildBootstrap_pvalue_int, pvalue2_int, ///
                WildBootstrap_pvalue_logpop, pvalue2_pop) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    * Terceira regressão - Dummy sem controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_high_cap_v2 i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg3
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue3_spill = r(p)
    boottest spillover_high_cap_v2, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue3_int = r(p)
    
    * Adicionar terceira regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity_v2.tex", tex append ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_high_cap_v2) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue3_spill, ///
WildBootstrap_pvalue_int, pvalue3_int) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    * Quarta regressão - Dummy com controle
    reg taxa_homicidios_total_por_100m_1 spillover spillover_high_cap_v2 log_population i.municipality_code i.year [weight=population_2000_muni], cluster(state_code)
    
    * Bootstrap para reg4
    boottest spillover, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue4_spill = r(p)
    boottest spillover_high_cap_v2, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue4_int = r(p)
    boottest log_population, cluster(state_code) noci nograph reps(9999) weighttype(webb)
    scalar pvalue4_pop = r(p)
    
    * Adicionar quarta regressão
    outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/spillover_capacity_v2.tex", tex append ///
        ctitle("Homicide Rate `dist'km") ///
        keep(spillover spillover_high_cap_v2 log_population) ///
        addstat(WildBootstrap_pvalue_spillover, pvalue4_spill, ///
                WildBootstrap_pvalue_int, pvalue4_int, ///
                WildBootstrap_pvalue_logpop, pvalue4_pop) ///
        addtext(Municipality FE, Yes, Year FE, Yes, Distance, `dist'km) ///
        nocons
    
    restore
}

* Limpeza final
scalar drop _all
