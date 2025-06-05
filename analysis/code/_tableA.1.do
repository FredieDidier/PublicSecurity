*Initial Setup
clear all
set more off

********************************************************************************
* 1. Preparing Data
********************************************************************************
* Load data
use "$inpdir/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

********************************************************************************
* 2. Dummy based on proportion of public employees with higher education (2006)
********************************************************************************
* Prepare variable of capacity by state (high_cap)
preserve
keep if year == 2006
drop if perc_superior == .

* Creating temporary table to store medians by state
tempfile state_medians_cap
tempname memhold
postfile `memhold' str2 state double median_perc_superior using `state_medians_cap'

* Calculating perc_superior median for each state separately
levelsof state, local(states)
foreach s of local states {
    quietly sum perc_superior if state == "`s'", detail
    post `memhold' ("`s'") (r(p50))
}
postclose `memhold'

* Saving for later use
keep municipality_code state
save "temp_muni_state.dta", replace
restore

* Merge with medians by state table
merge m:1 state using `state_medians_cap', nogenerate
* Merge with municipality-state table
merge m:1 municipality_code using "temp_muni_state.dta", nogenerate
erase "temp_muni_state.dta"

* Now create high_cap variable based of each state median
gen high_cap_pc = (perc_superior > median_perc_superior) if perc_superior != .
drop median_perc_superior


********************************************************************************
* 3. Create control variables  (2004-2005 means)
********************************************************************************
* Create means by municipality for 2004-2005
preserve
keep if year == 2004 | year == 2005

* Population
bysort municipality_code: egen pop_0405 = mean(population_muni)
gen log_pop_0405 = log(pop_0405)

* GDP per capita
bysort municipality_code: egen pib_pc_0405 = mean(pib_municipal_per_capita)
gen log_pib_pc_0405 = log(pib_pc_0405)

* School Facilities
bysort municipality_code: egen schools_0405 = mean(total_estabelecimentos_educ)
gen log_schools_0405 = log(schools_0405)

* Health Facilities
bysort municipality_code: egen health_0405 = mean(total_estabelecimentos_saude)
gen log_health_0405 = log(health_0405)

keep municipality_code log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405
duplicates drop municipality_code, force
save "temp_controls.dta", replace
restore

merge m:1 municipality_code using "temp_controls.dta", nogenerate
erase "temp_controls.dta"

******************************************************************************************************************
* 3.1 Create additional control variable: Mean of proportion of public employees with higher education in 2004-2005
******************************************************************************************************************
preserve
keep if year == 2004 | year == 2005

* Calculating proportion of employees with higher education for 2004-2005
gen porc_func_superior_0405 = (funcionarios_superior / total_func_pub_munic) * 100 if funcionarios_superior > 0 & total_func_pub_munic > 0

* Calculating mean by municipality
bysort municipality_code: egen mean_porc_func_superior_0405 = mean(porc_func_superior_0405) if porc_func_superior_0405 > 0
gen log_mean_porc_func_superior_0405 = log(mean_porc_func_superior_0405) if mean_porc_func_superior_0405 > 0

keep municipality_code mean_porc_func_superior_0405 log_mean_porc_func_superior_0405
duplicates drop municipality_code, force
save "temp_additional_controls.dta", replace
restore

merge m:1 municipality_code using "temp_additional_controls.dta", nogenerate
erase "temp_additional_controls.dta"

********************************************************************************
* 4. Regressions with capacity dummy (high_cap_pc)
********************************************************************************
* Specification 1: Just population
reg high_cap_pc log_pop_0405 if year == 2006, cluster(municipality_code)
outreg2 using "${outdir}/tables/table_A.1.tex", tex replace ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405) nocons

* Specification 2: Population and GDP
reg high_cap_pc log_pop_0405 log_pib_pc_0405 if year == 2006, cluster(municipality_code)
outreg2 using "${outdir}/tables/table_A.1.tex", tex append ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405 log_pib_pc_0405) nocons

* Specification 3: All controls except mean of proportion of public employees with higher education in 2004-2005
reg high_cap_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 if year == 2006, cluster(municipality_code)
outreg2 using "${outdir}/tables/table_A.1.tex", tex append ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405) nocons
	
* Specification 4: All controls
reg high_cap_pc log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_porc_func_superior_0405 if year == 2006, cluster(municipality_code)
outreg2 using "${outdir}/tables/table_A.1.tex", tex append ///
    ctitle("High Capacity (% Higher Education)") keep(log_pop_0405 log_pib_pc_0405 log_schools_0405 log_health_0405 log_mean_porc_func_superior_0405) nocons
