//*** Open log file ***
cap log close
log using "output/op-baseline-table1.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"

//*** Import data ***
use "output/openprompt_dataset.dta", clear

//*** Table1_mc baseline demographic ***
label variable ethnicity_cat "Ethnicity"
label variable highest_educ "Highest education"
label variable sex "Gender"
label variable relation_status "Relationship status"
label variable disabled "Disability"
label variable covid_n "Number of COVID-19 episodes"
label variable vaccine_n "Number of COVID-19 vaccines"
label variable vaccine_hist "Have you had a COVID-19 vaccine"
label variable covid_history "Have you had COVID-19"
label variable covid_recovered "Recovered from COVID-19"
label variable covid_symptoms "Length of COVID-19 symptoms"
label variable hh_inc "Household Income"

table1_mc if survey_response==1, vars(ethnicity_cat cat %5.1f \ sex cat %5.1f \ ///
highest_educ cat %5.1f\ relation_status cat %5.1f\ hh_inc cat %5.1f \ disabled cat %5.1f\ ///
unemployed cat %5.1f\ covid_n cat %5.1f \ vaccine_n cat %5.1f \ vaccine_hist cat %5.1f \ ///
covid_history cat %5.1f \ covid_recovered cat %5.1f \ covid_symptoms cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",")  ///
saving("output/table1_demographic.xls", replace)
preserve

import excel "output/table1_demographic.xls", clear
outsheet * using "output/table1_demographic.csv", comma nonames replace

//*** Questionnaire responses ***
restore
table1_mc if survey_response==1, vars(mobility cat %5.1f \ selfcare cat %5.1f \ ///
activity cat %5.1f \ pain cat %5.1f \ anxiety cat %5.1f \ ///
work_effect cat %5.1f \ life_effect cat %5.1f \ breathlessness_mrc cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",")  ///
saving("output/table1_questions.xls", replace)
preserve

import excel "output/table1_questions.xls", clear
outsheet * using "output/table1_questions.csv", comma nonames replace

restore
hist UK_crosswalk if survey_response==1, freq xtitle(EQ-5D Index Score) fcolor(khaki)
graph export "output/baseline_EQ5D.svg", width(12in) replace
log close
