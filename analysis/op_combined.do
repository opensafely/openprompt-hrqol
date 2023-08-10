//*** Open log file ***
cap log close
log using "output/open-prompt-combine.log", replace
clear

//*** Import ***
use "output/op_stata.dta"
//*** Drop non answered ***
drop if base_ethnicity_creation_date==.

//*** Long COVID ***
gen long_covid=0 if covid_duration==1 | covid_duration==2
replace long_covid=1 if covid_duration==3 & recovered_from_covid==2 | covid_duration==4 & recovered_from_covid==2
replace long_covid=0 if recovered_from_covid==1
label define long_covid_symptoms 0 "No Long COVID" 1 "Long COVID"
label values long_covid long_covid_symptoms
gen covid_n=n_covids-1
replace covid_n=4 if n_covids==5 | n_covids==6 | n_covids==7
label define covids_n 4 "4+"
label values covid_n covids_n
gen vaccines_n=n_vaccines-1
replace vaccines_n=4 if n_vaccines==5 | n_vaccines==6 | n_vaccines==7
label values vaccines_n covids_n

replace covid_history=. if covid_history==6
replace vaccinated=. if vaccinated==3

label drop base_highest_edu
recode base_highest_edu (2=1) (3=2) (4=3) (5=4) (6=5)
label define education 1 "Primary School/Less" 2 "Secondary/high school" ///
3 "College/University" 4 "Postgraduate qualification" 5 "Not stated"
label values base_highest_edu education

//*** WPAI Score ***
gen work_effect=work_affected-1
label define affect 0 "0 (No effect on my daily activities)" ///
10 "10 (Completely prevented me from doing my daily activities)"
label values work_effect affect

gen life_effect=life_affected-1
label values life_effect affect

//*** FACIT fatigue ***
label define rvs_facit 0 "Very much" 1 "Quite a bit" 2 "Somewhat" 3 "A little bit" 4 "Not at all"
gen fatigue_facit=facit_fatigue-1
label values fatigue_facit rvs_facit

gen weak_facit=facit_weak-1
label values weak_facit rvs_facit

gen listless_facit=facit_listless-1
label values listless_facit rvs_facit

gen tired_facit=facit_tired-1
label values tired_facit rvs_facit

gen starting_trouble_facit=facit_trouble_starting-1
label values starting_trouble_facit rvs_facit

gen finishing_trouble_facit=facit_trouble_finishing-1
label values finishing_trouble_facit rvs_facit

label define facit 0 "Not at all" 1 "A little bit" 2 "Somewhat" 3 "Quite a bit" 4 "Very much"
gen energy_facit=facit_energy-1
label values energy_facit facit

gen activity_facit=facit_usual_activities-1
label values activity_facit facit

gen sleep_facit=facit_sleep_during_day-1
label values sleep_facit rvs_facit

gen eat_facit=facit_eat-1
label values eat_facit rvs_facit

gen help_facit=facit_need_help-1
label values help_facit rvs_facit

gen frustrated_facit=facit_frustrated-1
label values frustrated_facit rvs_facit

gen social_limited_facit=facit_limit_social_activity-1
label values social_limited_facit rvs_facit

//*** Fscore ***
egen qtotal_facit= rownonmiss(fatigue_facit weak_facit listless_facit tired_facit ///
starting_trouble_facit finishing_trouble_facit energy_facit activity_facit ///
sleep_facit eat_facit help_facit frustrated_facit social_limited_facit)
egen score_facit=rowtotal(fatigue_facit weak_facit listless_facit ///
tired_facit starting_trouble_facit finishing_trouble_facit ///
energy_facit activity_facit sleep_facit eat_facit help_facit ///
frustrated_facit social_limited_facit)
gen fscore = (13*(score_facit)/qtotal_facit)

//*** EQ-5D-5L score (crosswalk using Dolan value set) ***
rename eq5d_mobility mobility
rename eq5d_selfcare selfcare
rename eq5d_usualactivities activity
rename eq5d_pain_discomfort pain
rename eq5d_anxiety_depression anxiety

save "./output/openprompt_dataset.dta", replace
log close
