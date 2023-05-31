library(tidyverse)
library(lubridate)
library(here)
library(arrow)
library(gtsummary)

source(here("analysis/R_fn/summarise_data.R"))

op_baseline <- read_csv(here("output/openprompt_baseline.csv.gz"))

op_survey1 <- read_csv(here("output/openprompt_survey1.csv.gz")) %>% 
  mutate(survey_response = 1)

op_survey2 <- read_csv(here("output/openprompt_survey2.csv.gz")) %>% 
  mutate(survey_response = 2)

op_survey3 <- read_csv(here("output/openprompt_survey3.csv.gz")) %>% 
  mutate(survey_response = 3)

op_survey4 <- read_csv(here("output/openprompt_survey4.csv.gz")) %>% 
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

summarise_data(data_in = op_raw, filename = "op_raw")

# baseline summary --------------------------------------------------------
tab1 <- op_raw %>% 
  filter(survey_response==1) %>% 
  select(-where(is.Date), -patient_id) %>% 
  tbl_summary(
    statistic = list(
      all_continuous() ~ "{p50} ({p25}-{p75})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 1
  )

tab1 %>%
  as_gt() %>%
  gt::gtsave(
    filename = "tab1_baseline_description.html",
    path = fs::path(here("output"))
  )

