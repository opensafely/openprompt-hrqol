Question <- function(id, ctv3_codes, value_property){
  data.frame(
    id = rep(id, length(ctv3_codes)),
    ctv3_codes, 
    value_property = rep(value_property, length(ctv3_codes))
  )
}

questions_research <- bind_rows(
    Question(
    "covid_history", # "Do you think that you currently have or have ever had COVID-19?
    c(
      "Y26b2",
      "Y25a5",
      "Y3a94",
      "Y3a95",
      "Y3a96"
    ),
    "ctv3_code"
  ),
  Question(
    "first_covid", # "When do you think you first got (or might have got) COVID-19? If you do not remember exactly, please put your best estimate.
    c(
      "Y3a97"
    ),
    "consultation_date"
  ),
  Question( 
    "n_covids", # "How many times do you think you have had an episode of COVID-19?
    c(
      "Y3a98"
    ),
    "numeric_value" 
  ),
  Question(
    "recovered_from_covid",
    c(
      "Y3a99",
      "Y3a9a"
    ),
    "ctv3_code"
  ),
  Question(
    "covid_duration",
    c(
      "Y3a7f"
    ),
    "numeric_value"
  ),
  Question(
    "vaccinated",
    c(
      "Y3a9b",
      "Y3a9c",
      "Y3a9d"
    ),
    "ctv3_code"
  ),
  Question(
    "n_vaccines",
    c(
      "Y3a9e"
    ),
    "numeric_value"
  ),
  Question(
    "first_vaccine_date",
    c(
      "Y3a9f"
    ),
    "consultation_date" # FIXME: should be date
  ),
  Question(
    "most_recent_vaccine_date",
    c(
      "Y3aa0"
    ),
    "consultation_date" # FIXME: should be date
  ),
  Question( 
    "eq5d_mobility", # "How many times do you think you have had an episode of COVID-19?
    c(
      "XaYwl"
    ),
    "numeric_value" # should be 0-5
  ),
  Question( 
    "eq5d_selfcare", # "How many times do you think you have had an episode of COVID-19?
    c(
      "XaYwm"
    ),
    "numeric_value" # should be 0-5
  ),
  Question( 
    "eq5d_usualactivities", # "How many times do you think you have had an episode of COVID-19?
    c(
      "XaYwo"
    ),
    "numeric_value" # should be 0-5
  ),
  Question( 
    "eq5d_pain_discomfort", # "How many times do you think you have had an episode of COVID-19?
    c(
      "XaYwp"
    ),
    "numeric_value" # should be 0-5
  ),
  Question( 
    "eq5d_anxiety_depression", # "How many times do you think you have had an episode of COVID-19?
    c(
      "XaYwr"
    ),
    "numeric_value" # should be 0-5
  ),
  Question(
    "EuroQol_score",
    c(
      "XaZ2m"
    ),
    "numeric_value"
  ),
  Question(
    "employment_status",
    c(
      "Ua0TB",
      "13J7."
    ),
    "ctv3_code"
  ),
  # Question( FIXME: Ua0pu used for three questions, can't disambiguate 
  #     "hours_worked",
  #     c(
  #         "Ua0pu",
  #     ),
  #     "numeric_value"
  # ),
  Question(
    "work_affected",
    c(
      "Y3a80"
    ),
    "numeric_value"
  ),
  Question(
    "life_affected",
    c(
      "Y3a81"
    ),
    "numeric_value"
  ),
  Question(
    "facit_fatigue",
    c(
      "Y3a82"
    ),
    "numeric_value"
  ), 
  Question(
    "facit_weak",
    c(
      "Y3a83" 
    ),
    "numeric_value"
  ), 
  Question(
    "facit_listless",
    c(
      "Y3a84" 
    ),
    "numeric_value"
  ), 
  Question(
    "facit_tired",
    c(
      "Y3a85" 
    ),
    "numeric_value"
  ), 
  Question(
    "facit_trouble_starting",
    c(
      "Y3a86"
    ),
    "numeric_value"
  ),
  Question(
    "facit_trouble_finishing",
    c(
      "Y3a87"
    ),
    "numeric_value"
  ), 
  Question(
    "facit_energy",
    c(
      "Y3a88"
    ),
    "numeric_value"
  ), 
  Question(
    "facit_usual_activities",
    c(
      "Y3a89"
    ),
    "numeric_value"
  ), 
  Question(
    "facit_sleep_during_day",
    c(
      "Y3a8a"
    ),
    "numeric_value"
  ),
  Question(
    "facit_eat",
    c(
      "Y3a8b"
    ),
    "numeric_value"
  ),
  Question(
    "facit_need_help",
    c(
      "Y3a8c"
    ),
    "numeric_value"
  ),
  Question(
    "facit_frustrated",
    c(
      "Y3a8d"
    ),
    "numeric_value"
  ),
  Question(
    "facit_limit_social_activity",
    c(
      "Y3a8e"
    ),
    "numeric_value"
  ),
  Question(
    "mrc_breathlessness",
    c(
      "XaIUi",
      "XaIUl",
      "XaIUm",
      "XaIUn",
      "XaIUo"    
    ),
    "ctv3_code"
  ),
)
