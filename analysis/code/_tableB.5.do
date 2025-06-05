
*********************************************************************************************************
* Event Study for PE with Heterogeneity by Capacity and Distance to Police Stations (Robustness excluding SE state)
**********************************************************************************************************

* Load data
 use "$inpdir/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000
drop if state == "SE"

* Set seed for bootstrap
set seed 982638

* Create treatment year variable
gen treatment_year = 0
replace treatment_year = 2007 if state == "PE"
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"

* Create relative time to treatment variable
gen rel_year = year - treatment_year

gen log_pop = log(population_muni)

* Define ids for xtreg
xtset municipality_code year

* Create dummies for treatment cohorts
gen t2007 = (treatment_year == 2007)  // PE
gen t2011 = (treatment_year == 2011)  // BA, PB
gen t2015 = (treatment_year == 2015)  // CE
gen t2016 = (treatment_year == 2016)  // MA

* Create year dummies
forvalues y = 2000/2019 {
    gen d`y' = (year == `y')
}

* Prepare capacity variable by state (high_cap)
preserve
keep if year == 2006
drop if perc_superior == .

* Create a temporary table to store medians by state
tempfile state_medians_cap
tempname memhold
postfile `memhold' str2 state double median_perc_superior using `state_medians_cap'

* Calculate median of perc_superior for each state separately
levelsof state, local(states)
foreach s of local states {
    quietly sum perc_superior if state == "`s'", detail
    post `memhold' ("`s'") (r(p50))
}
postclose `memhold'

* Save only municipality and state for later use
keep municipality_code state
save "temp_muni_state.dta", replace
restore

* Merge with state medians table
merge m:1 state using `state_medians_cap', nogenerate
* Merge with municipality-state table
merge m:1 municipality_code using "temp_muni_state.dta", nogenerate
erase "temp_muni_state.dta"

* Now create high_cap variable based on each state's median
gen high_cap = (perc_superior > median_perc_superior) if perc_superior != .
drop median_perc_superior

* Prepare police station variable by state
* Create a temporary table to store distance medians by state
tempfile state_medians_del
tempname memhold_del
postfile `memhold_del' str2 state double median_dist_delegacia using `state_medians_del'

* Calculate median distance to police station for each state separately
levelsof state, local(states)
foreach s of local states {
    quietly sum distancia_delegacia_km if state == "`s'", detail
    post `memhold_del' ("`s'") (r(p50))
}
postclose `memhold_del'

* Merge with distance medians table by state
merge m:1 state using `state_medians_del', nogenerate

* Now create police station variable based on each state's median
gen delegacia = (distancia_delegacia_km > median_dist_delegacia)
drop median_dist_delegacia

* Drop observations with missing values
drop if high_cap == .
drop if population_2000_muni == .

* Create delcap variable with the 4 requested categories
gen delcap = 1 if high_cap == 0 & delegacia == 0
replace delcap = 2 if high_cap == 0 & delegacia == 1
replace delcap = 3 if high_cap == 1 & delegacia == 0
replace delcap = 4 if high_cap == 1 & delegacia == 1

* Create dummies for each delcap category
gen delcap1 = (delcap == 1)
gen delcap2 = (delcap == 2)
gen delcap3 = (delcap == 3)
gen delcap4 = (delcap == 4)

********************************************************************************
* Calculate mean homicide rate by delcap category for PE (2007)
********************************************************************************

* For PE (2007) - pre-treatment period: 2000-2006
preserve
    * Keep only PE cohort and pre-treatment period
    keep if t2007 == 1 & year >= 2000 & year <= 2006

    * Calculate mean for each delcap category
    * Category 1: low cap & low police station distance
    quietly summarize taxa_homicidios_total_por_100m_1 if delcap == 1 [aw = population_2000_muni], detail
    scalar mean_pre_2007_delcap1 = r(mean)
    display "Pre-treatment mean for PE (2007) - delcap1 (low cap & low police station distance): " mean_pre_2007_delcap1
    
    * Category 2: low cap & high police station distance
    quietly summarize taxa_homicidios_total_por_100m_1 if delcap == 2 [aw = population_2000_muni], detail
    scalar mean_pre_2007_delcap2 = r(mean)
    display "Pre-treatment mean for PE (2007) - delcap2 (low cap & high police station distance): " mean_pre_2007_delcap2
    
    * Category 3: high cap & low police station distance
    quietly summarize taxa_homicidios_total_por_100m_1 if delcap == 3 [aw = population_2000_muni], detail
    scalar mean_pre_2007_delcap3 = r(mean)
    display "Pre-treatment mean for PE (2007) - delcap3 (high cap & low police station distance): " mean_pre_2007_delcap3
    
    * Category 4: high cap & high police station distance
    quietly summarize taxa_homicidios_total_por_100m_1 if delcap == 4 [aw = population_2000_muni], detail
    scalar mean_pre_2007_delcap4 = r(mean)
    display "Pre-treatment mean for PE (2007) - delcap4 (high cap & high police station distance): " mean_pre_2007_delcap4

    * Optionally, display all in a matrix for comparison
    matrix mean_pre_2007_delcap = (mean_pre_2007_delcap1 \ mean_pre_2007_delcap2 \ mean_pre_2007_delcap3 \ mean_pre_2007_delcap4)
    matrix rownames mean_pre_2007_delcap = "Low cap & Low police dist" "Low cap & High police dist" "High cap & Low police dist" "High cap & High police dist"
    matrix colnames mean_pre_2007_delcap = "Pre-treatment mean"
    matrix list mean_pre_2007_delcap
	restore

******************************************************************************
* Create event dummies for PE (2007) interacted with the 4 categories
******************************************************************************

* For cohort 2007 (PE) - Category 1: low cap & close police station
* Pre-treatment: define up to t-7 with interactions
gen t_7_2007_cat1 = t2007 * d2000 * delcap1
gen t_6_2007_cat1 = t2007 * d2001 * delcap1
gen t_5_2007_cat1 = t2007 * d2002 * delcap1
gen t_4_2007_cat1 = t2007 * d2003 * delcap1
gen t_3_2007_cat1 = t2007 * d2004 * delcap1
gen t_2_2007_cat1 = t2007 * d2005 * delcap1
gen t_1_2007_cat1 = t2007 * d2006 * delcap1
* Omit treatment year (2007)
* Post-treatment
gen t1_2007_cat1 = t2007 * d2008 * delcap1
gen t2_2007_cat1 = t2007 * d2009 * delcap1
gen t3_2007_cat1 = t2007 * d2010 * delcap1
gen t4_2007_cat1 = t2007 * d2011 * delcap1
gen t5_2007_cat1 = t2007 * d2012 * delcap1
gen t6_2007_cat1 = t2007 * d2013 * delcap1
gen t7_2007_cat1 = t2007 * d2014 * delcap1
gen t8_2007_cat1 = t2007 * d2015 * delcap1
gen t9_2007_cat1 = t2007 * d2016 * delcap1
gen t10_2007_cat1 = t2007 * d2017 * delcap1
gen t11_2007_cat1 = t2007 * d2018 * delcap1
gen t12_2007_cat1 = t2007 * d2019 * delcap1

* For cohort 2007 (PE) - Category 2: low cap & far police station
* Pre-treatment
gen t_7_2007_cat2 = t2007 * d2000 * delcap2
gen t_6_2007_cat2 = t2007 * d2001 * delcap2
gen t_5_2007_cat2 = t2007 * d2002 * delcap2
gen t_4_2007_cat2 = t2007 * d2003 * delcap2
gen t_3_2007_cat2 = t2007 * d2004 * delcap2
gen t_2_2007_cat2 = t2007 * d2005 * delcap2
gen t_1_2007_cat2 = t2007 * d2006 * delcap2
* Omit treatment year (2007)
* Post-treatment
gen t1_2007_cat2 = t2007 * d2008 * delcap2
gen t2_2007_cat2 = t2007 * d2009 * delcap2
gen t3_2007_cat2 = t2007 * d2010 * delcap2
gen t4_2007_cat2 = t2007 * d2011 * delcap2
gen t5_2007_cat2 = t2007 * d2012 * delcap2
gen t6_2007_cat2 = t2007 * d2013 * delcap2
gen t7_2007_cat2 = t2007 * d2014 * delcap2
gen t8_2007_cat2 = t2007 * d2015 * delcap2
gen t9_2007_cat2 = t2007 * d2016 * delcap2
gen t10_2007_cat2 = t2007 * d2017 * delcap2
gen t11_2007_cat2 = t2007 * d2018 * delcap2
gen t12_2007_cat2 = t2007 * d2019 * delcap2

* For cohort 2007 (PE) - Category 3: high cap & close police station
* Pre-treatment
gen t_7_2007_cat3 = t2007 * d2000 * delcap3
gen t_6_2007_cat3 = t2007 * d2001 * delcap3
gen t_5_2007_cat3 = t2007 * d2002 * delcap3
gen t_4_2007_cat3 = t2007 * d2003 * delcap3
gen t_3_2007_cat3 = t2007 * d2004 * delcap3
gen t_2_2007_cat3 = t2007 * d2005 * delcap3
gen t_1_2007_cat3 = t2007 * d2006 * delcap3
* Omit treatment year (2007)
* Post-treatment
gen t1_2007_cat3 = t2007 * d2008 * delcap3
gen t2_2007_cat3 = t2007 * d2009 * delcap3
gen t3_2007_cat3 = t2007 * d2010 * delcap3
gen t4_2007_cat3 = t2007 * d2011 * delcap3
gen t5_2007_cat3 = t2007 * d2012 * delcap3
gen t6_2007_cat3 = t2007 * d2013 * delcap3
gen t7_2007_cat3 = t2007 * d2014 * delcap3
gen t8_2007_cat3 = t2007 * d2015 * delcap3
gen t9_2007_cat3 = t2007 * d2016 * delcap3
gen t10_2007_cat3 = t2007 * d2017 * delcap3
gen t11_2007_cat3 = t2007 * d2018 * delcap3
gen t12_2007_cat3 = t2007 * d2019 * delcap3

