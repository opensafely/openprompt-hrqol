library(tidyverse)
library(lubridate)
library(here)
library(gtsummary)

source(here("analysis/R_fn/clean_raw_data.R"))

raw_data <- read_csv(here("output/openprompt_raw_plus_tpp.gz.csv"))
spec(raw_data)

cleaned_data <- clean_raw_data(raw_data)

arrow::write_parquet(x = cleaned_data,
                     sink = here("output/cleaned_data.gz.parquet")
)
#
tab1 <- cleaned_data %>% 
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


# longcovid_dates ---------------------------------------------------------


