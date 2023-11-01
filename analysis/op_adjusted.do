//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open a log file ***
cap log close
log using "output/adjusted_models.log", replace
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

// Base model
mixed disutility long_covid male i.base_disability i.age_bands i.comorbid_count  ///
ib3.base_highest_edu ib5.base_hh_income i.imd_q5 if disutI>0 || patient_id:
eststo full

mixed disutility long_covid male i.base_disability i.age_bands i.comorbid_count  ///
ib3.base_highest_edu if disutI>0 || patient_id:
eststo education

mixed disutility long_covid male i.base_disability i.age_bands i.comorbid_count  ///
ib5.base_hh_income if disutI>0 || patient_id:
eststo income

mixed disutility long_covid male i.base_disability i.age_bands i.comorbid_count  ///
i.imd_q5 if disutI>0 || patient_id:
eststo imd

coefplot full education income imd (., pstyle(p1) if(@ll>-10&@ul<15)) ///
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
title("Demographic indicators", size(medsmall)) drop(_cons 1.base_disability) msize(small)
graph export "$projectdir/output/figures/adjusted_models.svg", width(12in) replace