* For cohort 2007 (PE) - Category 4: high cap & far police station
* Pre-treatment
gen t_7_2007_cat4 = t2007 * d2000 * delcap4
gen t_6_2007_cat4 = t2007 * d2001 * delcap4
gen t_5_2007_cat4 = t2007 * d2002 * delcap4
gen t_4_2007_cat4 = t2007 * d2003 * delcap4
gen t_3_2007_cat4 = t2007 * d2004 * delcap4
gen t_2_2007_cat4 = t2007 * d2005 * delcap4
gen t_1_2007_cat4 = t2007 * d2006 * delcap4
* Omit treatment year (2007)
* Post-treatment
gen t1_2007_cat4 = t2007 * d2008 * delcap4
gen t2_2007_cat4 = t2007 * d2009 * delcap4
gen t3_2007_cat4 = t2007 * d2010 * delcap4
gen t4_2007_cat4 = t2007 * d2011 * delcap4
gen t5_2007_cat4 = t2007 * d2012 * delcap4
gen t6_2007_cat4 = t2007 * d2013 * delcap4
gen t7_2007_cat4 = t2007 * d2014 * delcap4
gen t8_2007_cat4 = t2007 * d2015 * delcap4
gen t9_2007_cat4 = t2007 * d2016 * delcap4
gen t10_2007_cat4 = t2007 * d2017 * delcap4
gen t11_2007_cat4 = t2007 * d2018 * delcap4
gen t12_2007_cat4 = t2007 * d2019 * delcap4

******************************************************************************
* Create event dummies for BA/PB (2011) interacted with the 4 categories
******************************************************************************

* For cohort 2011 (BA, PB) - Category 1: low cap & close police station
* Pre-treatment
gen t_11_2011_cat1 = t2011 * d2000 * delcap1
gen t_10_2011_cat1 = t2011 * d2001 * delcap1
gen t_9_2011_cat1 = t2011 * d2002 * delcap1
gen t_8_2011_cat1 = t2011 * d2003 * delcap1
gen t_7_2011_cat1 = t2011 * d2004 * delcap1
gen t_6_2011_cat1 = t2011 * d2005 * delcap1
gen t_5_2011_cat1 = t2011 * d2006 * delcap1
gen t_4_2011_cat1 = t2011 * d2007 * delcap1
gen t_3_2011_cat1 = t2011 * d2008 * delcap1
gen t_2_2011_cat1 = t2011 * d2009 * delcap1
gen t_1_2011_cat1 = t2011 * d2010 * delcap1
* Omit treatment year (2011)
* Post-treatment
gen t1_2011_cat1 = t2011 * d2012 * delcap1
gen t2_2011_cat1 = t2011 * d2013 * delcap1
gen t3_2011_cat1 = t2011 * d2014 * delcap1
gen t4_2011_cat1 = t2011 * d2015 * delcap1
gen t5_2011_cat1 = t2011 * d2016 * delcap1
gen t6_2011_cat1 = t2011 * d2017 * delcap1
gen t7_2011_cat1 = t2011 * d2018 * delcap1
gen t8_2011_cat1 = t2011 * d2019 * delcap1

* For cohort 2011 (BA, PB) - Category 2: low cap & far police station
* Pre-treatment
gen t_11_2011_cat2 = t2011 * d2000 * delcap2
gen t_10_2011_cat2 = t2011 * d2001 * delcap2
gen t_9_2011_cat2 = t2011 * d2002 * delcap2
gen t_8_2011_cat2 = t2011 * d2003 * delcap2
gen t_7_2011_cat2 = t2011 * d2004 * delcap2
gen t_6_2011_cat2 = t2011 * d2005 * delcap2
gen t_5_2011_cat2 = t2011 * d2006 * delcap2
gen t_4_2011_cat2 = t2011 * d2007 * delcap2
gen t_3_2011_cat2 = t2011 * d2008 * delcap2
gen t_2_2011_cat2 = t2011 * d2009 * delcap2
gen t_1_2011_cat2 = t2011 * d2010 * delcap2
* Omit treatment year (2011)
* Post-treatment
gen t1_2011_cat2 = t2011 * d2012 * delcap2
gen t2_2011_cat2 = t2011 * d2013 * delcap2
gen t3_2011_cat2 = t2011 * d2014 * delcap2
gen t4_2011_cat2 = t2011 * d2015 * delcap2
gen t5_2011_cat2 = t2011 * d2016 * delcap2
gen t6_2011_cat2 = t2011 * d2017 * delcap2
gen t7_2011_cat2 = t2011 * d2018 * delcap2
gen t8_2011_cat2 = t2011 * d2019 * delcap2

* For cohort 2011 (BA, PB) - Category 3: high cap & close police station
* Pre-treatment
gen t_11_2011_cat3 = t2011 * d2000 * delcap3
gen t_10_2011_cat3 = t2011 * d2001 * delcap3
gen t_9_2011_cat3 = t2011 * d2002 * delcap3
gen t_8_2011_cat3 = t2011 * d2003 * delcap3
gen t_7_2011_cat3 = t2011 * d2004 * delcap3
gen t_6_2011_cat3 = t2011 * d2005 * delcap3
gen t_5_2011_cat3 = t2011 * d2006 * delcap3
gen t_4_2011_cat3 = t2011 * d2007 * delcap3
gen t_3_2011_cat3 = t2011 * d2008 * delcap3
gen t_2_2011_cat3 = t2011 * d2009 * delcap3
gen t_1_2011_cat3 = t2011 * d2010 * delcap3
* Omit treatment year (2011)
* Post-treatment
gen t1_2011_cat3 = t2011 * d2012 * delcap3
gen t2_2011_cat3 = t2011 * d2013 * delcap3
gen t3_2011_cat3 = t2011 * d2014 * delcap3
gen t4_2011_cat3 = t2011 * d2015 * delcap3
gen t5_2011_cat3 = t2011 * d2016 * delcap3
gen t6_2011_cat3 = t2011 * d2017 * delcap3
gen t7_2011_cat3 = t2011 * d2018 * delcap3
gen t8_2011_cat3 = t2011 * d2019 * delcap3

* For cohort 2011 (BA, PB) - Category 4: high cap & far police station
* Pre-treatment
gen t_11_2011_cat4 = t2011 * d2000 * delcap4
gen t_10_2011_cat4 = t2011 * d2001 * delcap4
gen t_9_2011_cat4 = t2011 * d2002 * delcap4
gen t_8_2011_cat4 = t2011 * d2003 * delcap4
gen t_7_2011_cat4 = t2011 * d2004 * delcap4
gen t_6_2011_cat4 = t2011 * d2005 * delcap4
gen t_5_2011_cat4 = t2011 * d2006 * delcap4
gen t_4_2011_cat4 = t2011 * d2007 * delcap4
gen t_3_2011_cat4 = t2011 * d2008 * delcap4
gen t_2_2011_cat4 = t2011 * d2009 * delcap4
gen t_1_2011_cat4 = t2011 * d2010 * delcap4
* Omit treatment year (2011)
* Post-treatment
gen t1_2011_cat4 = t2011 * d2012 * delcap4
gen t2_2011_cat4 = t2011 * d2013 * delcap4
gen t3_2011_cat4 = t2011 * d2014 * delcap4
gen t4_2011_cat4 = t2011 * d2015 * delcap4
gen t5_2011_cat4 = t2011 * d2016 * delcap4
gen t6_2011_cat4 = t2011 * d2017 * delcap4
gen t7_2011_cat4 = t2011 * d2018 * delcap4
gen t8_2011_cat4 = t2011 * d2019 * delcap4

******************************************************************************
* Create event dummies for CE (2015) interacted with the 4 categories
******************************************************************************

* For cohort 2015 (CE) - Category 1: low cap & close police station
* Pre-treatment
gen t_15_2015_cat1 = t2015 * d2000 * delcap1
gen t_14_2015_cat1 = t2015 * d2001 * delcap1
gen t_13_2015_cat1 = t2015 * d2002 * delcap1
gen t_12_2015_cat1 = t2015 * d2003 * delcap1
gen t_11_2015_cat1 = t2015 * d2004 * delcap1
gen t_10_2015_cat1 = t2015 * d2005 * delcap1
gen t_9_2015_cat1 = t2015 * d2006 * delcap1
gen t_8_2015_cat1 = t2015 * d2007 * delcap1
gen t_7_2015_cat1 = t2015 * d2008 * delcap1
gen t_6_2015_cat1 = t2015 * d2009 * delcap1
gen t_5_2015_cat1 = t2015 * d2010 * delcap1
gen t_4_2015_cat1 = t2015 * d2011 * delcap1
gen t_3_2015_cat1 = t2015 * d2012 * delcap1
gen t_2_2015_cat1 = t2015 * d2013 * delcap1
gen t_1_2015_cat1 = t2015 * d2014 * delcap1
* Omit treatment year (2015)
* Post-treatment
gen t1_2015_cat1 = t2015 * d2016 * delcap1
gen t2_2015_cat1 = t2015 * d2017 * delcap1
gen t3_2015_cat1 = t2015 * d2018 * delcap1
gen t4_2015_cat1 = t2015 * d2019 * delcap1

* For cohort 2015 (CE) - Category 2: low cap & far police station
* Pre-treatment
gen t_15_2015_cat2 = t2015 * d2000 * delcap2
gen t_14_2015_cat2 = t2015 * d2001 * delcap2
gen t_13_2015_cat2 = t2015 * d2002 * delcap2
gen t_12_2015_cat2 = t2015 * d2003 * delcap2
gen t_11_2015_cat2 = t2015 * d2004 * delcap2
gen t_10_2015_cat2 = t2015 * d2005 * delcap2
gen t_9_2015_cat2 = t2015 * d2006 * delcap2
gen t_8_2015_cat2 = t2015 * d2007 * delcap2
gen t_7_2015_cat2 = t2015 * d2008 * delcap2
gen t_6_2015_cat2 = t2015 * d2009 * delcap2
gen t_5_2015_cat2 = t2015 * d2010 * delcap2
gen t_4_2015_cat2 = t2015 * d2011 * delcap2
gen t_3_2015_cat2 = t2015 * d2012 * delcap2
gen t_2_2015_cat2 = t2015 * d2013 * delcap2
gen t_1_2015_cat2 = t2015 * d2014 * delcap2
* Omit treatment year (2015)
* Post-treatment
gen t1_2015_cat2 = t2015 * d2016 * delcap2
gen t2_2015_cat2 = t2015 * d2017 * delcap2
gen t3_2015_cat2 = t2015 * d2018 * delcap2
gen t4_2015_cat2 = t2015 * d2019 * delcap2

