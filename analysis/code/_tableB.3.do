********************************************************************************
* Event Study (Robustness - < 50km from PE's border)
********************************************************************************

* Load data
 use "$inpdir/main_data.dta", clear
drop if municipality_code == 2300000 | municipality_code == 2600000
keep if dist_PE < 50

* Seed
set seed 982638

* Creating year of treatment adoption variable (staggered treatment)
gen treatment_year = 0
replace treatment_year = 2011 if state == "BA" | state == "PB"
replace treatment_year = 2015 if state == "CE"
replace treatment_year = 2016 if state == "MA"
replace treatment_year = 2007 if state == "PE"

* Create relative year variable
gen rel_year = year - treatment_year

* Create log population variable
gen log_pop = log(population_muni)

* Defining ids for xtreg
xtset municipality_code year

* Creating dummies for treatment years
gen t2007 = (treatment_year == 2007)  // PE
gen t2011 = (treatment_year == 2011)  // BA, PB
gen t2015 = (treatment_year == 2015)  // CE
gen t2016 = (treatment_year == 2016)  // MA

* Creating dummies for years
forvalues y = 2000/2019 {
    gen d`y' = (year == `y')
}

******************************************************************************
* Creating event dummies for all cohorts
******************************************************************************

* Creating dummies for years
* PE cohort (2007)
* Pre-treatment: 
gen t_7_2007 = t2007 * d2000
gen t_6_2007 = t2007 * d2001
gen t_5_2007 = t2007 * d2002
gen t_4_2007 = t2007 * d2003
gen t_3_2007 = t2007 * d2004
gen t_2_2007 = t2007 * d2005
gen t_1_2007 = t2007 * d2006
* Ommitting treatment year (2007)
* Post-treatment
gen t1_2007 = t2007 * d2008
gen t2_2007 = t2007 * d2009
gen t3_2007 = t2007 * d2010
gen t4_2007 = t2007 * d2011
gen t5_2007 = t2007 * d2012
gen t6_2007 = t2007 * d2013
gen t7_2007 = t2007 * d2014
gen t8_2007 = t2007 * d2015
gen t9_2007 = t2007 * d2016
gen t10_2007 = t2007 * d2017
gen t11_2007 = t2007 * d2018
gen t12_2007 = t2007 * d2019

* 2011 cohort (BA/PB)
* Pre-treatment: 
gen t_7_2011 = t2011 * d2004
gen t_6_2011 = t2011 * d2005
gen t_5_2011 = t2011 * d2006
gen t_4_2011 = t2011 * d2007
gen t_3_2011 = t2011 * d2008
gen t_2_2011 = t2011 * d2009
gen t_1_2011 = t2011 * d2010
* Ommitting treatment year (2011)
* Post-treatment
gen t1_2011 = t2011 * d2012
gen t2_2011 = t2011 * d2013
gen t3_2011 = t2011 * d2014
gen t4_2011 = t2011 * d2015
gen t5_2011 = t2011 * d2016
gen t6_2011 = t2011 * d2017
gen t7_2011 = t2011 * d2018
gen t8_2011 = t2011 * d2019

* 2015 cohort (CE)
* Pre-treatment: 
gen t_7_2015 = t2015 * d2008
gen t_6_2015 = t2015 * d2009
gen t_5_2015 = t2015 * d2010
gen t_4_2015 = t2015 * d2011
gen t_3_2015 = t2015 * d2012
gen t_2_2015 = t2015 * d2013
gen t_1_2015 = t2015 * d2014
* Ommitting treatment year (2015)
* Post-treatment
gen t1_2015 = t2015 * d2016
gen t2_2015 = t2015 * d2017
gen t3_2015 = t2015 * d2018
gen t4_2015 = t2015 * d2019

* 2016 cohort (MA)
* Pre-treatment: 
gen t_7_2016 = t2016 * d2009
gen t_6_2016 = t2016 * d2010
gen t_5_2016 = t2016 * d2011
gen t_4_2016 = t2016 * d2012
gen t_3_2016 = t2016 * d2013
gen t_2_2016 = t2016 * d2014
gen t_1_2016 = t2016 * d2015
* Ommitting treatment year (2015)
* Post-treatment
gen t1_2016 = t2016 * d2017
gen t2_2016 = t2016 * d2018
gen t3_2016 = t2016 * d2019

********************************************************************************
* Part 1: Event Study
********************************************************************************

* Model with all variables
xtreg taxa_homicidios_total_por_100m_1 ///
    t_7_2007 t_6_2007 t_5_2007 t_4_2007 t_3_2007 t_2_2007 t_1_2007 ///
    t1_2007 t2_2007 t3_2007 t4_2007 t5_2007 t6_2007 t7_2007 t8_2007 t9_2007 t10_2007 t11_2007 t12_2007 ///
    t_7_2011 t_6_2011 t_5_2011 t_4_2011 t_3_2011 t_2_2011 t_1_2011 ///
    t1_2011 t2_2011 t3_2011 t4_2011 t5_2011 t6_2011 t7_2011 t8_2011 ///
    t_7_2015 t_6_2015 t_5_2015 t_4_2015 t_3_2015 t_2_2015 t_1_2015 ///
    t1_2015 t2_2015 t3_2015 t4_2015 ///
    t_7_2016 t_6_2016 t_5_2016 t_4_2016 t_3_2016 t_2_2016 t_1_2016 ///
    t1_2016 t2_2016 t3_2016 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Saving number of obs
sca nobs = e(N)

* Saving coefficients
matrix betas = e(b)

* Extracting coefs for each cohort
* PE (2007)
matrix betas2007 = betas[1, 1..19], .
* BA/PB (2011)
matrix betas2011 = betas[1, 20..34], ., .
* CE (2015)
matrix betas2015 = betas[1, 35..45], ., ., .
* MA (2016)
matrix betas2016 = betas[1, 46..55], ., ., ., .

* Extracting sd errors
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* PE (2007)
matrix vars2007 = A[1, 1..19], .
* BA/PB (2011)
matrix vars2011 = A[1, 20..34], ., .
* CE (2015)
matrix vars2015 = A[1, 35..45], ., ., .
* MA (2016)
matrix vars2016 = A[1, 46..55], ., ., ., .

* Calculate p-values using boottest
boottest {t_7_2007} {t_6_2007} {t_5_2007} {t_4_2007} {t_3_2007} {t_2_2007} {t_1_2007} ///
        {t1_2007} {t2_2007} {t3_2007} {t4_2007} {t5_2007} {t6_2007} {t7_2007} {t8_2007} {t9_2007} {t10_2007} {t11_2007} {t12_2007} ///
        {t_7_2011} {t_6_2011} {t_5_2011} {t_4_2011} {t_3_2011} {t_2_2011} {t_1_2011} ///
        {t1_2011} {t2_2011} {t3_2011} {t4_2011} {t5_2011} {t6_2011} {t7_2011} {t8_2011} ///
        {t_7_2015} {t_6_2015} {t_5_2015} {t_4_2015} {t_3_2015} {t_2_2015} {t_1_2015} ///
        {t1_2015} {t2_2015} {t3_2015} {t4_2015} ///
        {t_7_2016} {t_6_2016} {t_5_2016} {t_4_2016} {t_3_2016} {t_2_2016} {t_1_2016} ///
        {t1_2016} {t2_2016} {t3_2016}, ///
        noci cluster(state_code) reps(9999) weighttype(webb) seed(982638)

* Storing p-values for each cohort
matrix pvalue2007 = r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), r(p_7), ///
                   r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), r(p_19), .

