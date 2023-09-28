//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open a log file ***
cap log close
log using "output/qaly-estimates.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"

//*** Import data ***
use "./output/op_tpp_linked.dta", clear

// Longitudinal plots
preserve
sort survey_response
xtset patient_id survey_response
bysort patient_id: egen maxsurvey = max(survey_response)
egen mean_full=mean(utility) if maxsurvey==4, by(survey_response long_covid)
egen mean_three=mean(utility) if maxsurvey==3, by(survey_response long_covid)
egen mean_two=mean(utility) if maxsurvey==2, by(survey_response long_covid)
egen mean_one=mean(utility) if maxsurvey==1, by(survey_response long_covid)
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

// Utility scores by exposure 
// Complete case 
sort survey_response
xtset patient_id survey_response
bysort patient_id: egen maxsurvey = max(survey_response)
replace base_disability=. if base_disability==3
replace base_highest_edu=. if base_highest_edu==5
replace base_hh_income=. if base_hh_income==9

preserve
keep if maxsurvey==4
estpost tabstat disutility if long_covid==1, by(survey_response) listwise statistics(n mean sd)
eststo long_covid
estpost tabstat disutility if long_covid==0, by(survey_response) listwise statistics(n mean sd)
eststo recovered
esttab long_covid recovered using "$projectdir/output/tables/utility-scores.csv", ///
replace cells(mean(fmt(3)) sd(fmt(3) par)) noobs mtitle("Long COVID" "Recovered") ///
title("Disutility Scores by Long COVID") gaps compress par number ///
varlabels(1 "Baseline" 2 "1 Month" 3 "2 Months" 4 "3 Months")

egen q1= total(disutility) if survey_response<=2, by(patient_id)
gen qaly1=(q1/2)*(1/12)
replace qaly1=. if survey_response==1
egen q2=total(disutility) if survey_response>1 & survey_response<=3, by(patient_id)
gen qaly2= (q2/2)*(1/12)
replace qaly2=. if survey_response==2
egen q3=total(disutility) if survey_response>2 & survey_response<=4, by(patient_id)
gen qaly3 = (q3/2)*(1/12)
replace qaly3=. if survey_response==3

estpost tabstat qaly1 if long_covid==1, statistics(n mean sd)
eststo qaly_lc
estpost tabstat qaly2 if long_covid==1, statistics(n mean sd)
eststo qaly2_lc
estpost tabstat qaly3 if long_covid==1, statistics(n mean sd)
eststo qaly3_lc 
estpost tabstat qaly1 if long_covid==0, statistics(n mean sd)
eststo qaly_rec
estpost tabstat qaly2 if long_covid==0, statistics(n mean sd)
eststo qaly2_rec
estpost tabstat qaly3 if long_covid==0, statistics(n mean sd)
eststo qaly3_rec
esttab qaly_lc qaly2_lc qaly3_lc qaly_rec qaly2_rec qaly3_rec using ///
"$projectdir/output/tables/utility-scores.csv", append cells(mean(fmt(3)) ///
sd(fmt(3) par) n) noobs nomtitles varlabels(qaly1 "1 Month" qaly2 "2 Months" ///
qaly3 "3 Months") title("QALY losses")

log close