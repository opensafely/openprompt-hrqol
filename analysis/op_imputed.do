//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open a log file ***
cap log close
log using "output/mi_models.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"
sysdir set PLUS "analysis/Extra_ados"

//*** Import data ***
use "./output/op_tpp_linked.dta", clear
drop if merge_link!=3
drop if survey_response==.

replace base_disability=. if base_disability==3
label drop base_disability
recode base_disability (1=0) (2=1)
replace base_highest_edu=. if base_highest_edu==5
replace base_hh_income=. if base_hh_income==9 | base_hh_income==10
replace comorbid_count=3 if comorbid_count>3 & !missing(comorbid_count)

// Imputation
// drop unused
keep patient_id survey_response base_ethnicity base_highest_edu base_disability ///
male base_hh_income imd_q5 comorbid_count age long_covid ///
mrc_breathlessness fscore mobility selfcare activity pain anxiety

reshape wide mobility selfcare activity pain anxiety mrc_breathlessness long_covid ///
fscore, i(patient_id) j(survey_response)

ice mobility* selfcare* activity* pain* anxiety* mrc_breathlessness* fscore* ///
comorbid_count imd_q5 age base_ethnicity base_highest_edu long_covid* base_disability ///
male base_hh_income, m(5) saving(imputed, replace) cmd(mobility* selfcare* ///
activity* pain* anxiety* mrc_breathlessness*:ologit, imd_q5 base_ethnicity ///
base_highest_edu comorbid_count base_hh_income:mlogit, ///
fscore* age:regress, long_covid* base_disability male:logit) seed(1550703)

clear
use imputed
mi import ice, automatic
mi reshape long mobility selfcare activity pain anxiety fscore mrc_breathlessness ///
long_covid, i(patient_id) j(survey_response)
mi describe

eq5dmap utility, covariates(age male) items(mobility selfcare activity pain anxiety) direction(5->3)
gen disutility=1-utility

gen disutI=0 if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1
replace disutI=1 if disutI==.
replace disutI=. if disutility==.

log close
