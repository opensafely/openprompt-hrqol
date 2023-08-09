//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open a log file ***
cap log close
log using "output/models.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"

//*** Import data ***
use "./output/op_tpp_linked.dta", clear

hist disutility if disutility>0, freq xtitle(EQ-5D Index Score (Non-Zero)) color(teal%60) ///
title("Frequency Distribution of baseline EQ-5D Index Score (disutility)", size(medlarge))
graph export "$projectdir/output/figures/nonzero_EQ5D_disutility.svg", width(12in) replace

//*** Set panel/time variables ***
xtset patient_id survey_response
gen disutI=0 if disutility==0
replace disutI=1 if disutility>0
replace disutI=. if disutility==.

//*** GEE ***
/* DUMMY DATA ONLY */
replace disutI=0 if disutI==.

xtlogit disutI male i.age_bands ib2.vaccinated i.comorbid_count, pa vce(robust) base 
//predict prob_disutility
eststo part_one
// xtgee disutI male i.age_bands ib2.vaccinated i.comorbid_count, family(binomial) link(logit) vce(robust) base

xtgee disutility male i.age_bands ib2.vaccinated if disutility>0, family(gamma) link(log)
//predict disut
eststo part_two
esttab part_one part_two using "$projectdir/output/tables/twopart-model.csv", ///
replace b(a2) ci(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') 

/* gen pred_disut=prob_disutility*disut
xtgee disutility male i.age_bands i.comorbid_count if disutility>0, family(gamma) link(log) 
Mixed *
xtlogit disutI male i.age_bands ib2.vaccinated i.comorbid_count, re base or
xtmelogit disutI male i.age_bands ib2.vaccinated i.comorbid_count || patient_id:, base or
mixed disutility male i.age_bands ib2.vaccinated comorbid_count || patient_id: if disutility>0, base
*/

log close