matrix pvalue2011 = r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), r(p_26), ///
                   r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), r(p_34), ., .

matrix pvalue2015 = r(p_35), r(p_36), r(p_37), r(p_38), r(p_39), r(p_40), r(p_41), ///
                   r(p_42), r(p_43), r(p_44), r(p_45), ., ., ., .

matrix pvalue2016 = r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), r(p_52), ///
                   r(p_53), r(p_54), r(p_55), ., ., ., ., .

********************************************************************************
* Create treated-cohort specific linear trend
********************************************************************************
gen trend = year - 2000

* Create specific trends for each cohort
gen partrend2007 = trend * t2007
gen partrend2011 = trend * t2011
gen partrend2015 = trend * t2015
gen partrend2016 = trend * t2016

********************************************************************************
* Part 2: Event Study with trends by Cohort
********************************************************************************
* IMPORTANT: Removing t_7 for each cohort due to collinearity
* Model with all variables, including trends
xtreg taxa_homicidios_total_por_100m_1 ///
    t_6_2007 t_5_2007 t_4_2007 t_3_2007 t_2_2007 t_1_2007 ///
    t1_2007 t2_2007 t3_2007 t4_2007 t5_2007 t6_2007 t7_2007 t8_2007 t9_2007 t10_2007 t11_2007 t12_2007 ///
    partrend2007 ///
    t_6_2011 t_5_2011 t_4_2011 t_3_2011 t_2_2011 t_1_2011 ///
    t1_2011 t2_2011 t3_2011 t4_2011 t5_2011 t6_2011 t7_2011 t8_2011 ///
    partrend2011 ///
    t_6_2015 t_5_2015 t_4_2015 t_3_2015 t_2_2015 t_1_2015 ///
    t1_2015 t2_2015 t3_2015 t4_2015 ///
    partrend2015 ///
    t_6_2016 t_5_2016 t_4_2016 t_3_2016 t_2_2016 t_1_2016 ///
    t1_2016 t2_2016 t3_2016 ///
    partrend2016 ///
    log_pop i.year i.municipality_code [aw = population_2000_muni], fe vce(cluster state_code)

