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
meglm disutility long_covid male i.age_bands i.comorbid_count ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base

meglm disutility long_covid male i.age_bands i.comorbid_count i.base_ethnicity ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_eth

meglm disutility long_covid male i.age_bands i.comorbid_count i.base_hh_income ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_inc

meglm disutility long_covid male i.age_bands i.comorbid_count i.base_disability ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_disabled

meglm disutility long_covid male i.age_bands i.comorbid_count i.base_highest_edu ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_educ

meglm disutility long_covid male i.age_bands i.comorbid_count i.region ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_region

meglm disutility long_covid male i.age_bands i.comorbid_count i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_imd

meglm disutility long_covid male i.age_bands i.comorbid_count i.all_covid_hosp ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_hosps

esttab base base_eth base_inc base_disabled base_educ base_region base_imd base_hosps ///
using "$projectdir/output/tables/mixed-models.csv", ///
replace mtitles("Base" "Ethnicity" "Income" "Disability" "Education" "Region" "IMD" "Hospitalised") ///
b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') 

eststo clear

// Mixed effect GLMs
meglm disutility long_covid male i.age_bands i.comorbid_count i.base_disability ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base

meglm disutility long_covid male i.age_bands i.comorbid_count i.mrc_breathlessness ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_mrc

meglm disutility long_covid male i.age_bands i.comorbid_count fscore ///
if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo base_fscore

meglm disutility long_covid male i.age_bands i.comorbid_count i.mrc_breathlessness ///
fscore if disutI>0 || patient_id:, cov(exch) family(gamma) link(log)
eststo all_proms

esttab base base_mrc base_fscore all_proms using "$projectdir/output/tables/glm-proms.csv", ///
replace mtitles("Base" "MRC" "Facit" "All") b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') 

log close

