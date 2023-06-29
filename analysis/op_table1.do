//*** Open log file ***
cap log close
log using "output/op-baseline-table1.log", replace
clear

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
saving("output/table1_demographic.xls", replace)
preserve

import excel "output/table1_demographic.xls", clear
outsheet * using "output/table1_demographic.csv", comma nonames replace

//*** Questionnaire responses ***
restore
table1_mc if survey_response==1, vars(mobility cat %5.1f \ selfcare cat %5.1f \ ///
activity cat %5.1f \ pain cat %5.1f \ anxiety cat %5.1f \ ///
work_effect cat %5.1f \ life_effect cat %5.1f \ mrc_breathlessness cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",")  ///
saving("output/table1_questions.xls", replace)
preserve

import excel "output/table1_questions.xls", clear
outsheet * using "output/table1_questions.csv", comma nonames replace

restore
hist UK_crosswalk if survey_response==1, freq xtitle(EQ-5D Index Score) fcolor(khaki)
graph export "output/baseline_EQ5D.svg", width(12in) replace
log close
