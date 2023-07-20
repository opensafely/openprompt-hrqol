library(tidyverse)
library(lubridate)
library(here)
library(arrow)
library(gtsummary)
library(haven)
source(here("analysis/R_fn/summarise_data.R"))
source(here("analysis/model_questions/master_mapping.R"))

op_baseline <- read_csv(here("output/openprompt_survey1.csv"),
                        col_types = list(
                          patient_id = "d",
                          creation_date = "D",
                          base_ethnicity = "c",
                          base_highest_edu = "c",
                          base_disability = "c",
                          base_relationship = "c",
                          base_gender = "c",
                          base_gender_ctv3 = "c",
                          base_hh_income = "c",
                          base_hh_income_snomed = "c",
                          base_ethnicity_creation_date = "D",
                          base_highest_edu_creation_date = "D",
                          base_disability_creation_date = "D",
                          base_relationship_creation_date = "D",
                          base_gender_creation_date = "D",
                          base_gender_ctv3_creation_date = "D",
                          base_hh_income_creation_date = "D",
                          base_hh_income_snomed_creation_date = "D"
                        )) %>% 
  dplyr::select(patient_id, creation_date, starts_with("base_"))

# get index_date as the first recorded of any "base_" variable
op_baseline$index_date <- pmin(
  op_baseline$creation_date,
  op_baseline$base_ethnicity_creation_date,
  op_baseline$base_highest_edu_creation_date,
  op_baseline$base_disability_creation_date,
  op_baseline$base_relationship_creation_date,
  op_baseline$base_gender_creation_date,
  op_baseline$base_gender_ctv3_creation_date,
  op_baseline$base_hh_income_creation_date,
  op_baseline$base_hh_income_snomed_creation_date,
  na.rm = T
)

## Combine the ctv3 and snomed codes for hh_income and gender
op_baseline <- op_baseline %>% 
  mutate(base_gender = ifelse(is.na(base_gender), base_gender_ctv3, base_gender),
         base_hh_income = ifelse(is.na(base_hh_income), base_hh_income_snomed, base_hh_income),
         base_gender_creation_date = pmin(base_gender_creation_date, base_gender_ctv3_creation_date, na.rm = TRUE),
         base_hh_income_creation_date = pmin(base_hh_income_creation_date, base_hh_income_snomed_creation_date, na.rm = TRUE)
         ) %>% 
  dplyr::select(-c(base_gender_ctv3, base_gender_ctv3_creation_date,
                base_hh_income_snomed, base_hh_income_snomed_creation_date))

# Survey column specification 
research_col_spec <- list(
  patient_id = "d",
  creation_date = "D",
  days_since_baseline = "d",
  long_covid = "c",
  first_covid = "D",
  n_covids = "d",
  recovered_from_covid = "c",
  covid_duration = "d",
  vaccinated = "c",
  n_vaccines = "d",
  first_vaccine_date = "D",
  most_recent_vaccine_date = "D",
  eq5d_mobility = "d",
  eq5d_selfcare = "d",
  eq5d_usualactivities = "d",
  eq5d_pain_discomfort = "d",
  eq5d_anxiety_depression = "d",
  EuroQol_score = "d",
  #FIXME: when employment data comes back "online"
  #employment_status = "c",
  work_affected = "d",
  life_affected = "d",
  facit_fatigue = "d",
  facit_weak = "d",
  facit_listless = "d",
  facit_tired = "d",
  facit_trouble_starting = "d",
  facit_trouble_finishing = "d",
  facit_energy = "d",
  facit_usual_activities = "d",
  facit_sleep_during_day = "d",
  facit_eat = "d",
  facit_need_help = "d",
  facit_frustrated = "d",
  facit_limit_social_activity = "d",
  mrc_breathlessness = "c",
  # repeat for _creation_date
  long_covid_creation_date = "D",
  first_covid_creation_date = "D",
  n_covids_creation_date = "D",
  recovered_from_covid_creation_date = "D",
  covid_duration_creation_date = "D",
  vaccinated_creation_date = "D",
  n_vaccines_creation_date = "D",
  first_vaccine_date_creation_date = "D",
  most_recent_vaccine_date_creation_date = "D",
  eq5d_mobility_creation_date = "D",
  eq5d_selfcare_creation_date = "D",
  eq5d_usualactivities_creation_date = "D",
  eq5d_pain_discomfort_creation_date = "D",
  eq5d_anxiety_depression_creation_date = "D",
  EuroQol_score_creation_date = "D",
  #FIXME: when employment data comes back "online"
  #employment_status_creation_date = "D",
  work_affected_creation_date = "D",
  life_affected_creation_date = "D",
  facit_fatigue_creation_date = "D",
  facit_weak_creation_date = "D",
  facit_listless_creation_date = "D",
  facit_tired_creation_date = "D",
  facit_trouble_starting_creation_date = "D",
  facit_trouble_finishing_creation_date = "D",
  facit_energy_creation_date = "D",
  facit_usual_activities_creation_date = "D",
  facit_sleep_during_day_creation_date = "D",
  facit_eat_creation_date = "D",
  facit_need_help_creation_date = "D",
  facit_frustrated_creation_date = "D",
  facit_limit_social_activity_creation_date = "D",
  mrc_breathlessness_creation_date = "D"
)