* Saving number of obs
sca nobs_trend = e(N)

* Saving coefficients
matrix betas_trend = e(b)

* Extracting coefs for each cohort
* PE (2007)
matrix betas2007_trend = ., betas_trend[1, 1..18], ., betas_trend[1, 19]
* BA/PB (2011)
matrix betas2011_trend = ., betas_trend[1, 20..33], ., ., betas_trend[1, 34]
* CE (2015)
matrix betas2015_trend = ., betas_trend[1, 35..44], ., ., ., betas_trend[1, 45]
* MA (2016)
matrix betas2016_trend = ., betas_trend[1, 46..54], ., ., ., ., betas_trend[1, 55]

* Extracting SD error
mata st_matrix("A", sqrt(st_matrix("e(V)")))
mata st_matrix("A", diagonal(st_matrix("A")))
matrix A = A'

* PE (2007)
matrix vars2007_trend = ., A[1, 1..18], ., A[1, 19]
* BA/PB (2011)
matrix vars2011_trend = ., A[1, 20..33], ., ., A[1, 34]
* CE (2015)
matrix vars2015_trend = ., A[1, 35..44], ., ., ., A[1, 45]
* MA (2016)
matrix vars2016_trend = ., A[1, 46..54], ., ., ., ., A[1, 55]

