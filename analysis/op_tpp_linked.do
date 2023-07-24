//*** Open a log file ***
cap log close
log using "output/linked-tpp.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"
sysdir set PLUS "analysis/Extra_ados"

//*** Import data ***
!gunzip "output/openprompt_linked_tpp.csv.gz"
import delimited using "output/openprompt_linked_tpp.csv"

//*** TPP Demographics ***
encode practice_nuts, gen(region)
gen male=1 if sex=="male"
replace male=0 if sex=="female"
gen first_lc_date=date(first_lc, "YMD")
gen first_covhosp_date=date(first_covid_hosp, "YMD")
format first_lc_date first_covhosp_date %td
sort patient_id
save "./output/openprompt_linked_tpp.dta", replace
clear

//*** Merge with App data ***
use "./output/openprompt_dataset.dta", clear
merge m:1 patient_id using "./output/openprompt_linked_tpp.dta"
rename _merge merge_link

//*** Mapping EQ5D with linked ***
eq5dmap utility, covariates(age male) items(mobility selfcare activity pain anxiety) direction(5->3)
gen disutility=1-utility
save "./output/op_tpp_linked.dta", replace

log close