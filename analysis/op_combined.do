//*** Open log file ***
cap log close
log using "logs/open-prompt-combine.log", replace
clear

//*** Import ***
// stata cannot handle compressed CSV files directly, so unzip first to a plain CSV file
// the unzipped file will be discarded when the action finishes.
!gunzip "output/openprompt_raw.csv.gz"
// now import the uncompressed CSV using delimited
import delimited "output/openprompt_raw.csv"

//*** Drop non answered ***
drop if base_ethnicity_consult_date=="NA"

//*** Ethnicity ***
gen ethnicity_cat= 1 if base_ethnicity=="White"
replace ethnicity_cat=2 if base_ethnicity=="Mixed"
replace ethnicity_cat=3 if base_ethnicity=="Asian/Asian Brit"
replace ethnicity_cat=4 if base_ethnicity=="Black/African/Caribbn/Black Brit"
replace ethnicity_cat=5 if base_ethnicity=="Other/not stated" | base_ethnicity=="NA"
label define ethnicities 1 "White" 2 "Mixed" 3 "South Asian" 4 "Black" 5 "Other/Not stated"
label values ethnicity_cat ethnicities

//*** Education ***
gen highest_educ=1 if base_highest_edu=="less than primary school"
replace highest_educ=2 if base_highest_edu=="primary school completed"
replace highest_educ=3 if base_highest_edu=="secondary / high school completed"
replace highest_educ=4 if base_highest_edu=="college / university completed"
replace highest_educ=5 if base_highest_edu=="post graduate degree"
replace highest_educ=6 if base_highest_edu=="NA" | base_highest_edu=="Refused"
label define education 1 "None/less than primary school" 2 "Primary School" ///
3 "Secondary/high school" 4 "College/university" 5 "Postgraduate qualification" 6 "Not stated"
label values highest_educ education

//*** Disability ***
gen disabled=0 if base_disability=="None"
replace disabled=1 if base_disability=="Disability"
replace disabled=2 if base_disability=="Refused" | base_disability=="NA"
label define disabilities 0 "No" 1 "Yes" 2 "Not stated"
label values disabled disabilities

//*** Relationship status ***
gen relation_status=1 if base_relationship=="Single person"
replace relation_status=2 if base_relationship=="Cohabiting"
replace relation_status=3 if base_relationship=="Married/civil partner"
replace relation_status=4 if base_relationship=="Separated"
replace relation_status=5 if base_relationship=="Divorced/person whose civil partnership has been dissolved"
replace relation_status=6 if base_relationship=="Widowed/surviving civil partner"
replace relation_status=7 if base_relationship=="Marital/civil state not disclosed"
replace relation_status=8 if base_relationship=="NA"
label define relationships 1 "Single" 2 "Cohabiting" 3 "Married/civil partner" ///
4 "Separated" 5 "Divorced/dissolved civil partnership" 6 "Widowed/surviving civil partner" /// 
7 "Prefer not to say" 8 "Not stated"
label values relation_status relationships

//*** Gender - Male/Female only ***
//*** Gender - male/female only ***
gen sex=1 if base_gender=="Male"
replace sex=2 if base_gender=="Female"
replace sex=3 if base_gender=="Intersex/non-binary/other/refused"
replace sex=4 if base_gender=="NA"
label define gender 1 "Male" 2 "Female" 3 "Intersex/non-binary/other/refused" 4 "Not stated"
label values sex gender

//*** Income ***
gen hh_inc=1 if base_hh_income=="Â£6,000-12,999"
replace hh_inc=2 if base_hh_income=="Â£13,000-18,999"
replace hh_inc=3 if base_hh_income=="Â£19,000-25,999"
replace hh_inc=4 if base_hh_income=="Â£26,000-31,999"
replace hh_inc=5 if base_hh_income=="Â£32,000-47,999"
replace hh_inc=6 if base_hh_income=="Â£48,000-63,999"
replace hh_inc=7 if base_hh_income=="Â£64,000-95,999"
replace hh_inc=8 if base_hh_income=="Â£96,000"
replace hh_inc=9 if base_hh_income=="Unknown income" | base_hh_income=="NA"
label define income 1 "<£13,000" 2 "£13,000-£19,000" 3 "£19,001-£26,000" ///
4 "£26,001-£31,999" 5 "£32,000-£47,999" 6 "£48,000-£63,999" 7 "£64,000-£95,999" ///
8 ">£96,000" 9 "Not stated"
label values hh_inc income