* Calculate p-values using boottest
boottest {t_6_2007} {t_5_2007} {t_4_2007} {t_3_2007} {t_2_2007} {t_1_2007} ///
        {t1_2007} {t2_2007} {t3_2007} {t4_2007} {t5_2007} {t6_2007} {t7_2007} {t8_2007} {t9_2007} {t10_2007} {t11_2007} {t12_2007} ///
        {partrend2007} ///
        {t_6_2011} {t_5_2011} {t_4_2011} {t_3_2011} {t_2_2011} {t_1_2011} ///
        {t1_2011} {t2_2011} {t3_2011} {t4_2011} {t5_2011} {t6_2011} {t7_2011} {t8_2011} ///
        {partrend2011} ///
        {t_6_2015} {t_5_2015} {t_4_2015} {t_3_2015} {t_2_2015} {t_1_2015} ///
        {t1_2015} {t2_2015} {t3_2015} {t4_2015} ///
        {partrend2015} ///
        {t_6_2016} {t_5_2016} {t_4_2016} {t_3_2016} {t_2_2016} {t_1_2016} ///
        {t1_2016} {t2_2016} {t3_2016} ///
        {partrend2016}, ///
        noci cluster(state_code) reps(9999) weighttype(webb) seed(982638)

* Storing p-values for each cohort
matrix pvalue2007_trend = ., r(p_1), r(p_2), r(p_3), r(p_4), r(p_5), r(p_6), ///
                  r(p_7), r(p_8), r(p_9), r(p_10), r(p_11), r(p_12), r(p_13), r(p_14), r(p_15), r(p_16), r(p_17), r(p_18), ., r(p_19)

matrix pvalue2011_trend = ., r(p_20), r(p_21), r(p_22), r(p_23), r(p_24), r(p_25), ///
                  r(p_26), r(p_27), r(p_28), r(p_29), r(p_30), r(p_31), r(p_32), r(p_33), ., ., r(p_34)

matrix pvalue2015_trend = ., r(p_35), r(p_36), r(p_37), r(p_38), r(p_39), r(p_40), ///
                  r(p_41), r(p_42), r(p_43), r(p_44), ., ., ., ., r(p_45)

matrix pvalue2016_trend = ., r(p_46), r(p_47), r(p_48), r(p_49), r(p_50), r(p_51), ///
                  r(p_52), r(p_53), r(p_54), ., ., ., ., ., r(p_55)

********************************************************************************
* Create LaTeX Table for Event Study - PE Cohort (2007)
********************************************************************************

* Open file for writing
cap file close f1
file open f1 using "${outdir}/tables/event_study_robustness_PE.tex", write replace

* Write table header
file write f1 "\begin{table}[h!]" _n
file write f1 "\centering" _n
file write f1 "\label{tab:event_study_robustness_PE}" _n
file write f1 "\begin{tabular}{lcc}" _n
file write f1 "\hline\hline" _n
file write f1 "& \multicolumn{2}{c}{Pernambuco (2007)} \\" _n
file write f1 "Relative Time & \multicolumn{1}{c}{Without Trend} & \multicolumn{1}{c}{With Trend} \\" _n
file write f1 "\hline" _n

* Cohort-specific trend (only for model with trend)
file write f1 "Trend & - & $" %7.3f (betas2007_trend[1,21]) "$ \\" _n
file write f1 "& - & $(" %7.3f (vars2007_trend[1,21]) ")$ \\" _n
file write f1 "& - & $[" %7.3f (pvalue2007_trend[1,21]) "]$ \\" _n
file write f1 "\hline" _n

* Pre-treatment periods
* t-7 (only for model without trend)
file write f1 "$t_{-7}$ & $" %7.3f (betas2007[1,1]) "$ & - \\" _n
file write f1 "& $(" %7.3f (vars2007[1,1]) ")$ & - \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,1]) "]$ & - \\" _n
file write f1 "\hline" _n

* t-6
file write f1 "$t_{-6}$ & $" %7.3f (betas2007[1,2]) "$ & $" %7.3f (betas2007_trend[1,2]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,2]) ")$ & $(" %7.3f (vars2007_trend[1,2]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,2]) "]$ & $[" %7.3f (pvalue2007_trend[1,2]) "]$ \\" _n
file write f1 "\hline" _n

* t-5
file write f1 "$t_{-5}$ & $" %7.3f (betas2007[1,3]) "$ & $" %7.3f (betas2007_trend[1,3]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,3]) ")$ & $(" %7.3f (vars2007_trend[1,3]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,3]) "]$ & $[" %7.3f (pvalue2007_trend[1,3]) "]$ \\" _n
file write f1 "\hline" _n

