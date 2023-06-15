#' Edit the dummy data file created by ehrQL
#' 
#' Run the following in command line before executing this code
#' opensafely exec ehrql:v0 create-dummy-tables analysis/model_questions/process_baseline.py output/dummydata -- --day=0

library(tidyverse)
library(here)

dir.create(here::here("output/dummydata/dummy_edited/"), showWarnings = FALSE)

source(here::here("analysis/dummy_data_editing/baseline_questions.R"))
source(here::here("analysis/dummy_data_editing/research_questions.R"))

op_baseline <- read_csv(here::here("output/dummydata/open_prompt.csv"))

questions <- bind_rows(questions_baseline, questions_research)

get_ctv3_or_numeric <- function(qq, return_value = "ctv3"){
  subset_qs <- questions[questions$id == qq,]
  if(subset_qs[1, "value_property"] == "ctv3_code"){
    num_val <- 0
    ctv3 <- sample(subset_qs$ctv3_codes, 1)
  }else{
    num_val <- sample(0:10, size = 1)
    ctv3 <- subset_qs[1, "ctv3_codes"]
  }
  return(get(return_value))
}

unique_ids <- unique(op_baseline$patient_id)
# number of patients in the dummy data
n_patid <- length(unique_ids)
set.seed(1320523756)

# generate a random response to every questions for day 0 
dummy_data <- NULL
for(patid in unique_ids){
  dummy_data <- bind_rows(
    dummy_data, 
    bind_cols(
      patient_id = patid,
      consultation_date = as.Date("2022-11-01") + sample(1:180, 1),
      consultation_id = round(runif(1, 531513,5314141)),
      ctv3_code = sapply(unique(questions$id), function(xx){get_ctv3_or_numeric(xx, return_value = "ctv3")}),
      numeric_value = sapply(unique(questions$id), function(xx){get_ctv3_or_numeric(xx, return_value = "num_val")})
      )
  )
}

# generate research survey responses 25-35 days after day 0 
dummy_data_survey2 <- NULL 
previous_ids <- unique(dummy_data$patient_id)
sample_ids <- sample(previous_ids, size = length(previous_ids) * 0.4)
for(patid in sample_ids){
  dummy_data_survey2 <- bind_rows(
    dummy_data_survey2,
    bind_cols(
      patient_id = patid, 
      consultation_date = pull(dummy_data[dummy_data$patient_id==patid, "consultation_date"])[1] + runif(1, 25, 35),
      consultation_id = round(runif(1, 531513,5314141)),
      ctv3_code = sapply(unique(questions_research$id), function(xx){get_ctv3_or_numeric(xx, return_value = "ctv3")}),
      numeric_value = sapply(unique(questions_research$id), function(xx){get_ctv3_or_numeric(xx, return_value = "num_val")})
      )
  )
}

# generate research survey responses 25-35 days after day 0 
dummy_data_survey3 <- NULL 
previous_ids <- unique(dummy_data_survey2$patient_id)
sample_ids <- sample(previous_ids, size = length(previous_ids) * 0.5)
for(patid in sample_ids){
  dummy_data_survey3 <- bind_rows(
    dummy_data_survey3,
    bind_cols(
      patient_id = patid, 
      consultation_date = pull(dummy_data[dummy_data$patient_id==patid, "consultation_date"])[1] + runif(1, 55, 65),
      consultation_id = round(runif(1, 531513,5314141)),
      ctv3_code = sapply(unique(questions_research$id), function(xx){get_ctv3_or_numeric(xx, return_value = "ctv3")}),
      numeric_value = sapply(unique(questions_research$id), function(xx){get_ctv3_or_numeric(xx, return_value = "num_val")})
    )
  )
}

# generate research survey responses 25-35 days after day 0 
dummy_data_survey4 <- NULL 
previous_ids <- unique(dummy_data_survey3$patient_id)
sample_ids <- sample(previous_ids, size = length(previous_ids) * 0.5)
for(patid in sample_ids){
  dummy_data_survey4 <- bind_rows(
    dummy_data_survey4,
    bind_cols(
      patient_id = patid, 
      consultation_date = pull(dummy_data[dummy_data$patient_id==patid, "consultation_date"])[1] + runif(1, 85, 95),
      consultation_id = round(runif(1, 531513,5314141)),
      ctv3_code = sapply(unique(questions_research$id), function(xx){get_ctv3_or_numeric(xx, return_value = "ctv3")}),
      numeric_value = sapply(unique(questions_research$id), function(xx){get_ctv3_or_numeric(xx, return_value = "num_val")})
    )
  )
}


dummy_data_combined <- bind_rows(
  dummy_data, 
  dummy_data_survey2,
  dummy_data_survey3,
  dummy_data_survey4
)


# some final manual bodge edits on the numeric_value
new_euroqol <- dummy_data_combined[dummy_data_combined$ctv3_code == "XaZ2m", "numeric_value"] * 9 + round(runif(1, 0, 10))
dummy_data_combined[dummy_data_combined$ctv3_code == "XaZ2m", "numeric_value"] <- new_euroqol

# Eq5d should be between 1-5
eq5d_row_ids <- dummy_data_combined$ctv3_code %in% c("XaYwl", "XaYwm", "XaYwn", "XaYwo", "XaYwp") 
new_eq5d <- sample(x = 1:5, sum(eq5d_row_ids), replace = TRUE)
dummy_data_combined[eq5d_row_ids, "numeric_value"] <- new_eq5d

# long covid duration (Y3a7f) should be 0-3
covid_duration_ids <- dummy_data_combined$ctv3_code == "Y3a7f"
new_covid_duration <- sample(0:3, sum(covid_duration_ids), replace = TRUE)
dummy_data_combined[covid_duration_ids, "numeric_value"] <- new_covid_duration

# number of covids (Y3a98) should be 0:6
covid_count_ids <- dummy_data_combined$ctv3_code == "Y3a98"
new_covid_count <- sample(0:6, sum(covid_count_ids), replace = TRUE)
dummy_data_combined[covid_count_ids, "numeric_value"] <- new_covid_count

# number of vaccines (Y3a9e) should be 1:6
vacc_count_ids <- dummy_data_combined$ctv3_code == "Y3a9e"
new_vacc_count <- sample(0:6, sum(vacc_count_ids), replace = TRUE)
dummy_data_combined[vacc_count_ids, "numeric_value"] <- new_vacc_count

# create some missingness 
optional_questions <- c("Y3a80",
                        "Y3a97",
                        "Y3a98",
                        "Y3a99",
                        "Y3a9a",
                        "Y3a7f",
                        "Y3a9e",
                        "Y3a9f",
                        "Y3aa0")
optional_response_rows <- which(dummy_data_combined$ctv3_code %in% optional_questions)
# delete some of the optional responses:
dummy_data_combined <- dummy_data_combined[-sample(optional_response_rows, size = length(optional_response_rows)*0.4), ]

# export this mess --------------------------------------------------------
write_csv(dummy_data_combined, here::here("output/dummydata/dummy_edited/open_prompt.csv"))
