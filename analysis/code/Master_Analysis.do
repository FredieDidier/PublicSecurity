////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

clear all
discard
set more off
capture log close
version 18.0

global GITHUB_PATH "/Users/fredie/Documents/GitHub/PublicSecurity"
global DROPBOX_PATH "/Users/fredie/Library/CloudStorage/Dropbox/PublicSecurity"

* make sure to set all macro globals
global inpdir				"${DROPBOX_PATH}/build/workfile/output"
global outdir				"${GITHUB_PATH}/analysis/output"
global codedir    			"${GITHUB_PATH}/analysis/code"
global tmp					"${GITHUB_PATH}/analysis/tmp"


/* Make sure folders exist */
capture mkdir "${tmp}"
capture mkdir "${outdir}"
capture mkdir "${outdir}/graphs/"
capture mkdir "${outdir}/tables/"

*****************************
* Main Analysis
*****************************

* Main Regression
do "${codedir}/_figure4a_4b.do" // also includes table B.1 code

* Heterogenity by Local Capacity and Police Acessibility Regression
do "${codedir}/_figure5a_5b.do" // also includes table B.2 code

* Young Non-White Regression
do "${codedir}/_figure6a_6b.do" // also includes table B.8 code

* Determinants of local capacity
do "${codedir}/_tableA.1.do"

* Spillover Analysis
do "${codedir}/_figureB.1.do"

* Robustness Checks (Restricting Sample to cities less than 50km from PE's border)
do "${codedir}/_table_B.3.do"

* Robustness Checks (Removing Spillovers municipalities from Sample)
do "${codedir}/_table_B.4.do"

* Robustness Checks (Removing SE state from Sample)
do "${codedir}/_table_B.5.do"

* Robustness Checks (Removing MA and PI states from Sample)
do "${codedir}/_table_B.6.do"

* Robustness Checks (Removing BA and MA states from Sample)
do "${codedir}/_table_B.7.do"

