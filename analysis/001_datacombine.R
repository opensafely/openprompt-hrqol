library(tidyverse)
library(lubridate)
library(here)
library(gtsummary)

op_baseline <- read_csv(here("output/openprompt_baseline.csv"))
op_survey1 <- read_csv(here("output/openprompt_survey1.csv")) %>% 
  mutate(survey_response = 1)
op_survey2 <- read_csv(here("output/openprompt_survey2.csv")) %>% 
  mutate(survey_response = 2)


# stack research questionnaire responses ----------------------------------
op_surveys <- bind_rows(
  op_survey1, 
  op_survey2
)

# left join baseline vars -------------------------------------------------
op_raw <- op_baseline %>% 
  left_join(op_surveys, by = "patient_id") %>% 
  arrange(patient_id)

# output data -------------------------------------------------------------
write_csv(op_raw, here("output/openprompt_raw.csv"))