op_survey1 <- read_csv(here("output/openprompt_survey1.csv"), 
                       col_types = research_col_spec) %>% 
  mutate(survey_response = 1) %>% 
  dplyr::select(!starts_with("base_"))

op_survey2 <- read_csv(here("output/openprompt_survey2.csv"), col_types = research_col_spec) %>%
  mutate(survey_response = 2)

op_survey3 <- read_csv(here("output/openprompt_survey3.csv"), col_types = research_col_spec) %>% 
  mutate(survey_response = 3)

op_survey4 <- read_csv(here("output/openprompt_survey4.csv"), col_types = research_col_spec) %>% 
  mutate(survey_response = 4)

# output raw data summaries -----------------------------------------------
summarise_data(data_in = op_baseline, filename = "op_baseline")
summarise_data(data_in = op_survey1, filename = "op_survey1")
summarise_data(data_in = op_survey2, filename = "op_survey2")
summarise_data(data_in = op_survey3, filename = "op_survey3")
summarise_data(data_in = op_survey4, filename = "op_survey4")

# stack research questionnaire responses ----------------------------------
op_surveys <- bind_rows(
  op_survey1, 
  op_survey2,
  op_survey3,
  op_survey4
)

# left join baseline vars -------------------------------------------------
op_raw <- op_baseline %>% 
  left_join(op_surveys, by = "patient_id") %>%
  arrange(patient_id) %>% 
  rename("baseline_creation_date"="creation_date.x") %>% 
  rename("survey_date"="creation_date.y") 

# Output a summary of the raw data ----------------------------------------
summarise_data(data_in = op_raw, filename = "op_raw")

sample_ids <- op_raw %>% 
  filter(!is.na(survey_date)) %>% 
  filter(survey_response >= 2) %>% 
  dplyr::select(patient_id) %>% 
  pull() %>% 
  sample(size = 20, replace = TRUE)

pdf(here::here("output/data_properties/sample_day_lags.pdf"), width = 6, height = 4)
op_raw %>% 
  filter(patient_id %in% sample_ids) %>% 
  ggplot(aes(y = days_since_baseline, x = survey_response, group = patient_id)) +
  geom_line() + 
  geom_point(pch = 1)
dev.off()

# map ctv3codes to the description ----------------------------------------
op_mapped <- op_raw %>% 
  dplyr::select(patient_id, survey_response, where(is_character)) %>% 
  pivot_longer(cols = c(-patient_id, -survey_response), names_to = "varname", values_to = "q_code") %>% 
  left_join(openprompt_mapping, by = c("q_code" = "codes")) %>% 
  pivot_wider(id_cols = c(patient_id, survey_response), names_from = varname, values_from = description)

op_numeric <- op_raw %>% 
  dplyr::select(patient_id, survey_response, where(is.numeric)) 

op_dates <- op_raw %>% 
  dplyr::select(patient_id, survey_response, where(is.Date)) 

op_neat <- op_mapped %>% 
  left_join(op_numeric, by = c("patient_id", "survey_response")) %>% 
  left_join(op_dates, by = c("patient_id", "survey_response"))

# Mapping values for scored assessments -----------------------------------
# some questions are stored as numeric but they correspond to a scored assessment
# between [1, 5] or [0, 10] usually (with some exceptions).
# Need to map these as they are actually categorical vars, not numeric

