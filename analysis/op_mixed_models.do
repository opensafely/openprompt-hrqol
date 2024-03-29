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
drop if merge_link!=3

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
replace comorbid_count=3 if comorbid_count>3 & !missing(comorbid_count)
xtset patient_id survey_response

// Demographic comparison
xtlogit disutI long_covid male i.age_bands i.comorbid_count, re or
eststo base_or
mixed disutility long_covid male i.age_bands i.comorbid_count ///
if disutI>0 || patient_id:, cov(exch) 
eststo base

xtlogit disutI long_covid male i.age_bands i.comorbid_count i.base_ethnicity, re or
eststo eth_or
mixed disutility long_covid male i.age_bands i.comorbid_count i.base_ethnicity ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_eth

xtlogit disutI long_covid male i.age_bands i.comorbid_count i.base_hh_income, re or
eststo inc_or
mixed disutility long_covid male i.age_bands i.comorbid_count i.base_hh_income ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_inc

xtlogit disutI long_covid i.base_disability male i.age_bands i.comorbid_count, re or
eststo disabled_or
mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_disabled

xtlogit disutI long_covid male i.age_bands i.comorbid_count i.base_highest_edu, re or
eststo educ_or
mixed disutility long_covid male i.age_bands i.comorbid_count i.base_highest_edu ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_educ

xtlogit disutI long_covid male i.age_bands i.comorbid_count i.region, re or
eststo region_or
mixed disutility long_covid male i.age_bands i.comorbid_count i.region ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_region

xtlogit disutI long_covid male i.age_bands i.comorbid_count i.imd_q5, re or 
eststo imd_or
mixed disutility long_covid male i.age_bands i.comorbid_count i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_imd

xtlogit disutI long_covid male i.age_bands i.comorbid_count i.all_covid_hosp, re or 
eststo hosps_or
mixed disutility long_covid male i.age_bands i.comorbid_count i.all_covid_hosp ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_hosps

esttab base_or base eth_or base_eth inc_or base_inc disabled_or base_disabled ///
educ_or base_educ region_or base_region imd_or base_imd hosps_or base_hosps ///
using "$projectdir/output/tables/mixed-models.csv", ///
replace mtitles("Base" "Ethnicity" "Income" "Disability" "Education" "Region" "IMD" "Hospitalised") ///
b(a2) se(2) aic eform label wide compress ///
	varlabels(`e(labels)') 

mixed disutility long_covid i.base_disability male i.age_bands i.base_ethnicity ///
i.comorbid_count i.base_highest_edu i.base_hh_income i.region i.imd_q5 ///
if disutI>0 || patient_id:, cov(exch) 
eststo full

esttab full using "$projectdir/output/tables/mixed-models.csv", ///
mtitles("Full model") b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') ///
	append
	
eststo clear


// Mixed effects
mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
if disutI>0 || patient_id:, cov(exch) 
eststo base

mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
i.mrc_breathlessness if disutI>0 || patient_id:, cov(exch) 
eststo base_mrc

mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count fscore ///
if disutI>0 || patient_id:, cov(exch) 
eststo base_fscore

mixed disutility long_covid i.base_disability male i.age_bands i.comorbid_count ///
i.mrc_breathlessness fscore if disutI>0 || patient_id:, cov(exch) 
eststo all_proms

set scheme s1color
coefplot all_proms, baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 1.mrc_breathlessness="Grade 1 (Base)" ///
2.mrc_breathlessness="Grade 2" 3.mrc_breathlessness="Grade 3" ///
4.mrc_breathlessness="Grade 4" 5.mrc_breathlessness="Grade 5" fscore="FACIT-F" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)", labsize(vsmall)) ///
groups(?.base_highest_edu = `""{bf:Highest}" "{bf:Education}""' ///
?.base_hh_income=`""{bf:Household}" "{bf:Income}""' fscore="{bf:FACIT-F Reversed}" ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ?.mrc_breathlessness="{bf:MRC Dyspnoea}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(0) xlabel(, labsize(small)) ///
title("PROMs Coefficients", size(medsmall)) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/demo_proms_coefs.svg", width(12in) replace

coefplot, keep(long_covid 1.mrc_breathlessness 2.mrc_breathlessness 3.mrc_breathlessness ///
4.mrc_breathlessness 5.mrc_breathlessness fscore) baselevels coeflabels( ///
long_covid=`""Self-reported" "Long COVID""' 1.mrc_breathlessness="Grade 1 (Base)" ///
2.mrc_breathlessness="Grade 2" 3.mrc_breathlessness="Grade 3" ///
4.mrc_breathlessness="Grade 4" 5.mrc_breathlessness="Grade 5" fscore="FACIT-F (reversed)") ///
 headings(0.comorbid_count="Comorbidities" 1.mrc_breathlessness="MRC Dyspnoea Scale") ///
