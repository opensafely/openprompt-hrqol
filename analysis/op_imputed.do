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
fscore* age:regress, long_covid* base_disability male:logit) persist seed(1550703)

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

label define income 1 "6000-12999" 2 "13000-18999" 3 "19000-25999" ///
4 "26000-31999" 5 "32000-47999" 6 "48000-63999" 7 "64000-95999" 8 "96000"
label values base_hh_income income

// Imputed models
mi xtset patient_id survey_response
mi estimate, esampvaryok nowarning post: xtlogit disutI long_covid base_disability ///
male i.age_bands i.comorbid_count ib3.base_highest_edu ib5.base_hh_income i.imd_q5, re or
eststo xt_melogit

set scheme s1color
coefplot xt_melogit  (., pstyle(p1) if(@ll>-1&@ul<10)) ///
(., pstyle(p1) if(@ll>-1&@ul>=10)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-1&@ul<10)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-1&@ul>=10) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-1),10)) legend(off) nooffset ///
coeflabels(1.age_bands="18-29 (Base)" male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 5.base_hh_income="£32,000-47,999 (Base)" ///
1.imd_q5="1st (most deprived) (Base)", labsize(vsmall)) groups(?.base_highest_edu = ///
`""{bf:Highest}" "{bf:Education}""' ?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(1) eform ///
xlabel(-1(2)10, labsize(small)) title("First Part", size(medsmall)) ///
grid(none) drop(_cons base_disability long_covid) msize(small)
graph export "$projectdir/output/figures/socio_miodds.svg", width(12in) replace

coefplot xt_melogit  (., pstyle(p1) if(@ll>-1&@ul<35)) ///
(., pstyle(p1) if(@ll>-1&@ul>=35)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-1&@ul<35)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-1&@ul>=35) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-1),35)) legend(off) nooffset ///
keep(long_covid base_disability) baselevels xlabel(0(5)30, labsize(small)) ///
coeflabels(base_disability="Disabled" long_covid=`""Self-reported" "Long COVID""') ///
xline(1) eform xtitle("Odds ratio") title("First Part", ///
size(medlarge)) grid(none) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/mi_melogit.svg", width(12in) replace

mi estimate, esampvaryok nowarning post: mixed disutility long_covid base_disability ///
male i.age_bands i.comorbid_count ib3.base_highest_edu ib5.base_hh_income i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
eststo xt_mixed

set scheme s1color
coefplot xt_mixed, legend(off) nooffset ///
baselevels coeflabels(base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 5.base_hh_income="£32,000-47,999 (Base)" ///
1.imd_q5="1st (most deprived) (Base)", labsize(vsmall)) groups(?.base_highest_edu = ///
`""{bf:Highest}" "{bf:Education}""' ?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(0) xlabel(, labsize(small)) ///
title("Second Part", size(medsmall)) grid(none) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/mixed_micoefs.svg", width(12in) replace

coefplot xt_mixed, legend(off) nooffset ///
keep(1.base_highest_edu 2.base_highest_edu 3.base_highest_edu 4.base_highest_edu ///
5.base_highest_edu 0.base_hh_income 1.base_hh_income 2.base_hh_income 3.base_hh_income ///
4.base_hh_income 5.base_hh_income 6.base_hh_income 7.base_hh_income 8.base_hh_income ///
 1.imd_q5 2.imd_q5 3.imd_q5 4.imd_q5 5.imd_q5) baselevels groups(?.base_highest_edu = ///
`""{bf:Highest}" "{bf:Education}""' ?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""', labsize(small) angle(0)) ///
coeflabels(3.base_highest_edu="College/University (Base)" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)") ///
xline(0) grid(none) xtitle("Coefficients") title("Socioeconomic factors", size(medlarge))
graph export "$projectdir/output/figures/socio_micoefs.svg", width(12in) replace

esttab xt_melogit xt_mixed using "$projectdir/output/tables/mi-model.csv", ///
replace mtitles("Mixed effect logit" "Mixed effect") eform(1) b(a2) ci(2) aic label wide compress

log close
