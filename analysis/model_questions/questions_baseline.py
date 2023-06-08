"""
Relates information in the codebook to information in the table.

We could generate this data structure from the information in the codebook; it's just
convenient to hard-code it into a module when explaining our approach.
"""
from collections import namedtuple

Question = namedtuple("Question", ["id", "ctv3_codes", "value_property"])

questions_baseline = [
    Question(
        "ethnicity", # What is your ethnicity?
        [
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
            "XaBEN", # technically this is dm03 but map it to "Other"
        ],
        "ctv3_code",
    ),
    Question( 
        "highest_edu", # "What is the highest level of education that you completed?
        [
            "Y26f2",
            "Y26f1",
            "Y26f0",
            "Y26ef",
            "Y26ee",
            "Y26f4",
        ],
        "ctv3_code",
    ),
    Question( 
        "disability", # "Do you have a disability?  
        [
            "13VC.",
            "1152.",
            "XaR8E",
        ],
        "ctv3_code",
    ),
    Question(
        "relationship", # What is your current relationship status?
        [
            "XE0oZ",
            "1336.",
            "XaMz3",
            "XE0ob",
            "XaMz4",
            "XaMz6",
            "XaMz7",
        ],
        "ctv3_code",
    ),
    Question(
        "gender", # What is your gender
        [
            "X768D",
            "X768C",
            "X785Q",
            "Y1bd8",
            "Y1f4b",
            "XC00J", #technicially free text ("describe gender in your own terms") but map to "Other"
        ],
        "ctv3_code"
    ),
    Question(
        "hh_income", 
        [
            "Y24b5",
            "Y24b6",
            "Y24b7",
            "Y24b8",
            "Y24b9",
            "Y24ba",
            "Y24bb",
            "Y24bc",
            "X90UG",
        ],
        "ctv3_code"
    )
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