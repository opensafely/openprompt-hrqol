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
drop if merge_link!=3

gen disutI=0 if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1
replace disutI=1 if disutI==.
replace disutI=. if disutility==.
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
replace base_hh_income=. if base_hh_income==9
replace all_covid_hosp=2 if all_covid_hosp>2 & !missing(all_covid_hosp)

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


// Mixed effect logistic & linear models
xtset patient_id survey_response
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
xtlogit disutI long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability ib3.base_highest_edu ib5.base_hh_income i.imd_q5, re
eststo xt_melogit 

coefplot, keep(1.base_highest_edu 2.base_highest_edu 3.base_highest_edu 4.base_highest_edu ///
5.base_highest_edu 1.base_hh_income 2.base_hh_income 3.base_hh_income 4.base_hh_income ///
5.base_hh_income 6.base_hh_income 7.base_hh_income 8.base_hh_income 1.imd_q5 2.imd_q5 ///
3.imd_q5 4.imd_q5 5.imd_q5) baselevels headings(1.base_highest_edu="Highest education" ///
1.base_hh_income="Household income" 1.imd_q5="IMD Quintiles") ///
coeflabels(3.base_highest_edu="College/University (Base)" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)") /// 
xline(1) eform xtitle("Odds ratio") title("Socioeconomic factors", ///
size(medlarge))
graph export "$projectdir/output/figures/socio_odds.svg", width(12in) replace

coefplot, keep(long_covid male 1.age_bands 2.age_bands 3.age_bands 4.age_bands 5.age_bands ///
6.age_bands 2.base_disability 0.comorbid_count 1.comorbid_count 2.comorbid_count ///
3.comorbid_count) baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)") ///
 headings(0.comorbid_count="Comorbidities" 1.age_bands="Age groups") ///
xline(1) eform xtitle("Odds ratio") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/mixed_odds_ratio.svg", width(12in) replace

mixed disutility long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability ib3.base_highest_edu ib5.base_hh_income i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
eststo xt_mixed

coefplot, keep(long_covid male 1.age_bands 2.age_bands 3.age_bands 4.age_bands 5.age_bands ///
6.age_bands 2.base_disability 0.comorbid_count 1.comorbid_count 2.comorbid_count ///
3.comorbid_count) baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)")  ///
headings(0.comorbid_count="Comorbidities" 1.age_bands="Age groups") ///
xline(0) xtitle("Coefficients") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/mixed_coefs.svg", width(12in) replace

coefplot, keep(1.base_highest_edu 2.base_highest_edu 3.base_highest_edu 4.base_highest_edu ///
5.base_highest_edu 0.base_hh_income 1.base_hh_income 2.base_hh_income 3.base_hh_income 4.base_hh_income ///
5.base_hh_income 6.base_hh_income 7.base_hh_income 8.base_hh_income 1.imd_q5 2.imd_q5 ///
3.imd_q5 4.imd_q5 5.imd_q5) baselevels headings(1.base_highest_edu="Highest education" ///
1.base_hh_income="Household income" 1.imd_q5="IMD Quintiles") ///
coeflabels(3.base_highest_edu="College/University (Base)" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)") ///
xline(0) xtitle("Coefficients") title("Socioeconomic factors", ///
size(medlarge))
graph export "$projectdir/output/figures/socio_coefs.svg", width(12in) replace

esttab xt_melogit xt_mixed using "$projectdir/output/tables/longit-model.csv", ///
replace mtitles("Mixed effect logit" "Mixed effect") b(a2) ci(2) aic label wide compress eform  

mixed disutility long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability ib3.base_highest_edu ib5.base_hh_income i.imd_q5 || patient_id:
eststo base_model

coefplot, keep(long_covid male 1.age_bands 2.age_bands 3.age_bands 4.age_bands 5.age_bands ///
6.age_bands 2.base_disability 0.comorbid_count 1.comorbid_count 2.comorbid_count ///
3.comorbid_count) baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)")  ///
headings(0.comorbid_count="Comorbidities" 1.age_bands="Age groups") ///
xline(0) xtitle("Coefficients") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/mixed_demos.svg", width(12in) replace

coefplot, keep(1.base_highest_edu 2.base_highest_edu 3.base_highest_edu 4.base_highest_edu ///
5.base_highest_edu 0.base_hh_income 1.base_hh_income 2.base_hh_income 3.base_hh_income 4.base_hh_income ///
5.base_hh_income 6.base_hh_income 7.base_hh_income 8.base_hh_income 1.imd_q5 2.imd_q5 ///
3.imd_q5 4.imd_q5 5.imd_q5) baselevels headings(1.base_highest_edu="Highest education" ///
1.base_hh_income="Household income" 1.imd_q5="IMD Quintiles") ///
coeflabels(3.base_highest_edu="College/University (Base)" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)") ///
xline(0) xtitle("Coefficients") title("Socioeconomic factors", ///
size(medlarge))
graph export "$projectdir/output/figures/mixed_socio.svg", width(12in) replace

esttab base_model using "$projectdir/output/tables/longit-model.csv", ///
append mtitles("Mixed linear") b(a2) ci(2) aic label wide compress eform

// Baseline utility
by patient_id (survey_response), sort: gen baseline_ut = utility[1]
xtlogit disutI long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 baseline_ut if survey_response>1, re
eststo melogit_ut

mixed disutility long_covid male i.age_bands i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 baseline_ut ///
if disutI>0 & survey_response>1 || patient_id:, cov(exch) 
eststo mixed_ut

esttab melogit_ut mixed_ut using "$projectdir/output/tables/longit-model.csv", ///
mtitles("ME Logit w/baseline utility" "Mixed model w/baseline utility") b(a2) ci(2) ///
aic label wide compress eform append

eststo clear
mixed disutility long_covid male i.age_bands i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 i.all_covid_hosp ///
|| patient_id:
eststo hosps

esttab hosps using "$projectdir/output/tables/longit-model.csv", ///
mtitles("Hospitalisations") b(a2) ci(2) aic label wide compress eform append

// Selective attrition
bysort patient_id: egen maxsurvey = max(survey_response)

reg maxsurvey long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 
eststo attrition

esttab attrition using "$projectdir/output/tables/selective_attrition.csv", ///
replace mtitles("Max survey response") b(a2) ci(2) aic label wide compress

log close