* For cohort 2015 (CE) - Category 3: high cap & close police station
* Pre-treatment
gen t_15_2015_cat3 = t2015 * d2000 * delcap3
gen t_14_2015_cat3 = t2015 * d2001 * delcap3
gen t_13_2015_cat3 = t2015 * d2002 * delcap3
gen t_12_2015_cat3 = t2015 * d2003 * delcap3
gen t_11_2015_cat3 = t2015 * d2004 * delcap3
gen t_10_2015_cat3 = t2015 * d2005 * delcap3
gen t_9_2015_cat3 = t2015 * d2006 * delcap3
gen t_8_2015_cat3 = t2015 * d2007 * delcap3
gen t_7_2015_cat3 = t2015 * d2008 * delcap3
gen t_6_2015_cat3 = t2015 * d2009 * delcap3
gen t_5_2015_cat3 = t2015 * d2010 * delcap3
gen t_4_2015_cat3 = t2015 * d2011 * delcap3
gen t_3_2015_cat3 = t2015 * d2012 * delcap3
gen t_2_2015_cat3 = t2015 * d2013 * delcap3
gen t_1_2015_cat3 = t2015 * d2014 * delcap3
* Omit treatment year (2015)
* Post-treatment
gen t1_2015_cat3 = t2015 * d2016 * delcap3
gen t2_2015_cat3 = t2015 * d2017 * delcap3
gen t3_2015_cat3 = t2015 * d2018 * delcap3
gen t4_2015_cat3 = t2015 * d2019 * delcap3

* For cohort 2015 (CE) - Category 4: high cap & far police station
* Pre-treatment
gen t_15_2015_cat4 = t2015 * d2000 * delcap4
gen t_14_2015_cat4 = t2015 * d2001 * delcap4
gen t_13_2015_cat4 = t2015 * d2002 * delcap4
gen t_12_2015_cat4 = t2015 * d2003 * delcap4
gen t_11_2015_cat4 = t2015 * d2004 * delcap4
gen t_10_2015_cat4 = t2015 * d2005 * delcap4
gen t_9_2015_cat4 = t2015 * d2006 * delcap4
gen t_8_2015_cat4 = t2015 * d2007 * delcap4
gen t_7_2015_cat4 = t2015 * d2008 * delcap4
gen t_6_2015_cat4 = t2015 * d2009 * delcap4
gen t_5_2015_cat4 = t2015 * d2010 * delcap4
gen t_4_2015_cat4 = t2015 * d2011 * delcap4
gen t_3_2015_cat4 = t2015 * d2012 * delcap4
gen t_2_2015_cat4 = t2015 * d2013 * delcap4
gen t_1_2015_cat4 = t2015 * d2014 * delcap4
* Omit treatment year (2015)
* Post-treatment
gen t1_2015_cat4 = t2015 * d2016 * delcap4
gen t2_2015_cat4 = t2015 * d2017 * delcap4
gen t3_2015_cat4 = t2015 * d2018 * delcap4
gen t4_2015_cat4 = t2015 * d2019 * delcap4

******************************************************************************
* Create event dummies for MA (2016) interacted with the 4 categories
******************************************************************************

* For cohort 2016 (MA) - Category 1: low cap & close police station
* Pre-treatment
gen t_16_2016_cat1 = t2016 * d2000 * delcap1
gen t_15_2016_cat1 = t2016 * d2001 * delcap1
gen t_14_2016_cat1 = t2016 * d2002 * delcap1
gen t_13_2016_cat1 = t2016 * d2003 * delcap1
gen t_12_2016_cat1 = t2016 * d2004 * delcap1
gen t_11_2016_cat1 = t2016 * d2005 * delcap1
gen t_10_2016_cat1 = t2016 * d2006 * delcap1
gen t_9_2016_cat1 = t2016 * d2007 * delcap1
gen t_8_2016_cat1 = t2016 * d2008 * delcap1
gen t_7_2016_cat1 = t2016 * d2009 * delcap1
gen t_6_2016_cat1 = t2016 * d2010 * delcap1
gen t_5_2016_cat1 = t2016 * d2011 * delcap1
gen t_4_2016_cat1 = t2016 * d2012 * delcap1
gen t_3_2016_cat1 = t2016 * d2013 * delcap1
gen t_2_2016_cat1 = t2016 * d2014 * delcap1
gen t_1_2016_cat1 = t2016 * d2015 * delcap1
* Omit treatment year (2016)
* Post-treatment
gen t1_2016_cat1 = t2016 * d2017 * delcap1
gen t2_2016_cat1 = t2016 * d2018 * delcap1
gen t3_2016_cat1 = t2016 * d2019 * delcap1

* For cohort 2016 (MA) - Category 2: low cap & far police station
* Pre-treatment
gen t_16_2016_cat2 = t2016 * d2000 * delcap2
gen t_15_2016_cat2 = t2016 * d2001 * delcap2
gen t_14_2016_cat2 = t2016 * d2002 * delcap2
gen t_13_2016_cat2 = t2016 * d2003 * delcap2
gen t_12_2016_cat2 = t2016 * d2004 * delcap2
gen t_11_2016_cat2 = t2016 * d2005 * delcap2
gen t_10_2016_cat2 = t2016 * d2006 * delcap2
gen t_9_2016_cat2 = t2016 * d2007 * delcap2
gen t_8_2016_cat2 = t2016 * d2008 * delcap2
gen t_7_2016_cat2 = t2016 * d2009 * delcap2
gen t_6_2016_cat2 = t2016 * d2010 * delcap2
gen t_5_2016_cat2 = t2016 * d2011 * delcap2
gen t_4_2016_cat2 = t2016 * d2012 * delcap2
gen t_3_2016_cat2 = t2016 * d2013 * delcap2
gen t_2_2016_cat2 = t2016 * d2014 * delcap2
gen t_1_2016_cat2 = t2016 * d2015 * delcap2
* Omit treatment year (2016)
* Post-treatment
gen t1_2016_cat2 = t2016 * d2017 * delcap2
gen t2_2016_cat2 = t2016 * d2018 * delcap2
gen t3_2016_cat2 = t2016 * d2019 * delcap2

* For cohort 2016 (MA) - Category 3: high cap & close police station
* Pre-treatment
gen t_16_2016_cat3 = t2016 * d2000 * delcap3
gen t_15_2016_cat3 = t2016 * d2001 * delcap3
gen t_14_2016_cat3 = t2016 * d2002 * delcap3
gen t_13_2016_cat3 = t2016 * d2003 * delcap3
gen t_12_2016_cat3 = t2016 * d2004 * delcap3
gen t_11_2016_cat3 = t2016 * d2005 * delcap3
gen t_10_2016_cat3 = t2016 * d2006 * delcap3
gen t_9_2016_cat3 = t2016 * d2007 * delcap3
gen t_8_2016_cat3 = t2016 * d2008 * delcap3
gen t_7_2016_cat3 = t2016 * d2009 * delcap3
gen t_6_2016_cat3 = t2016 * d2010 * delcap3
gen t_5_2016_cat3 = t2016 * d2011 * delcap3
gen t_4_2016_cat3 = t2016 * d2012 * delcap3
gen t_3_2016_cat3 = t2016 * d2013 * delcap3
gen t_2_2016_cat3 = t2016 * d2014 * delcap3
gen t_1_2016_cat3 = t2016 * d2015 * delcap3
* Omit treatment year (2016)
* Post-treatment
gen t1_2016_cat3 = t2016 * d2017 * delcap3
gen t2_2016_cat3 = t2016 * d2018 * delcap3
gen t3_2016_cat3 = t2016 * d2019 * delcap3

* For cohort 2016 (MA) - Category 4: high cap & far police station
* Pre-treatment
gen t_16_2016_cat4 = t2016 * d2000 * delcap4
gen t_15_2016_cat4 = t2016 * d2001 * delcap4
gen t_14_2016_cat4 = t2016 * d2002 * delcap4
gen t_13_2016_cat4 = t2016 * d2003 * delcap4
gen t_12_2016_cat4 = t2016 * d2004 * delcap4
gen t_11_2016_cat4 = t2016 * d2005 * delcap4
gen t_10_2016_cat4 = t2016 * d2006 * delcap4
gen t_9_2016_cat4 = t2016 * d2007 * delcap4
gen t_8_2016_cat4 = t2016 * d2008 * delcap4
gen t_7_2016_cat4 = t2016 * d2009 * delcap4
gen t_6_2016_cat4 = t2016 * d2010 * delcap4
gen t_5_2016_cat4 = t2016 * d2011 * delcap4
gen t_4_2016_cat4 = t2016 * d2012 * delcap4
gen t_3_2016_cat4 = t2016 * d2013 * delcap4
gen t_2_2016_cat4 = t2016 * d2014 * delcap4
gen t_1_2016_cat4 = t2016 * d2015 * delcap4
* Omit treatment year (2016)
* Post-treatment
gen t1_2016_cat4 = t2016 * d2017 * delcap4
gen t2_2016_cat4 = t2016 * d2018 * delcap4
gen t3_2016_cat4 = t2016 * d2019 * delcap4

********************************************************************************
* Part 1: Event Study in a Single Regression with the 4 Categories
********************************************************************************