* t-4
file write f1 "$t_{-4}$ & $" %7.3f (betas2007[1,4]) "$ & $" %7.3f (betas2007_trend[1,4]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,4]) ")$ & $(" %7.3f (vars2007_trend[1,4]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,4]) "]$ & $[" %7.3f (pvalue2007_trend[1,4]) "]$ \\" _n
file write f1 "\hline" _n

* t-3
file write f1 "$t_{-3}$ & $" %7.3f (betas2007[1,5]) "$ & $" %7.3f (betas2007_trend[1,5]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,5]) ")$ & $(" %7.3f (vars2007_trend[1,5]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,5]) "]$ & $[" %7.3f (pvalue2007_trend[1,5]) "]$ \\" _n
file write f1 "\hline" _n

* t-2
file write f1 "$t_{-2}$ & $" %7.3f (betas2007[1,6]) "$ & $" %7.3f (betas2007_trend[1,6]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,6]) ")$ & $(" %7.3f (vars2007_trend[1,6]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,6]) "]$ & $[" %7.3f (pvalue2007_trend[1,6]) "]$ \\" _n
file write f1 "\hline" _n

* t-1
file write f1 "$t_{-1}$ & $" %7.3f (betas2007[1,7]) "$ & $" %7.3f (betas2007_trend[1,7]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,7]) ")$ & $(" %7.3f (vars2007_trend[1,7]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,7]) "]$ & $[" %7.3f (pvalue2007_trend[1,7]) "]$ \\" _n
file write f1 "\hline" _n

* Write line to indicate that t0 is omitted
file write f1 "$t_{0}$ & \multicolumn{2}{c}{(omitted - treatment year)} \\" _n
file write f1 "\hline" _n

* t+1
file write f1 "$t_{+1}$ & $" %7.3f (betas2007[1,8]) "$ & $" %7.3f (betas2007_trend[1,8]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,8]) ")$ & $(" %7.3f (vars2007_trend[1,8]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,8]) "]$ & $[" %7.3f (pvalue2007_trend[1,8]) "]$ \\" _n
file write f1 "\hline" _n

* t+2
file write f1 "$t_{+2}$ & $" %7.3f (betas2007[1,9]) "$ & $" %7.3f (betas2007_trend[1,9]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,9]) ")$ & $(" %7.3f (vars2007_trend[1,9]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,9]) "]$ & $[" %7.3f (pvalue2007_trend[1,9]) "]$ \\" _n
file write f1 "\hline" _n

* t+3
file write f1 "$t_{+3}$ & $" %7.3f (betas2007[1,10]) "$ & $" %7.3f (betas2007_trend[1,10]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,10]) ")$ & $(" %7.3f (vars2007_trend[1,10]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,10]) "]$ & $[" %7.3f (pvalue2007_trend[1,10]) "]$ \\" _n
file write f1 "\hline" _n

* t+4
file write f1 "$t_{+4}$ & $" %7.3f (betas2007[1,11]) "$ & $" %7.3f (betas2007_trend[1,11]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,11]) ")$ & $(" %7.3f (vars2007_trend[1,11]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,11]) "]$ & $[" %7.3f (pvalue2007_trend[1,11]) "]$ \\" _n
file write f1 "\hline" _n

* t+5
file write f1 "$t_{+5}$ & $" %7.3f (betas2007[1,12]) "$ & $" %7.3f (betas2007_trend[1,12]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,12]) ")$ & $(" %7.3f (vars2007_trend[1,12]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,12]) "]$ & $[" %7.3f (pvalue2007_trend[1,12]) "]$ \\" _n
file write f1 "\hline" _n

