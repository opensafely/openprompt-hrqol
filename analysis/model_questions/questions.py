"""
Relates information in the codebook to information in the table.

We could generate this data structure from the information in the codebook; it's just
convenient to hard-code it into a module when explaining our approach.
"""
from collections import namedtuple

Question = namedtuple("Question", ["id", "q_code", "search_col", "value_property"])

questions = [
    # Base questionnaire starts here
    Question(
        "base_ethnicity", # What is your ethnicity?
        [
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
            "1024701000000100", # technically this is dm03 but map it to "Other"
        ],
        "snomedct_code", ## search this column in `open_prompt`
        "snomedct_code", ## if match any of the `q_code` options, then return the value in this column
    ),
    Question( 
        "base_highest_edu", # "What is the highest level of education that you completed?
        [
            "Y26f2",
            "Y26f1",
            "Y26f0",
            "Y26ef",
            "Y26ee",
            "Y26f4",
        ],
        "ctv3_code",
        "ctv3_code",
    ),
    Question( 
        "base_disability", # "Do you have a disability?  
        [
            "21134002",
            "160245001",
            "1092951000000100",
        ],
        "snomedct_code",
        "snomedct_code",
    ),
    Question(
        "base_relationship", # What is your current relationship status?
        [
            "125681006",
            "38070000",
            "286051000000109",
            "13184001",
            "286081000000103",
            "286141000000107",
            "286171000000101",
        ],
        "snomedct_code",
        "snomedct_code",
    ),
    Question(
        "base_gender", # What is your gender
        [
            "703117000",
            "703118005",
            "32570691000036100",
            "263495000", #technicially free text ("describe gender in your own terms") but map to "Other"
        ],
        "snomedct_code",
        "snomedct_code",
    ),
    # there are two possible responses to the gender question that have Y ctv3_code responses, so we need the `ctv3_code` as the `value_property`
    Question( 
        "base_gender_ctv3",
        [
            "Y1bd8",
            "Y1f4b",
        ],
        "ctv3_code",
        "ctv3_code",
    ),
    Question(
        "base_hh_income", 
        [
            "Y24b5",
            "Y24b6",
            "Y24b7",
            "Y24b8",
            "Y24b9",
            "Y24ba",
            "Y24bb",
            "Y24bc",
        ],
        "ctv3_code",
        "ctv3_code",
    ),
    Question( # the "unknown" option is a snomedct_code 
        "base_hh_income_snomed", 
        [
            "261665006",
        ],
        "snomedct_code",
        "snomedct_code",
    ),
    # Research questionnaire starts here
    Question(
        "long_covid", # "Do you think that you currently have or have ever had COVID-19?
        [
            "Y26b2",
            "Y31ce",
            "Y25a5",
            "Y3a94",
            "Y3a95",
            "Y3a96",
        ],
        "ctv3_code",  
        "ctv3_code",  
    ),
    Question(
        "first_covid", # "When do you think you first got (or might have got) COVID-19? If you do not remember exactly, please put your best estimate.
        [
            "Y3a97",
        ],
        "ctv3_code",
        "consultation_date",
    ),
    Question( 
        "n_covids", # "How many times do you think you have had an episode of COVID-19?
        [
            "Y3a98",
        ],
        "ctv3_code", 
        "numeric_value", 
    ),
    Question(
        "recovered_from_covid",
        [
            "Y3a99",
            "Y3a9a",
        ],
        "ctv3_code",
        "ctv3_code",
    ),
    Question(
        "covid_duration",
        [
            "Y3a7f"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "vaccinated",
        [
            "Y3a9b",
            "Y3a9c",
            "Y3a9d",
        ],
        "ctv3_code",
        "ctv3_code",
    ),
    Question(
        "n_vaccines",
        [
            "Y3a9e"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "first_vaccine_date",
        [
            "Y3a9f",
        ],
        "ctv3_code", 
        "consultation_date", 
    ),
    Question(
        "most_recent_vaccine_date",
        [
            "Y3aa0",
        ],
        "ctv3_code", 
        "consultation_date", 
    ),
    Question( 
        "eq5d_mobility", # "How many times do you think you have had an episode of COVID-19?
        [
            "821551000000108",
        ],
        "snomedct_code",
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_selfcare", # "How many times do you think you have had an episode of COVID-19?
        [
            "821561000000106",
        ],
        "snomedct_code",
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_usualactivities", # "How many times do you think you have had an episode of COVID-19?
        [
            "821581000000102",
        ],
        "snomedct_code",
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_pain_discomfort", # "How many times do you think you have had an episode of COVID-19?
        [
            "821591000000100",
        ],
        "snomedct_code",
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_anxiety_depression", # "How many times do you think you have had an episode of COVID-19?
        [
            "821611000000108",
        ],
        "snomedct_code",
        "numeric_value", # should be 0-5
    ),
    Question(
        "EuroQol_score",
        [
            "736535009",
        ],
        "snomedct_code",
        "numeric_value",
    ),
    # Question( # FIXME: currently will not work because no Y ctv3_code and no snomedct_code 
    #     "employment_status", 
    #     [
    #         "Ua0TB",
    #         "13J7.",
    #     ],
    #     "ctv3_code",
    # ),
    # Question( FIXME: Ua0pu used for three questions, can't disambiguate 
    #     "hours_worked",
    #     [
    #         "Ua0pu",
    #     ],
    #     "numeric_value",
    # ),
    Question(
        "work_affected",
        [
            "Y3a80",
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "life_affected",
        [
            "Y3a81",
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "facit_fatigue",
        [
            "Y3a82",
        ],
        "ctv3_code",
        "numeric_value",
    ), 
    Question(
        "facit_weak",
        [
            "Y3a83" 
        ],
        "ctv3_code",
        "numeric_value",
    ), 
    Question(
        "facit_listless",
        [
            "Y3a84" 
        ],
        "ctv3_code",
        "numeric_value", 
    ), 
    Question(
        "facit_tired",
        [
            "Y3a85" 
        ],
        "ctv3_code",
        "numeric_value",
    ), 
    Question(
        "facit_trouble_starting",
        [
            "Y3a86"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "facit_trouble_finishing",
        [
            "Y3a87"
        ],
        "ctv3_code",
        "numeric_value",
    ), 
    Question(
        "facit_energy",
        [
            "Y3a88"
        ],
        "ctv3_code",
        "numeric_value",
    ), 
    Question(
        "facit_usual_activities",
        [
            "Y3a89"
        ],
        "ctv3_code",
        "numeric_value",
    ), 
    Question(
        "facit_sleep_during_day",
        [
            "Y3a8a"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "facit_eat",
        [
            "Y3a8b"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "facit_need_help",
        [
            "Y3a8c"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "facit_frustrated",
        [
            "Y3a8d"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "facit_limit_social_activity",
        [
            "Y3a8e"
        ],
        "ctv3_code",
        "numeric_value",
    ),
    Question(
        "mrc_breathlessness",
        [
            "XaIUi",
            "XaIUl",
            "XaIUm",
            "XaIUn",
            "XaIUo",            
        ],
        "ctv3_code",
        "ctv3_code",
    ),
]


# "In what year were you born? 
# "What is your ethnicity?
# "What is the highest level of education that you completed?
# "Do you have a disability?  
# "What is your current relationship status?
# What is your gender?
# "What is your yearly household income in UK sterling? 
# "Please enter the first part of your postcode. 
# "Where did you hear about the study? 

# "Y3a9f", "Y3aa0", "Y3a97": date questions 
# Y3a9f: When did you have your first COVID-19 vaccination?
# Y3aa0: When did you have your most recent COVID-19 vaccination?
# Y3a97: I belive I first had COVID-19 on this date