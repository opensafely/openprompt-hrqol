library(tidyverse)
library(lubridate)
library(here)
library(arrow)
library(gtsummary)

source(here("analysis/R_fn/summarise_data.R"))
source(here("analysis/model_questions/master_mapping.R"))

op_baseline <- read_csv(here("output/openprompt_baseline.csv"), 
                        col_types = list(
                          patient_id = "d",
                          first_consult_date = "D", 
                          consult_date = "D",
                          ethnicity = "c",
                          highest_edu = "c",
                          disability = "c",
                          relationship = "c",
                          gender = "c",
                          hh_income = "c"
                        ))

# Survey column specification 
research_col_spec <- list(
  patient_id = "d",
  consult_date = "D",
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
  employment_status = "c",
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
  mrc_breathlessness = "c"
)

op_survey1 <- read_csv(here("output/openprompt_survey1.csv"), col_types = research_col_spec) %>% 
  mutate(survey_response = 1)

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
  rename("baseline_consult_date"="consult_date.x") %>% 
  rename("survey_date"="consult_date.y") 

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

# output data -------------------------------------------------------------
write.csv(op_raw, here::here("output/openprompt_raw.csv.gz"))

# Filter out missing data:  -----------------------------------------------
op_filtered <- op_raw

# map ctv3codes to the description ----------------------------------------
op_mapped <- op_filtered %>% 
  dplyr::select(patient_id, survey_response, where(is_character)) %>% 
  pivot_longer(cols = c(-patient_id, -survey_response), names_to = "varname", values_to = "ctv3_code") %>% 
  left_join(openprompt_mapping, by = c("ctv3_code" = "codes")) %>% 
  pivot_wider(id_cols = c(patient_id, survey_response), names_from = varname, values_from = description)

op_numeric <- op_filtered %>% 
  dplyr::select(patient_id, survey_response, where(is.numeric)) 

op_dates <- op_filtered %>% 
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
eq5d_questions <- op_neat %>% dplyr::select(starts_with("eq5d_")) %>% names()
op_neat <- op_neat %>% 
  mutate_at(all_of(eq5d_questions), ~factor(., levels = 1:5, 
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
labels_facit <- c(
  "Not at all",
  "A little bit",
  "Somewhat",
  "Quite a bit",
  "Very much"
)
facit_questions <- op_neat %>% dplyr::select(starts_with("facit")) %>% names()
op_neat <- op_neat %>% 
  mutate_at(all_of(facit_questions), ~factor(., levels = 0:4, 
                                            labels = labels_facit))

# Output summary of the tidied up dataset ---------------------------------
summarise_data(data_in = op_neat, filename = "op_mapped")

# baseline summary --------------------------------------------------------
tab1 <- op_neat %>% 
  #filter(survey_response==1) %>% 
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
      ethnicity ~ "categorical",
      highest_edu ~ "categorical",
      disability ~ "categorical",
      relationship ~ "categorical",
      gender ~ "categorical",
      hh_income ~ "categorical",
      long_covid ~ "categorical",
      recovered_from_covid ~ "categorical",
      vaccinated ~ "categorical",
      employment_status ~ "categorical",
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
