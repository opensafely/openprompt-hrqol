//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open a log file ***
cap log close
log using "output/mi_models.log", replace
clear

//*** Import data ***
use "./output/op_tpp_linked.dta", clear
drop if merge_link!=3
drop if survey_response==.

gen disutI=0 if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1
replace disutI=1 if disutI==.
replace disutI=. if disutility==.
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
replace base_hh_income=. if base_hh_income==9 | base_hh_income==10
replace comorbid_count=3 if comorbid_count>3 & !missing(comorbid_count)

// Imputation
// drop unused
keep patient_id survey_response base_ethnicity base_highest_edu base_disability ///
male base_hh_income imd_q5 comorbid_count age_bands long_covid ///
mrc_breathlessness fscore disutility
mi set mlong
mi reshape wide disutility fscore mrc_breathlessness long_covid, i(patient_id) j(survey_response)

mi register imputed disutility* fscore* mrc_breathlessness* base_ethnicity ///
base_highest_edu base_disability base_hh_income comorbid_count male age_bands imd_q5

mi impute chained (regress) disutility* fscore* (ologit, aug) mrc_breathlessness* ///
(mlogit, aug) base_ethnicity base_highest_edu base_disability base_hh_income ///
comorbid_count age_bands imd_q5 (logit, aug) male, add(10) rseed(1550703) noisily 

log close