* t+6
file write f1 "$t_{+6}$ & $" %7.3f (betas2007[1,13]) "$ & $" %7.3f (betas2007_trend[1,13]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,13]) ")$ & $(" %7.3f (vars2007_trend[1,13]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,13]) "]$ & $[" %7.3f (pvalue2007_trend[1,13]) "]$ \\" _n
file write f1 "\hline" _n

* t+7
file write f1 "$t_{+7}$ & $" %7.3f (betas2007[1,14]) "$ & $" %7.3f (betas2007_trend[1,14]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,14]) ")$ & $(" %7.3f (vars2007_trend[1,14]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,14]) "]$ & $[" %7.3f (pvalue2007_trend[1,14]) "]$ \\" _n
file write f1 "\hline" _n

* t+8
file write f1 "$t_{+8}$ & $" %7.3f (betas2007[1,15]) "$ & $" %7.3f (betas2007_trend[1,15]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,15]) ")$ & $(" %7.3f (vars2007_trend[1,15]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,15]) "]$ & $[" %7.3f (pvalue2007_trend[1,15]) "]$ \\" _n
file write f1 "\hline" _n

* t+9
file write f1 "$t_{+9}$ & $" %7.3f (betas2007[1,16]) "$ & $" %7.3f (betas2007_trend[1,16]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,16]) ")$ & $(" %7.3f (vars2007_trend[1,16]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,16]) "]$ & $[" %7.3f (pvalue2007_trend[1,16]) "]$ \\" _n
file write f1 "\hline" _n

* t+10
file write f1 "$t_{+10}$ & $" %7.3f (betas2007[1,17]) "$ & $" %7.3f (betas2007_trend[1,17]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,17]) ")$ & $(" %7.3f (vars2007_trend[1,17]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,17]) "]$ & $[" %7.3f (pvalue2007_trend[1,17]) "]$ \\" _n
file write f1 "\hline" _n

* t+11
file write f1 "$t_{+11}$ & $" %7.3f (betas2007[1,18]) "$ & $" %7.3f (betas2007_trend[1,18]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,18]) ")$ & $(" %7.3f (vars2007_trend[1,18]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,18]) "]$ & $[" %7.3f (pvalue2007_trend[1,18]) "]$ \\" _n
file write f1 "\hline" _n

* t+12
file write f1 "$t_{+12}$ & $" %7.3f (betas2007[1,19]) "$ & $" %7.3f (betas2007_trend[1,19]) "$ \\" _n
file write f1 "& $(" %7.3f (vars2007[1,19]) ")$ & $(" %7.3f (vars2007_trend[1,19]) ")$ \\" _n
file write f1 "& $[" %7.3f (pvalue2007[1,19]) "]$ & $[" %7.3f (pvalue2007_trend[1,19]) "]$ \\" _n
file write f1 "\hline" _n

* Number of observations
file write f1 "Observations & $" %9.0fc (nobs) "$ & $" %9.0fc (nobs_trend) "$ \\" _n
file write f1 "\hline\hline" _n

* Close table
file write f1 "\end{tabular}" _n
file write f1 "\end{table}" _n

* Close the file
file close f1

********************************************************************************
* Part 2: Event Study Graph - PE
********************************************************************************

* Convert matrices to dataset
clear
set obs 20
gen rel_year = _n - 8   // Create values from -7 to 12

* PE (2007)
gen coef_2007 = .
gen se_2007 = .
gen pvalue_2007 = .

