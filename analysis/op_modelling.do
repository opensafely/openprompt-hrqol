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

hist disutility if disutility>0 & long_covid==1, freq color(red%40) ///
xtitle(EQ-5D Index Score (Non-Zero)) ylabel(, angle(0)) ///
title("Long COVID", size(medlarge)) name(long_covid_disutility, replace)

hist disutility if disutility>0 & long_covid==0, freq color(blue%40) ///
xtitle(EQ-5D Index Score (Non-Zero)) ylabel(, angle(0)) ///
title("No Long COVID", size(medlarge)) name(recovered_disutility, replace)

graph combine long_covid_disutility recovered_disutility, ///
title("Frequency Distribution of baseline EQ-5D Index Score (disutility)")
graph export "$projectdir/output/figures/nonzero_EQ5D_disutility.svg", width(12in) replace

// Baseline models 
gen disutI=0 if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1
replace disutI=1 if disutI==.
replace disutI=. if disutility==.

logit disutI male long_covid i.age_bands i.n_vaccines i.comorbid_count if survey_response==1
eststo part_one
reg disutility male long_covid i.age_bands i.n_vaccines i.comorbid_count if survey_response==1, vce(robust)
eststo part_two

esttab part_one part_two using "$projectdir/output/tables/twopart-model.csv", ///
replace b(a2) ci(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') 

log close
