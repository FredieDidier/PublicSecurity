********************************************************************************
* 1. Preparação inicial dos dados
********************************************************************************
use "seu_arquivo.dta", clear

* Remover municípios específicos
drop if municipality_code == 2300000 | municipality_code == 2600000
gen log_population = log(population_muni)

* 2.3 Log dos funcionários por 1000 habitantes
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

* Configurações básicas
set more off
set seed 1234

********************************************************************************
* 2. Criar variáveis base de tratamento
********************************************************************************
* Criar indicador de tratamento por coorte
gen treat_2007 = (state == "PE")
gen treat_2011 = (state == "BA" | state == "PB")
gen treat_2015 = (state == "CE")

* Criar variável de tempo relativo para cada coorte
gen rel_2007 = year - 2007
gen rel_2011 = year - 2011
gen rel_2015 = year - 2015

* Criar indicador de not yet treated para cada coorte
gen control_2007 = (treat_2007 == 0)  // Inclui BA, PB, CE, MA e never treated
gen control_2011 = (treat_2011 == 0 & treat_2007 == 0)  // Inclui CE, MA e never treated (exclui PE)
gen control_2015 = (treat_2015 == 0 & treat_2007 == 0 & treat_2011 == 0)  // Inclui MA e never treated (exclui PE, BA, PB)

********************************************************************************
* 3. Gerar dummies de event time para cada coorte
********************************************************************************
* Para coorte 2007
forvalues l = 0/12 {
   gen L`l'_2007 = (treat_2007==1 & rel_2007==`l')
}
forvalues l = 1/7 {
   gen F`l'_2007 = (treat_2007==1 & rel_2007==-`l')
}

* Interações com capacidade para 2007
foreach var in high_cap_pc {
   forvalues l = 1/7 {
       gen F`l'_2007_`var' = F`l'_2007 * `var'
   }
   forvalues l = 0/12 {
       gen L`l'_2007_`var' = L`l'_2007 * `var'
   }
}

* Para coorte 2011
forvalues l = 0/8 {    // Ajustado para período disponível até 2019
   gen L`l'_2011 = (treat_2011==1 & rel_2011==`l')
}
forvalues l = 1/7 {
   gen F`l'_2011 = (treat_2011==1 & rel_2011==-`l')
}

* Interações com capacidade para 2011
foreach var in high_cap_pc {
   forvalues l = 1/7 {
       gen F`l'_2011_`var' = F`l'_2011 * `var'
   }
   forvalues l = 0/8 {
       gen L`l'_2011_`var' = L`l'_2011 * `var'
   }
}

* Para coorte 2015
forvalues l = 0/4 {    // Ajustado para período disponível até 2019
   gen L`l'_2015 = (treat_2015==1 & rel_2015==`l')
}
forvalues l = 1/7 {
   gen F`l'_2015 = (treat_2015==1 & rel_2015==-`l')
}

* Interações com capacidade para 2015
foreach var in high_cap_pc {
   forvalues l = 1/7 {
       gen F`l'_2015_`var' = F`l'_2015 * `var'
   }
   forvalues l = 0/4 {
       gen L`l'_2015_`var' = L`l'_2015 * `var'
   }
}

********************************************************************************
* 4. Análise para coorte 2007 (PE)
********************************************************************************
* Regressão principal para 2007
estimates clear
reg taxa_homicidios_total_por_100m_1 F*_2007 L*_2007 F*_2007_high_cap_pc L*_2007_high_cap_pc ///
   log_population i.municipality_code i.year ///
   if treat_2007==1 | control_2007==1 [weight=population_2000_muni], cluster(state_code)
estimates store reg_2007

* Teste F para coeficientes pré-tratamento - Low Capacity
test F7_2007 F6_2007 F5_2007 F4_2007 F3_2007 F2_2007
scalar f_2007_low = r(F)
scalar p_2007_low = r(p)

* Teste F para coeficientes pré-tratamento - High Capacity
test F7_2007_high_cap_pc F6_2007_high_cap_pc F5_2007_high_cap_pc F4_2007_high_cap_pc F3_2007_high_cap_pc F2_2007_high_cap_pc
scalar f_2007_high = r(F)
scalar p_2007_high = r(p)

* Wild bootstrap p-values para eventos pré-tratamento
forvalues l = 2/7 {
   boottest F`l'_2007, reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
   scalar wild_p_F`l' = r(p)
   boottest F`l'_2007_high_cap_pc, reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
   scalar wild_p_F`l'_int = r(p)
}

