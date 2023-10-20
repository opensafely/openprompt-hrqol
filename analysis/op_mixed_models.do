//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open a log file ***
cap log close
log using "output/mixed-glm.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"

//*** Import data ***
use "./output/op_tpp_linked.dta", clear
drop if merge_link!=3

gen disutI=0 if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1
replace disutI=1 if disutI==.
replace disutI=. if disutility==.

recode all_covid_hosp (2=1)
label define hosps 0 "No" 1 "Yes"
label values all_covid_hosp hosps
xtset patient_id survey_response

replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
replace base_hh_income=. if base_hh_income==9 | base_hh_income==10
replace comorbid_count=3 if comorbid_count>3 & !missing(comorbid_count)

// Demographic comparison
mixed disutility long_covid male i.age_bands i.comorbid_count ///
if disutI>0 || patient_id:, cov(exch) 
eststo base

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_ethnicity ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_eth

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_hh_income ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_inc

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_disability ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_disabled

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_highest_edu ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_educ

mixed disutility long_covid male i.age_bands i.comorbid_count i.region ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_region

mixed disutility long_covid male i.age_bands i.comorbid_count i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_imd

mixed disutility long_covid male i.age_bands i.comorbid_count i.all_covid_hosp ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_hosps

esttab base base_eth base_inc base_disabled base_educ base_region base_imd base_hosps ///
using "$projectdir/output/tables/mixed-models.csv", ///
replace mtitles("Base" "Ethnicity" "Income" "Disability" "Education" "Region" "IMD" "Hospitalised") ///
b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') 

mixed disutility long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.region i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
eststo full

esttab full using "$projectdir/output/tables/mixed-models.csv", ///
mtitles("Full model") b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') ///
	append
	
eststo clear


// Mixed effects
mixed disutility long_covid male i.age_bands i.comorbid_count i.base_disability ///
if disutI>0 || patient_id:, cov(exch) 
eststo base

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_disability ///
i.mrc_breathlessness if disutI>0 || patient_id:, cov(exch) 
eststo base_mrc

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_disability fscore ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_fscore

mixed disutility long_covid male i.age_bands i.comorbid_count i.base_disability ///
i.mrc_breathlessness fscore if disutI>0 || patient_id:, cov(exch) 
eststo all_proms

coefplot, keep(long_covid male 1.age_bands 2.age_bands 3.age_bands 4.age_bands 5.age_bands ///
6.age_bands 2.base_disability 0.comorbid_count 1.comorbid_count 2.comorbid_count ///
3.comorbid_count) baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)") ///
 headings(0.comorbid_count="Comorbidities" 1.age_bands="Age groups") ///
xline(0) xtitle("Coefficients") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/demo_proms_coefs.svg", width(12in) replace

coefplot, keep(long_covid 1.mrc_breathlessness 2.mrc_breathlessness 3.mrc_breathlessness ///
4.mrc_breathlessness 5.mrc_breathlessness fscore) baselevels coeflabels( ///
long_covid=`""Self-reported" "Long COVID""' 1.mrc_breathlessness="Grade 1 (Base)" ///
2.mrc_breathlessness="Grade 2" 3.mrc_breathlessness="Grade 3" ///
4.mrc_breathlessness="Grade 4" 5.mrc_breathlessness="Grade 5" fscore="FACIT-F (reversed)") ///
 headings(0.comorbid_count="Comorbidities" 1.mrc_breathlessness="MRC Dyspnoea Scale") ///
xline(0) xtitle("Coefficients") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/proms_coefs.svg", width(12in) replace

esttab base base_mrc base_fscore all_proms using "$projectdir/output/tables/mixed-proms.csv", ///
replace mtitles("Base" "MRC" "Facit" "All") b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') 

xtset patient_id survey_response
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
xtlogit disutI long_covid male i.age_bands i.comorbid_count i.base_disability ///
i.mrc_breathlessness fscore, re
eststo part_one

coefplot, keep(long_covid male 1.age_bands 2.age_bands 3.age_bands 4.age_bands 5.age_bands ///
6.age_bands 2.base_disability 0.comorbid_count 1.comorbid_count 2.comorbid_count ///
3.comorbid_count) baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)") ///
 headings(0.comorbid_count="Comorbidities" 1.age_bands="Age groups") ///
xline(1) eform xtitle("Odds ratio") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/demo_odds.svg", width(12in) replace

coefplot, keep(long_covid 1.mrc_breathlessness 2.mrc_breathlessness 3.mrc_breathlessness ///
4.mrc_breathlessness 5.mrc_breathlessness fscore) baselevels coeflabels( ///
long_covid=`""Self-reported" "Long COVID""' 1.mrc_breathlessness="Grade 1 (Base)" ///
2.mrc_breathlessness="Grade 2" 3.mrc_breathlessness="Grade 3" ///
4.mrc_breathlessness="Grade 4" 5.mrc_breathlessness="Grade 5" fscore="FACIT-F (reversed)") ///
 headings(0.comorbid_count="Comorbidities" 1.mrc_breathlessness="MRC Dyspnoea Scale") ///
xline(1) eform xtitle("Odds ratio") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/proms_odds.svg", width(12in) replace

esttab part_one all_proms using "$projectdir/output/tables/mixed-proms.csv", ///
append mtitles("ME Logit" "Mixed Linear") b(a2) ci(2) aic label wide compress eform


log close
