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

get_ctv3_snomed_date_numeric <- function(qq, return_value = "ctv3"){
  subset_qs <- questions[questions$id == qq,]
  q_type <- subset_qs[1, "value_property"]
  
  # set default values for all four possible `return_value` objects
  num_val <- 0
  consultation_date <- NA
  ctv3 <- "None"
  snomedct_code <- "None"
  
  if(q_type == "ctv3_code"){
    ctv3 <- sample(subset_qs$q_codes, 1)
  }else if(q_type == "snomedct_code"){
    snomedct_code <- sample(subset_qs$q_codes, 1)
  }else if(q_type == "consultation_date"){
    ctv3 <- subset_qs[1, "q_codes"]
    consultation_date <- as.Date("2016-08-05") + abs(rnorm(1, 200, sd = 150))
  }else if(q_type == "numeric_value"){
    ctv3 <- snomedct_code <- subset_qs[1, "q_codes"]
    num_val <- sample(1:10, 1)
  }
  ## return whichever of those we need
  output <- get(return_value)
  names(output) <- NULL
  return(output)
}
#get_ctv3_snomed_date_numeric("mrc_breathlessness")
#get_ctv3_snomed_date_numeric("base_ethnicity", "snomedct_code")

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
      consultation_id = round(runif(1, 531513,5314141)),
      creation_date = as.Date("2022-11-01") + sample(1:180, 1),
      consultation_date = sapply(unique(questions$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "consultation_date")}, USE.NAMES = FALSE),
      ctv3_code = sapply(unique(questions$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "ctv3")}, USE.NAMES = FALSE),
      snomedct_code = sapply(unique(questions$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "snomedct_code")}, USE.NAMES = FALSE),
      numeric_value = sapply(unique(questions$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "num_val")}, USE.NAMES = FALSE)
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
      consultation_id = round(runif(1, 531513,5314141)),
      creation_date = pull(dummy_data[dummy_data$patient_id==patid, "creation_date"])[1] + runif(1, 25, 35),
      consultation_date = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "consultation_date")}, USE.NAMES = FALSE),
      ctv3_code = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "ctv3")}, USE.NAMES = FALSE),
      snomedct_code = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "snomedct_code")}, USE.NAMES = FALSE),
      numeric_value = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "num_val")}, USE.NAMES = FALSE)
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
      consultation_id = round(runif(1, 531513,5314141)),
      creation_date = pull(dummy_data[dummy_data$patient_id==patid, "creation_date"])[1] + runif(1, 55, 65),
      consultation_date = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "consultation_date")}, USE.NAMES = FALSE),
      ctv3_code = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "ctv3")}, USE.NAMES = FALSE),
      snomedct_code = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "snomedct_code")}, USE.NAMES = FALSE),
      numeric_value = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "num_val")}, USE.NAMES = FALSE)
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
      consultation_id = round(runif(1, 531513,5314141)),
      creation_date = pull(dummy_data[dummy_data$patient_id==patid, "creation_date"])[1] + runif(1, 85, 95),
      consultation_date = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "consultation_date")}, USE.NAMES = FALSE),
      ctv3_code = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "ctv3")}, USE.NAMES = FALSE),
      snomedct_code = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "snomedct_code")}, USE.NAMES = FALSE),
      numeric_value = sapply(unique(questions_research$id), function(xx){get_ctv3_snomed_date_numeric(xx, return_value = "num_val")}, USE.NAMES = FALSE)
      )
  )
}


dummy_data_combined <- bind_rows(
  dummy_data, 
  dummy_data_survey2,
  dummy_data_survey3,
  dummy_data_survey4
)

dummy_data_combined$consultation_date <-
  ifelse(
    is.na(dummy_data_combined$consultation_date),
    dummy_data_combined$creation_date,
    dummy_data_combined$consultation_date
  ) %>% as.Date(origin = "1970-01-01")


# some final manual bodge edits on the numeric_value
new_euroqol <- dummy_data_combined[dummy_data_combined$snomedct_code == "736535009", "numeric_value"] * 9 + round(runif(1, 0, 10))
dummy_data_combined[dummy_data_combined$snomedct_code == "736535009", "numeric_value"] <- new_euroqol

# Eq5d should be between 1-5
eq5d_row_ids <- dummy_data_combined$snomedct_code %in% c("821551000000108", "821561000000106", "821581000000102", "821591000000100", "821611000000108") 
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