* Filling values from 2007 cohort (PE)
replace coef_2007 = betas2007[1,1] if rel_year == -7
replace coef_2007 = betas2007[1,2] if rel_year == -6
replace coef_2007 = betas2007[1,3] if rel_year == -5
replace coef_2007 = betas2007[1,4] if rel_year == -4
replace coef_2007 = betas2007[1,5] if rel_year == -3
replace coef_2007 = betas2007[1,6] if rel_year == -2
replace coef_2007 = betas2007[1,7] if rel_year == -1
replace coef_2007 = 0 if rel_year == 0  // Base Year (ommited)
replace coef_2007 = betas2007[1,8] if rel_year == 1
replace coef_2007 = betas2007[1,9] if rel_year == 2
replace coef_2007 = betas2007[1,10] if rel_year == 3
replace coef_2007 = betas2007[1,11] if rel_year == 4
replace coef_2007 = betas2007[1,12] if rel_year == 5
replace coef_2007 = betas2007[1,13] if rel_year == 6
replace coef_2007 = betas2007[1,14] if rel_year == 7
replace coef_2007 = betas2007[1,15] if rel_year == 8
replace coef_2007 = betas2007[1,16] if rel_year == 9
replace coef_2007 = betas2007[1,17] if rel_year == 10
replace coef_2007 = betas2007[1,18] if rel_year == 11
replace coef_2007 = betas2007[1,19] if rel_year == 12

* Filling SD Errors for 2007 cohort
replace se_2007 = vars2007[1,1] if rel_year == -7
replace se_2007 = vars2007[1,2] if rel_year == -6
replace se_2007 = vars2007[1,3] if rel_year == -5
replace se_2007 = vars2007[1,4] if rel_year == -4
replace se_2007 = vars2007[1,5] if rel_year == -3
replace se_2007 = vars2007[1,6] if rel_year == -2
replace se_2007 = vars2007[1,7] if rel_year == -1
replace se_2007 = 0 if rel_year == 0  // Base Year (ommited)
replace se_2007 = vars2007[1,8] if rel_year == 1
replace se_2007 = vars2007[1,9] if rel_year == 2
replace se_2007 = vars2007[1,10] if rel_year == 3
replace se_2007 = vars2007[1,11] if rel_year == 4
replace se_2007 = vars2007[1,12] if rel_year == 5
replace se_2007 = vars2007[1,13] if rel_year == 6
replace se_2007 = vars2007[1,14] if rel_year == 7
replace se_2007 = vars2007[1,15] if rel_year == 8
replace se_2007 = vars2007[1,16] if rel_year == 9
replace se_2007 = vars2007[1,17] if rel_year == 10
replace se_2007 = vars2007[1,18] if rel_year == 11
replace se_2007 = vars2007[1,19] if rel_year == 12

* Calculating CI (95%)
gen ci_upper_2007 = coef_2007 + 1.96 * se_2007
gen ci_lower_2007 = coef_2007 - 1.96 * se_2007

