//*** Set filepaths ***
global projectdir `c(pwd)'
capture mkdir "$projectdir/output/tables"
capture mkdir "$projectdir/output/figures"

//*** Open log file ***
cap log close
log using "output/op-baseline-table1.log", replace
clear

//*** Set ado file path ***
adopath + "analysis/Extra_ados"

//*** Import data ***
use "output/op_tpp_linked.dta", clear
keep if merge_link>=2

//*** Table1_mc baseline demographic ***
label variable base_ethnicity "Ethnicity"
label variable base_highest_edu "Highest education"
label variable base_gender "Gender"
label variable base_relationship "Relationship status"
label variable base_disability "Disability"
label variable covid_n "Number of COVID-19 episodes"
label variable vaccines_n "Number of COVID-19 vaccines"
label variable vaccinated "Have you had a COVID-19 vaccine"
label variable covid_history "Have you had COVID-19"
label variable recovered_from_covid "Recovered from COVID-19"
label variable covid_duration "Length of COVID-19 symptoms"
label variable all_covid_hosp "COVID-19 Hospitalisation"
label variable base_hh_income "Household Income"
label variable comorbid_count "Number of comorbidities"
label variable age_bands "Age"
label variable imd_q5 "IMD (quintiles)"

recode all_covid_hosp (2=1)
label define hosps 0 "No" 1 "Yes"
label values all_covid_hosp hosps

preserve
table1_mc if survey_response==1, vars(age_bands cat %5.1f \ base_ethnicity cat %5.1f \ ///
base_gender cat %5.1f \ region cat %5.1f \ base_highest_edu cat %5.1f\ base_relationship cat %5.1f\ ///
base_hh_income cat %5.1f \ imd_q5 cat %5.1f \ base_disability cat %5.1f \ comorbid_count cat %5.1f \ ///
all_covid_hosp cat %5.1f \ covid_n cat %5.1f \ vaccines_n cat %5.1f \ vaccinated cat %5.1f \ ///
covid_history cat %5.1f \ recovered_from_covid cat %5.1f \ covid_duration cat %5.1f \) ///
nospacelowpercent total(before) onecol missing iqrmiddle(",")  clear
export delimited using "$projectdir/output/tables/table1_demographic.csv", replace
// Rounding numbers
destring _columna_1, gen(n) ignore(",") force
destring _columnb_1, gen(percent) ignore("-" "%" "(" ")")  force
gen rounded_n = round(n, 5)
keep factor Total rounded_n percent
export delimited using "$projectdir/output/tables/table1_demographic_rounded.csv", replace


//*** Self reported vs diagnosis of LC ***
restore
label variable long_covid "Self-reported long COVID"
label variable n_distinct_lc_records "Number of distinct Long COVID records"
label variable n_lc_records "Number of long COVID records"

preserve
table1_mc if survey_response==1, vars(long_covid cat %5.1f \ n_lc_records cat %5.1f \ ///
n_distinct_lc_records cat %5.1f \) nospacelowpercent total(before) onecol missing iqrmiddle(",") clear 
export delimited using "$projectdir/output/tables/long-covid-dx.csv", replace
// Rounding numbers
destring _columna_1, gen(n) ignore(",") force
destring _columnb_1, gen(percent) ignore("-" "%" "(" ")")  force
gen rounded_n = round(n, 5)
keep factor Total rounded_n percent
export delimited using "$projectdir/output/tables/long-covid-dx-rounded.csv", replace


//*** Questionnaire responses ***
restore
preserve
table1_mc if survey_response==1, by(long_covid) vars(mobility cat %5.1f \ selfcare cat %5.1f \ ///
activity cat %5.1f \ pain cat %5.1f \ anxiety cat %5.1f \ ///
work_effect cat %5.1f \ life_effect cat %5.1f \ mrc_breathlessness cat %5.1f \ fscore conts %5.1f \) ///
nospacelowpercent total(before) onecol missing iqrmiddle(",")  clear
export delimited using "$projectdir/output/tables/table1_questions.csv", replace
// Rounding numbers
destring _columna_T, gen(n) ignore(",") force
destring _columnb_T, gen(percent) ignore("-" "%" "(" ")")  force
destring _columna_0, gen(n1) ignore(",") force
destring _columnb_0, gen(percent1) ignore("-" "%" "(" ")")  force
destring _columna_1, gen(n2) ignore(",") force
destring _columnb_1, gen(percent2) ignore("-" "%" "(" ")")  force
gen rounded_n = round(n, 5)
gen rounded_n1 = round(n1, 5)
gen rounded_n2 = round(n2, 5)
keep factor long_covid_T rounded_n percent rounded_n1 percent1 rounded_n2 percent2
export delimited using "$projectdir/output/tables/table1_questions_rounded.csv", replace
restore

set scheme s1color
hist utility if survey_response==1, xtitle(EQ-5D Index Score) color(green%40) ///
title("Distribution of baseline EQ-5D Index Score", size(medlarge))
graph export "$projectdir/output/figures/baseline_EQ5D_utility.svg", width(12in) replace

hist disutility if survey_response==1, freq xtitle(EQ-5D Index Score (disutility)) color(orange%60) ///
title("Frequency Distribution of baseline EQ-5D Index Score (disutility)", size(medlarge))
graph export "$projectdir/output/figures/baseline_EQ5D_disutility.svg", width(12in) replace

codebook mobility selfcare activity pain anxiety if survey_response==1, m
tab2 mobility selfcare activity pain anxiety if survey_response==1, m
tab2 covid_duration recovered_from_covid if survey_response==1, m
tab2 long_covid has_covid_dx, m
sum utility if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1 & survey_response==1
tab utility if mobility==1 & selfcare==1 & activity==1 & pain==1 & anxiety==1 & survey_response==1

//*** Baseline EQ-5D-5L by long COVID ***
graph bar (count) if survey_response==1, over(long_covid) over(mobility, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) ///
asyvars blabel(bar, size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Mobility", size(medsmall)) ///
ytitle("") ///
ylabel(0(500)2500, labsize(2) angle(0)) ///
name(mobility_freq, replace)

graph bar (count) if survey_response==1, over(long_covid) over(selfcare, label(labsize(vsmall)) /// 
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Self Care", size(medsmall)) ///
ytitle("") ///
ylabel(0(500)2500, labsize(2) angle(0)) ///
name(selfcare_freq, replace)

graph bar (count) if survey_response==1, over(long_covid) over(activity, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Usual Activities", size(medsmall)) ///
ytitle("") ///
ylabel(0(500)2500, labsize(2) angle(0)) ///
name(activity_freq, replace)

graph bar (count) if survey_response==1, over(long_covid) over(pain, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Pain/Discomfort", size(medsmall)) ///
ytitle("") ///
ylabel(0(500)2500, labsize(2) angle(0)) ///
name(pain_freq, replace)

graph bar (count) if survey_response==1, over(long_covid) over(anxiety, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Anxiety/Depression", size(medsmall)) ///
ytitle("") ///
ylabel(0(500)2500, labsize(2) angle(0)) ///
name(anxiety_freq, replace)

graph combine mobility_freq selfcare_freq activity_freq pain_freq anxiety_freq, ///
title("Responses at baseline (Frequency)", size(medlarge))
graph export "$projectdir/output/figures/baseline_EQ5D_responses.svg", width(12in) replace


//*** Percentages for baseline EQ-5D response ***
graph bar if survey_response==1, over(long_covid) over(mobility, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" 3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) ///
asyvars blabel(bar, format(%9.0f) size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Mobility", size(medsmall)) ///
ytitle("") ///
ylabel(0(20)100, labsize(2) angle(0)) ///
name(mobility_perc, replace)

graph bar if survey_response==1, over(long_covid) over(selfcare, label(labsize(vsmall)) /// 
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, format(%9.0f) size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Self Care", size(medsmall)) ///
ytitle("") ///
ylabel(0(20)100, labsize(2) angle(0)) ///
name(selfcare_perc, replace)

graph bar if survey_response==1, over(long_covid) over(activity, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, format(%9.0f) size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Usual Activities", size(medsmall)) ///
ytitle("") ///
ylabel(0(20)100, labsize(2) angle(0)) ///
name(activity_perc, replace)

graph bar if survey_response==1, over(long_covid) over(pain, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, format(%9.0f) size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Pain/Discomfort", size(medsmall)) ///
ytitle("") ///
ylabel(0(20)100, labsize(2) angle(0)) ///
name(pain_perc, replace)

graph bar if survey_response==1, over(long_covid) over(anxiety, label(labsize(vsmall)) ///
relabel(1 `""No" "Problems""' 2 "Slight" ///
3 "Moderate" 4 "Severe" 5 `""Extreme/" "Unable to""')) asyvars blabel(bar, format(%9.0f) size(vsmall)) ///
bar(1, color(blue%40)) bar(2, color(red%40)) ///
legend(size(vsmall) margin(vsmall) region(lstyle(none))) ///
title("Anxiety/Depression", size(medsmall)) ///
ytitle("") ///
ylabel(0(20)100, labsize(2) angle(0)) ///
name(anxiety_perc, replace)

graph combine mobility_perc selfcare_perc activity_perc pain_perc anxiety_perc, ///
title("Responses at baseline (Percent)", size(medlarge))
graph export "$projectdir/output/figures/baseline_EQ5D_percentage.svg", width(12in) replace

//*** EQ-VAS by COVID ***
preserve
egen mean_vas = mean(EuroQol_score), by(long_covid covid_n)
egen sd_vas = sd(EuroQol_score), by(long_covid covid_n)
egen tag_vas = tag(long_covid covid_n)
gen n_covid2 = cond(long_covid==1, covid_n - 0.1, covid_n + 0.1)
gen upper= mean_vas +sd_vas
gen lower= mean_vas-sd_vas
twoway rcap upper lower n_covid2 if tag & long_covid==0, lc(blue%40) ///
|| scatter mean_vas n_covid2 if tag & long_covid==0, mc(blue%80) ///
|| rcap upper lower n_covid2 if tag & long_covid==1, lc(red%40) ///
|| scatter mean_vas n_covid2 if tag & long_covid==1, mc(red%80) ///
legend(order(4 "Long COVID" 2 "No Long COVID")) legend(margin(vsmall) region(lstyle(none))) ///
xtitle("Number of COVID-19 Cases") ylabel(, angle(0)) ///
xlabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4+") ytitle(Mean and SD of EQ-VAS) ///
title("EQ-VAS Score by COVID-19 Cases")
graph export "$projectdir/output/figures/VAS_by_covids.svg", width(12in) replace
restore

preserve
egen mean_vas = mean(EuroQol_score), by(long_covid vaccines_n)
egen sd_vas = sd(EuroQol_score), by(long_covid vaccines_n)
egen tag_vas = tag(long_covid vaccines_n)
gen n_vax2 = cond(long_covid==1, vaccines_n - 0.1, vaccines_n + 0.1)
gen upper= mean_vas +sd_vas
gen lower= mean_vas-sd_vas
twoway rcap upper lower n_vax2 if tag & long_covid==0, lc(blue%40) ///
|| scatter mean_vas n_vax2 if tag & long_covid==0, mc(blue%80) ///
|| rcap upper lower n_vax2 if tag & long_covid==1, lc(red%40) ///
|| scatter mean_vas n_vax2 if tag & long_covid==1, mc(red%80) ///
legend(order(4 "Long COVID" 2 "No Long COVID")) legend(margin(vsmall) region(lstyle(none))) ///
xtitle("Number of COVID-19 Vaccines") ylabel(, angle(0)) ///
xlabel(0 "0" 1 "1" 2 "2" 3 "3" 4 "4+") ytitle(Mean and SD of EQ-VAS) ///
title("EQ-VAS Score by COVID-19 Vaccines")
graph export "$projectdir/output/figures/VAS_by_vaccines.svg", width(12in) replace
restore

//*** FACIT-F Scores ***
hist fscore if long_covid==1 & survey_response==1, freq color(red%40) ///
xtitle(FACIT-F Scores at baseline) ylabel(0(50)300, angle(0)) xlabel(0(10)52) ///
title(Long COVID) name(fatigue_long_covid, replace)

hist fscore if long_covid==0 & survey_response==1, freq color(blue%40) ///
xtitle(FACIT-F Scores at baseline) ylabel(0(50)300, angle(0)) xlabel(0(10)52) ///
title(No Long COVID) name(fatigue_nolong_covid, replace)

graph combine fatigue_long_covid fatigue_nolong_covid, ///
title("FACIT-F Subscale Scores (Frequency Distribution)")
graph export "$projectdir/output/figures/facit_baseline.svg", width(12in) replace

log close