* Model with all variables and interactions with the 4 categories for PE, BA/PB, CE and MA
xtreg taxa_homicidios_total_por_100m_1 ///
    t_7_2007_cat1 t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1 ///
    t1_2007_cat1 t2_2007_cat1 t3_2007_cat1 t4_2007_cat1 t5_2007_cat1 t6_2007_cat1 t7_2007_cat1 t8_2007_cat1 t9_2007_cat1 t10_2007_cat1 t11_2007_cat1 t12_2007_cat1 ///
    t_7_2007_cat2 t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2 ///
    t1_2007_cat2 t2_2007_cat2 t3_2007_cat2 t4_2007_cat2 t5_2007_cat2 t6_2007_cat2 t7_2007_cat2 t8_2007_cat2 t9_2007_cat2 t10_2007_cat2 t11_2007_cat2 t12_2007_cat2 ///
    t_7_2007_cat3 t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3 ///
    t1_2007_cat3 t2_2007_cat3 t3_2007_cat3 t4_2007_cat3 t5_2007_cat3 t6_2007_cat3 t7_2007_cat3 t8_2007_cat3 t9_2007_cat3 t10_2007_cat3 t11_2007_cat3 t12_2007_cat3 ///
    t_7_2007_cat4 t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4 ///
    t1_2007_cat4 t2_2007_cat4 t3_2007_cat4 t4_2007_cat4 t5_2007_cat4 t6_2007_cat4 t7_2007_cat4 t8_2007_cat4 t9_2007_cat4 t10_2007_cat4 t11_2007_cat4 t12_2007_cat4 ///
     t_7_2011_cat1 t_6_2011_cat1 t_5_2011_cat1 t_4_2011_cat1 t_3_2011_cat1 t_2_2011_cat1 t_1_2011_cat1 ///
    t1_2011_cat1 t2_2011_cat1 t3_2011_cat1 t4_2011_cat1 t5_2011_cat1 t6_2011_cat1 t7_2011_cat1 t8_2011_cat1 ///
     t_7_2011_cat2 t_6_2011_cat2 t_5_2011_cat2 t_4_2011_cat2 t_3_2011_cat2 t_2_2011_cat2 t_1_2011_cat2 ///
    t1_2011_cat2 t2_2011_cat2 t3_2011_cat2 t4_2011_cat2 t5_2011_cat2 t6_2011_cat2 t7_2011_cat2 t8_2011_cat2 ///
     t_7_2011_cat3 t_6_2011_cat3 t_5_2011_cat3 t_4_2011_cat3 t_3_2011_cat3 t_2_2011_cat3 t_1_2011_cat3 ///
    t1_2011_cat3 t2_2011_cat3 t3_2011_cat3 t4_2011_cat3 t5_2011_cat3 t6_2011_cat3 t7_2011_cat3 t8_2011_cat3 ///
    t_7_2011_cat4 t_6_2011_cat4 t_5_2011_cat4 t_4_2011_cat4 t_3_2011_cat4 t_2_2011_cat4 t_1_2011_cat4 ///
    t1_2011_cat4 t2_2011_cat4 t3_2011_cat4 t4_2011_cat4 t5_2011_cat4 t6_2011_cat4 t7_2011_cat4 t8_2011_cat4 ///
     t_7_2015_cat1 t_6_2015_cat1 t_5_2015_cat1 t_4_2015_cat1 t_3_2015_cat1 t_2_2015_cat1 t_1_2015_cat1 ///
    t1_2015_cat1 t2_2015_cat1 t3_2015_cat1 t4_2015_cat1 ///
     t_7_2015_cat2 t_6_2015_cat2 t_5_2015_cat2 t_4_2015_cat2 t_3_2015_cat2 t_2_2015_cat2 t_1_2015_cat2 ///
    t1_2015_cat2 t2_2015_cat2 t3_2015_cat2 t4_2015_cat2 ///
     t_7_2015_cat3 t_6_2015_cat3 t_5_2015_cat3 t_4_2015_cat3 t_3_2015_cat3 t_2_2015_cat3 t_1_2015_cat3 ///
    t1_2015_cat3 t2_2015_cat3 t3_2015_cat3 t4_2015_cat3 ///
     t_7_2015_cat4 t_6_2015_cat4 t_5_2015_cat4 t_4_2015_cat4 t_3_2015_cat4 t_2_2015_cat4 t_1_2015_cat4 ///
    t1_2015_cat4 t2_2015_cat4 t3_2015_cat4 t4_2015_cat4 ///
    t_7_2016_cat1 t_6_2016_cat1 t_5_2016_cat1 t_4_2016_cat1 t_3_2016_cat1 t_2_2016_cat1 t_1_2016_cat1 ///
    t1_2016_cat1 t2_2016_cat1 t3_2016_cat1 ///
     t_7_2016_cat2 t_6_2016_cat2 t_5_2016_cat2 t_4_2016_cat2 t_3_2016_cat2 t_2_2016_cat2 t_1_2016_cat2 ///
    t1_2016_cat2 t2_2016_cat2 t3_2016_cat2 ///
     t_7_2016_cat3 t_6_2016_cat3 t_5_2016_cat3 t_4_2016_cat3 t_3_2016_cat3 t_2_2016_cat3 t_1_2016_cat3 ///
    t1_2016_cat3 t2_2016_cat3 t3_2016_cat3 ///
     t_7_2016_cat4 t_6_2016_cat4 t_5_2016_cat4 t_4_2016_cat4 t_3_2016_cat4 t_2_2016_cat4 t_1_2016_cat4 ///
    t1_2016_cat4 t2_2016_cat4 t3_2016_cat4 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)
	
* Save number of observations
sca nobs = e(N)

* Save complete coefficients
matrix betas = e(b)

* Extract coefficients for each category
* For PE (2007) Category 1: low cap & close police station
matrix betas2007_cat1 = betas[1, 1..19], .
* For PE (2007) Category 2: low cap & far police station
matrix betas2007_cat2 = betas[1, 20..38], ., .
* For PE (2007) Category 3: high cap & close police station
matrix betas2007_cat3 = betas[1, 39..57], ., ., .
* For PE (2007) Category 4: high cap & far police station
matrix betas2007_cat4 = betas[1, 58..76], ., ., ., .

* Extract standard errors
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* For PE (2007) Category 1
matrix vars2007_cat1 = A[1, 1..19], .
* For PE (2007) Category 2
matrix vars2007_cat2 = A[1, 20..38], ., .
* For PE (2007) Category 3
matrix vars2007_cat3 = A[1, 39..57], ., ., .
* For PE (2007) Category 4
matrix vars2007_cat4 = A[1, 58..76], ., ., ., .

* Calculate p-values using boottest with Webb weights
boottest {t_7_2007_cat1} {t_6_2007_cat1} {t_5_2007_cat1} {t_4_2007_cat1} {t_3_2007_cat1} {t_2_2007_cat1} {t_1_2007_cat1} ///
        {t1_2007_cat1} {t2_2007_cat1} {t3_2007_cat1} {t4_2007_cat1} {t5_2007_cat1} {t6_2007_cat1} {t7_2007_cat1} {t8_2007_cat1} {t9_2007_cat1} {t10_2007_cat1} {t11_2007_cat1} {t12_2007_cat1} ///
        {t_7_2007_cat2} {t_6_2007_cat2} {t_5_2007_cat2} {t_4_2007_cat2} {t_3_2007_cat2} {t_2_2007_cat2} {t_1_2007_cat2} ///
        {t1_2007_cat2} {t2_2007_cat2} {t3_2007_cat2} {t4_2007_cat2} {t5_2007_cat2} {t6_2007_cat2} {t7_2007_cat2} {t8_2007_cat2} {t9_2007_cat2} {t10_2007_cat2} {t11_2007_cat2} {t12_2007_cat2} ///
        {t_7_2007_cat3} {t_6_2007_cat3} {t_5_2007_cat3} {t_4_2007_cat3} {t_3_2007_cat3} {t_2_2007_cat3} {t_1_2007_cat3} ///
        {t1_2007_cat3} {t2_2007_cat3} {t3_2007_cat3} {t4_2007_cat3} {t5_2007_cat3} {t6_2007_cat3} {t7_2007_cat3} {t8_2007_cat3} {t9_2007_cat3} {t10_2007_cat3} {t11_2007_cat3} {t12_2007_cat3} ///
        {t_7_2007_cat4} {t_6_2007_cat4} {t_5_2007_cat4} {t_4_2007_cat4} {t_3_2007_cat4} {t_2_2007_cat4} {t_1_2007_cat4} ///
        {t1_2007_cat4} {t2_2007_cat4} {t3_2007_cat4} {t4_2007_cat4} {t5_2007_cat4} {t6_2007_cat4} {t7_2007_cat4} {t8_2007_cat4} {t9_2007_cat4} {t10_2007_cat4} {t11_2007_cat4} {t12_2007_cat4}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)

* Store p-values for each category
* For PE (2007) Category 1
matrix pvalue2007_cat1 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19), .

* For PE (2007) Category 2
matrix pvalue2007_cat2 = r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), r(p_26), ///
                  r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), r(p_38), ., .

* For PE (2007) Category 3
matrix pvalue2007_cat3 = r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), r(p_45), ///
                   r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), r(p_54), r(p_55), r(p_56), r(p_57), ., ., .

* For PE (2007) Category 4
matrix pvalue2007_cat4 = r(p_58), r(p_59), r(p_60), r(p_61), r(p_62), r(p_63), r(p_64), ///
                  r(p_65), r(p_66), r(p_67), r(p_68), r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75), r(p_76), ., ., ., .


********************************************************************************
* Create category-specific trends for all treated states
********************************************************************************
gen trend = year - 2000

* Create specific trends for each category of PE (2007)
gen partrend2007_cat1 = trend * t2007 * delcap1
gen partrend2007_cat2 = trend * t2007 * delcap2
gen partrend2007_cat3 = trend * t2007 * delcap3
gen partrend2007_cat4 = trend * t2007 * delcap4

* Create specific trends for each category of BA/PB (2011)
gen partrend2011_cat1 = trend * t2011 * delcap1
gen partrend2011_cat2 = trend * t2011 * delcap2
gen partrend2011_cat3 = trend * t2011 * delcap3
gen partrend2011_cat4 = trend * t2011 * delcap4

* Create specific trends for each category of CE (2015)
gen partrend2015_cat1 = trend * t2015 * delcap1
gen partrend2015_cat2 = trend * t2015 * delcap2
gen partrend2015_cat3 = trend * t2015 * delcap3
gen partrend2015_cat4 = trend * t2015 * delcap4

* Create specific trends for each category of MA (2016)
gen partrend2016_cat1 = trend * t2016 * delcap1
gen partrend2016_cat2 = trend * t2016 * delcap2
gen partrend2016_cat3 = trend * t2016 * delcap3
gen partrend2016_cat4 = trend * t2016 * delcap4

********************************************************************************
* Part 2: Event Study with Linear Category-Specific Trends for All States
********************************************************************************

