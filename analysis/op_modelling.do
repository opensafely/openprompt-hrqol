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

gen disutI=0 if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1
replace disutI=1 if disutI==.
replace disutI=. if disutility==.

// Baseline models 
logit disutI male i.base_ethnicity long_covid i.age_bands i.vaccinated i.comorbid_count if survey_response==1
eststo part_one
mixed disutility male i.base_ethnicity long_covid i.age_bands i.vaccinated i.comorbid_count ///
if survey_response==1 & disutI>0, vce(robust)
eststo part_two
esttab part_one part_two using "$projectdir/output/tables/twopart-model.csv", ///
replace b(a2) se(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') 

logit disutI male long_covid i.age_bands i.vaccinated i.comorbid_count i.imd_q5 if survey_response==1
eststo follow_up
mixed disutility male long_covid i.age_bands i.vaccinated i.comorbid_count i.imd_q5 ///
if survey_response==1 & disutI>0, vce(robust)
eststo mixed_followup 
esttab follow_up mixed_followup using "$projectdir/output/tables/twopart-model.csv", ///
b(a2) se(2) label wide compress eform ///
	title ("`i'") ///
	varlabels(`e(labels)') ///
	append
eststo clear

// Longitudinal 
preserve
sort survey_response
egen mean = mean(utility), by(survey_response long_covid)
set scheme s1color
twoway (connected mean survey_response if long_covid==1, lcolor(red%40) mcolor(red%80)) || ///
(connected mean survey_response if long_covid==0, lcolor(blue%40) mcolor(blue%80)), ///
legend(order(1 "Long COVID" 2 "Recovered from COVID") margin(vsmall) ///
region(lstyle(none))) ytitle(EQ-5D utility score) ylabel(, angle(0)) ///
xtitle(Month) xlabel(1 "0" 2 "1" 3 "2" 4 "3") ///
title("Mean utility score by Long COVID", size(medlarge))
graph export "$projectdir/output/figures/EQ5D_longcovid.svg", width(12in) replace
restore 

xtset patient_id survey_response
xtmelogit disutI long_covid male i.age_bands i.base_disability i.comorbid_count || patient_id:, or
eststo xt_melogit 

mixed disutility long_covid male i.age_bands i.base_disability i.comorbid_count if disutI>0 || patient_id: 
eststo xt_mixed

esttab xt_melogit xt_mixed using "$projectdir/output/tables/longit-model.csv", ///
replace mtitles("Mixed effect logit" "Mixed effect") b(a2) se(2) aic label wide compress eform  


// Model by long COVID
meglm disutility male i.age_bands i.comorbid_count i.base_disability i.imd_q5 ///
if disutI>0 & long_covid==1|| patient_id:, cov(exch) family(gamma) link(log)
eststo covid_model

esttab covid_model using "$projectdir/output/tables/longit-model.csv", ///
mtitles("Long COVID specific") b(a2) se(2) aic label wide compress eform append


log close
