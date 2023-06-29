//*** Open log file ***
cap log close
log using "output/open-prompt-combine.log", replace
clear

//*** Import ***
use "output/op_stata.dta"
//*** Drop non answered ***
drop if base_ethnicity_consult_date==.

rename long_covid covid_history
gen long_covid=0 if covid_duration==1 | covid_duration==2
replace long_covid=1 if covid_duration==3 | covid_duration==4
label define long_covid_symptoms 0 "No Long COVID" 1 "Long COVID"
label values long_covid long_covid_symptoms

//*** WPAI Score ***
gen work_effect=work_affected
replace work_effect=0 if work_affected==1
replace work_effect=10 if work_affected==11
label define affect 0 "0 (No effect on my daily activities)" ///
10 "10 (Completely prevented me from doing my daily activities)"
label values work_effect affect

gen life_effect=life_affected
replace life_effect=0 if life_affected==1
replace life_effect=10 if life_affected==11
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

gen UK_crosswalk = .												
replace UK_crosswalk= 1.000 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.879 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.848 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.635 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.414 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.837 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.768 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.750 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.537 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.316 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.796 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.740 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.725 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.512 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.291 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.584 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.527 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.513 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.352 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.186 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.264 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.208 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.193 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.112 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk= 0.028 if mobility== 1 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.906 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.837 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.819 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.606 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.385 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.795 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.736 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.721 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.508 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.287 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.767 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.711 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.696 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.483 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.262 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.555 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.498 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.484 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.323 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.157 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.235 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.179 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.164 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.083 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.001 if mobility== 1 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.883 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.827 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.812 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.599 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.378 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.785 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.728 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.714 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.501 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.280 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.760 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.704 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.689 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.476 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.255 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.548 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.491 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.477 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.316 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.150 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.228 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.172 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.157 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.076 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.008 if mobility== 1 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.776 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.719 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.705 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.535 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.359 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.677 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.621 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.606 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.437 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.260 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.653 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.596 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.582 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.412 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.236 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.475 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.419 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.404 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.270 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.131 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.209 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.153 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.138 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.057 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.027 if mobility== 1 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.556 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.500 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.485 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.404 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.320 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.458 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.401 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.387 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.306 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.222 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.433 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.377 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.362 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.281 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.197 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.328 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.272 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.257 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.176 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.092 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.170 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.114 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.099 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.018 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.066 if mobility== 1 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.846 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.779 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.761 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.548 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.327 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.737 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.678 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.663 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.450 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.229 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.709 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.653 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.638 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.425 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.204 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.497 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.441 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.426 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.266 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.099 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.177 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.121 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.106 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.025 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.059 if mobility== 1 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.806 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.748 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.733 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.520 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.299 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.706 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.649 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.634 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.421 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.200 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.681 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.624 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.610 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.397 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.176 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.468 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.412 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.397 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.237 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.071 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.149 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.092 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.078 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.003 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.088 if mobility== 1 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.796 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.740 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.725 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.512 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.291 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.698 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.642 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.627 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.414 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.193 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.673 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.617 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.602 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.389 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.168 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.461 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.405 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.390 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.230 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.063 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.141 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.085 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.070 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.011 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.095 if mobility== 1 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.689 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.633 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.618 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.448 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.272 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.591 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.534 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.520 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.350 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.174 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.566 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.510 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.495 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.325 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.149 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.389 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.332 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.318 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.184 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.044 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.122 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.066 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.051 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.030 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.114 if mobility== 1 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.469 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.413 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.398 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.317 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.233 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.371 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.315 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.300 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.219 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.135 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.346 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.290 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.275 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.194 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.110 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.241 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.185 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.170 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.089 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.005 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.083 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.027 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.012 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.069 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.153 if mobility== 1 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.815 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.759 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.744 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.531 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.310 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.717 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.660 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.646 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.433 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.212 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.692 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.636 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.621 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.408 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.187 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.480 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.423 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.409 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.248 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.082 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.160 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.104 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.089 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.008 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.076 if mobility== 1 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.786 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.730 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.715 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.502 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.281 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.688 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.631 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.617 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.404 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.183 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.663 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.607 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.592 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.379 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.158 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.451 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.394 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.380 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.219 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.053 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.131 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.075 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.060 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.021 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.105 if mobility== 1 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.779 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.723 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.708 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.495 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.274 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.681 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.624 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.610 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.397 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.176 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.656 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.600 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.585 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.372 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.151 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.444 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.387 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.373 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.212 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.046 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.124 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.068 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.053 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.028 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.112 if mobility== 1 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.672 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.615 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.601 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.431 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.255 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.573 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.517 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.502 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.333 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.156 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.549 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.492 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.478 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.308 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.132 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.371 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.315 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.300 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.166 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.027 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.105 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.049 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.034 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.047 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.131 if mobility== 1 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.452 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.396 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.381 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.300 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.216 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.354 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.297 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.283 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.202 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.118 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.329 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.273 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.258 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.177 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.093 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.224 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.168 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.153 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.072 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.012 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.066 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.010 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.005 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.086 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.170 if mobility== 1 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.723 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.667 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.652 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.471 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.283 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.624 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.568 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.553 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.373 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.185 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.600 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.544 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.529 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.348 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.160 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.414 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.357 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.343 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.202 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.055 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.133 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.077 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.062 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.019 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.103 if mobility== 1 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.694 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.638 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.623 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.442 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.254 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.596 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.539 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.525 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.344 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.156 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.571 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.515 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.500 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.319 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.131 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.385 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.328 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.314 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.173 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.026 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.104 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.048 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.033 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.048 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.132 if mobility== 1 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.687 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.631 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.616 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.435 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.247 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.588 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.532 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.517 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.337 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.149 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.564 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.508 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.493 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.312 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.124 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.378 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.321 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.307 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.166 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.019 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.097 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.041 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.026 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.055 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.139 if mobility== 1 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.601 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.545 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.530 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.382 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.228 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.502 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.446 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.431 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.283 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.130 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.478 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.422 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.407 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.259 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.105 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.318 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.262 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.247 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.126 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.000 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.078 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.022 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.007 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.074 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.158 if mobility== 1 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.425 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.369 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.354 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.273 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.189 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.327 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.270 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.256 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.175 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.091 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.302 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.246 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.231 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.150 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.066 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.197 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.141 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.126 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.045 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.039 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.039 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.017 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.032 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.113 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.197 if mobility== 1 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.436 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.380 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.365 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.284 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.200 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.338 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.281 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.267 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.186 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.102 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.313 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.257 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.242 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.161 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.077 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.208 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.152 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.137 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.056 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.028 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.050 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.006 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.021 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.102 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.186 if mobility== 1 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.407 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.351 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.336 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.255 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.171 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.309 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.252 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.238 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.157 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.073 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.284 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.228 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.213 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.132 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.048 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.179 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.123 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.108 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.027 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.057 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.021 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.035 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.050 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.131 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.215 if mobility== 1 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.400 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.344 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.329 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.248 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.164 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.302 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.245 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.231 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.150 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.066 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.277 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.221 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.206 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.125 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.041 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.172 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.116 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.101 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.020 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.064 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.014 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.042 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.057 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.138 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.222 if mobility== 1 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.381 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.325 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.310 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.229 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.145 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.282 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.226 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.211 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.130 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.046 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.258 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.202 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.187 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.106 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.022 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.153 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.097 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.082 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.001 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.083 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.005 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.061 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.076 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.157 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.241 if mobility== 1 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.342 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.286 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.271 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.190 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.106 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.244 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.187 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.173 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.092 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.008 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.219 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.163 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.148 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.067 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.017 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.114 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.058 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.043 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.038 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.122 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.044 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.100 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.115 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.196 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.280 if mobility== 1 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.877 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.809 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.791 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.578 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.357 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.767 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.708 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.693 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.480 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.259 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.739 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.683 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.668 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.455 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.234 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.527 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.470 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.456 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.296 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.129 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.207 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.151 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.136 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.055 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.029 if mobility== 2 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.836 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.778 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.762 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.549 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.328 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.735 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.679 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.664 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.451 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.230 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.710 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.654 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.639 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.426 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.205 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.498 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.442 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.427 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.267 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.100 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.178 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.122 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.107 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.026 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.058 if mobility== 2 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.826 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.770 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.755 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.542 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.321 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.728 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.671 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.657 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.444 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.223 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.703 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.647 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.632 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.419 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.198 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.491 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.434 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.420 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.260 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.093 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.171 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.115 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.100 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.019 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.065 if mobility== 2 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.719 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.663 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.648 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.478 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.302 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.620 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.564 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.549 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.380 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.204 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.596 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.540 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.525 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.355 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.179 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.419 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.362 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.348 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.213 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.074 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.152 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.096 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.081 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.000 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.084 if mobility== 2 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.499 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.443 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.428 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.347 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.263 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.401 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.344 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.330 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.249 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.165 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.376 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.320 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.305 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.224 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.140 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.271 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.215 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.200 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.119 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.035 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.113 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.057 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.042 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.039 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.123 if mobility== 2 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.778 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.720 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.705 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.492 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.271 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.678 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.621 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.606 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.393 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.172 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.653 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.596 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.582 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.369 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.148 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.440 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.384 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.369 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.209 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.043 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.121 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.064 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.050 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.031 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.115 if mobility== 2 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.747 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.691 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.676 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.463 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.242 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.648 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.592 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.577 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.364 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.143 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.624 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.567 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.553 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.340 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.119 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.411 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.355 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.340 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.180 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.014 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.092 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.035 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.021 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.060 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.144 if mobility== 2 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.740 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.683 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.669 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.456 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.235 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.641 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.585 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.570 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.357 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.136 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.617 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.560 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.546 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.333 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.112 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.404 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.348 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.333 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.173 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.007 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.085 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.028 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.014 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.067 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.151 if mobility== 2 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.632 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.576 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.561 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.392 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.216 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.534 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.477 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.463 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.293 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.117 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.509 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.453 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.438 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.269 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.093 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.332 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.276 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.261 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.127 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.013 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.066 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.009 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.005 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.086 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.170 if mobility== 2 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.413 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.356 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.342 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.261 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.177 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.314 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.258 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.243 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.162 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.078 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.290 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.233 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.219 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.138 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.054 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.185 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.128 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.114 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.033 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.051 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.027 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.030 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.044 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.125 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.209 if mobility== 2 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.758 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.702 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.687 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.474 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.253 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.660 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.603 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.589 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.376 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.155 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.635 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.579 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.564 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.351 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.130 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.423 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.366 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.352 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.192 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.025 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.103 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.047 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.032 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.049 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.133 if mobility== 2 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.729 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.673 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.658 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.445 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.224 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.631 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.575 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.560 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.347 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.126 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.606 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.550 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.535 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.322 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.101 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.394 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.338 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.323 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.163 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.004 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.074 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.018 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.003 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.078 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.162 if mobility== 2 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.722 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.666 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.651 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.438 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.217 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.624 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.567 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.553 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.340 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.119 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.599 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.543 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.528 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.315 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.094 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.387 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.330 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.316 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.156 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.011 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.067 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.011 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.004 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.085 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.169 if mobility== 2 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.615 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.559 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.544 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.374 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.198 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.516 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.460 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.445 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.276 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.100 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.492 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.436 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.421 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.251 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.075 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.315 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.258 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.244 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.109 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.030 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.048 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.008 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.023 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.104 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.188 if mobility== 2 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.395 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.339 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.324 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.243 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.159 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.297 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.240 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.226 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.145 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.061 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.272 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.216 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.201 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.120 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.036 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.167 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.111 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.096 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.015 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.069 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.009 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.047 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.062 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.143 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.227 if mobility== 2 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.666 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.610 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.595 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.414 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.227 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.568 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.511 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.497 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.316 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.128 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.543 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.487 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.472 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.291 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.104 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.357 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.300 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.286 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.145 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.002 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.077 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.020 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.006 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.076 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.160 if mobility== 2 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.637 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.581 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.566 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.385 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.198 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.539 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.482 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.468 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.287 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.099 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.514 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.458 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.443 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.262 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.075 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.328 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.272 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.257 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.116 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.030 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.048 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.009 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.023 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.104 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.188 if mobility== 2 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.630 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.574 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.559 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.378 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.191 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.532 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.475 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.461 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.280 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.092 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.507 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.451 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.436 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.255 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.068 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.321 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.264 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.250 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.109 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.038 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.041 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.016 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.031 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.112 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.196 if mobility== 2 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.544 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.488 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.473 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.325 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.172 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.446 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.389 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.375 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.227 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.073 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.421 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.365 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.350 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.202 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.049 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.262 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.205 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.191 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.069 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.057 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.022 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.035 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.050 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.131 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.215 if mobility== 2 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.369 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.312 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.298 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.217 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.133 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.270 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.214 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.199 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.118 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.034 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.246 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.189 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.175 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.094 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.010 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.140 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.084 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.069 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.012 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.096 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.018 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.074 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.089 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.170 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.254 if mobility== 2 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.379 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.323 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.308 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.227 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.143 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.281 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.224 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.210 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.129 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.045 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.256 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.200 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.185 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.104 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.020 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.151 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.095 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.080 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.001 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.085 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.007 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.063 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.078 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.159 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.243 if mobility== 2 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.350 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.294 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.279 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.198 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.114 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.252 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.196 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.181 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.100 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.016 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.227 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.171 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.156 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.075 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.009 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.122 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.066 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.051 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.030 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.114 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.036 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.092 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.107 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.188 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.272 if mobility== 2 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.343 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.287 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.272 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.191 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.107 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.245 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.188 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.174 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.093 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.009 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.220 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.164 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.149 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.068 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.016 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.115 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.059 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.044 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.037 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.121 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.043 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.099 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.114 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.195 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.279 if mobility== 2 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.324 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.268 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.253 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.172 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.088 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.226 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.169 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.155 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.074 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.010 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.201 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.145 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.130 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.049 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.035 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.096 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.040 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.025 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.056 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.140 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.062 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.118 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.133 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.214 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.298 if mobility== 2 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.285 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.229 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.214 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.133 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.049 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.187 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.130 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.116 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.035 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.049 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.162 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.106 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.091 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.010 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.074 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.057 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.001 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.014 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.095 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.179 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.101 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.157 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.172 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.253 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.337 if mobility== 2 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.850 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.794 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.779 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.566 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.345 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.752 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.695 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.681 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.468 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.247 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.727 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.671 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.656 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.443 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.222 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.515 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.458 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.444 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.283 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.117 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.195 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.139 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.124 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.043 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.041 if mobility== 3 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.821 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.765 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.750 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.537 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.316 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.723 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.666 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.652 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.439 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.218 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.698 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.642 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.627 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.414 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.193 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.486 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.429 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.415 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.254 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.088 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.166 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.110 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.095 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.014 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.070 if mobility== 3 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.814 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.758 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.743 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.530 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.309 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.716 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.659 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.645 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.432 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.211 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.691 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.635 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.620 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.407 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.186 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.479 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.422 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.408 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.247 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.081 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.159 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.103 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.088 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.007 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.077 if mobility== 3 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.707 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.650 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.636 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.466 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.290 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.608 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.552 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.537 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.368 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.191 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.584 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.527 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.513 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.343 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.167 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.406 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.350 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.335 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.201 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.062 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.140 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.084 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.069 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.012 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.096 if mobility== 3 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.487 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.431 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.416 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.335 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.251 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.389 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.332 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.318 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.237 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.153 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.364 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.308 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.293 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.212 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.128 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.259 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.203 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.188 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.107 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.023 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.101 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.045 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.030 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.051 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.135 if mobility== 3 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.763 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.707 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.692 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.479 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.258 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.665 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.609 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.594 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.381 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.160 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.640 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.584 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.569 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.356 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.135 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.428 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.372 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.357 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.197 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.030 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.108 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.052 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.037 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.044 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.128 if mobility== 3 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.735 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.678 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.664 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.451 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.230 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.636 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.580 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.565 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.352 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.131 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.612 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.555 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.541 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.328 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.107 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.399 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.343 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.328 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.168 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.002 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.080 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.023 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.009 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.072 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.157 if mobility== 3 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.727 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.671 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.656 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.443 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.222 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.629 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.573 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.558 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.345 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.124 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.604 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.548 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.533 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.320 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.099 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.392 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.336 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.321 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.161 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.006 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.072 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.016 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.001 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.080 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.164 if mobility== 3 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.620 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.564 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.549 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.379 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.203 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.522 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.465 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.451 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.281 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.105 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.497 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.441 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.426 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.256 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.080 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.320 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.263 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.249 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.115 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.025 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.053 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.003 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.018 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.099 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.183 if mobility== 3 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.400 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.344 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.329 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.248 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.164 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.302 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.246 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.231 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.150 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.066 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.277 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.221 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.206 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.125 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.041 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.172 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.116 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.101 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.020 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.064 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.014 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.042 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.057 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.138 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.222 if mobility== 3 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.746 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.690 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.675 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.462 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.241 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.648 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.591 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.577 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.364 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.143 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.623 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.567 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.552 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.339 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.118 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.411 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.354 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.340 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.179 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.013 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.091 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.035 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.020 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.061 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.145 if mobility== 3 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.717 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.661 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.646 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.433 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.212 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.619 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.562 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.548 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.335 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.114 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.594 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.538 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.523 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.310 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.089 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.382 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.325 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.311 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.150 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.016 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.062 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.006 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.009 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.090 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.174 if mobility== 3 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.710 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.654 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.639 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.426 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.205 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.612 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.555 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.541 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.328 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.107 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.587 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.531 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.516 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.303 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.082 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.375 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.318 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.304 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.143 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.023 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.055 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.001 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.016 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.097 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.181 if mobility== 3 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.603 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.546 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.532 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.362 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.186 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.504 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.448 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.433 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.264 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.087 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.480 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.423 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.409 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.239 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.063 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.302 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.246 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.231 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.097 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.042 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.036 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.020 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.035 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.116 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.200 if mobility== 3 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.383 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.327 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.312 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.231 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.147 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.285 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.228 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.214 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.133 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.049 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.260 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.204 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.189 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.108 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.024 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.155 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.099 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.084 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.003 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.081 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.003 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.059 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.074 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.155 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.239 if mobility== 3 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.654 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.598 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.583 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.402 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.214 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.555 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.499 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.484 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.304 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.116 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.531 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.475 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.460 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.279 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.091 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.345 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.288 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.274 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.133 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.014 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.064 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.008 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.007 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.088 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.172 if mobility== 3 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.625 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.569 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.554 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.373 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.185 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.527 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.470 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.456 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.275 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.087 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.502 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.446 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.431 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.250 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.062 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.316 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.259 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.245 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.104 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.043 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.035 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.021 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.036 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.117 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.201 if mobility== 3 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.618 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.562 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.547 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.366 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.178 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.519 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.463 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.448 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.268 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.080 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.495 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.439 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.424 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.243 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.055 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.309 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.252 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.238 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.097 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.050 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.028 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.028 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.043 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.124 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.208 if mobility== 3 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.532 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.476 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.461 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.313 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.159 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.433 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.377 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.362 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.214 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.061 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.409 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.353 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.338 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.190 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.036 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.249 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.193 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.178 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.057 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.069 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.009 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.047 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.062 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.143 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.227 if mobility== 3 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.356 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.300 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.285 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.204 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.120 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.258 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.201 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.187 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.106 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.022 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.233 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.177 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.162 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.081 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.003 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.128 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.072 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.057 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.024 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.108 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.030 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.086 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.101 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.182 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.266 if mobility== 3 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.367 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.311 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.296 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.215 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.131 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.269 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.212 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.198 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.117 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.033 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.244 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.188 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.173 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.092 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.008 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.139 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.083 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.068 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.013 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.097 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.019 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.075 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.090 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.171 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.255 if mobility== 3 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.338 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.282 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.267 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.186 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.102 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.240 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.183 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.169 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.088 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.004 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.215 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.159 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.144 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.063 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.021 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.110 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.054 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.039 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.042 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.126 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.048 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.104 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.119 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.200 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.284 if mobility== 3 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.331 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.275 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.260 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.179 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.095 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.233 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.176 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.162 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.081 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.004 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.208 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.152 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.137 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.056 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.028 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.103 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.047 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.032 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.049 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.133 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.055 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.111 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.126 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.207 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.291 if mobility== 3 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.312 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.256 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.241 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.160 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.076 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.213 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.157 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.142 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.061 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.023 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.189 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.133 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.118 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.037 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.047 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.084 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.028 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.013 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.068 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.152 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.074 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.130 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.145 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.226 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.310 if mobility== 3 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.273 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.217 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.202 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.121 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.037 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.175 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.118 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.104 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.023 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.062 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.150 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.094 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.079 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.002 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.086 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.045 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.011 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.026 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.107 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.191 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.113 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.169 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.184 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.265 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.349 if mobility== 3 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.813 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.757 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.742 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.539 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.327 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.714 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.658 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.643 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.440 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.229 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.690 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.634 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.619 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.416 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.204 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.485 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.429 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.414 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.260 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.099 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.177 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.121 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.106 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk= 0.025 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.059 if mobility== 4 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.784 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.728 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.713 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.510 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.299 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.686 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.629 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.615 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.411 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.200 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.661 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.605 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.590 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.387 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.176 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.456 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.400 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.385 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.231 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.070 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.149 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.092 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.078 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.004 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.088 if mobility== 4 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.777 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.721 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.706 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.503 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.291 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.678 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.622 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.607 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.404 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.193 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.654 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.598 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.583 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.380 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.168 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.449 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.393 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.378 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.224 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.063 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.141 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.085 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.070 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.011 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.095 if mobility== 4 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.676 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.620 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.605 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.442 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.272 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.577 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.521 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.506 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.343 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.174 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.553 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.497 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.482 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.319 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.149 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.381 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.325 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.310 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.180 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.044 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.122 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.066 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.051 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.030 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.114 if mobility== 4 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.469 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.413 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.398 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.317 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.233 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.371 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.315 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.300 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.219 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.135 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.346 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.290 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.275 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.194 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.110 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.241 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.185 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.170 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.089 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.005 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.083 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.027 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.012 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.069 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.153 if mobility== 4 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.726 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.670 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.655 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.452 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.241 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.628 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.572 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.557 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.353 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.142 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.603 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.547 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.532 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.329 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.118 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.399 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.342 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.328 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.173 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk= 0.013 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.091 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.034 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.020 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.061 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.145 if mobility== 4 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.698 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.641 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.627 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.423 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.212 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.599 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.543 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.528 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.325 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.113 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.575 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.518 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.504 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.300 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.089 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.370 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.313 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.299 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.144 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.016 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.062 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.006 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.009 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.090 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.174 if mobility== 4 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.690 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.634 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.619 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.416 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.205 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.592 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.536 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.521 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.317 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.106 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.567 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.511 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.496 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.293 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.082 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.363 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.306 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.292 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.137 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.023 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.055 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.002 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.016 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.097 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.181 if mobility== 4 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.589 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.533 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.518 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.355 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.186 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.491 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.434 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.420 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.257 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.087 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.466 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.410 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.395 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.232 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.063 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.294 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.238 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.223 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.093 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.042 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.036 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.021 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.035 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.116 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.200 if mobility== 4 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.383 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.326 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.312 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.231 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.147 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.284 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.228 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.213 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.132 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.048 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.260 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.203 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.189 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.108 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.024 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.155 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.098 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.084 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.003 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.081 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.003 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.060 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.074 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.155 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.239 if mobility== 4 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.709 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.653 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.638 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.435 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.223 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.610 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.554 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.539 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.336 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.125 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.586 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.530 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.515 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.312 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.100 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.381 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.325 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.310 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.156 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.005 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.073 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk= 0.017 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk= 0.002 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.079 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.163 if mobility== 4 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.680 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.624 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.609 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.406 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.195 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.582 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.525 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.511 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.307 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.096 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.557 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.501 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.486 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.283 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.072 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.352 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.296 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.281 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.127 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.034 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.045 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.012 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.027 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.108 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.192 if mobility== 4 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.673 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.617 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.602 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.399 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.187 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.574 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.518 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.503 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.300 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.089 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.550 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.494 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.479 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.276 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.064 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.345 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.289 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.274 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.120 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.041 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.037 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.019 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.034 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.115 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.199 if mobility== 4 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.572 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.516 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.501 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.338 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.168 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.473 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.417 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.402 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.239 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.070 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.449 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.393 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.378 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.215 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.045 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.277 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.221 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.206 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.076 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.060 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.018 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.038 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.053 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.134 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.218 if mobility== 4 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.365 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.309 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.294 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.213 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.129 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.267 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.211 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.196 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.115 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.031 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.242 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.186 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.171 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.090 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.006 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.137 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.081 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.066 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.015 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.099 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.021 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.077 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.092 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.173 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.257 if mobility== 4 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.622 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.565 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.551 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.377 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.197 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.523 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.467 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.452 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.278 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.098 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.499 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.442 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.428 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.254 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.074 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.318 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.262 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.247 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.110 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.032 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.047 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.010 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.024 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.105 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.189 if mobility== 4 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.593 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.536 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.522 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.348 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.168 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.494 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.438 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.423 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.249 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.069 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.470 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.413 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.399 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.225 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.045 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.289 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.233 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.218 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.082 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.060 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.018 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.039 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.053 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.134 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.218 if mobility== 4 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.586 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.529 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.515 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.341 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.161 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.487 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.431 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.416 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.242 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.062 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.463 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.406 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.392 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.218 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.038 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.282 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.226 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.211 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.074 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.068 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk= 0.011 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.046 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.060 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.141 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.225 if mobility== 4 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.504 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.448 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.433 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.290 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.142 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.406 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.350 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.335 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.192 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.043 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.381 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.325 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.310 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.167 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk= 0.019 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.226 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.169 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.155 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk= 0.036 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.087 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.009 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.065 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.080 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.160 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.245 if mobility== 4 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.339 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.282 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.268 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.187 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.103 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.240 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.184 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.169 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.088 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.004 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.216 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.159 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.145 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.064 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.020 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.111 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.054 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.040 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.041 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.126 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.047 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.104 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.118 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.199 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.283 if mobility== 4 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.349 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.293 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.278 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.197 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.113 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.251 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.195 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.180 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.099 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.015 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.226 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.170 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.155 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.074 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.010 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.121 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.065 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.050 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.031 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.115 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.037 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.093 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.108 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.189 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.273 if mobility== 4 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.321 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.264 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.250 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.169 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.085 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.222 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.166 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.151 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.070 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.014 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.198 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.141 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.127 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.046 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.039 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.092 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.036 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.021 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.060 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.144 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.066 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.122 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.137 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.218 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.302 if mobility== 4 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.313 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.257 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.242 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.161 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.077 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.215 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.159 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.144 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.063 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.021 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.190 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.134 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.119 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.038 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.046 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.085 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.029 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.014 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.067 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.151 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.073 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.129 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.144 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.225 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.309 if mobility== 4 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.294 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.238 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.223 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.142 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.058 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.196 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.139 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.125 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.044 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.040 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.171 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.115 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.100 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.019 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.065 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.066 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.010 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.005 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.086 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.170 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.092 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.148 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.163 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.244 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.328 if mobility== 4 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.255 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.199 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.184 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.103 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.019 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.157 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.101 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.086 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.005 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.079 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.132 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.076 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.061 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.020 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.104 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.027 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.029 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.044 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.125 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.209 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.131 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.187 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.202 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.283 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.367 if mobility== 4 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.336 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.280 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.265 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.184 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.100 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.238 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.181 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.167 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.086 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk= 0.002 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.213 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.157 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.142 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.061 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.023 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.108 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.052 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.037 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.044 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.128 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.050 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.106 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.121 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.202 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.286 if mobility== 5 & selfcare== 1 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.307 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.251 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.236 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.155 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.071 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.209 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.152 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.138 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.057 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.027 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.184 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.128 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.113 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.032 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.052 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.079 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.023 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.008 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.073 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.157 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.079 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.135 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.150 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.231 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.315 if mobility== 5 & selfcare== 1 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.300 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.244 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.229 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.148 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.064 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.202 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.145 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.131 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.050 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.035 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.177 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.121 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.106 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.025 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.059 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.072 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk= 0.016 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk= 0.001 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.080 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.164 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.086 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.142 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.157 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.238 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.322 if mobility== 5 & selfcare== 1 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.281 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.225 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.210 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.129 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.045 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.182 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.126 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.111 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk= 0.030 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.054 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.158 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.102 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.087 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk= 0.006 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.078 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.053 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.003 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.018 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.099 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.183 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.105 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.161 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.176 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.257 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.341 if mobility== 5 & selfcare== 1 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.242 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.186 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.171 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.090 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.006 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.144 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.087 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.073 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.009 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.093 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.119 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.063 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.048 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.033 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.117 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.014 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.042 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.057 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.138 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.222 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.144 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.200 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.215 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.296 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.380 if mobility== 5 & selfcare== 1 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.249 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.193 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.178 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.097 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk= 0.013 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.151 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.095 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.080 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.001 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.085 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.126 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.070 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.055 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.026 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.110 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.021 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.035 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.050 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.131 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.215 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.137 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.193 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.208 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.289 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.373 if mobility== 5 & selfcare== 2 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.221 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.164 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.150 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.069 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.016 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.122 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.066 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.051 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.030 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.114 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.098 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.041 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.027 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.054 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.139 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.008 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.064 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.079 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.160 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.244 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.166 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.222 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.237 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.317 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.402 if mobility== 5 & selfcare== 2 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.213 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.157 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.142 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.061 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.023 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.115 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.059 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.044 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.037 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.121 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.090 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.034 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.019 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.062 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.146 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.015 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.071 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.086 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.167 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.251 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.173 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.229 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.244 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.325 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.409 if mobility== 5 & selfcare== 2 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.194 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.138 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.123 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.042 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.042 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.096 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.040 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.025 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.056 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.140 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.071 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.015 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.000 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.081 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.165 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.034 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.090 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.105 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.186 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.270 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.192 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.248 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.263 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.344 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.428 if mobility== 5 & selfcare== 2 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.155 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.099 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.084 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.003 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.081 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.057 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.001 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.014 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.095 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.179 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.032 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.024 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.039 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.120 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.204 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.073 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.129 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.144 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.225 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.309 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.231 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.287 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.302 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.383 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.467 if mobility== 5 & selfcare== 2 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.232 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.176 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.161 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.080 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.004 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.134 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.077 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.063 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.019 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.103 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.109 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.053 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.038 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.043 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.127 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk= 0.004 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.052 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.067 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.148 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.232 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.154 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.210 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.225 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.306 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.390 if mobility== 5 & selfcare== 3 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.203 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.147 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.132 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.051 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.033 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.105 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.048 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.034 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.047 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.131 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.080 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.024 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.009 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.072 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.156 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.025 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.081 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.096 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.177 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.261 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.183 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.239 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.254 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.335 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.419 if mobility== 5 & selfcare== 3 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.196 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.140 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.125 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.044 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.040 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.098 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.041 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.027 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.055 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.139 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.073 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.017 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.002 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.079 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.163 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.032 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.088 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.103 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.184 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.268 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.190 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.246 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.261 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.342 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.426 if mobility== 5 & selfcare== 3 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.177 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.121 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.106 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.025 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.059 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.078 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.022 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.007 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.074 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.158 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.054 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.002 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.017 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.098 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.182 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.051 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.107 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.122 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.203 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.287 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.209 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.265 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.280 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.361 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.445 if mobility== 5 & selfcare== 3 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.138 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.082 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.067 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.014 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.098 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.040 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.017 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.032 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.113 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.197 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.015 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.041 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.056 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.137 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.221 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.090 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.146 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.161 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.242 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.326 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.248 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.304 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.319 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.400 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.484 if mobility== 5 & selfcare== 3 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.205 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.149 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.134 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.053 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.031 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.107 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.050 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.036 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.045 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.129 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.082 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk= 0.026 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk= 0.011 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.070 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.154 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.023 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.079 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.094 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.175 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.259 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.181 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.237 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.252 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.333 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.417 if mobility== 5 & selfcare== 4 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.176 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.120 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.105 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.024 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.060 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.078 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.022 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.007 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.074 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.158 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.053 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.003 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.018 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.099 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.183 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.052 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.108 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.123 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.204 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.288 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.210 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.266 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.281 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.362 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.446 if mobility== 5 & selfcare== 4 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.169 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.113 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.098 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk= 0.017 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.067 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.071 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk= 0.014 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk= 0.000 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.081 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.165 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.046 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.010 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.025 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.106 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.190 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.059 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.115 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.130 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.211 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.295 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.217 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.273 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.288 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.369 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.453 if mobility== 5 & selfcare== 4 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.150 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.094 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.079 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.002 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.086 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.052 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.005 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.019 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.100 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.184 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk= 0.027 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.029 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.044 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.125 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.209 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.078 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.134 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.149 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.230 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.314 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.236 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.292 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.307 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.388 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.472 if mobility== 5 & selfcare== 4 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.111 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.055 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.040 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.041 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.125 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.013 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.044 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.058 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.139 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.223 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk=-0.012 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.068 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.083 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.164 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.248 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.117 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.173 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.188 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.269 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.353 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.275 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.331 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.346 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.427 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.511 if mobility== 5 & selfcare== 4 & activity== 5 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.122 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.066 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.051 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.030 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.114 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 1 & anxiety== 5
replace UK_crosswalk= 0.024 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.033 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.048 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.129 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.213 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 2 & anxiety== 5
replace UK_crosswalk=-0.001 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.057 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.072 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.153 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.237 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.106 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.162 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.177 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.258 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.342 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.264 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.320 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.335 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.416 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.500 if mobility== 5 & selfcare== 5 & activity== 1 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.093 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.037 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.022 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.059 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.143 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 1 & anxiety== 5
replace UK_crosswalk=-0.005 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.062 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.076 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.157 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.241 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 2 & anxiety== 5
replace UK_crosswalk=-0.030 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.086 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.101 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.182 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.266 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.135 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.191 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.206 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.287 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.371 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.293 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.349 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.364 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.445 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.529 if mobility== 5 & selfcare== 5 & activity== 2 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.086 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.030 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 2
replace UK_crosswalk= 0.015 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.066 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.150 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 1 & anxiety== 5
replace UK_crosswalk=-0.013 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.069 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.084 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.165 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.249 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 2 & anxiety== 5
replace UK_crosswalk=-0.037 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.093 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.108 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.189 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.273 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.142 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.198 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.213 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.294 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.378 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.300 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.356 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.371 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.452 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.536 if mobility== 5 & selfcare== 5 & activity== 3 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.067 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 1
replace UK_crosswalk= 0.011 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 2
replace UK_crosswalk=-0.004 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.085 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.169 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 1 & anxiety== 5
replace UK_crosswalk=-0.032 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.088 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.103 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.184 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.268 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 2 & anxiety== 5
replace UK_crosswalk=-0.056 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.112 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.127 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.208 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.292 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.161 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.217 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.232 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.313 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.397 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.319 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.375 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.390 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.471 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.555 if mobility== 5 & selfcare== 5 & activity== 4 & pain== 5 & anxiety== 5
replace UK_crosswalk= 0.028 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 1
replace UK_crosswalk=-0.028 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 2
replace UK_crosswalk=-0.043 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 3
replace UK_crosswalk=-0.124 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 4
replace UK_crosswalk=-0.208 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 1 & anxiety== 5
replace UK_crosswalk=-0.071 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 1
replace UK_crosswalk=-0.127 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 2
replace UK_crosswalk=-0.142 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 3
replace UK_crosswalk=-0.223 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 4
replace UK_crosswalk=-0.307 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 2 & anxiety== 5
replace UK_crosswalk=-0.095 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 1
replace UK_crosswalk=-0.151 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 2
replace UK_crosswalk=-0.166 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 3
replace UK_crosswalk=-0.247 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 4
replace UK_crosswalk=-0.331 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 3 & anxiety== 5
replace UK_crosswalk=-0.200 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 1
replace UK_crosswalk=-0.256 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 2
replace UK_crosswalk=-0.271 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 3
replace UK_crosswalk=-0.352 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 4
replace UK_crosswalk=-0.436 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 4 & anxiety== 5
replace UK_crosswalk=-0.358 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 1
replace UK_crosswalk=-0.414 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 2
replace UK_crosswalk=-0.429 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 3
replace UK_crosswalk=-0.510 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 4
replace UK_crosswalk=-0.594 if mobility== 5 & selfcare== 5 & activity== 5 & pain== 5 & anxiety== 5

save "./output/openprompt_dataset.dta", replace
log close