* IMPORTANT: Omitting t_7_2007, t_11_2011, t_15_2015, t_16_2016 for each category
xtreg taxa_homicidios_total_por_100m_1 ///
    t_6_2007_cat1 t_5_2007_cat1 t_4_2007_cat1 t_3_2007_cat1 t_2_2007_cat1 t_1_2007_cat1 ///
    t1_2007_cat1 t2_2007_cat1 t3_2007_cat1 t4_2007_cat1 t5_2007_cat1 t6_2007_cat1 t7_2007_cat1 t8_2007_cat1 t9_2007_cat1 t10_2007_cat1 t11_2007_cat1 t12_2007_cat1 ///
    partrend2007_cat1 ///
    t_6_2007_cat2 t_5_2007_cat2 t_4_2007_cat2 t_3_2007_cat2 t_2_2007_cat2 t_1_2007_cat2 ///
    t1_2007_cat2 t2_2007_cat2 t3_2007_cat2 t4_2007_cat2 t5_2007_cat2 t6_2007_cat2 t7_2007_cat2 t8_2007_cat2 t9_2007_cat2 t10_2007_cat2 t11_2007_cat2 t12_2007_cat2 ///
    partrend2007_cat2 ///
    t_6_2007_cat3 t_5_2007_cat3 t_4_2007_cat3 t_3_2007_cat3 t_2_2007_cat3 t_1_2007_cat3 ///
    t1_2007_cat3 t2_2007_cat3 t3_2007_cat3 t4_2007_cat3 t5_2007_cat3 t6_2007_cat3 t7_2007_cat3 t8_2007_cat3 t9_2007_cat3 t10_2007_cat3 t11_2007_cat3 t12_2007_cat3 ///
    partrend2007_cat3 ///
    t_6_2007_cat4 t_5_2007_cat4 t_4_2007_cat4 t_3_2007_cat4 t_2_2007_cat4 t_1_2007_cat4 ///
    t1_2007_cat4 t2_2007_cat4 t3_2007_cat4 t4_2007_cat4 t5_2007_cat4 t6_2007_cat4 t7_2007_cat4 t8_2007_cat4 t9_2007_cat4 t10_2007_cat4 t11_2007_cat4 t12_2007_cat4 ///
    partrend2007_cat4 ///
    t_6_2011_cat1 t_5_2011_cat1 t_4_2011_cat1 t_3_2011_cat1 t_2_2011_cat1 t_1_2011_cat1 ///
    t1_2011_cat1 t2_2011_cat1 t3_2011_cat1 t4_2011_cat1 t5_2011_cat1 t6_2011_cat1 t7_2011_cat1 t8_2011_cat1 ///
    partrend2011_cat1 ///
    t_6_2011_cat2 t_5_2011_cat2 t_4_2011_cat2 t_3_2011_cat2 t_2_2011_cat2 t_1_2011_cat2 ///
    t1_2011_cat2 t2_2011_cat2 t3_2011_cat2 t4_2011_cat2 t5_2011_cat2 t6_2011_cat2 t7_2011_cat2 t8_2011_cat2 ///
    partrend2011_cat2 ///
    t_6_2011_cat3 t_5_2011_cat3 t_4_2011_cat3 t_3_2011_cat3 t_2_2011_cat3 t_1_2011_cat3 ///
    t1_2011_cat3 t2_2011_cat3 t3_2011_cat3 t4_2011_cat3 t5_2011_cat3 t6_2011_cat3 t7_2011_cat3 t8_2011_cat3 ///
    partrend2011_cat3 ///
    t_6_2011_cat4 t_5_2011_cat4 t_4_2011_cat4 t_3_2011_cat4 t_2_2011_cat4 t_1_2011_cat4 ///
    t1_2011_cat4 t2_2011_cat4 t3_2011_cat4 t4_2011_cat4 t5_2011_cat4 t6_2011_cat4 t7_2011_cat4 t8_2011_cat4 ///
    partrend2011_cat4 ///
    t_6_2015_cat1 t_5_2015_cat1 t_4_2015_cat1 t_3_2015_cat1 t_2_2015_cat1 t_1_2015_cat1 ///
    t1_2015_cat1 t2_2015_cat1 t3_2015_cat1 t4_2015_cat1 ///
    partrend2015_cat1 ///
    t_6_2015_cat2 t_5_2015_cat2 t_4_2015_cat2 t_3_2015_cat2 t_2_2015_cat2 t_1_2015_cat2 ///
    t1_2015_cat2 t2_2015_cat2 t3_2015_cat2 t4_2015_cat2 ///
    partrend2015_cat2 ///
    t_6_2015_cat3 t_5_2015_cat3 t_4_2015_cat3 t_3_2015_cat3 t_2_2015_cat3 t_1_2015_cat3 ///
    t1_2015_cat3 t2_2015_cat3 t3_2015_cat3 t4_2015_cat3 ///
    partrend2015_cat3 ///
    t_6_2015_cat4 t_5_2015_cat4 t_4_2015_cat4 t_3_2015_cat4 t_2_2015_cat4 t_1_2015_cat4 ///
    t1_2015_cat4 t2_2015_cat4 t3_2015_cat4 t4_2015_cat4 ///
    partrend2015_cat4 ///
    t_6_2016_cat1 t_5_2016_cat1 t_4_2016_cat1 t_3_2016_cat1 t_2_2016_cat1 t_1_2016_cat1 ///
    t1_2016_cat1 t2_2016_cat1 t3_2016_cat1 ///
    partrend2016_cat1 ///
    t_6_2016_cat2 t_5_2016_cat2 t_4_2016_cat2 t_3_2016_cat2 t_2_2016_cat2 t_1_2016_cat2 ///
    t1_2016_cat2 t2_2016_cat2 t3_2016_cat2 ///
    partrend2016_cat2 ///
    t_6_2016_cat3 t_5_2016_cat3 t_4_2016_cat3 t_3_2016_cat3 t_2_2016_cat3 t_1_2016_cat3 ///
    t1_2016_cat3 t2_2016_cat3 t3_2016_cat3 ///
    partrend2016_cat3 ///
    t_6_2016_cat4 t_5_2016_cat4 t_4_2016_cat4 t_3_2016_cat4 t_2_2016_cat4 t_1_2016_cat4 ///
    t1_2016_cat4 t2_2016_cat4 t3_2016_cat4 ///
    partrend2016_cat4 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)
* Save the number of observations
sca nobs_trend = e(N)

* Save the complete coefficients
matrix betas_trend = e(b)

* Extract coefficients for each category and trend
* For PE (2007) Category 1 - we note that we no longer have t_7, so we start at t_6
matrix betas2007_cat1_trend = ., betas_trend[1, 1..18], ., betas_trend[1, 19]
* For PE (2007) Category 2
matrix betas2007_cat2_trend = ., betas_trend[1, 20..37], ., ., betas_trend[1, 38]
* For PE (2007) Category 3
matrix betas2007_cat3_trend = ., betas_trend[1, 39..56], ., ., ., betas_trend[1, 57]
* For PE (2007) Category 4
matrix betas2007_cat4_trend = ., betas_trend[1, 58..75], ., ., ., ., betas_trend[1, 76]

* Extract standard errors
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* For PE (2007) Category 1
matrix vars2007_cat1_trend = ., A[1, 1..18], ., A[1, 19]
* For PE (2007) Category 2
matrix vars2007_cat2_trend = ., A[1, 20..37], ., ., A[1, 38]
* For PE (2007) Category 3
matrix vars2007_cat3_trend = ., A[1, 39..56], ., ., ., A[1, 57]
* For PE (2007) Category 4
matrix vars2007_cat4_trend = ., A[1, 58..75], ., ., ., ., A[1, 76]

boottest {t_6_2007_cat1} {t_5_2007_cat1} {t_4_2007_cat1} {t_3_2007_cat1} {t_2_2007_cat1} {t_1_2007_cat1} ///
        {t1_2007_cat1} {t2_2007_cat1} {t3_2007_cat1} {t4_2007_cat1} {t5_2007_cat1} {t6_2007_cat1} {t7_2007_cat1} {t8_2007_cat1} {t9_2007_cat1} {t10_2007_cat1} {t11_2007_cat1} {t12_2007_cat1} ///
        {partrend2007_cat1} ///
        {t_6_2007_cat2} {t_5_2007_cat2} {t_4_2007_cat2} {t_3_2007_cat2} {t_2_2007_cat2} {t_1_2007_cat2} ///
        {t1_2007_cat2} {t2_2007_cat2} {t3_2007_cat2} {t4_2007_cat2} {t5_2007_cat2} {t6_2007_cat2} {t7_2007_cat2} {t8_2007_cat2} {t9_2007_cat2} {t10_2007_cat2} {t11_2007_cat2} {t12_2007_cat2} ///
        {partrend2007_cat2} ///
        {t_6_2007_cat3} {t_5_2007_cat3} {t_4_2007_cat3} {t_3_2007_cat3} {t_2_2007_cat3} {t_1_2007_cat3} ///
        {t1_2007_cat3} {t2_2007_cat3} {t3_2007_cat3} {t4_2007_cat3} {t5_2007_cat3} {t6_2007_cat3} {t7_2007_cat3} {t8_2007_cat3} {t9_2007_cat3} {t10_2007_cat3} {t11_2007_cat3} {t12_2007_cat3} ///
        {partrend2007_cat3} ///
        {t_6_2007_cat4} {t_5_2007_cat4} {t_4_2007_cat4} {t_3_2007_cat4} {t_2_2007_cat4} {t_1_2007_cat4} ///
        {t1_2007_cat4} {t2_2007_cat4} {t3_2007_cat4} {t4_2007_cat4} {t5_2007_cat4} {t6_2007_cat4} {t7_2007_cat4} {t8_2007_cat4} {t9_2007_cat4} {t10_2007_cat4} {t11_2007_cat4} {t12_2007_cat4} ///
        {partrend2007_cat4}, ///
        noci cluster(state_code) weighttype(webb) seed(982638)

* Store p-values for each category and trend
matrix pvalue2007_cat1_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), ., r(p_19)

matrix pvalue2007_cat2_trend = ., r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), ///
                  r(p_26), r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), r(p_35), r(p_36), r(p_37), ., ., r(p_38)

matrix pvalue2007_cat3_trend = ., r(p_39), r(p_40), r(p_41), r(p_42), r(p_43), r(p_44), ///
                  r(p_45), r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), r(p_53), r(p_54), r(p_55), r(p_56), ., ., ., r(p_57)

matrix pvalue2007_cat4_trend = ., r(p_58), r(p_59), r(p_60), r(p_61), r(p_62), r(p_63), ///
                  r(p_64), r(p_65), r(p_66), r(p_67), r(p_68), r(p_69), r(p_70), r(p_71), r(p_72), r(p_73), r(p_74), r(p_75), ., ., ., ., r(p_76)


********************************************************************************
* Create event study graphs for PE with the 4 categories
********************************************************************************

* PART 1: GRAPH WITHOUT TRENDS

* Create dataset from matrices to facilitate plotting
clear
set obs 20
gen rel_year = _n - 8   // Creates values from -7 to 12 to center at 0 (treatment year)

* PE (2007) - Category 1: low cap & close delegacia
gen coef_2007_cat1 = .
gen se_2007_cat1 = .