# there is probably a better way of doing this but this is a manual version that works

# - number of times you have had COVID - Y3a98
op_neat$n_covids <- factor(op_neat$n_covids, levels = 0:6, 
                           labels = c("0",
                                      "1",
                                      "2",
                                      "3",
                                      "4",
                                      "5",
                                      "6+"))
# - length of symptoms - Y3a7f
op_neat$covid_duration <- factor(op_neat$covid_duration, levels = 0:3,
                                 labels = c("Less than 2 weeks",
                                            "2 – 3 weeks",
                                            "4 – 12 weeks",
                                            "More than 12 weeks"))
# - N covid injections - Y3a9e
op_neat$n_vaccines <- factor(op_neat$n_vaccines, levels = 0:6,
                             labels = c("0",
                                        "1",
                                        "2",
                                        "3",
                                        "4",
                                        "5",
                                        "6+"))
# - EQ-5d questions: scored from 1:5 in increasing levels of disability
eq5d_questions <- op_neat %>% dplyr::select(starts_with("eq5d_")) %>% dplyr::select(!contains("creation_date")) %>% names()
op_neat <- op_neat %>% 
  mutate_at(eq5d_questions, ~factor(., levels = 1:5, 
                                            labels = c("none",
                                                       "slight", 
                                                       "moderate",
                                                       "severe",
                                                       "unable")))

# - work and productivity questions: Y3a80 & Y3a81
labels_work_and_productivity <- c(
  "0 (No effect on my daily activities)",
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "7",
  "8",
  "9",
  "10 (Completely prevented me from doing my daily activities)"
)
op_neat$work_affected <- factor(op_neat$work_affected, levels = 0:10, labels = labels_work_and_productivity)
op_neat$life_affected <- factor(op_neat$life_affected, levels = 0:10, labels = labels_work_and_productivity)

# - FACIT: 13 questions on fatigue scale

# Note: scores are reversed so that a high score is equivalent to not having a problem
# e.g., "Not at all" for "Do you feel fatigued"
labels_facit_proper <- c(
  "Very much",
  "Quite a bit",
  "Somewhat",
  "A little bit",
  "Not at all"
)
# HOWEVER, there are two questions that need to be scored the other way around
# fun
labels_facit_reverse <- c(
  "Not at all",
  "A little bit",
  "Somewhat",
  "Quite a bit",
  "Very much"
)

facit_questions <- op_neat %>% dplyr::select(starts_with("facit")) %>% dplyr::select(!contains("creation_date")) %>% names()
facit_questions_reverse <- c("facit_energy", "facit_usual_activities")
facit_questions_proper <- facit_questions[!facit_questions %in% facit_questions_reverse]

op_neat <- op_neat %>% 
  mutate_at(all_of(facit_questions_proper), ~factor(., levels = 0:4, 
                                            labels = labels_facit_proper)) %>% 
  mutate_at(all_of(facit_questions_reverse), ~factor(., levels = 0:4, 
                                                    labels = labels_facit_reverse))


# TODO: convert all strings to factor
# Ethnicity:
op_neat$base_ethnicity <- factor(op_neat$base_ethnicity, 
                                 levels = c("White",
                                            "Mixed",
                                            "Asian/Asian Brit",
                                            "Black/African/Caribbn/Black Brit",
                                            "Other/not stated",
                                            "NA"),
                                 labels = c("White",
                                            "Mixed",
                                            "Asian/Asian Brit",
                                            "Black/African/Caribbn/Black Brit",
                                            "Other/not stated",
                                            "Other/not stated"))


# Eductaion
op_neat$base_highest_edu <- factor(op_neat$base_highest_edu, 
                                 levels = c("less than primary school",
                                            "primary school completed",
                                            "secondary / high school completed",
                                            "college / university completed",
                                            "post graduate degree",
                                            "NA",
                                            "Refused"),
                                 labels = c("None/less than primary school",
                                            "Primary School",
                                            "Secondary/high school",
                                            "College/university",
                                            "Postgraduate qualification",
                                            "Not stated",
                                            "Not stated"))

# Disability
op_neat$base_disability <- factor(op_neat$base_disability, 
                                 levels = c("None",
                                            "Disability",
                                            "Refused",
                                            "NA"),
                                 labels = c("No",
                                            "Yes",
                                            "Not stated",
                                            "Not stated"))

