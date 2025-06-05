* Load Data
 use "$inpdir/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000

* Removing Pernambuco (PE) from analysis (PE was treated in 2007)
drop if state == "PE"

* Defining treatment year for other states
gen treatment_year = 0
replace treatment_year = 2007 if inlist(state, "AL", "PI", "RN", "SE")
replace treatment_year = 2011 if inlist(state, "BA", "PB")
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"

* Create variables for analysis
gen t2007 = (treatment_year == 2007)
gen trend = year - 2000 
gen partrend2007 = trend * t2007
gen post = 1 if year >= 2007
replace post = 0 if year < 2007

* Create variable to limit tje sample by period of treatment
gen sample_state = 1
replace sample_state = 0 if inlist(state, "BA", "PB") & year > 2010
replace sample_state = 0 if state == "CE" & year > 2014
replace sample_state = 0 if state == "MA" & year > 2015

* Necessary Variables
gen log_pop = log(population_muni)
gen spillover50 = (dist_PE < 50)

* Panel configuration
xtset municipality_code year

* Graph of residuals after controlling for fixed effects
preserve
keep if sample_state == 1

* Model
areg taxa_homicidios_total_por_100m_1 i.year log_pop partrend2007 [aw=population_2000_muni], absorb(municipality_code) vce(cluster state_code)

* Predict Residuals
predict residuals, residuals

* Calculate means of residuals by year and spillover50 status
collapse (mean) residuals [aw=population_2000_muni], by(year spillover50)

* Reshape data
reshape wide residuals, i(year) j(spillover50)

* Rename variables for clarity
rename residuals0 residuals_no_spillover
rename residuals1 residuals_spillover

* Create Graph
twoway (line residuals_spillover year, lcolor(red) lwidth(medthick)) ///
       (scatter residuals_spillover year, mcolor(red) msymbol(circle) msize(medium)) ///
       (line residuals_no_spillover year, lcolor(blue) lwidth(medthick)) ///
       (scatter residuals_no_spillover year, mcolor(blue) msymbol(circle) msize(medium)), ///
       ytitle("Homicide Rate") xtitle("Year") ///
       xlabel(2000(2)2019, angle(45)) ///
       xline(2007, lpattern(dash) lcolor(black)) ///
       yline(0, lpattern(dash) lcolor(black)) ///
       legend(order(2 "Distance to PE's border (< 50km)" ///
                    4 "Distance to PE's border (> 50km)") rows(2) size(small)) ///
       scheme(s1color)
	   
* Save graph
graph export "${outdir}/graphs/figure_B1.pdf", replace

restore

