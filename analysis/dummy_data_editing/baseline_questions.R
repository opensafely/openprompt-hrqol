Question <- function(id, ctv3_codes, value_property){
  data.frame(
    id = rep(id, length(ctv3_codes)),
    ctv3_codes, 
    value_property = rep(value_property, length(ctv3_codes))
  )
}

questions_baseline <- bind_rows(
    Question("base_ethnicity",
             ctv3_codes =
               c(
                 "XactH",
                 "XactI",
                 "XactJ",
                 "XactK",
                 "XactL",
                 "Xactd",
                 "Xacte",
                 "Xactf",
                 "Xactg",
                 "Xacth",
                 "Xacti",
                 "Xactj",
                 "Xactk",
                 "Xactl",
                 "Xactm",
                 "Xactn",
                 "Xacto",
                 "Xactp",
                 "Y32d7",
                 "XaBEN" # technically this is dm03 but map it to "Other"
                 ),
                 value_property = "ctv3_code"
                 ),
    Question("base_highest_edu", # "What is the highest level of education that you completed?
             c(
               "Y26f2",
               "Y26f1",
               "Y26f0",
               "Y26ef",
               "Y26ee",
               "Y26f4"
               ),
              "ctv3_code"
            ),
  Question(
    "base_disability", # "Do you have a disability?  
    c(
      "13VC.",
      "1152.",
      "XaR8E"
    ),
    "ctv3_code"
  ),
  Question(
    "base_relationship", # What is your current relationship status?
    c(
      "XE0oZ",
      "1336.",
      "XaMz3",
      "XE0ob",
      "XaMz4",
      "XaMz6",
      "XaMz7"
    ),
    "ctv3_code"
  ),
  Question(
    "base_gender", # What is your gender
    c(
      "X768D",
      "X768C",
      "X785Q",
      "Y1bd8",
      "Y1f4b",
      "XC00J" #technicially free text ("describe gender in your own terms") but map to "Other"
    ),
    "ctv3_code"
  ),
  Question(
    "base_hh_income", 
    c(
      "Y24b5",
      "Y24b6",
      "Y24b7",
      "Y24b8",
      "Y24b9",
      "Y24ba",
      "Y24bb",
      "Y24bc",
      "X90UG"
    ),
    "ctv3_code"
  )
)


# "In what year were you born? 
# "What is your ethnicity?
# "What is the highest level of education that you completed?
# "Do you have a disability?  
# "What is your current relationship status?
# What is your gender?
# "What is your yearly household income in UK sterling? 
# "Please enter the first part of your postcode. 
# "Where did you hear about the study? 