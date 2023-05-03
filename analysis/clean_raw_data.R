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
      # Outcome variables
      # convert first Long COVID record date into numeric 1,0 variable
      lc_out = as.numeric(!is.na(first_lc)),
      lc_dx_only = as.numeric(!is.na(first_lc_dx)),
      fracture = as.numeric(!is.na(first_fracture_hosp)),
      # convert gap between most recent vaccine and LC record into years
      last_vacc_gap = last_vacc_gap / 365.25,
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
                                  ))) %>% 
    # treat Long covid diagnosis (Dx) or referral (Rx) as a factor
    mutate(lc_dx_flag = factor(lc_dx_flag, levels = c("Dx", "Rx"))) %>% 
    # convert number of comorbidities to factor (0,1,2+)
    mutate(comorbidities = cut(
      comorbid_count, 
      breaks = c(-Inf, 0, 1, 2, Inf),
      labels = c("0", "1", "2+", "2+"))
    ) %>% 
    # create number of hospitalisations as factor (0-5+)
    mutate(covid_hosp_cat = cut(
      all_covid_hosp, 
      breaks = c(-Inf, 0:3, Inf),
      labels = c(as.character(0:2), "3+", "3+"))
    ) %>% 
    # create number of covid records as factor (0-5+)
    mutate(covid_primary_cat = cut(
      total_primarycare_covid, 
      breaks = c(-Inf, 0:5, Inf),
      labels = c(as.character(0:4), "5+", "5+"))
    ) %>% 
    # create number of covid positive Tests as factor (0-20+)
    mutate(test_positive_cat = cut(
      all_test_positive, 
      breaks = c(-Inf, 0:5, Inf),
      labels = c(as.character(0:4), "5+", "5+"))
    ) %>% 
    # create number of covid Tests as factor (0-20+)
    mutate(test_total_cat = cut(
      all_tests, 
      breaks = c(-Inf, 0:5, Inf),
      labels = c(as.character(0:4), "5+", "5+"))
    ) %>% 
    # long covid categorical (depends on previous covid status)
    mutate(lc_cat = factor(longcovid_categorical, 
                           levels = c(
                             "LC only",
                             "LC post-positive test",
                             "LC post-primary care COVID",
                             "LC post-COVID hospitalisation",
                             "LC post-critical COVID hospitalisation"
                           ))) %>% 
    # exclude 
    filter(t > 0) 
  
  df_full %>% 
    dplyr::select(patient_id, pt_start_date, pt_end_date, 
                  sex, age, age_centred, age_cat, 
                  practice_nuts, ethnicity, 
                  imd_q5, comorbidities, comorbid_count,
                  care_home, care_home_nursing, care_home_code,
                  highrisk_shield, lowrisk_shield,
                  ons_death_date, death_date,
                  all_test_positive, all_tests,
                  first_covid_hosp, first_covid_discharge, all_covid_hosp,
                  first_covid_critical, first_covid_hosp_primary_dx,
                  latest_primarycare_covid, total_primarycare_covid,
                  covid_hosp_cat, covid_primary_cat, test_positive_cat, test_total_cat,
                  starts_with("vaccine_dose_"),
                  no_prev_vacc, date_last_vacc, last_vacc_gap,
                  first_lc, first_lc_code, first_lc_dx, lc_dx_flag, first_fracture_hosp,
                  t, lc_out, lc_dx_only, lc_cat, fracture
    )
}