# Relationship status
op_neat$base_relationship <- factor(op_neat$base_relationship, 
                                 levels = c("Single person",
                                            "Cohabiting",
                                            "Married/civil partner",
                                            "Separated",
                                            "Divorced/person whose civil partnership has been dissolved",
                                            "Widowed/surviving civil partner",
                                            "Marital/civil state not disclosed",
                                            "NA"
                                            ),
                                 labels = c("Single person",
                                            "Cohabiting",
                                            "Married/civil partner",
                                            "Separated",
                                            "Divorced/dissolved civil partnership",
                                            "Widowed/surviving civil partner",
                                            "Not stated",
                                            "Not stated"
                                            ))

# Gender - Male/Female only 
op_neat$base_gender <- factor(op_neat$base_gender, 
                                  levels = c("Male",
                                             "Female",
                                             "Intersex/non-binary/other/refused",
                                             "NA"),
                                  labels = c("Male",
                                             "Female",
                                             "Intersex/non-binary/other/refused",
                                             "Not stated"))

# Income 
op_neat$base_hh_income <- factor(op_neat$base_hh_income, 
                                 levels = c("£6,000-12,999",
                                            "£13,000-18,999",
                                            "£19,000-25,999",
                                            "£26,000-31,999",
                                            "£32,000-47,999",
                                            "£48,000-63,999",
                                            "£64,000-95,999",
                                            "£96,000",
                                            "Unknown income",
                                            "NA"
                                            ),
                                 labels = c("£6,000-12,999",
                                            "£13,000-18,999",
                                            "£19,000-25,999",
                                            "£26,000-31,999",
                                            "£32,000-47,999",
                                            "£48,000-63,999",
                                            "£64,000-95,999",
                                            "£96,000",
                                            "Not stated",
                                            "Not stated"
                                            ))

# Employment Status
#FIXME: when employment data comes back "online"
#op_neat$employment_status <- as_factor(op_neat$employment_status)

# Covid history 
op_neat$long_covid <- factor(op_neat$long_covid,
                             levels = c(
                               "My test for COVID-19 was positive",
                               "I think I have already had COVID-19 (coronavirus) disease",
                               "Suspected COVID-19",
                               "I am unsure if I currently have or have ever had COVID-19",
                               "I do not think I currently have or have ever had COVID-19",
                               "I prefer not to say if I currently have or have ever had COVID-19",
                               "NA"
                             ),
                             labels = c(
                               "Yes (+ve test)",
                               "Yes (medical advice",
                               "Yes (suspected)",
                               "Unsure",
                               "No",
                               "Not stated",
                               "Not stated"
                             ))

# Covid recovery 
op_neat$recovered_from_covid <- factor(op_neat$recovered_from_covid,
                                       levels = c(
                                         "I feel I have fully recovered from my (latest) episode of COVID-19",
                                         "I feel I have not fully recovered from my (latest) episode of COVID-19",
                                         "NA"
                                       ),
                                       labels = c(
                                         "Yes, back to normal",
                                         "No, still have symptoms",
                                         "Not stated"
                                       ))

# Vaccinated
op_neat$vaccinated <- factor(op_neat$vaccinated, 
                             levels = c(
                               "I have had at least one COVID-19 vaccination",
                               "I have not had any COVID-19 vaccinations",
                               "I prefer not to say if I have had any COVID-19 vaccinations",
                               "NA"
                             ),
                             labels = c(
                               "Yes",
                               "No",
                               "Not stated",
                               "Not stated"
                             ))

# MRC breathlessness
op_neat$mrc_breathlessness <- factor(op_neat$mrc_breathlessness,
                                     levels = c(
                                       "MRC Breathlessness Scale: grade 1",
                                       "MRC Breathlessness Scale: grade 2",
                                       "MRC Breathlessness Scale: grade 3",
                                       "MRC Breathlessness Scale: grade 4",
                                       "MRC Breathlessness Scale: grade 5"
                                     ))

# Output summary of the tidied up dataset ---------------------------------
summarise_data(data_in = op_neat, filename = "op_mapped")

# output data -------------------------------------------------------------
readr::write_csv(op_neat, here::here("output/openprompt_raw.csv.gz"))

# STATA variable names have max length of 32. So truncate anynames longer than that

# make a new dataset to output as the stata .dta
op_stata <- op_neat 

