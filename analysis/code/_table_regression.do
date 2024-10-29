* Important papers and packages:
* did_imputation: Event studies: robust and efficient estimation, testing, and plotting
* This is a Stata package for Borusyak, Jaravel, and Spiess (2024) REStud, "Revisiting Event Study Designs: Robust and Efficient Estimation" and (Borusyak et al. 2021)
*
* did_multiplegt_dyn: Estimation of event-study Difference-in-Difference (DID) estimators in designs with multiple groups and periods and with a potentially non-binary treatment that may increase or decrease multiple times, based on Difference-in-Differences Estimators of Intertemporal Treatment Effects (2024) Review of Economics and Statistics, Clément de Chaisemartin,  Xavier D'Haultfœuille
*
* did_multiplegt_stat In stat mode, the command computes heterogeneity-robust DID estimators introduced in de Chaisemartin and D'Haultfoeuille (2020) and de Chaisemartin et al. (2022). These estimators can be used with a non-binary (discrete or continuous) and non-absorbing treatment. However, they assume that past treatments do not affect the current outcome. Finally, these estimators can be used to compute IV-DID estimators, relying on a parallel-trends assumption with respect to an instrumental variable rather than the treatment. de Chaisemartin, C and D'Haultfoeuille, X (2020). American Economic Review, vol. 110, no. 9. Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects
* de Chaisemartin, C, D'Haultfoeuille, X, Pasquier, F, Vazquez‐Bare, G (2022). Difference-in-Differences for Continuous Treatments and Instruments with Stayers.

* csdid (Difference-in-Differences with multiple time periods, Callaway and Sant'Anna (2021)) and drdid ( Sant'Anna and Zhao (2020)

* eventstudyinteract (Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects (2020)). eventstudyinteract is a Stata package that implements the interaction weighted estimator for an event study. Sun and Abraham (2021) proposes this estimator as an alternative to the canonical two-way fixed effects regressions with relative time indicators. Sun and Abraham (2020) proves that this estimator is consistent for the average dynamic effect at a given relative time even under heterogeneous treatment effects. As outlined in the paper, eventstudyinteract uses either never-treated units or last-treated units as the comparison group. A similar estimator is Callaway and Sant'Anna (2020), which uses all not-yet-treated units for comparison. eventstudyinteract also constructs pointwise confidence intervals valid for the effect at a given relative time. The bootstrap-based inference by Callaway and Sant'Anna (2020) constructs simultaneous confidence intervals that are valid for the entire path of dynamic effects, i.e., effects across multiple relative times.

* sdid: This Stata package implements the synthetic difference-in-differences estimation procedure, along with a range of inference and graphing procedures, following Arkhangelsky et al., (2021). Arkhangelsky et al. provide a code implementation in R, with accompanying materials here: synthdid. Here we provide a native Stata implementation, principally written in Mata. This package extends the funcionality of the original R package, allowing very simply for estimation in contexts with staggered adoption over multiple treatment periods (as well as in a single adoption period as in the original code). We can also estimate SC and DID

* sdid_event: If you wish to implement Event Study analysis with SDiD, please check out

* twowayfeweights

* staggered: The staggered package computes the efficient estimator for settings with randomized treatment timing, based on the theoretical results in Roth and Sant'Anna (2023). If units are randomly (or quasi-randomly) assigned to begin treatment at different dates, the efficient estimator can potentially offer substantial gains over methods that only impose parallel trends.

* Instalação dos pacotes necessários
ssc install did_imputation
ssc install event_plot
ssc install did_multiplegt
ssc install csdid
ssc install drdid
ssc install eventstudyinteract
ssc install sdid
net install staggered, from(https://raw.githubusercontent.com/jonathandroth/staggered/main/stata)

* Load data
use "/Users/Fredie/Library/CloudStorage/Dropbox/PublicSecurity/build/workfile/output/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

gen pop_den_mun = pop_density_municipality
gen log_pib_mun_p_capita = log_pib_municipal_per_capita
gen log_formal_emp = log(total_vinculos_munic + 1)
gen log_formal_est = log(total_estabelecimentos_munic)


* foreach var of varlist log_pib_municipal_per_capita pop_density_municipality log_formal_est log_formal_emp {
	*bysort municipality_code (year): replace `var' = `var'[_n-1] if missing(`var')
	*}

*gen log_families_bf = log(families_bf +1)
*gen log_bf_value_families = log(bf_value_families + 1)
*gen log_average_value_bf = log(average_value_bf + 1)

* fillin municipality_code year

* Criar a variável de tratamento
gen treated = 0
replace treated = 1 if (state == "PE" & year >= 2007) |(state == "BA" & year >= 2011) | ///
                      (state == "PB" & year >= 2011) | (state == "CE" & year >= 2015) | ///
                      (state == "MA" & year >= 2016)

* Criar a variável de ano de adoção (staggered treatment)
gen treatment_year = 0 // Inicializa todos os estados como não tratados
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"
replace treatment_year = 2007 if state == "PE"

* Criar a variável de tempo relativo ao tratamento
gen rel_year = year - treatment_year

* Estimar o modelo de DiD com múltiplos grupos e períodos usando csdid
csdid taxa_homicidios_total_por_100m_1 treated, ivar(municipality_code) time(year) weight(population_2000_muni) ///
 gvar(treatment_year) method(dripw) cluster(state_code)
 
estat event
csdid_plot, title("Event Study")

gen pib_temp = pib_municipal_per_capita if year == 2006
egen pibpc2006 = max(pib_temp), by(municipality_code)

* Estimar o modelo de DiD com múltiplos grupos e períodos usando csdid
csdid taxa_homicidios_total_por_100m_1 treated log_pib_municipal_per_capita pop_density_municipality log_formal_est log_formal_emp, ivar(municipality_code) time(year) weight(population_2000_muni) ///
gvar(treatment_year) method(dripw) cluster(state_code)
 
estat event
csdid_plot, title("Event Study")


* event study simples

forvalues l = 0/12 {
	gen L`l'event = rel_year==`l'
}
forvalues l = 1/16 {
	gen F`l'event = rel_year==-`l'
}
drop F1event // normalize K=-1 (and also K=-15) to zero

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event [aw = population_2000_muni], a(municipality_code year) cluster(state_code)
event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-16(1)12) ///
	title("OLS"))
	
	
