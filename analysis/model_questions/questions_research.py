"""
Relates information in the codebook to information in the table.

We could generate this data structure from the information in the codebook; it's just
convenient to hard-code it into a module when explaining our approach.
"""
from collections import namedtuple

Question = namedtuple("Question", ["id", "ctv3_codes", "value_property"])

questions_research = [
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
    ),
    Question(
        "first_covid", # "When do you think you first got (or might have got) COVID-19? If you do not remember exactly, please put your best estimate.
        [
            "Y3a97",
        ],
        "numeric_value", # FIXME: should be date
    ),
    Question( 
        "n_covids", # "How many times do you think you have had an episode of COVID-19?
        [
            "Y3a98",
        ],
        "numeric_value", 
    ),
    Question(
        "recovered_from_covid",
        [
            "Y3a99",
            "Y3a9a",
        ],
        "ctv3_code",
    ),
    Question(
        "covid_duration",
        [
            "Y3a7f"
        ],
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
    ),
    Question(
        "n_vaccines",
        [
            "Y3a9e"
        ],
        "numeric_value",
    ),
    Question(
        "first_vaccine_date",
        [
            "Y3a9f",
        ],
        "numeric_value", # FIXME: should be date
    ),
    Question(
        "most_recent_vaccine_date",
        [
            "Y3aa0",
        ],
        "numeric_value", # FIXME: should be date
    ),
    Question( 
        "eq5d_mobility", # "How many times do you think you have had an episode of COVID-19?
        [
            "XaYwl",
        ],
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_selfcare", # "How many times do you think you have had an episode of COVID-19?
        [
            "XaYwm",
        ],
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_usualactivities", # "How many times do you think you have had an episode of COVID-19?
        [
            "XaYwo",
        ],
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_pain_discomfort", # "How many times do you think you have had an episode of COVID-19?
        [
            "XaYwp",
        ],
        "numeric_value", # should be 0-5
    ),
    Question( 
        "eq5d_anxiety_depression", # "How many times do you think you have had an episode of COVID-19?
        [
            "XaYwr",
        ],
        "numeric_value", # should be 0-5
    ),
    Question(
        "EuroQol_score",
        [
            "XaZ2m",
        ],
        "numeric_value",
    ),
    Question(
        "employment_status",
        [
            "Ua0TB",
            "13J7.",
        ],
        "ctv3_code",
    ),
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
        "numeric_value",
    ),
    Question(
        "life_affected",
        [
            "Y3a81",
        ],
        "numeric_value",
    ),
    Question(
        "facit_fatigue",
        [
            "Y3a82",
        ],
        "numeric_value",
    ), 
    Question(
        "facit_weak",
        [
            "Y3a83" 
        ],
        "numeric_value",
    ), 
    Question(
        "facit_listless",
        [
            "Y3a84" 
        ],
        "numeric_value",
    ), 
    Question(
        "facit_tired",
        [
            "Y3a85" 
        ],
        "numeric_value",
    ), 
    Question(
        "facit_trouble_starting",
        [
            "Y3a86"
        ],
        "numeric_value",
    ),
    Question(
        "facit_trouble_finishing",
        [
            "Y3a87"
        ],
        "numeric_value",
    ), 
    Question(
        "facit_energy",
        [
            "Y3a88"
        ],
        "numeric_value",
    ), 
    Question(
        "facit_usual_activities",
        [
            "Y3a89"
        ],
        "numeric_value",
    ), 
    Question(
        "facit_sleep_during_day",
        [
            "Y3a8a"
        ],
        "numeric_value",
    ),
    Question(
        "facit_eat",
        [
            "Y3a8b"
        ],
        "numeric_value",
    ),
    Question(
        "facit_need_help",
        [
            "Y3a8c"
        ],
        "numeric_value",
    ),
    Question(
        "facit_frustrated",
        [
            "Y3a8d"
        ],
        "numeric_value",
    ),
    Question(
        "facit_limit_social_activity",
        [
            "Y3a8e"
        ],
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
    ),
]