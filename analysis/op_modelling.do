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

sum age, d
count if survey_response==1 & disutility>1 & !missing(disutility)
count if survey_response==1 & disutI==0
sum utility if survey_response==1 & long_covid==1
sum utility if survey_response==1 & long_covid==0
sum fscore if survey_response==1 & long_covid==1
sum fscore if survey_response==1 & long_covid==0

tabstat utility if long_covid==1, by(survey_response)
tabstat utility if long_covid==0, by(survey_response)

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
xtlogit disutI long_covid i.base_disability male i.age_bands i.comorbid_count ///
ib3.base_highest_edu ib5.base_hh_income i.imd_q5, re or
eststo xt_melogit
predict prob_disut, pr

set scheme s1color
coefplot xt_melogit  (., pstyle(p1) if(@ll>-10&@ul<7)) ///
(., pstyle(p1) if(@ll>-10&@ul>=7)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-10&@ul<7)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-10&@ul>=7) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-10),7)) legend(off) nooffset ///
baselevels coeflabels(1.age_bands="18-29 (Base)" male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 5.base_hh_income="£32,000-47,999 (Base)" ///
1.imd_q5="1st (most deprived) (Base)", labsize(vsmall)) groups(?.base_highest_edu = ///
`""{bf:Highest}" "{bf:Education}""' ?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(1) eform xlabel(, labsize(small)) ///
title("First Part", size(medsmall)) ///
drop(_cons 1.base_disability 2.base_disability long_covid) msize(small)
graph export "$projectdir/output/figures/socio_odds.svg", width(12in) replace

coefplot xt_melogit  (., pstyle(p1) if(@ll>-1&@ul<65)) ///
(., pstyle(p1) if(@ll>-1&@ul>=65)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-1&@ul<65)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-1&@ul>=65) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-1),65)) legend(off) nooffset ///
keep(long_covid 2.base_disability) baselevels xlabel(, labsize(small)) ///
coeflabels(2.base_disability="Disabled" long_covid=`""Self-reported" "Long COVID""') ///
xline(1) eform xtitle("Odds ratio") title("First Part", ///
size(medlarge)) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/mixed_odds_ratio.svg", width(12in) replace

mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
ib3.base_highest_edu ib5.base_hh_income i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
predict disut_loss
eststo xt_mixed

set scheme s1color
coefplot xt_mixed  (., pstyle(p1) if(@ll>-10&@ul<15)) ///
(., pstyle(p1) if(@ll>-10&@ul>=15)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-10&@ul<15)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-10&@ul>=15) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-10),15)) legend(off) nooffset ///
baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 5.base_hh_income="£32,000-47,999 (Base)" ///
1.imd_q5="1st (most deprived) (Base)", labsize(vsmall)) groups(?.base_highest_edu = ///
`""{bf:Highest}" "{bf:Education}""' ?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(0) xlabel(, labsize(small)) ///
title("Second Part", size(medsmall)) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/mixed_coefs.svg", width(12in) replace

coefplot xt_mixed (., pstyle(p1) if(@ll>-10&@ul<15)) ///
(., pstyle(p1) if(@ll>-10&@ul>=15)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-10&@ul<15)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-10&@ul>=15) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-10),15)) legend(off) nooffset ///
keep(1.base_highest_edu 2.base_highest_edu 3.base_highest_edu 4.base_highest_edu ///
5.base_highest_edu 0.base_hh_income 1.base_hh_income 2.base_hh_income 3.base_hh_income ///
4.base_hh_income 5.base_hh_income 6.base_hh_income 7.base_hh_income 8.base_hh_income ///
 1.imd_q5 2.imd_q5 3.imd_q5 4.imd_q5 5.imd_q5) baselevels groups(?.base_highest_edu = ///
`""{bf:Highest}" "{bf:Education}""' ?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""', labsize(small) angle(0)) ///
coeflabels(3.base_highest_edu="College/University (Base)" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)") ///
xline(0) xtitle("Coefficients") title("Socioeconomic factors", size(medlarge))
graph export "$projectdir/output/figures/socio_coefs.svg", width(12in) replace

esttab xt_melogit xt_mixed using "$projectdir/output/tables/longit-model.csv", ///
replace mtitles("Mixed effect logit" "Mixed effect") eform(1) b(a2) ci(2) aic label wide compress   

mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
ib3.base_highest_edu ib5.base_hh_income i.imd_q5 || patient_id:
predict mixed_effect
gen pred_disut=prob_disut*disut_loss
sum pred_disut disutility
estpost tabstat pred_disut mixed_effect disutility, by(long_covid) listwise ///
statistics(n mean sd) columns(statistics)
eststo predicted_disut

esttab predicted_disut using "$projectdir/output/tables/longit-model.csv", ///
append cells(mean(fmt(3)) sd(fmt(3) par)) noobs mtitle("Predicted Disutility" "Disutility") ///
title("Predicted Disutility") gaps compress par number ///
varlabels(pred_disut "Predicted Disutility Two-part model" ///
mixed_effect "Predicted Disutility" disutility "Disutility score")

mixed disutility long_covid i.base_disability male i.age_bands i.base_ethnicity i.comorbid_count ///
ib3.base_highest_edu ib5.base_hh_income i.imd_q5 || patient_id:
eststo base_model

esttab base_model using "$projectdir/output/tables/longit-model.csv", ///
append mtitles("Mixed linear") b(a2) ci(2) aic label wide compress 

// Baseline utility
by patient_id (survey_response), sort: gen baseline_ut = utility[1]
xtlogit disutI long_covid i.base_disability male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_highest_edu i.base_hh_income i.imd_q5 baseline_ut if survey_response>1, re or
eststo melogit_ut

mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
i.base_highest_edu i.base_hh_income i.imd_q5 baseline_ut ///
if disutI>0 & survey_response>1 || patient_id:, cov(exch) 
eststo mixed_ut

esttab melogit_ut mixed_ut using "$projectdir/output/tables/longit-model.csv", ///
mtitles("ME Logit w/baseline utility" "Mixed model w/baseline utility") eform(1) b(a2) ci(2) ///
aic label wide compress append

eststo clear
mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
i.base_highest_edu i.base_hh_income i.imd_q5 i.all_covid_hosp ///
|| patient_id:
eststo hosps

esttab hosps using "$projectdir/output/tables/longit-model.csv", ///
mtitles("Hospitalisations") b(a2) ci(2) aic label wide compress append

// Selective attrition
bysort patient_id: egen maxsurvey = max(survey_response)

reg maxsurvey long_covid male i.age_bands i.base_ethnicity i.comorbid_count ///
i.base_disability i.base_highest_edu i.base_hh_income i.imd_q5 
eststo attrition

esttab attrition using "$projectdir/output/tables/selective_attrition.csv", ///
replace mtitles("Max survey response") b(a2) ci(2) aic label wide compress

log close
