//*** Open log file ***
cap log close
log using "logs\open-prompt-combine.log", replace
clear

//*** Import ***
// stata cannot handle compressed CSV files directly, so unzip first to a plain CSV file
// the unzipped file will be discarded when the action finishes.
!gunzip "output/openprompt_raw.csv.gz"
// now import the uncompressed CSV using delimited
import delimited "output/openprompt_raw.csv"

// save in compressed dta.gz format
gzsave output/openprompt_raw.dta.gz

// load a compressed .dta.gz file
gzload output/openprompt_raw.dta.gz

//*** Drop non answered ***
drop if first_consult_datex=="NA"

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
gen hh_inc=1 if base_hh_income=="£6,000-12,999"
replace hh_inc=2 if base_hh_income=="£13,000-18,999"
replace hh_inc=3 if base_hh_income=="£19,000-25,999"
replace hh_inc=4 if base_hh_income=="£26,000-31,999"
replace hh_inc=5 if base_hh_income=="£32,000-47,999"
replace hh_inc=6 if base_hh_income=="£48,000-63,999"
replace hh_inc=7 if base_hh_income=="£64,000-95,999"
replace hh_inc=8 if base_hh_income=="£96,000"
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
replace covid_symptoms=1 if covid_duration=="2 – 3 weeks"
replace covid_symptoms=2 if covid_duration=="4 – 12 weeks"
replace covid_symptoms=3 if covid_duration=="More than 12 weeks"
label define symptoms 0 "Less than 2 weeks" 1 "2-3 weeks" 2 "4-12 weeks" 3 "More than 12 weeks"
label values covid_symptoms symptoms

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

//*** Days since baseline ***
gen days_since_base=real(days_since_baseline)

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