xline(0) xtitle("Coefficients") ///
title("Demographic indicators", size(medlarge))
graph export "$projectdir/output/figures/proms_coefs.svg", width(12in) replace

esttab base base_mrc base_fscore all_proms using "$projectdir/output/tables/mixed-proms.csv", ///
replace mtitles("Base" "MRC" "Facit" "All") b(a2) se(2) aic label wide compress eform ///
	varlabels(`e(labels)') 

xtset patient_id survey_response
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
xtlogit disutI long_covid i.base_disability male i.age_bands i.comorbid_count ///
i.mrc_breathlessness fscore, re or
eststo part_one

set scheme s1color
coefplot part_one  (., pstyle(p1) if(@ll>-10&@ul<8)) ///
(., pstyle(p1) if(@ll>-10&@ul>=8)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-10&@ul<8)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-10&@ul>=8) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-10),8)) legend(off) nooffset ///
baselevels coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 1.mrc_breathlessness="Grade 1 (Base)" ///
2.mrc_breathlessness="Grade 2" 3.mrc_breathlessness="Grade 3" ///
4.mrc_breathlessness="Grade 4" 5.mrc_breathlessness="Grade 5" fscore="FACIT-F" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)", ///
labsize(vsmall)) groups(?.base_highest_edu=`""{bf:Highest}" "{bf:Education}""' ///
?.base_hh_income=`""{bf:Household}" "{bf:Income}""' ?.fscore="{bf:FACIT-F Reversed}" ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ?.mrc_breathlessness="{bf:MRC Dyspnoea}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(1) eform xlabel(, labsize(small)) ///
title("PROMs OR", size(medsmall)) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/demo_odds.svg", width(12in) replace

coefplot all_proms (., pstyle(p1) if(@ll>-10&@ul<15)) ///
(., pstyle(p1) if(@ll>-10&@ul>=15)  ciopts(recast(pcarrow)))  ///
(., pstyle(p1) if(@ll<=-10&@ul<15)  ciopts(recast(pcrarrow))) ///
(., pstyle(p1) if(@ll<=-10&@ul>=15) ciopts(recast(pcbarrow))) ///
, transform(* = min(max(@,-10),15)) legend(off) nooffset ///
coeflabels(2.base_disability="Disabled" 1.age_bands="18-29 (Base)" ///
long_covid=`""Self-reported" "Long COVID""' male="Males" 0.comorbid_count="0 (Base)" ///
3.base_highest_edu="College/University (Base)" 1.mrc_breathlessness="Grade 1 (Base)" ///
2.mrc_breathlessness="Grade 2" 3.mrc_breathlessness="Grade 3" ///
4.mrc_breathlessness="Grade 4" 5.mrc_breathlessness="Grade 5" fscore="FACIT-F" ///
5.base_hh_income="£32,000-47,999 (Base)" 1.imd_q5="1st (most deprived) (Base)", labsize(vsmall)) ///
groups(?.base_highest_edu = `""{bf:Highest}" "{bf:Education}""' ///
?.base_hh_income=`""{bf:Household}" "{bf:Income}""' fscore="{bf:FACIT-F Reversed}" ///
?.imd_q5=`""{bf:IMD}" "{bf:Quintiles}""' ?.age_bands="{bf:Age}" ?.mrc_breathlessness="{bf:MRC Dyspnoea}" ///
?.comorbid_count="{bf:Comorbidities}", labsize(small) angle(0)) xline(0) xlabel(, labsize(small)) ///
title("PROMs Coefficients", size(medsmall)) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/proms_odds.svg", width(12in) replace

esttab part_one all_proms using "$projectdir/output/tables/mixed-proms.csv", ///
append mtitles("ME Logit" "Mixed Linear") b(a2) ci(2) aic label wide compress eform(1)


log close