# get the names of the original data
df_names <- names(op_neat)

# replace names on new dataset to 1-32 characters of original names
names(op_stata) <- substr(df_names, 1, 32)

# output as .dta
haven::write_dta(op_stata, path = here::here("output/op_stata.dta"))

# baseline summary --------------------------------------------------------
# op_raw contains every participant ID included in the `open_prompt` table 
# we therefore have a lot of rows with nothing more than NA in them
# a lot of people filled in `op_survey1`. Fewer filled in `op_survey2`,
# `op_survey3` & `op_survey4` etc.
# Remove these before summarising:

tab1 <- op_neat %>%
  select(-where(is.Date), -patient_id) %>% 
  tbl_summary(
    by = survey_response,
    statistic = list(
      all_continuous() ~ "{p50} ({p25}-{p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    type = list(
      days_since_baseline ~ "continuous",
      EuroQol_score ~ "continuous",
      n_covids ~ "categorical",
      covid_duration ~ "categorical",
      n_vaccines ~ "categorical",
      eq5d_mobility ~ "categorical",
      eq5d_selfcare ~ "categorical",
      eq5d_usualactivities ~ "categorical",
      eq5d_pain_discomfort ~ "categorical",
      eq5d_anxiety_depression ~ "categorical",
      work_affected ~ "categorical",
      life_affected ~ "categorical",
      facit_fatigue ~ "categorical",
      facit_weak  ~ "categorical",
      facit_listless ~ "categorical",
      facit_tired ~ "categorical",
      facit_trouble_starting ~ "categorical",
      facit_trouble_finishing ~ "categorical",
      facit_energy ~ "categorical",
      facit_usual_activities ~ "categorical",
      facit_sleep_during_day ~ "categorical",
      facit_eat ~ "categorical",
      facit_need_help ~ "categorical",
      facit_frustrated  ~ "categorical",
      facit_limit_social_activity ~ "categorical",
      base_ethnicity ~ "categorical",
      base_highest_edu ~ "categorical",
      base_disability ~ "categorical",
      base_relationship ~ "categorical",
      base_gender ~ "categorical",
      base_hh_income ~ "categorical",
      long_covid ~ "categorical",
      recovered_from_covid ~ "categorical",
      vaccinated ~ "categorical",
      #FIXME: when employment data comes back "online"
      #employment_status ~ "categorical",
      mrc_breathlessness ~ "categorical"
    ),
    digits = all_continuous() ~ 1
  )

tab1 %>%
  as_gt() %>%
  gt::gtsave(
    filename = "tab1_baseline_description.html",
    path = fs::path(here("output"))
  )


# plot distribution of day0 -----------------------------------------------
pdf(here::here("output/data_properties/index_dates.pdf"), width = 6, height = 4)
ggplot(op_neat, aes(x = index_date)) +
  geom_density(fill = "gray") +
  theme_classic()
dev.off()

# is creation_date consistent across participant survey responses?  ---------
date_consistency <- op_neat %>% 
  ungroup() %>% 
  # only keep the idenitifier cols and the creation_date variables
  dplyr::select(patient_id, survey_response, survey_date, contains("creation_date")) %>% 
  # get rid of those with missing survey_date: this means there was no valid response in the dataset_definition
  filter(!is.na(survey_date)) %>% 
  # remove survey_date and baseline_creation_date to avoid confusion
  dplyr::select(-survey_date, -baseline_creation_date) %>% 
  # make it a long data.frame to summarise 
  pivot_longer(cols = contains("creation_date"), names_to = "var", values_to = "date") %>%
  # group by each participant for each survey response
  group_by(patient_id, survey_response) %>% 
  # summarise the date column: number of unique values, number NA, min and max
  summarise(n_date_vals = n_distinct(date, na.rm = T),
            min_date = min(date, na.rm = T), 
            max_date = max(date, na.rm = T),
            n_missing = sum(is.na(date)),
            .groups = "keep")

summ_date_consistency <- date_consistency %>% 
  # get the summary of these summaries because I can't scroll through thousands of responses
  ungroup() %>% 
  count(n_date_vals)

write_csv(date_consistency, here::here("output/data_properties/survey_date_consistency.csv"))
write_csv(summ_date_consistency, here::here("output/data_properties/survey_date_consistency_summary.csv"))

