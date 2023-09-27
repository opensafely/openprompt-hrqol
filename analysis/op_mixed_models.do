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

esttab base base_mrc base_fscore all_proms using "$projectdir/output/tables/mixed-proms.csv", ///
replace mtitles("Base" "MRC" "Facit" "All") b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') 


log close