//*** Covid history ***
gen covid_history=1 if long_covid=="My test for COVID-19 was positive"
replace covid_history=2 if long_covid=="I think I have already had COVID-19 (coronavirus) disease"
replace covid_history=3 if long_covid=="Suspected COVID-19"
replace covid_history=4 if long_covid=="I am unsure if I currently have or have ever had COVID-19"
replace covid_history=5 if long_covid=="I do not think I currently have or have ever had COVID-19"
replace covid_history=6 if long_covid=="I prefer not to say if I currently have or have ever had COVID-19" | long_covid=="NA"
label define history_of_covid 1 "Yes (+ve test)" 2 "Yes (medical advice)" ///
3 "Yes (personal suspicion)" 4 "Unsure" 5 "No" 6 "Not Stated"
label values covid_history history_of_covid

//*** Covid recovery ***
gen covid_recovered=0 if recovered_from_covid=="I feel I have fully recovered from my (latest) episode of COVID-19"
replace covid_recovered=1 if recovered_from_covid=="I feel I have not fully recovered from my (latest) episode of COVID-19"
replace covid_recovered=2 if recovered_from_covid=="NA"
label define recovery 0 "Yes, back to normal" 1 "No, still have symptoms" ///
2 "Not stated"
label values covid_recovered recovery

gen covid_symptoms=0 if covid_duration=="Less than 2 weeks"
replace covid_symptoms=1 if covid_duration=="2 â 3 weeks"
replace covid_symptoms=2 if covid_duration=="4 â 12 weeks"
replace covid_symptoms=3 if covid_duration=="More than 12 weeks"
label define symptoms 0 "Less than 2 weeks" 1 "2-3 weeks" 2 "4-12 weeks" 3 "More than 12 weeks"
label values covid_symptoms symptoms

gen long_covid_symptoms=0 if covid_symptoms==0 | covid_symptoms==1
replace long_covid_symptoms=1 if covid_symptoms==2 | covid_symptoms==3
label define long_covid 0 "No Long COVID" 1 "Long COVID"
label values long_covid_symptoms long_covid

//*** Vaccine History ***
gen vaccine_hist=0 if vaccinated=="I have had at least one COVID-19 vaccination"
replace vaccine_hist=1 if vaccinated=="I have not had any COVID-19 vaccinations"
replace vaccine_hist=2 if vaccinated=="I prefer not to say if I have had any COVID-19 vaccinations" | vaccinated=="NA"
label define vax_ind 0 "Yes" 1 "No" 2 "Not stated"
label values vaccine_hist vax_ind
gen covid_n=real(n_covids)
replace covid_n=6 if n_covids=="6+"

//*** Employment Status ***
gen unemployed=0 if employment_status=="Employed"
replace unemployed=1 if employment_status=="Unemployed"
label define employment 0 "Employed" 1 "Unemployed"
label values unemployed employment

gen vaccine_n=real(n_vaccines)
replace vaccine_n=6 if n_vaccines=="6+"

//*** EQ-5D-5L ***
gen mobility_eq5d=1 if eq5d_mobility=="none"
replace mobility_eq5d=2 if eq5d_mobility=="slight"
replace mobility_eq5d=3 if eq5d_mobility=="moderate"
replace mobility_eq5d=4 if eq5d_mobility=="severe"
replace mobility_eq5d=5 if eq5d_mobility=="unable"

gen self_care_eq5d=1 if eq5d_selfcare=="none"
replace self_care_eq5d=2 if eq5d_selfcare=="slight"
replace self_care_eq5d=3 if eq5d_selfcare=="moderate"
replace self_care_eq5d=4 if eq5d_selfcare=="severe"
replace self_care_eq5d=5 if eq5d_selfcare=="unable"

gen usual_activity_eq5d=1 if eq5d_usualactivities=="none"
replace usual_activity_eq5d=2 if eq5d_usualactivities=="slight"
replace usual_activity_eq5d=3 if eq5d_usualactivities=="moderate"
replace usual_activity_eq5d=4 if eq5d_usualactivities=="severe"
replace usual_activity_eq5d=5 if eq5d_usualactivities=="unable"

gen pain_discomfort_eq5d=1 if eq5d_pain_discomfort=="none"
replace pain_discomfort_eq5d=2 if eq5d_pain_discomfort=="slight"
replace pain_discomfort_eq5d=3 if eq5d_pain_discomfort=="moderate"
replace pain_discomfort_eq5d=4 if eq5d_pain_discomfort=="severe"
replace pain_discomfort_eq5d=5 if eq5d_pain_discomfort=="unable"

