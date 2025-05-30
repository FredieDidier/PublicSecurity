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
do "${codedir}\_figure4a_4b.do"

* Heterogenity by Local Capacity and Police Acessibility Regression
do "${codedir}\_figure5a_5b.do"

* Young Non-White Regression
do "${codedir}\_figure6a_6b.do"

* Determinants of local capacity
do "${codedir}\_tableA.1.do"

* Spillover Analysis
do "${codedir}\_figureB.2.do"
