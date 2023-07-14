Question <- function(id, q_codes, value_property){
  data.frame(
    id = rep(id, length(q_codes)),
    q_codes, 
    value_property = rep(value_property, length(q_codes))
  )
}

questions_baseline <- bind_rows(
    Question("base_ethnicity",
               c(
                 "976631000000101",
                 "976651000000108",
                 "976671000000104",
                 "976691000000100",
                 "976711000000103",
                 "976731000000106",
                 "976751000000104",
                 "976591000000101",
                 "976791000000107",
                 "976811000000108",
                 "976831000000100",
                 "976851000000107",
                 "976871000000103",
                 "976891000000104",
                 "976911000000101",
                 "976931000000109",
                 "976951000000102",
                 "976971000000106",
                 "1024701000000100",
                 "1024701000000100" # technically this is dm03 but map it to "Other"
               ),
                 value_property = "snomedct_code"
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
      "21134002",
      "160245001",
      "1092951000000100"
    ),
    "snomedct_code"
  ),
  Question(
    "base_relationship", # What is your current relationship status?
    c(
      "125681006",
      "38070000",
      "286051000000109",
      "13184001",
      "286081000000103",
      "286141000000107",
      "286171000000101"
      ),
    "snomedct_code"
  ),
  Question(
    "base_gender", # What is your gender
    c(
      "703117000",
      "703118005",
      "32570691000036100",
      "263495000" #technicially free text ("describe gender in your own terms") but map to "Other"
    ),
    "snomedct_code"
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