gen anx_depression_eq5d=1 if eq5d_anxiety_depression=="none"
replace anx_depression_eq5d=2 if eq5d_anxiety_depression=="slight"
replace anx_depression_eq5d=3 if eq5d_anxiety_depression=="moderate"
replace anx_depression_eq5d=4 if eq5d_anxiety_depression=="severe"
replace anx_depression_eq5d=5 if eq5d_anxiety_depression=="unable"

label define eq5d 1 "No problems" 2 "Slight problems" 3 "Moderate problems" 4 "Severe problems" 5 "Extreme problems/unable"
label values (mobility_eq5d self_care_eq5d usual_activity_eq5d pain_discomfort_eq5d anx_depression_eq5d) eq5d

//*** WPAI Score ***
gen work_effect=real(work_affected)
replace work_effect=0 if work_affected=="0 (No effect on my daily activities)"
replace work_effect=10 if work_affected=="10 (Completely prevented me from doing my daily activities)"
label define affect 0 "0 (No effect on my daily activities)" ///
10 "10 (Completely prevented me from doing my daily activities)"
label values work_effect affect

gen life_effect=real(life_affected)
replace life_effect=0 if life_affected=="0 (No effect on my daily activities)"
replace life_effect=10 if life_affected=="10 (Completely prevented me from doing my daily activities)"
label values life_effect affect

//*** FACIT fatigue ***
label define rvs_facit 0 "Very much" 1 "Quite a bit" 2 "Somewhat" 3 "A little bit" 4 "Not at all"
gen fatigue_rvs_facit=0 if facit_fatigue=="Very much"
replace fatigue_rvs_facit=1 if facit_fatigue=="Quite a bit"
replace fatigue_rvs_facit=2 if facit_fatigue=="Somewhat"
replace fatigue_rvs_facit=3 if facit_fatigue=="A little bit"
replace fatigue_rvs_facit=4 if facit_fatigue=="Not at all"
label values fatigue_rvs_facit rvs_facit

gen weak_rvs_facit=0 if facit_weak=="Very much"
replace weak_rvs_facit=1 if facit_weak=="Quite a bit"
replace weak_rvs_facit=2 if facit_weak=="Somewhat"
replace weak_rvs_facit=3 if facit_weak=="A little bit"
replace weak_rvs_facit=4 if facit_weak=="Not at all"
label values weak_rvs_facit rvs_facit

gen listless_rvs_facit=0 if facit_listless=="Very much"
replace listless_rvs_facit=1 if facit_listless=="Quite a bit"
replace listless_rvs_facit=2 if facit_listless=="Somewhat"
replace listless_rvs_facit=3 if facit_listless=="A little bit"
replace listless_rvs_facit=4 if facit_listless=="Not at all"
label values listless_rvs_facit rvs_facit

gen tired_rvs_facit=0 if facit_tired=="Very much"
replace tired_rvs_facit=1 if facit_tired=="Quite a bit"
replace tired_rvs_facit=2 if facit_tired=="Somewhat"
replace tired_rvs_facit=3 if facit_tired=="A little bit"
replace tired_rvs_facit=4 if facit_tired=="Not at all"
label values tired_rvs_facit rvs_facit

gen starting_trouble_rvs_facit=0 if facit_trouble_starting=="Very much"
replace starting_trouble_rvs_facit=1 if facit_trouble_starting=="Quite a bit"
replace starting_trouble_rvs_facit=2 if facit_trouble_starting=="Somewhat"
replace starting_trouble_rvs_facit=3 if facit_trouble_starting=="A little bit"
replace starting_trouble_rvs_facit=4 if facit_trouble_starting=="Not at all"
label values starting_trouble_rvs_facit rvs_facit

gen finishing_trouble_rvs_facit=0 if facit_trouble_finishing=="Very much"
replace finishing_trouble_rvs_facit=1 if facit_trouble_finishing=="Quite a bit"
replace finishing_trouble_rvs_facit=2 if facit_trouble_finishing=="Somewhat"
replace finishing_trouble_rvs_facit=3 if facit_trouble_finishing=="A little bit"
replace finishing_trouble_rvs_facit=4 if facit_trouble_finishing=="Not at all"
label values finishing_trouble_rvs_facit rvs_facit

label define facit 0 "Not at all" 1 "A little bit" 2 "Somewhat" 3 "Quite a bit" 4 "Very much"
gen energy_facit=0 if facit_energy=="Not at all"
replace energy_facit=1 if facit_energy=="A little bit"
replace energy_facit=2 if facit_energy=="Somewhat"
replace energy_facit=3 if facit_energy=="Quite a bit"
replace energy_facit=4 if facit_energy=="Very much"
label values energy_facit facit