* Calcular médias pré-tratamento
sum taxa_homicidios_total_por_100m_1 if treat_2007==1 & rel_2007 < 0 & high_cap_pc == 0
scalar mean_2007_low = r(mean)
sum taxa_homicidios_total_por_100m_1 if treat_2007==1 & rel_2007 < 0 & high_cap_pc == 1
scalar mean_2007_high = r(mean)

********************************************************************************
* 5. Análise para coorte 2011 (BA/PB)
********************************************************************************
* Regressão principal para 2011
estimates clear
reg taxa_homicidios_total_por_100m_1 F*_2011 L*_2011 F*_2011_high_cap_pc L*_2011_high_cap_pc ///
   log_population i.municipality_code i.year ///
   if treat_2011==1 | control_2011==1 [weight=population_2000_muni], cluster(state_code)
estimates store reg_2011

* Teste F para coeficientes pré-tratamento - Low Capacity
test F7_2011 F6_2011 F5_2011 F4_2011 F3_2011 F2_2011
scalar f_2011_low = r(F)
scalar p_2011_low = r(p)

* Teste F para coeficientes pré-tratamento - High Capacity
test F7_2011_high_cap_pc F6_2011_high_cap_pc F5_2011_high_cap_pc F4_2011_high_cap_pc F3_2011_high_cap_pc F2_2011_high_cap_pc
scalar f_2011_high = r(F)
scalar p_2011_high = r(p)

* Wild bootstrap p-values para eventos pré-tratamento
forvalues l = 2/7 {
   boottest F`l'_2011, reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
   scalar wild_p_F`l' = r(p)
   boottest F`l'_2011_high_cap_pc, reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
   scalar wild_p_F`l'_int = r(p)
}

* Calcular médias pré-tratamento
sum taxa_homicidios_total_por_100m_1 if treat_2011==1 & rel_2011 < 0 & high_cap_pc == 0
scalar mean_2011_low = r(mean)
sum taxa_homicidios_total_por_100m_1 if treat_2011==1 & rel_2011 < 0 & high_cap_pc == 1
scalar mean_2011_high = r(mean)

********************************************************************************
* 6. Análise para coorte 2015 (CE)
********************************************************************************
* Regressão principal para 2015
estimates clear
reg taxa_homicidios_total_por_100m_1 F*_2015 L*_2015 F*_2015_high_cap_pc L*_2015_high_cap_pc ///
   log_population i.municipality_code i.year ///
   if treat_2015==1 | control_2015==1 [weight=population_2000_muni], cluster(state_code)
estimates store reg_2015

* Teste F para coeficientes pré-tratamento - Low Capacity
test F7_2015 F6_2015 F5_2015 F4_2015 F3_2015 F2_2015
scalar f_2015_low = r(F)
scalar p_2015_low = r(p)

* Teste F para coeficientes pré-tratamento - High Capacity
test F7_2015_high_cap_pc F6_2015_high_cap_pc F5_2015_high_cap_pc F4_2015_high_cap_pc F3_2015_high_cap_pc F2_2015_high_cap_pc
scalar f_2015_high = r(F)
scalar p_2015_high = r(p)

* Wild bootstrap p-values para eventos pré-tratamento
forvalues l = 2/7 {
   boottest F`l'_2015, reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
   scalar wild_p_F`l' = r(p)
   boottest F`l'_2015_high_cap_pc, reps(9999) cluster(state_code) boottype(wild) weighttype(webb) nograph
   scalar wild_p_F`l'_int = r(p)
}

* Calcular médias pré-tratamento
sum taxa_homicidios_total_por_100m_1 if treat_2015==1 & rel_2015 < 0 & high_cap_pc == 0
scalar mean_2015_low = r(mean)
sum taxa_homicidios_total_por_100m_1 if treat_2015==1 & rel_2015 < 0 & high_cap_pc == 1
scalar mean_2015_high = r(mean)