* event study simples com controles

forvalues l = 0/12 {
	gen L`l'event = rel_year==`l'
}
forvalues l = 1/16 {
	gen F`l'event = rel_year==-`l'
}
drop F1event // normalize K=-1 (and also K=-15) to zero

reghdfe taxa_homicidios_total_por_100m_1 F*event L*event pop_density_municipality log_formal_emp log_formal_est log_pib_municipal_per_capita [aw = population_2000_muni], a(municipality_code year) cluster(state_code)

event_plot, default_look stub_lag(L#event) stub_lead(F#event) together graph_opt(xtitle("Days since the event") ytitle("OLS coefficients") xlabel(-16(1)12) ///
	title("OLS"))
	
* estimar
did_multiplegt_dyn taxa_homicidios_total_por_100m_1 municipality_code year treated, controls(log_pib_municipal_per_capita pop_density_municipality log_formal_emp log_formal_est) effects(12) placebo(7) weight(population_2000_muni) cluster(state_code)

gen lastunit = treatment_year == .

* estimar sun
eventstudyinteract taxa_homicidios_total_por_100m_1 F*event L*event [aw = population_2000_muni], vce(cluster state_code) absorb(municipality_code year) cohort(treatment_year) control_cohort(lastunit)

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-16(1)12) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together
	

	* estimar sun
eventstudyinteract taxa_homicidios_total_por_100m_1 F*event L*event [aw = population_2000_muni], vce(cluster state_code) absorb(municipality_code year) cohort(treatment_year) control_cohort(lastunit) covariates(pop_density_municipality log_pib_municipal_per_capita log_formal_emp log_formal_est)

event_plot e(b_iw)#e(V_iw), default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") xlabel(-16(1)12) ///
	title("Sun and Abraham (2020)")) stub_lag(L#event) stub_lead(F#event) together
	
	****
	reg taxa_homicidios_total_por_100m_1 log_pib_municipal_per_capita pop_density_municipality log_formal_emp log_formal_est [aw = population_2000_muni]
	_predict res, res
	
	****
	
	
	* did_imputation
	did_imputation res municipality_code year treatment_year [aw = population_2000_muni], allhorizons pretrends(16) cluster(state_code)
	
	event_plot, default_look graph_opt(xtitle("Periods since the event") ytitle("Average causal effect") ///
	title("Borusyak et al. (2021) imputation estimator") xlabel(-16(1)12))
	
	* sdid *
	
	* Primeiro, vamos garantir que temos apenas os anos desejados
keep if inrange(year, 2000, 2019)

* Verificar número de observações por município
bysort municipality_code: gen n_years = _N
tab n_years

* Manter apenas municípios com dados para todos os 20 anos
keep if n_years == 20

* Verificar missing values em cada covariável
misstable summarize log_pib_mun_p_capita pop_den_mun log_formal_emp log_formal_est

* Criar indicadores para missing values
foreach var of varlist log_pib_mun_p_capita pop_den_mun log_formal_emp log_formal_est {
    gen miss_`var' = missing(`var')
    bysort municipality_code: egen total_miss_`var' = sum(miss_`var')
}

* Identificar municípios com missing values
egen total_missing = rowtotal(miss_*)
tab total_missing

* Identificar quais municípios têm missing values e em quais anos
list municipality_code year log_pib_mun_p_capita pop_den_mun log_formal_emp log_formal_est if total_missing > 0, sepby(municipality_code)

* Remover municípios que têm qualquer missing value
bysort municipality_code: egen mun_has_missing = max(total_missing)
drop if mun_has_missing > 0

* Verificar se o painel está balanceado
xtset municipality_code year

sdid taxa_homicidios_total_por_100m_1 municipality_code year treated, vce(bootstrap) reps(100) seed(123) covariates(log_pib_municipal_per_capita pop_density_municipality log_formal_emp log_formal_est, projected) ///
  method(sdid) graph
  
  ****
  