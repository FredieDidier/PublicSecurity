* Carregar os dados
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear

* Limpeza inicial
drop if municipality_code == 2300000 | municipality_code == 2600000

* Remover Pernambuco (estado focal) da análise
drop if state == "PE"

* Definir anos de tratamento para diferentes estados
gen treatment_year = 0
replace treatment_year = 2007 if inlist(state, "AL", "PI", "RN", "SE")
replace treatment_year = 2011 if inlist(state, "BA", "PB")
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"

* Gerar variáveis para a análise
gen t2007 = (treatment_year == 2007)
gen trend = year - 2000 // Tendência linear começando em 2000
gen partrend2007 = trend * t2007
gen post = 1 if year >= 2007
replace post = 0 if year < 2007

* Criar variáveis para limitar a amostra por período de tratamento (mesmo filtro da tabela)
gen sample_state = 1
replace sample_state = 0 if inlist(state, "BA", "PB") & year > 2010
replace sample_state = 0 if state == "CE" & year > 2014
replace sample_state = 0 if state == "MA" & year > 2015

* Variáveis necessárias
gen log_pop = log(population_muni)
gen spillover50 = (dist_PE < 50)

* Configurar painel
xtset municipality_code year

* Abordagem 1: Gráfico de resíduos após controlar por efeitos fixos
preserve
keep if sample_state == 1

* Estimar modelo com efeitos fixos para extrair resíduos
* Apenas removendo os efeitos fixos de município e ano (sem incluir as variáveis de interesse)
areg taxa_homicidios_total_por_100m_1 i.year [aw=population_2000_muni], absorb(municipality_code) vce(cluster state_code)

* Predizer resíduos
predict residuals, residuals

* Calcular médias dos resíduos por ano e por status de spillover50
collapse (mean) residuals [aw=population_2000_muni], by(year spillover50)

* Reorganizar os dados para formato amplo
reshape wide residuals, i(year) j(spillover50)

* Renomear variáveis para maior clareza
rename residuals0 residuals_no_spillover
rename residuals1 residuals_spillover

* Gerar gráfico com pontos
twoway (line residuals_spillover year, lcolor(red) lwidth(medthick)) ///
       (scatter residuals_spillover year, mcolor(red) msymbol(circle) msize(medium)) ///
       (line residuals_no_spillover year, lcolor(blue) lwidth(medthick)) ///
       (scatter residuals_no_spillover year, mcolor(blue) msymbol(circle) msize(medium)), ///
       ytitle("Homicide Rate") ///
       xlabel(2000(2)2019, angle(45)) ///
       xline(2007, lpattern(dash) lcolor(black)) ///
       yline(0, lpattern(dash) lcolor(black)) ///
       legend(order(2 "Distance to PE's border (< 50km)" ///
                    4 "Distance to PE's border (> 50km)") rows(2) size(small)) ///
       scheme(s1color)
	   
* Salvar o gráfico
graph export "/Users/fredie/Documents/GitHub/PublicSecurity/analysis/output/graphs/spillover_residuals_50km.pdf", replace

restore