gen activity_facit=0 if facit_usual_activities=="Not at all"
replace activity_facit=1 if facit_usual_activities=="A little bit"
replace activity_facit=2 if facit_usual_activities=="Somewhat"
replace activity_facit=3 if facit_usual_activities=="Quite a bit"
replace activity_facit=4 if facit_usual_activities=="Very much"
label values activity_facit facit

gen sleep_rvs_facit=0 if facit_sleep_during_day=="Very much"
replace sleep_rvs_facit=1 if facit_sleep_during_day=="Quite a bit"
replace sleep_rvs_facit=2 if facit_sleep_during_day=="Somewhat"
replace sleep_rvs_facit=3 if facit_sleep_during_day=="A little bit"
replace sleep_rvs_facit=4 if facit_sleep_during_day=="Not at all"
label values sleep_rvs_facit rvs_facit

gen eat_rvs_facit=0 if facit_eat=="Very much"
replace eat_rvs_facit=1 if facit_eat=="Quite a bit"
replace eat_rvs_facit=2 if facit_eat=="Somewhat"
replace eat_rvs_facit=3 if facit_eat=="A little bit"
replace eat_rvs_facit=4 if facit_eat=="Not at all"
label values eat_rvs_facit rvs_facit

gen help_rvs_facit=0 if facit_need_help=="Very much"
replace help_rvs_facit=1 if facit_need_help=="Quite a bit"
replace help_rvs_facit=2 if facit_need_help=="Somewhat"
replace help_rvs_facit=3 if facit_need_help=="A little bit"
replace help_rvs_facit=4 if facit_need_help=="Not at all"
label values help_rvs_facit rvs_facit

gen frustrated_rvs_facit=0 if facit_frustrated=="Very much"
replace frustrated_rvs_facit=1 if facit_frustrated=="Quite a bit"
replace frustrated_rvs_facit=2 if facit_frustrated=="Somewhat"
replace frustrated_rvs_facit=3 if facit_frustrated=="A little bit"
replace frustrated_rvs_facit=4 if facit_frustrated=="Not at all"
label values frustrated_rvs_facit rvs_facit

gen social_limited_rvs_facit=0 if facit_limit_social_activity=="Very much"
replace social_limited_rvs_facit=1 if facit_limit_social_activity=="Quite a bit"
replace social_limited_rvs_facit=2 if facit_limit_social_activity=="Somewhat"
replace social_limited_rvs_facit=3 if facit_limit_social_activity=="A little bit"
replace social_limited_rvs_facit=4 if facit_limit_social_activity=="Not at all"
label values social_limited_rvs_facit rvs_facit

//*** Fscore ***
egen qtotal_facit= rownonmiss(fatigue_rvs_facit weak_rvs_facit listless_rvs_facit tired_rvs_facit ///
starting_trouble_rvs_facit finishing_trouble_rvs_facit energy_facit activity_facit ///
sleep_rvs_facit eat_rvs_facit help_rvs_facit frustrated_rvs_facit social_limited_rvs_facit)
egen score_facit=rowtotal(fatigue_rvs_facit weak_rvs_facit listless_rvs_facit ///
tired_rvs_facit starting_trouble_rvs_facit finishing_trouble_rvs_facit ///
energy_facit activity_facit sleep_rvs_facit eat_rvs_facit help_rvs_facit ///
frustrated_rvs_facit social_limited_rvs_facit)
gen fscore = (13*(score_facit)/qtotal_facit)

//*** MRC Dyspnoea ***
gen breathlessness_mrc=1 if mrc_breathlessness=="MRC Breathlessness Scale: grade 1"
replace breathlessness_mrc=2 if mrc_breathlessness=="MRC Breathlessness Scale: grade 2"
replace breathlessness_mrc=3 if mrc_breathlessness=="MRC Breathlessness Scale: grade 3"
replace breathlessness_mrc=4 if mrc_breathlessness=="MRC Breathlessness Scale: grade 4"
replace breathlessness_mrc=5 if mrc_breathlessness=="MRC Breathlessness Scale: grade 5"
label define breathless_grade 1 "MRC Breathlessness Scale: grade 1" 2 "MRC Breathlessness Scale: grade 2" ///
3 "MRC Breathlessness Scale: grade 3" 4 "MRC Breathlessness Scale: grade 4" 5 "MRC Breathlessness Scale: grade 5"
label values breathlessness_mrc breathless_grade

//*** EQ-5D-5L score (crosswalk using Dolan value set) ***
rename mobility_eq5d mobility
rename self_care_eq5d selfcare
rename usual_activity_eq5d activity
rename pain_discomfort_eq5d pain
rename anx_depression_eq5d anxiety

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
