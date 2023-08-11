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

recode comorbid_count (3=3) (4=3) (5=3) (6=3) (7=3) (8=3) (9=3)
label define count_factor 3 "3+"
label values comorbid_count count_factor

recode n_lc_records (3=3) (4=3) (5=3) (6=3) (7=3) (8=3) (9=3) (10=3) (11=3) (12=3) (13=3) (14=3)
label values n_lc_records count_factor
recode all_covid_hosp (3=2) (4=2) (5=2) (6=2) (7=2) (8=2) (9=2) (10=2) (11=2) (12=2) (13=2) (14=2)
label define two_count 2 "2+"
label values all_covid_hosp two_count

gen age_bands = age
replace age_bands = 1 if age <=29
replace age_bands = 2 if age>29 & age<=39
replace age_bands = 3 if age>39 & age<=49
replace age_bands = 4 if age>49 & age<=59
replace age_bands = 5 if age>59 & age<=69
replace age_bands = 6 if age>69
replace age_bands=. if age==.
label define ages 1 "18-29" 2 "30-39" 3 "40-49" 4 "50-59" 5 "60-69" 6 "70+"
label values age_bands ages

egen imd_q5 = cut(imd), at (0.0 6558.8 13137.6 19706.4 26275.2 32844.0)
recode imd_q5 (0=1) (6558.8=2) (13137.6=3) (19706.4=4) (26275.2=5)
label define quintiles 1 "1st (most deprived)" 2 "2nd" 3 "3rd" 4 "4th" 5 "5th (least deprived)"
label values imd_q5 quintiles

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