* PE graph (2007)
twoway (rcap ci_upper_2007 ci_lower_2007 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007 rel_year if rel_year >= -7 & rel_year <= 12, mcolor(navy) msymbol(circle)) ///
       (connect coef_2007 rel_year if rel_year >= -7 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007 rel_year if rel_year == 0, msymbol(diamond) mcolor(red) msize(large)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       xline(0, lpattern(dash) lcolor(red)) yline(0, lpattern(dash) lcolor(black)) ///
       xlabel(-7(1)12) ///
       title("Pernambuco (2007)") ///
       legend(off) name(graph_2007, replace)
	   
	 graph export "${outdir}/graphs/robustness_event_study_PE.pdf", replace


********************************************************************************
* Event Study graph with Trends
********************************************************************************

* Convert Matrices to dataset
clear
set obs 20
gen rel_year = _n - 8   // Create values from -7 to 12

* PE graph (2007)
gen coef_2007_trend = .
gen se_2007_trend = .

* Filling values from 2007 cohort (PE)
replace coef_2007_trend = . if rel_year == -7
replace coef_2007_trend = betas2007_trend[1,2] if rel_year == -6
replace coef_2007_trend = betas2007_trend[1,3] if rel_year == -5
replace coef_2007_trend = betas2007_trend[1,4] if rel_year == -4
replace coef_2007_trend = betas2007_trend[1,5] if rel_year == -3
replace coef_2007_trend = betas2007_trend[1,6] if rel_year == -2
replace coef_2007_trend = betas2007_trend[1,7] if rel_year == -1
replace coef_2007_trend = 0 if rel_year == 0  // Base Year (ommitted)
replace coef_2007_trend = betas2007_trend[1,8] if rel_year == 1
replace coef_2007_trend = betas2007_trend[1,9] if rel_year == 2
replace coef_2007_trend = betas2007_trend[1,10] if rel_year == 3
replace coef_2007_trend = betas2007_trend[1,11] if rel_year == 4
replace coef_2007_trend = betas2007_trend[1,12] if rel_year == 5
replace coef_2007_trend = betas2007_trend[1,13] if rel_year == 6
replace coef_2007_trend = betas2007_trend[1,14] if rel_year == 7
replace coef_2007_trend = betas2007_trend[1,15] if rel_year == 8
replace coef_2007_trend = betas2007_trend[1,16] if rel_year == 9
replace coef_2007_trend = betas2007_trend[1,17] if rel_year == 10
replace coef_2007_trend = betas2007_trend[1,18] if rel_year == 11
replace coef_2007_trend = betas2007_trend[1,19] if rel_year == 12

* Filling SD errors from 2007 cohort (PE)
replace se_2007_trend = . if rel_year == -7
replace se_2007_trend = vars2007_trend[1,2] if rel_year == -6
replace se_2007_trend = vars2007_trend[1,3] if rel_year == -5
replace se_2007_trend = vars2007_trend[1,4] if rel_year == -4
replace se_2007_trend = vars2007_trend[1,5] if rel_year == -3
replace se_2007_trend = vars2007_trend[1,6] if rel_year == -2
replace se_2007_trend = vars2007_trend[1,7] if rel_year == -1
replace se_2007_trend = 0 if rel_year == 0  // Base Year (ommitted)
replace se_2007_trend = vars2007_trend[1,8] if rel_year == 1
replace se_2007_trend = vars2007_trend[1,9] if rel_year == 2
replace se_2007_trend = vars2007_trend[1,10] if rel_year == 3
replace se_2007_trend = vars2007_trend[1,11] if rel_year == 4
replace se_2007_trend = vars2007_trend[1,12] if rel_year == 5
replace se_2007_trend = vars2007_trend[1,13] if rel_year == 6
replace se_2007_trend = vars2007_trend[1,14] if rel_year == 7
replace se_2007_trend = vars2007_trend[1,15] if rel_year == 8
replace se_2007_trend = vars2007_trend[1,16] if rel_year == 9
replace se_2007_trend = vars2007_trend[1,17] if rel_year == 10
replace se_2007_trend = vars2007_trend[1,18] if rel_year == 11
replace se_2007_trend = vars2007_trend[1,19] if rel_year == 12

* Calculating CI (95%)
gen ci_upper_2007_trend = coef_2007_trend + 1.96 * se_2007_trend
gen ci_lower_2007_trend = coef_2007_trend - 1.96 * se_2007_trend

* PE graph (2007)
twoway (rcap ci_upper_2007_trend ci_lower_2007_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007_trend rel_year if rel_year >= -6 & rel_year <= 12, mcolor(navy) msymbol(circle)) ///
       (connect coef_2007_trend rel_year if rel_year >= -6 & rel_year <= 12, lcolor(navy)) ///
       (scatter coef_2007_trend rel_year if rel_year == 0, msymbol(diamond) mcolor(red) msize(large)), ///
       ytitle("Coefficient") xtitle("Years Since Treatment") ///
       xline(0, lpattern(dash) lcolor(red)) yline(0, lpattern(dash) lcolor(black)) ///
       xlabel(-6(1)12) ///
       title("Pernambuco (2007)") ///
       legend(off) name(graph_2007_trend, replace)
	   
	   graph export "${outdir}/graphs/robustness_event_study_PE_trends.pdf", replace
