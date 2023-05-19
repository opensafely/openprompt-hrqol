#' Clean raw data - calculate time in study, create binary outcome variables, convert strings to factors 
#' @description Imports the raw data and cleans it
#' @param data_in Combined case and control data (created by import_raw_data)
#' @return A dataframe containing cleaned data and string variables converted to factors

clean_raw_data <- function(data_in){
  df_full <- data_in %>% 
    arrange(patient_id) %>% 
    mutate(
      # create time variable for follow up (years)
      t =  pt_start_date %--% pt_end_date / dyears(1),
      # convert IMD to quintiles
      imd_q5 = cut(imd,
                   breaks = c(32844 * seq(0, 1, 0.2)),
                   labels = c("1 (most deprived)",
                              "2",
                              "3",
                              "4",
                              "5 (least deprived)")
      ),
      # label ethnicity variable 
      ethnicity = factor(
        ethnicity,
        levels = 1:6, 
        labels = c(
          "White",
          "Mixed", 
          "South Asian", 
          "Black",
          "Other",
          "Not stated"
        )),
      # create an age category variable for easy stratification
      age_cat = cut(
        age, 
        breaks = c(0, 31, 41, 51, 61, 71, Inf),
        labels = c(
          "18-29",
          "30-39",
          "40-49",
          "50-59",
          "60-69",
          "70+"
        )),
      # age centred (for modelling purposes)
      age_centred = age - mean(age, na.rm = TRUE),
      # make ethnicity a factor
      ethnicity = factor(ethnicity)
    ) %>% 
    # only keep people with recorded sex
    mutate(sex = factor(sex, levels = c("male", "female"))) %>% 
    # treat region as a factor
    mutate(practice_nuts = factor(practice_nuts,
                                  levels = c("London", 
                                             "East Midlands",
                                             "East",
                                             "North East",
                                             "North West",
                                             "South East",
                                             "South West",
                                             "West Midlands", 
                                             "Yorkshire and The Humber"
                                  ))) 
  
  df_full %>% 
    dplyr::select(patient_id, pt_start_date, pt_end_date, 
                  sex, age, age_centred, age_cat, 
                  practice_nuts, ethnicity, 
                  imd_q5, 
                  has_died,
                  all_test_positive, all_tests,
                  long_covid_first_dx, long_covid_first_rx,
                  t
    )
}
