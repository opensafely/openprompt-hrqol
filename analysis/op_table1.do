//*** Open log file ***
cap log close
log using "logs/op-baseline-table1.log", replace
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
unemployed bin %5.1f\ covid_n conts %5.1f \ vaccine_n conts %5.1f \ vaccine_hist cat %5.1f \ ///
covid_history cat %5.1f \ covid_recovered cat %5.1f \ covid_symptoms cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",")  ///
saving("/output/tables/table1_demograph.xls", replace)
preserve

import excel "/output/tables/table1_demo.xls", clear
outsheet * using "/output/tables/table1_demo.csv", comma nonames replace

//*** Questionnaire responses ***
restore
label variable mobility_eq5d "Mobility"
label variable self_care_eq5d "Self-care"
label variable usual_activity_eq5d "Usual Activities"
label variable pain_discomfort_eq5d "Pain/Discomfort"
label variable anx_depression_eq5d "Anxiety/Depression"
table1_mc if survey_response==1, vars(mobility_eq5d cat %5.1f \ self_care_eq5d cat %5.1f \ ///
usual_activity_eq5d cat %5.1f \ pain_discomfort_eq5d cat %5.1f \ anx_depression_eq5d cat %5.1f \ ///
work_effect cat %5.1f \ life_effect cat %5.1f \ breathlessness_mrc cat %5.1f) ///
nospacelowpercent percent_n onecol missing iqrmiddle(",") ///
saving("/output/tables/table1_questions.xls", replace)

import excel "/output/tables/table1_questions.xls", clear
outsheet * using "/output/tables/table1_questions.csv", comma nonames replace

log close