* Fill in coefficient and standard error values
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat1 = betas2007_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1 = vars2007_cat1[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat1 = 0 if rel_year == 0
replace se_2007_cat1 = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat1 = betas2007_cat1[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1 = vars2007_cat1[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Category 2: low cap & far delegacia
gen coef_2007_cat2 = .
gen se_2007_cat2 = .

* Fill in coefficient and standard error values
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat2 = betas2007_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2 = vars2007_cat2[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat2 = 0 if rel_year == 0
replace se_2007_cat2 = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat2 = betas2007_cat2[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2 = vars2007_cat2[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Category 3: high cap & close delegacia
gen coef_2007_cat3 = .
gen se_2007_cat3 = .

* Fill in coefficient and standard error values
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat3 = betas2007_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3 = vars2007_cat3[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat3 = 0 if rel_year == 0
replace se_2007_cat3 = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat3 = betas2007_cat3[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3 = vars2007_cat3[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Category 4: high cap & far delegacia
gen coef_2007_cat4 = .
gen se_2007_cat4 = .

* Fill in coefficient and standard error values
forvalues i=1/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat4 = betas2007_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4 = vars2007_cat4[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat4 = 0 if rel_year == 0
replace se_2007_cat4 = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat4 = betas2007_cat4[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4 = vars2007_cat4[1,`pos'] if rel_year == `rel_year'
}

* Calculate confidence intervals (95%)
gen ci_upper_2007_cat1 = coef_2007_cat1 + 1.96 * se_2007_cat1
gen ci_lower_2007_cat1 = coef_2007_cat1 - 1.96 * se_2007_cat1
gen ci_upper_2007_cat2 = coef_2007_cat2 + 1.96 * se_2007_cat2
gen ci_lower_2007_cat2 = coef_2007_cat2 - 1.96 * se_2007_cat2
gen ci_upper_2007_cat3 = coef_2007_cat3 + 1.96 * se_2007_cat3
gen ci_lower_2007_cat3 = coef_2007_cat3 - 1.96 * se_2007_cat3
gen ci_upper_2007_cat4 = coef_2007_cat4 + 1.96 * se_2007_cat4
gen ci_lower_2007_cat4 = coef_2007_cat4 - 1.96 * se_2007_cat4

* Graph for PE (2007) - 4 categories (Without Trends)
twoway (rcap ci_upper_2007_cat1 ci_lower_2007_cat1 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(midblue)) ///
       (scatter coef_2007_cat1 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2007_cat2 ci_lower_2007_cat2 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(cranberry)) ///
       (scatter coef_2007_cat2 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2007_cat3 ci_lower_2007_cat3 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(forest_green)) ///
       (scatter coef_2007_cat3 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2007_cat4 ci_lower_2007_cat4 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(gold)) ///
       (scatter coef_2007_cat4 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Pernambuco (2007)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-7(1)12) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(pe_without_trend, replace) scheme(s1mono)
       
* Save graph
graph export "${outdir}/graphs/robustness_event_study_PE_noSE.pdf", replace

* PART 2: GRAPH WITH LINEAR TRENDS

* Repeat the same process for models with linear trends
clear
set obs 20
gen rel_year = _n - 8   // Creates values from -7 to 12 to center at 0 (treatment year)

* PE (2007) - Category 1 with trend
gen coef_2007_cat1_trend = .
gen se_2007_cat1_trend = .

* Fill in coefficient and standard error values - Note that we start at t-6 (no t-7)
replace coef_2007_cat1_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat1_trend = betas2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1_trend = vars2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat1_trend = 0 if rel_year == 0
replace se_2007_cat1_trend = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat1_trend = betas2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat1_trend = vars2007_cat1_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Category 2 with trend
gen coef_2007_cat2_trend = .
gen se_2007_cat2_trend = .

* Fill in coefficient and standard error values
replace coef_2007_cat2_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat2_trend = betas2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2_trend = vars2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat2_trend = 0 if rel_year == 0
replace se_2007_cat2_trend = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat2_trend = betas2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat2_trend = vars2007_cat2_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Category 3 with trend
gen coef_2007_cat3_trend = .
gen se_2007_cat3_trend = .

* Fill in coefficient and standard error values
replace coef_2007_cat3_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat3_trend = betas2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3_trend = vars2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat3_trend = 0 if rel_year == 0
replace se_2007_cat3_trend = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat3_trend = betas2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat3_trend = vars2007_cat3_trend[1,`pos'] if rel_year == `rel_year'
}

* PE (2007) - Category 4 with trend
gen coef_2007_cat4_trend = .
gen se_2007_cat4_trend = .

* Fill in coefficient and standard error values
replace coef_2007_cat4_trend = . if rel_year == -7
forvalues i=2/7 {
    local rel_year = -8 + `i'
    local pos = `i'
    replace coef_2007_cat4_trend = betas2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4_trend = vars2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Omit year 0 (treatment)
replace coef_2007_cat4_trend = 0 if rel_year == 0
replace se_2007_cat4_trend = 0 if rel_year == 0

* Post-treatment
forvalues i=1/12 {
    local rel_year = `i'
    local pos = 7 + `i'
    replace coef_2007_cat4_trend = betas2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
    replace se_2007_cat4_trend = vars2007_cat4_trend[1,`pos'] if rel_year == `rel_year'
}

* Calculate confidence intervals (95%)
gen ci_upper_2007_cat1_trend = coef_2007_cat1_trend + 1.96 * se_2007_cat1_trend
gen ci_lower_2007_cat1_trend = coef_2007_cat1_trend - 1.96 * se_2007_cat1_trend
gen ci_upper_2007_cat2_trend = coef_2007_cat2_trend + 1.96 * se_2007_cat2_trend
gen ci_lower_2007_cat2_trend = coef_2007_cat2_trend - 1.96 * se_2007_cat2_trend
gen ci_upper_2007_cat3_trend = coef_2007_cat3_trend + 1.96 * se_2007_cat3_trend
gen ci_lower_2007_cat3_trend = coef_2007_cat3_trend - 1.96 * se_2007_cat3_trend
gen ci_upper_2007_cat4_trend = coef_2007_cat4_trend + 1.96 * se_2007_cat4_trend
gen ci_lower_2007_cat4_trend = coef_2007_cat4_trend - 1.96 * se_2007_cat4_trend

* Graph for PE (2007) - 4 categories (With Trends)
twoway (rcap ci_upper_2007_cat1_trend ci_lower_2007_cat1_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(midblue)) ///
       (scatter coef_2007_cat1_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(midblue) msymbol(circle) msize(medium)) ///
       (rcap ci_upper_2007_cat2_trend ci_lower_2007_cat2_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(cranberry)) ///
       (scatter coef_2007_cat2_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(cranberry) msymbol(triangle) msize(medium)) ///
       (rcap ci_upper_2007_cat3_trend ci_lower_2007_cat3_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(forest_green)) ///
       (scatter coef_2007_cat3_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(forest_green) msymbol(diamond) msize(medium)) ///
       (rcap ci_upper_2007_cat4_trend ci_lower_2007_cat4_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(gold)) ///
       (scatter coef_2007_cat4_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(gold) msymbol(square) msize(medium)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       title("Pernambuco (2007)", size(medium)) ///
       xline(0, lpattern(dash) lcolor(gray)) yline(0, lpattern(dash) lcolor(gray)) ///
       xlabel(-6(1)12) ylabel(, angle(horizontal)) ///
       legend(order(2 "Low Capacity & Close Distance" 4 "Low Capacity & Long Distance" 6 "High Capacity & Close Distance" 8 "High Capacity & Long Distance") position(6) rows(2)) ///
       name(pe_with_trend, replace) scheme(s1mono)

* Save graph
graph export "${outdir}/graphs/robustness_event_study_PE_trends_noSE.pdf", replace


********************************************************************************
* Create Latex Table
********************************************************************************
* Open File to Write
cap file close f1
file open f1 using "${outdir}/tables/table_B.5.tex", write replace
* Write header
file write f1 "\begin{table}[h!]" _n
file write f1 "\centering" _n
file write f1 "\caption{Event Study for Pernambuco (2007) by Capacity and Distance to Police Stations}" _n
file write f1 "\label{tab:event_study_PE_het}" _n
file write f1 "\begin{tabular}{lcccccccc}" _n
file write f1 "\hline\hline" _n
file write f1 "& \multicolumn{2}{c}{Low Cap \& Close} & \multicolumn{2}{c}{Low Cap \& Far} & \multicolumn{2}{c}{High Cap \& Close} & \multicolumn{2}{c}{High Cap \& Far} \\" _n
file write f1 "\cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7} \cmidrule(lr){8-9}" _n
file write f1 "Trends & No & Yes & No & Yes & No & Yes & No & Yes \\" _n
file write f1 "\hline" _n
* Part 1: Pre-treatment periods
* t-7 
file write f1 "$t_{-7}$ & $" %7.3f (betas2007_cat1[1,1]) "$ & - & $" %7.3f (betas2007_cat2[1,1]) "$ & - & $" %7.3f (betas2007_cat3[1,1]) "$ & - & $" %7.3f (betas2007_cat4[1,1]) "$ & - \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,1]) ")$ & - & $(" %7.3f (vars2007_cat2[1,1]) ")$ & - & $(" %7.3f (vars2007_cat3[1,1]) ")$ & - & $(" %7.3f (vars2007_cat4[1,1]) ")$ & - \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,1]) "]$ & - & $[" %7.3f (pvalue2007_cat2[1,1]) "]$ & - & $[" %7.3f (pvalue2007_cat3[1,1]) "]$ & - & $[" %7.3f (pvalue2007_cat4[1,1]) "]$ & - \\" _n
file write f1 "\hline" _n
* t-6
file write f1 "$t_{-6}$ & $" %7.3f (betas2007_cat1[1,2]) "$ & $" %7.3f (betas2007_cat1_trend[1,2]) "$ & $" %7.3f (betas2007_cat2[1,2]) "$ & $" %7.3f (betas2007_cat2_trend[1,2]) "$ & $" %7.3f (betas2007_cat3[1,2]) "$ & $" %7.3f (betas2007_cat3_trend[1,2]) "$ & $" %7.3f (betas2007_cat4[1,2]) "$ & $" %7.3f (betas2007_cat4_trend[1,2]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,2]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,2]) ")$ & $(" %7.3f (vars2007_cat2[1,2]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,2]) ")$ & $(" %7.3f (vars2007_cat3[1,2]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,2]) ")$ & $(" %7.3f (vars2007_cat4[1,2]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,2]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,2]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,2]) "]$ & $[" %7.3f (pvalue2007_cat2[1,2]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,2]) "]$ & $[" %7.3f (pvalue2007_cat3[1,2]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,2]) "]$ & $[" %7.3f (pvalue2007_cat4[1,2]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,2]) "]$ \\" _n
file write f1 "\hline" _n
* t-5
file write f1 "$t_{-5}$ & $" %7.3f (betas2007_cat1[1,3]) "$ & $" %7.3f (betas2007_cat1_trend[1,3]) "$ & $" %7.3f (betas2007_cat2[1,3]) "$ & $" %7.3f (betas2007_cat2_trend[1,3]) "$ & $" %7.3f (betas2007_cat3[1,3]) "$ & $" %7.3f (betas2007_cat3_trend[1,3]) "$ & $" %7.3f (betas2007_cat4[1,3]) "$ & $" %7.3f (betas2007_cat4_trend[1,3]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,3]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,3]) ")$ & $(" %7.3f (vars2007_cat2[1,3]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,3]) ")$ & $(" %7.3f (vars2007_cat3[1,3]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,3]) ")$ & $(" %7.3f (vars2007_cat4[1,3]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,3]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,3]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,3]) "]$ & $[" %7.3f (pvalue2007_cat2[1,3]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,3]) "]$ & $[" %7.3f (pvalue2007_cat3[1,3]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,3]) "]$ & $[" %7.3f (pvalue2007_cat4[1,3]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,3]) "]$ \\" _n
file write f1 "\hline" _n
* t-4
file write f1 "$t_{-4}$ & $" %7.3f (betas2007_cat1[1,4]) "$ & $" %7.3f (betas2007_cat1_trend[1,4]) "$ & $" %7.3f (betas2007_cat2[1,4]) "$ & $" %7.3f (betas2007_cat2_trend[1,4]) "$ & $" %7.3f (betas2007_cat3[1,4]) "$ & $" %7.3f (betas2007_cat3_trend[1,4]) "$ & $" %7.3f (betas2007_cat4[1,4]) "$ & $" %7.3f (betas2007_cat4_trend[1,4]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,4]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,4]) ")$ & $(" %7.3f (vars2007_cat2[1,4]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,4]) ")$ & $(" %7.3f (vars2007_cat3[1,4]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,4]) ")$ & $(" %7.3f (vars2007_cat4[1,4]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,4]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,4]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,4]) "]$ & $[" %7.3f (pvalue2007_cat2[1,4]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,4]) "]$ & $[" %7.3f (pvalue2007_cat3[1,4]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,4]) "]$ & $[" %7.3f (pvalue2007_cat4[1,4]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,4]) "]$ \\" _n
file write f1 "\hline" _n
* t-3
file write f1 "$t_{-3}$ & $" %7.3f (betas2007_cat1[1,5]) "$ & $" %7.3f (betas2007_cat1_trend[1,5]) "$ & $" %7.3f (betas2007_cat2[1,5]) "$ & $" %7.3f (betas2007_cat2_trend[1,5]) "$ & $" %7.3f (betas2007_cat3[1,5]) "$ & $" %7.3f (betas2007_cat3_trend[1,5]) "$ & $" %7.3f (betas2007_cat4[1,5]) "$ & $" %7.3f (betas2007_cat4_trend[1,5]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,5]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,5]) ")$ & $(" %7.3f (vars2007_cat2[1,5]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,5]) ")$ & $(" %7.3f (vars2007_cat3[1,5]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,5]) ")$ & $(" %7.3f (vars2007_cat4[1,5]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,5]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,5]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,5]) "]$ & $[" %7.3f (pvalue2007_cat2[1,5]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,5]) "]$ & $[" %7.3f (pvalue2007_cat3[1,5]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,5]) "]$ & $[" %7.3f (pvalue2007_cat4[1,5]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,5]) "]$ \\" _n
file write f1 "\hline" _n
* t-2
file write f1 "$t_{-2}$ & $" %7.3f (betas2007_cat1[1,6]) "$ & $" %7.3f (betas2007_cat1_trend[1,6]) "$ & $" %7.3f (betas2007_cat2[1,6]) "$ & $" %7.3f (betas2007_cat2_trend[1,6]) "$ & $" %7.3f (betas2007_cat3[1,6]) "$ & $" %7.3f (betas2007_cat3_trend[1,6]) "$ & $" %7.3f (betas2007_cat4[1,6]) "$ & $" %7.3f (betas2007_cat4_trend[1,6]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,6]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,6]) ")$ & $(" %7.3f (vars2007_cat2[1,6]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,6]) ")$ & $(" %7.3f (vars2007_cat3[1,6]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,6]) ")$ & $(" %7.3f (vars2007_cat4[1,6]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,6]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,6]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,6]) "]$ & $[" %7.3f (pvalue2007_cat2[1,6]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,6]) "]$ & $[" %7.3f (pvalue2007_cat3[1,6]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,6]) "]$ & $[" %7.3f (pvalue2007_cat4[1,6]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,6]) "]$ \\" _n
file write f1 "\hline" _n
* t-1
file write f1 "$t_{-1}$ & $" %7.3f (betas2007_cat1[1,7]) "$ & $" %7.3f (betas2007_cat1_trend[1,7]) "$ & $" %7.3f (betas2007_cat2[1,7]) "$ & $" %7.3f (betas2007_cat2_trend[1,7]) "$ & $" %7.3f (betas2007_cat3[1,7]) "$ & $" %7.3f (betas2007_cat3_trend[1,7]) "$ & $" %7.3f (betas2007_cat4[1,7]) "$ & $" %7.3f (betas2007_cat4_trend[1,7]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,7]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,7]) ")$ & $(" %7.3f (vars2007_cat2[1,7]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,7]) ")$ & $(" %7.3f (vars2007_cat3[1,7]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,7]) ")$ & $(" %7.3f (vars2007_cat4[1,7]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,7]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,7]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,7]) "]$ & $[" %7.3f (pvalue2007_cat2[1,7]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,7]) "]$ & $[" %7.3f (pvalue2007_cat3[1,7]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,7]) "]$ & $[" %7.3f (pvalue2007_cat4[1,7]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,7]) "]$ \\" _n
file write f1 "\hline" _n
* Part 2: Post-treatment periods
* t+1
file write f1 "$t_{+1}$ & $" %7.3f (betas2007_cat1[1,8]) "$ & $" %7.3f (betas2007_cat1_trend[1,8]) "$ & $" %7.3f (betas2007_cat2[1,8]) "$ & $" %7.3f (betas2007_cat2_trend[1,8]) "$ & $" %7.3f (betas2007_cat3[1,8]) "$ & $" %7.3f (betas2007_cat3_trend[1,8]) "$ & $" %7.3f (betas2007_cat4[1,8]) "$ & $" %7.3f (betas2007_cat4_trend[1,8]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,8]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,8]) ")$ & $(" %7.3f (vars2007_cat2[1,8]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,8]) ")$ & $(" %7.3f (vars2007_cat3[1,8]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,8]) ")$ & $(" %7.3f (vars2007_cat4[1,8]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,8]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,8]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,8]) "]$ & $[" %7.3f (pvalue2007_cat2[1,8]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,8]) "]$ & $[" %7.3f (pvalue2007_cat3[1,8]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,8]) "]$ & $[" %7.3f (pvalue2007_cat4[1,8]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,8]) "]$ \\" _n
file write f1 "\hline" _n
* t+2
file write f1 "$t_{+2}$ & $" %7.3f (betas2007_cat1[1,9]) "$ & $" %7.3f (betas2007_cat1_trend[1,9]) "$ & $" %7.3f (betas2007_cat2[1,9]) "$ & $" %7.3f (betas2007_cat2_trend[1,9]) "$ & $" %7.3f (betas2007_cat3[1,9]) "$ & $" %7.3f (betas2007_cat3_trend[1,9]) "$ & $" %7.3f (betas2007_cat4[1,9]) "$ & $" %7.3f (betas2007_cat4_trend[1,9]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,9]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,9]) ")$ & $(" %7.3f (vars2007_cat2[1,9]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,9]) ")$ & $(" %7.3f (vars2007_cat3[1,9]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,9]) ")$ & $(" %7.3f (vars2007_cat4[1,9]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,9]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,9]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,9]) "]$ & $[" %7.3f (pvalue2007_cat2[1,9]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,9]) "]$ & $[" %7.3f (pvalue2007_cat3[1,9]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,9]) "]$ & $[" %7.3f (pvalue2007_cat4[1,9]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,9]) "]$ \\" _n
file write f1 "\hline" _n
* t+3
file write f1 "$t_{+3}$ & $" %7.3f (betas2007_cat1[1,10]) "$ & $" %7.3f (betas2007_cat1_trend[1,10]) "$ & $" %7.3f (betas2007_cat2[1,10]) "$ & $" %7.3f (betas2007_cat2_trend[1,10]) "$ & $" %7.3f (betas2007_cat3[1,10]) "$ & $" %7.3f (betas2007_cat3_trend[1,10]) "$ & $" %7.3f (betas2007_cat4[1,10]) "$ & $" %7.3f (betas2007_cat4_trend[1,10]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,10]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,10]) ")$ & $(" %7.3f (vars2007_cat2[1,10]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,10]) ")$ & $(" %7.3f (vars2007_cat3[1,10]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,10]) ")$ & $(" %7.3f (vars2007_cat4[1,10]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,10]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,10]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,10]) "]$ & $[" %7.3f (pvalue2007_cat2[1,10]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,10]) "]$ & $[" %7.3f (pvalue2007_cat3[1,10]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,10]) "]$ & $[" %7.3f (pvalue2007_cat4[1,10]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,10]) "]$ \\" _n
file write f1 "\hline" _n
* t+4
file write f1 "$t_{+4}$ & $" %7.3f (betas2007_cat1[1,11]) "$ & $" %7.3f (betas2007_cat1_trend[1,11]) "$ & $" %7.3f (betas2007_cat2[1,11]) "$ & $" %7.3f (betas2007_cat2_trend[1,11]) "$ & $" %7.3f (betas2007_cat3[1,11]) "$ & $" %7.3f (betas2007_cat3_trend[1,11]) "$ & $" %7.3f (betas2007_cat4[1,11]) "$ & $" %7.3f (betas2007_cat4_trend[1,11]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,11]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,11]) ")$ & $(" %7.3f (vars2007_cat2[1,11]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,11]) ")$ & $(" %7.3f (vars2007_cat3[1,11]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,11]) ")$ & $(" %7.3f (vars2007_cat4[1,11]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,11]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,11]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,11]) "]$ & $[" %7.3f (pvalue2007_cat2[1,11]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,11]) "]$ & $[" %7.3f (pvalue2007_cat3[1,11]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,11]) "]$ & $[" %7.3f (pvalue2007_cat4[1,11]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,11]) "]$ \\" _n
file write f1 "\hline" _n
* t+5
file write f1 "$t_{+5}$ & $" %7.3f (betas2007_cat1[1,12]) "$ & $" %7.3f (betas2007_cat1_trend[1,12]) "$ & $" %7.3f (betas2007_cat2[1,12]) "$ & $" %7.3f (betas2007_cat2_trend[1,12]) "$ & $" %7.3f (betas2007_cat3[1,12]) "$ & $" %7.3f (betas2007_cat3_trend[1,12]) "$ & $" %7.3f (betas2007_cat4[1,12]) "$ & $" %7.3f (betas2007_cat4_trend[1,12]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,12]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,12]) ")$ & $(" %7.3f (vars2007_cat2[1,12]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,12]) ")$ & $(" %7.3f (vars2007_cat3[1,12]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,12]) ")$ & $(" %7.3f (vars2007_cat4[1,12]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,12]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,12]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,12]) "]$ & $[" %7.3f (pvalue2007_cat2[1,12]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,12]) "]$ & $[" %7.3f (pvalue2007_cat3[1,12]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,12]) "]$ & $[" %7.3f (pvalue2007_cat4[1,12]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,12]) "]$ \\" _n
file write f1 "\hline" _n
* t+6
file write f1 "$t_{+6}$ & $" %7.3f (betas2007_cat1[1,13]) "$ & $" %7.3f (betas2007_cat1_trend[1,13]) "$ & $" %7.3f (betas2007_cat2[1,13]) "$ & $" %7.3f (betas2007_cat2_trend[1,13]) "$ & $" %7.3f (betas2007_cat3[1,13]) "$ & $" %7.3f (betas2007_cat3_trend[1,13]) "$ & $" %7.3f (betas2007_cat4[1,13]) "$ & $" %7.3f (betas2007_cat4_trend[1,13]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,13]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,13]) ")$ & $(" %7.3f (vars2007_cat2[1,13]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,13]) ")$ & $(" %7.3f (vars2007_cat3[1,13]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,13]) ")$ & $(" %7.3f (vars2007_cat4[1,13]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,13]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,13]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,13]) "]$ & $[" %7.3f (pvalue2007_cat2[1,13]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,13]) "]$ & $[" %7.3f (pvalue2007_cat3[1,13]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,13]) "]$ & $[" %7.3f (pvalue2007_cat4[1,13]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,13]) "]$ \\" _n
file write f1 "\hline" _n
* t+7
file write f1 "$t_{+7}$ & $" %7.3f (betas2007_cat1[1,14]) "$ & $" %7.3f (betas2007_cat1_trend[1,14]) "$ & $" %7.3f (betas2007_cat2[1,14]) "$ & $" %7.3f (betas2007_cat2_trend[1,14]) "$ & $" %7.3f (betas2007_cat3[1,14]) "$ & $" %7.3f (betas2007_cat3_trend[1,14]) "$ & $" %7.3f (betas2007_cat4[1,14]) "$ & $" %7.3f (betas2007_cat4_trend[1,14]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,14]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,14]) ")$ & $(" %7.3f (vars2007_cat2[1,14]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,14]) ")$ & $(" %7.3f (vars2007_cat3[1,14]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,14]) ")$ & $(" %7.3f (vars2007_cat4[1,14]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,14]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,14]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,14]) "]$ & $[" %7.3f (pvalue2007_cat2[1,14]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,14]) "]$ & $[" %7.3f (pvalue2007_cat3[1,14]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,14]) "]$ & $[" %7.3f (pvalue2007_cat4[1,14]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,14]) "]$ \\" _n
file write f1 "\hline" _n
* t+8
file write f1 "$t_{+8}$ & $" %7.3f (betas2007_cat1[1,15]) "$ & $" %7.3f (betas2007_cat1_trend[1,15]) "$ & $" %7.3f (betas2007_cat2[1,15]) "$ & $" %7.3f (betas2007_cat2_trend[1,15]) "$ & $" %7.3f (betas2007_cat3[1,15]) "$ & $" %7.3f (betas2007_cat3_trend[1,15]) "$ & $" %7.3f (betas2007_cat4[1,15]) "$ & $" %7.3f (betas2007_cat4_trend[1,15]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,15]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,15]) ")$ & $(" %7.3f (vars2007_cat2[1,15]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,15]) ")$ & $(" %7.3f (vars2007_cat3[1,15]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,15]) ")$ & $(" %7.3f (vars2007_cat4[1,15]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,15]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,15]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,15]) "]$ & $[" %7.3f (pvalue2007_cat2[1,15]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,15]) "]$ & $[" %7.3f (pvalue2007_cat3[1,15]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,15]) "]$ & $[" %7.3f (pvalue2007_cat4[1,15]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,15]) "]$ \\" _n
file write f1 "\hline" _n
* t+9
file write f1 "$t_{+9}$ & $" %7.3f (betas2007_cat1[1,16]) "$ & $" %7.3f (betas2007_cat1_trend[1,16]) "$ & $" %7.3f (betas2007_cat2[1,16]) "$ & $" %7.3f (betas2007_cat2_trend[1,16]) "$ & $" %7.3f (betas2007_cat3[1,16]) "$ & $" %7.3f (betas2007_cat3_trend[1,16]) "$ & $" %7.3f (betas2007_cat4[1,16]) "$ & $" %7.3f (betas2007_cat4_trend[1,16]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,16]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,16]) ")$ & $(" %7.3f (vars2007_cat2[1,16]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,16]) ")$ & $(" %7.3f (vars2007_cat3[1,16]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,16]) ")$ & $(" %7.3f (vars2007_cat4[1,16]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,16]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,16]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,16]) "]$ & $[" %7.3f (pvalue2007_cat2[1,16]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,16]) "]$ & $[" %7.3f (pvalue2007_cat3[1,16]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,16]) "]$ & $[" %7.3f (pvalue2007_cat4[1,16]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,16]) "]$ \\" _n
file write f1 "\hline" _n
* t+10
file write f1 "$t_{+10}$ & $" %7.3f (betas2007_cat1[1,17]) "$ & $" %7.3f (betas2007_cat1_trend[1,17]) "$ & $" %7.3f (betas2007_cat2[1,17]) "$ & $" %7.3f (betas2007_cat2_trend[1,17]) "$ & $" %7.3f (betas2007_cat3[1,17]) "$ & $" %7.3f (betas2007_cat3_trend[1,17]) "$ & $" %7.3f (betas2007_cat4[1,17]) "$ & $" %7.3f (betas2007_cat4_trend[1,17]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,17]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,17]) ")$ & $(" %7.3f (vars2007_cat2[1,17]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,17]) ")$ & $(" %7.3f (vars2007_cat3[1,17]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,17]) ")$ & $(" %7.3f (vars2007_cat4[1,17]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,17]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,17]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,17]) "]$ & $[" %7.3f (pvalue2007_cat2[1,17]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,17]) "]$ & $[" %7.3f (pvalue2007_cat3[1,17]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,17]) "]$ & $[" %7.3f (pvalue2007_cat4[1,17]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,17]) "]$ \\" _n
file write f1 "\hline" _n
* t+11
file write f1 "$t_{+11}$ & $" %7.3f (betas2007_cat1[1,18]) "$ & $" %7.3f (betas2007_cat1_trend[1,18]) "$ & $" %7.3f (betas2007_cat2[1,18]) "$ & $" %7.3f (betas2007_cat2_trend[1,18]) "$ & $" %7.3f (betas2007_cat3[1,18]) "$ & $" %7.3f (betas2007_cat3_trend[1,18]) "$ & $" %7.3f (betas2007_cat4[1,18]) "$ & $" %7.3f (betas2007_cat4_trend[1,18]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,18]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,18]) ")$ & $(" %7.3f (vars2007_cat2[1,18]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,18]) ")$ & $(" %7.3f (vars2007_cat3[1,18]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,18]) ")$ & $(" %7.3f (vars2007_cat4[1,18]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,18]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,18]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,18]) "]$ & $[" %7.3f (pvalue2007_cat2[1,18]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,18]) "]$ & $[" %7.3f (pvalue2007_cat3[1,18]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,18]) "]$ & $[" %7.3f (pvalue2007_cat4[1,18]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,18]) "]$ \\" _n
file write f1 "\hline" _n
* t+12
file write f1 "$t_{+12}$ & $" %7.3f (betas2007_cat1[1,19]) "$ & $" %7.3f (betas2007_cat1_trend[1,19]) "$ & $" %7.3f (betas2007_cat2[1,19]) "$ & $" %7.3f (betas2007_cat2_trend[1,19]) "$ & $" %7.3f (betas2007_cat3[1,19]) "$ & $" %7.3f (betas2007_cat3_trend[1,19]) "$ & $" %7.3f (betas2007_cat4[1,19]) "$ & $" %7.3f (betas2007_cat4_trend[1,19]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007_cat1[1,19]) ")$ & $(" %7.3f (vars2007_cat1_trend[1,19]) ")$ & $(" %7.3f (vars2007_cat2[1,19]) ")$ & $(" %7.3f (vars2007_cat2_trend[1,19]) ")$ & $(" %7.3f (vars2007_cat3[1,19]) ")$ & $(" %7.3f (vars2007_cat3_trend[1,19]) ")$ & $(" %7.3f (vars2007_cat4[1,19]) ")$ & $(" %7.3f (vars2007_cat4_trend[1,19]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007_cat1[1,19]) "]$ & $[" %7.3f (pvalue2007_cat1_trend[1,19]) "]$ & $[" %7.3f (pvalue2007_cat2[1,19]) "]$ & $[" %7.3f (pvalue2007_cat2_trend[1,19]) "]$ & $[" %7.3f (pvalue2007_cat3[1,19]) "]$ & $[" %7.3f (pvalue2007_cat3_trend[1,19]) "]$ & $[" %7.3f (pvalue2007_cat4[1,19]) "]$ & $[" %7.3f (pvalue2007_cat4_trend[1,19]) "]$ \\" _n
file write f1 "\hline" _n
* Number of obs
file write f1 "Observations & \multicolumn{4}{c}{$" %10.0f (nobs) "$} & \multicolumn{4}{c}{$" %10.0f (nobs_trend) "$} \\" _n
file write f1 "\hline\hline" _n
* Close table
file write f1 "\end{tabular}" _n
file write f1 "\end{table}" _n

* Close file
file close f1
