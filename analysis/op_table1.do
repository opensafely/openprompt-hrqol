//*** Open log file ***
cap log close
log using "output/op-baseline-table1.log", replace
clear

//*** Create filepaths ***
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Set ado file path ***
adopath + "analysis/Extra_ados"

//*** Import data ***
use "output/openprompt_dataset.dta", clear

//*** Table1_mc baseline demographic ***
label variable base_ethnicity "Ethnicity"
label variable base_highest_edu "Highest education"
label variable base_gender "Gender"
label variable base_relationship "Relationship status"
label variable base_disability "Disability"
label variable n_covids "Number of COVID-19 episodes"
label variable n_vaccines "Number of COVID-19 vaccines"
label variable vaccinated "Have you had a COVID-19 vaccine"
label variable covid_history "Have you had COVID-19"
label variable recovered_from_covid "Recovered from COVID-19"
label variable covid_duration "Length of COVID-19 symptoms"
label variable base_hh_income "Household Income"

table1_mc if survey_response==1, vars(base_ethnicity cat %5.1f \ base_gender cat %5.1f \ ///
base_highest_edu cat %5.1f\ base_relationship cat %5.1f\ base_hh_income cat %5.1f \ base_disability cat %5.1f\ ///
employment_status cat %5.1f\ n_covids cat %5.1f \ n_vaccines cat %5.1f \ vaccinated cat %5.1f \ ///
covid_history cat %5.1f \ recovered_from_covid cat %5.1f \ covid_duration cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",")  ///
saving("output/tables/table1_demographic.xls", replace)
preserve

import excel "output/tables/table1_demographic.xls", clear
outsheet * using "output/tables/table1_demographic.csv", comma nonames replace

//*** Questionnaire responses ***
restore
table1_mc if survey_response==1, vars(mobility cat %5.1f \ selfcare cat %5.1f \ ///
activity cat %5.1f \ pain cat %5.1f \ anxiety cat %5.1f \ ///
work_effect cat %5.1f \ life_effect cat %5.1f \ mrc_breathlessness cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",")  ///
saving("output/tables/table1_questions.xls", replace)
preserve

import excel "output/tables/table1_questions.xls", clear
outsheet * using "output/tables/table1_questions.csv", comma nonames replace

restore
set scheme s1color
hist UK_crosswalk if survey_response==1, freq xtitle(EQ-5D Index Score) color(green%40) ///
title("Frequency Distribution of baseline EQ-5D Index Score", size(medlarge))
graph export "output/figures/baseline_EQ5D_utility.svg", width(12in) replace

//*** Baseline EQ-5D-5L by long COVID ***
preserve
drop if survey_response>1
gen test_mobility=mobility
replace test_mobility=test_mobility-0.2 if long_covid==1
replace test_mobility=test_mobility+0.2 if long_covid==0
gen countbygroup=1
collapse (sum) count, by(long_covid test_mobility)
set scheme s1color
twoway (bar count test_mobility if long_covid==1, vertical color(red%40) barwidth(0.4)) ///
(bar count test_mobility if long_covid==0, vertical color(blue%40) barwidth(0.4)), ///
legend(order(1 2) label(1 "Long COVID") label(2 "No Long COVID")) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Mobility", size(medsmall)) ///
xtitle("") ///
xlabel(1 `" "No" "Problems" "' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `" "Extreme/" "Unable to" "', labsize(2)) ///
ytitle("") ///
ylabel(, labsize(2) angle(0)) ///
name(mobility_by_lc, replace)
restore

preserve
drop if survey_response>1
gen test_selfcare=selfcare
replace test_selfcare=test_selfcare-0.2 if long_covid==1
replace test_selfcare=test_selfcare+0.2 if long_covid==0
gen countbygroup=1
collapse (sum) count, by(long_covid test_selfcare)
set scheme s1color
twoway (bar count test_selfcare if long_covid==1, vertical color(red%40) barwidth(0.4)) ///
(bar count test_selfcare if long_covid==0, vertical color(blue%40) barwidth(0.4)), ///
legend(order(1 2) label(1 "Long COVID") label(2 "No Long COVID")) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Self care", size(medsmall)) ///
xtitle("") ///
xlabel(1 `" "No" "Problems" "' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `" "Extreme/" "Unable to" "', labsize(2)) ///
ytitle("") ///
ylabel(, labsize(2) angle(0)) ///
name(selfcare_by_lc, replace)
restore

preserve
drop if survey_response>1
gen test_activity=activity
replace test_activity=test_activity-0.2 if long_covid==1
replace test_activity=test_activity+0.2 if long_covid==0
gen countbygroup=1
collapse (sum) count, by(long_covid test_activity)
set scheme s1color
twoway (bar count test_activity if long_covid==1, vertical color(red%40) barwidth(0.4)) ///
(bar count test_activity if long_covid==0, vertical color(blue%40) barwidth(0.4)), ///
legend(order(1 2) label(1 "Long COVID") label(2 "No Long COVID")) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Usual Activities", size(medsmall)) ///
xtitle("") ///
xlabel(1 `" "No" "Problems" "' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `" "Extreme/" "Unable to" "', labsize(2)) ///
ytitle("") ///
ylabel(, labsize(2) angle(0)) ///
name(activity_by_lc, replace)
restore

preserve
drop if survey_response>1
gen test_pain=pain
replace test_pain=test_pain-0.2 if long_covid==1
replace test_pain=test_pain+0.2 if long_covid==0
gen countbygroup=1
collapse (sum) count, by(long_covid test_pain)
set scheme s1color
twoway (bar count test_pain if long_covid==1, vertical color(red%40) barwidth(0.4)) ///
(bar count test_pain if long_covid==0, vertical color(blue%40) barwidth(0.4)), ///
legend(order(1 2) label(1 "Long COVID") label(2 "No Long COVID")) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Pain/Discomfort", size(medsmall)) ///
xtitle("") ///
xlabel(1 `" "No" "Problems" "' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `" "Extreme/" "Unable to" "', labsize(2)) ///
ytitle("") ///
ylabel(, labsize(2) angle(0)) ///
name(pain_by_lc, replace)
restore

preserve
drop if survey_response>1
gen test_anxiety=anxiety
replace test_anxiety=test_anxiety-0.2 if long_covid==1
replace test_anxiety=test_anxiety+0.2 if long_covid==0
gen countbygroup=1
collapse (sum) count, by(long_covid test_anxiety)
set scheme s1color
twoway (bar count test_anxiety if long_covid==1, vertical color(red%40) barwidth(0.4)) ///
(bar count test_anxiety if long_covid==0, vertical color(blue%40) barwidth(0.4)), ///
legend(order(1 2) label(1 "Long COVID") label(2 "No Long COVID")) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Anxiety/Depression", size(medsmall)) ///
xtitle("") ///
xlabel(1 `" "No" "Problems" "' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `" "Extreme/" "Unable to" "', labsize(2)) ///
ytitle("") ///
ylabel(, labsize(2) angle(0)) ///
name(anxiety_by_lc, replace)
restore

graph combine mobility_by_lc selfcare_by_lc activity_by_lc pain_by_lc anxiety_by_lc, ///
title("Responses at baseline (Frequency)", size(medlarge))
graph export "output/figures/baseline_EQ5D_responses.svg", width(12in) replace
log close
