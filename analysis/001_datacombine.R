library(tidyverse)
library(lubridate)
library(here)
library(arrow)
library(gtsummary)

source(here("analysis/R_fn/summarise_data.R"))
source(here("analysis/model_questions/master_mapping.R"))

op_baseline <- read_csv(here("output/openprompt_baseline.csv"))

op_survey1 <- read_csv(here("output/openprompt_survey1.csv")) %>% 
  mutate(survey_response = 1)

op_survey2 <- read_csv(here("output/openprompt_survey2.csv")) %>% 
  mutate(survey_response = 2)

op_survey3 <- read_csv(here("output/openprompt_survey3.csv")) %>% 
  mutate(survey_response = 3)

op_survey4 <- read_csv(here("output/openprompt_survey4.csv")) %>% 
  mutate(survey_response = 4)

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
  arrange(patient_id)

# output data -------------------------------------------------------------
arrow::write_parquet(op_raw, sink = here("output/openprompt_raw.gz.parquet"))

# map ctv3codes to the description ----------------------------------------
op_mapped <- op_raw %>% 
  dplyr::select(patient_id, survey_response, where(is_character)) %>% 
  pivot_longer(cols = c(-patient_id, -survey_response), names_to = "varname", values_to = "ctv3_code") %>% 
  left_join(openprompt_mapping, by = c("ctv3_code" = "codes")) %>% 
  pivot_wider(id_cols = c(patient_id, survey_response), names_from = varname, values_from = description)

op_numeric <- op_raw %>% 
  dplyr::select(patient_id, survey_response, where(is.numeric)) 

op_neat <- op_numeric %>% 
  left_join(op_mapped, by = c("patient_id", "survey_response"))

summarise_data(data_in = op_neat, filename = "op_raw")

# baseline summary --------------------------------------------------------
tab1 <- op_neat %>% 
  filter(survey_response==1) %>% 
  select(-where(is.Date), -patient_id) %>% 
  tbl_summary(
    statistic = list(
      all_continuous() ~ "{p50} ({p25}-{p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    type = list(
      survey_response ~ "continuous",
      first_covid ~ "continuous",
      n_covids ~ "continuous",
      covid_duration ~ "continuous",
      n_vaccines ~ "continuous",
      first_vaccine_date ~ "continuous",
      most_recent_vaccine_date ~ "continuous",
      eq5d_mobility ~ "continuous",
      eq5d_selfcare ~ "continuous",
      eq5d_usualactivities ~ "continuous",
      eq5d_pain_discomfort ~ "continuous",
      eq5d_anxiety_depression ~ "continuous",
      EuroQol_score ~ "continuous",
      work_affected ~ "continuous",
      life_affected ~ "continuous",
      facit_fatigue ~ "continuous",
      facit_weak  ~ "continuous",
      facit_listless ~ "continuous",
      facit_tired ~ "continuous",
      facit_trouble_starting ~ "continuous",
      facit_trouble_finishing ~ "continuous",
      facit_energy ~ "continuous",
      facit_usual_activities ~ "continuous",
      facit_sleep_during_day ~ "continuous",
      facit_eat ~ "continuous",
      facit_need_help ~ "continuous",
      facit_frustrated  ~ "continuous",
      facit_limit_social_activity ~ "continuous",
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