********************************************************************************
* 7. Criar Tabelas de Resultados
********************************************************************************
* Tabela para 2007
estimates restore reg_2007
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/no_anticipation_test_capacity.tex", ///
   keep(F7_2007 F6_2007 F5_2007 F4_2007 F3_2007 F2_2007 ///
        F7_2007_high_cap_pc F6_2007_high_cap_pc F5_2007_high_cap_pc F4_2007_high_cap_pc F3_2007_high_cap_pc F2_2007_high_cap_pc) ///
   tex nocons replace ///
   title("Pre-treatment Effects on Homicide Rates by Cohort and Local Capacity") ///
   addtext(Municipality FE, Yes, Year FE, Yes) ///
   addstat("F-stat Low Cap", f_2007_low, ///
           "F-stat High Cap", f_2007_high, ///
           "P-value Low Cap", p_2007_low, ///
           "P-value High Cap", p_2007_high, ///
           "Wild P-value F7 Low", wild_p_F7, ///
           "Wild P-value F6 Low", wild_p_F6, ///
           "Wild P-value F5 Low", wild_p_F5, ///
           "Wild P-value F4 Low", wild_p_F4, ///
           "Wild P-value F3 Low", wild_p_F3, ///
           "Wild P-value F2 Low", wild_p_F2, ///
           "Wild P-value F7 High", wild_p_F7_int, ///
           "Wild P-value F6 High", wild_p_F6_int, ///
           "Wild P-value F5 High", wild_p_F5_int, ///
           "Wild P-value F4 High", wild_p_F4_int, ///
           "Wild P-value F3 High", wild_p_F3_int, ///
           "Wild P-value F2 High", wild_p_F2_int, ///
           "Average Low Cap", mean_2007_low, ///
           "Average High Cap", mean_2007_high) ///
   label dec(3) pdec(3) ///
   ctitle("2007 Cohort")

* Tabela para 2011 (append)
estimates restore reg_2011
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/no_anticipation_test_capacity.tex", ///
   keep(F7_2011 F6_2011 F5_2011 F4_2011 F3_2011 F2_2011 ///
        F7_2011_high_cap_pc F6_2011_high_cap_pc F5_2011_high_cap_pc F4_2011_high_cap_pc F3_2011_high_cap_pc F2_2011_high_cap_pc) ///
   tex nocons append ///
   addstat("F-stat Low Cap", f_2011_low, ///
           "F-stat High Cap", f_2011_high, ///
           "P-value Low Cap", p_2011_low, ///
           "P-value High Cap", p_2011_high, ///
           "Wild P-value F7 Low", wild_p_F7, ///
           "Wild P-value F6 Low", wild_p_F6, ///
           "Wild P-value F5 Low", wild_p_F5, ///
           "Wild P-value F4 Low", wild_p_F4, ///
           "Wild P-value F3 Low", wild_p_F3, ///
           "Wild P-value F2 Low", wild_p_F2, ///
           "Wild P-value F7 High", wild_p_F7_int, ///
           "Wild P-value F6 High", wild_p_F6_int, ///
           "Wild P-value F5 High", wild_p_F5_int, ///
           "Wild P-value F4 High", wild_p_F4_int, ///
           "Wild P-value F3 High", wild_p_F3_int, ///
           "Wild P-value F2 High", wild_p_F2_int, ///
           "Average Low Cap", mean_2011_low, ///
           "Average High Cap", mean_2011_high) ///
   label dec(3) pdec(3) ///
   ctitle("2011 Cohort")

* Tabela para 2015 (append)
estimates restore reg_2015
outreg2 using "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/tables/no_anticipation_test_capacity.tex", ///
   keep(F7_2015 F6_2015 F5_2015 F4_2015 F3_2015 F2_2015 ///
        F7_2015_high_cap_pc F6_2015_high_cap_pc F5_2015_high_cap_pc F4_2015_high_cap_pc F3_2015_high_cap_pc F2_2015_high_cap_pc) ///
   tex nocons append ///
   addstat("F-stat Low Cap", f_2015_low, ///
           "F-stat High Cap", f_2015_high, ///
           "P-value Low Cap", p_2015_low, ///
           "P-value High Cap", p_2015_high, ///
           "Wild P-value F7 Low", wild_p_F7, ///
           "Wild P-value F6 Low", wild_p_F6, ///
           "Wild P-value F5 Low", wild_p_F5, ///
           "Wild P-value F4 Low", wild_p_F4, ///
           "Wild P-value F3 Low", wild_p_F3, ///
           "Wild P-value F2 Low", wild_p_F2, ///
           "Wild P-value F7 High", wild_p_F7_int, ///
           "Wild P-value F6 High", wild_p_F6_int, ///
           "Wild P-value F5 High", wild_p_F5_int, ///
           "Wild P-value F4 High", wild_p_F4_int, ///
           "Wild P-value F3 High", wild_p_F3_int, ///
           "Wild P-value F2 High", wild_p_F2_int, ///
           "Average Low Cap", mean_2015_low, ///
           "Average High Cap", mean_2015_high) ///
   label dec(3) pdec(3) ///
   ctitle("2015 Cohort")
   