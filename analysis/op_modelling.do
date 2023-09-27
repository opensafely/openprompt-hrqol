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
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
replace base_hh_income=. if base_hh_income==9

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

// Longitudinal plots
preserve
sort survey_response
xtset patient_id survey_response
bysort patient_id: egen maxsurvey = max(survey_response)
egen mean_full=mean(utility) if maxsurvey==4, by(survey_response long_covid)
egen mean_three=mean(utility) if maxsurvey==3, by(survey_response long_covid)
egen mean_two=mean(utility) if maxsurvey==2, by(survey_response long_covid)
egen mean_one=mean(utility) if maxsurvey==1, by(survey_response long_covid)
egen sd_full= sd(utility) if maxsurvey==4, by(survey_response long_covid)
gen upper = mean_full +1.96*sd_full
gen lower = mean_full -1.96*sd_full
sum mean_full if long_covid==0
sum mean_full if long_covid==1
tab survey_response if long_covid==1 & maxsurvey==4, sum(utility)
tab survey_response if long_covid==0 & maxsurvey==4, sum(utility)
tab survey_response if long_covid==1 & maxsurvey==3, sum(utility)
tab survey_response if long_covid==0 & maxsurvey==3, sum(utility)
tab survey_response if long_covid==1 & maxsurvey==2, sum(utility)
tab survey_response if long_covid==0 & maxsurvey==2, sum(utility)

egen mean_ut_lc = mean(utility) if long_covid==1 & maxsurvey==4, by(survey_response)
gen high_lc=.
gen low_lc=.
forvalues i = 1/4 {
	ci mean utility if survey_response == `i' & long_covid==1 & maxsurvey==4
	replace high_lc = r(ub) if survey_response == `i' & long_covid==1 & maxsurvey==4
	replace low_lc = r(lb) if survey_response == `i' & long_covid==1 & maxsurvey==4
}

egen mean_ut = mean(utility) if long_covid==0 & maxsurvey==4, by(survey_response)
gen high=.
gen low=.
forvalues i = 1/4 {
	ci mean utility if survey_response == `i' & long_covid==0 & maxsurvey==4
	replace high = r(ub) if survey_response == `i' & long_covid==0 & maxsurvey==4
	replace low = r(lb) if survey_response == `i' & long_covid==0 & maxsurvey==4
}

set scheme s1color
sort survey_response
twoway (connected mean_ut_lc survey_response, lcolor(red%80) mcolor(red%40)) ///
(connected mean_ut survey_response, lcolor(blue%80) mcolor(blue%40)) ///
(rcap low_lc high_lc survey_response, lcolor(green%50)) ///
(rcap low high survey_response, lcolor(green%50)) ///
, legend(order(1 "Long COVID" 2 "Recovered from COVID" 3 "95% CI") margin(vsmall) ///
region(lstyle(none))) ytitle(EQ-5D utility score) ylabel(0(0.2)1, angle(0)) ///
xtitle(Month) xlabel(1 "0" 2 "1" 3 "2" 4 "3") ///
title("Mean utility score by Long COVID", size(medlarge))
graph export "$projectdir/output/figures/EQ5D_longcovid.svg", width(12in) replace

xtset patient_id survey_response
twoway (tsline mean_full if long_covid==1, lcolor(red%80)) || ///
(tsline mean_full if long_covid==0, lcolor(blue%80)) || ///
(tsline mean_three if long_covid==1, lcolor(red%60)) || ///
(tsline mean_three if long_covid==0, lcolor(blue%60)) || ///
(tsline mean_two if long_covid==1, lcolor(red%40)) || ///
(tsline mean_two if long_covid==0, lcolor(blue%40)) || ///
(tsline mean_one if long_covid==1, lcolor(red%20)) || ///
(tsline mean_one if long_covid==0, lcolor(blue%20)) ///
, legend(order(1 "Long COVID" 2 "Recovered from COVID") margin(vsmall) ///
region(lstyle(none))) ytitle(EQ-5D utility score) ylabel(0(0.2)1, angle(0)) ///
xtitle(Month) xlabel(1 "0" 2 "1" 3 "2" 4 "3") ///
title("Mean utility score by Long COVID", size(medlarge))
graph export "$projectdir/output/figures/EQ5D_surveys.svg", width(12in) replace
restore

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

// Baseline utility
by patient_id (survey_response), sort: gen baseline_ut = utility[1]
xtlogit disutI long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 baseline_ut if survey_response>1, re
eststo melogit_ut

mixed disutility long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 baseline_ut ///
if disutI>0 & survey_response>1 || patient_id:, cov(exch) 
eststo mixed_ut

esttab melogit_ut mixed_ut using "$projectdir/output/tables/longit-model.csv", ///
mtitles("ME Logit w/baseline utility" "Mixed model w/baseline utility") b(a2) ci(2) ///
aic label wide compress eform append

// Model by long COVID
mixed disutility male i.age_bands i.comorbid_count i.base_disability i.imd_q5 ///
if disutI>0 & long_covid==1|| patient_id:
eststo covid_model

esttab covid_model using "$projectdir/output/tables/longit-model.csv", ///
mtitles("Long COVID specific") b(a2) ci(2) aic label wide compress eform append


log close
