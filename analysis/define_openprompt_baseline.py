from ehrql import case, when, Dataset
from ehrql.tables.beta.tpp import open_prompt, practice_registrations, patients

import codelists
from datetime import date

dataset = Dataset()

# import some other interesting vars at baseline from TPP registration and patients
dataset.tpp_reg_2023 = practice_registrations \
    .where(practice_registrations.end_date > date(2023, 1, 1)).exists_for_patient()
dataset.ever_tpp_reg = practice_registrations.exists_for_patient()

dataset.pt_sex = patients.sex
dataset.pt_age = patients.age_on(date(2023, 6, 30))


# filter to the actual baselin questionnaire
op_baseline_id = open_prompt \
    .where(open_prompt.ctv3_code == "13VC.") \
    .sort_by(open_prompt.consultation_id) \
    .first_for_patient().consultation_id

op_baseline = open_prompt.where(open_prompt.consultation_id == op_baseline_id)

dataset.n_baseline_rows = op_baseline.count_for_patient()
dataset.baseline_date = op_baseline \
    .sort_by(op_baseline.consultation_id) \
    .first_for_patient().consultation_date

# Ethnicity in 6 categories
dataset.ethnicity = op_baseline.where(op_baseline.ctv3_code.is_in(codelists.ethnicity)) \
    .sort_by(op_baseline.consultation_id) \
    .first_for_patient() \
    .ctv3_code.to_category(codelists.ethnicity)

# year of birth on survey, then age
yob = open_prompt \
    .where(open_prompt.ctv3_code == "9155.") \
    .sort_by(open_prompt.consultation_id) \
    .first_for_patient().numeric_value
dataset.age_at_baseline = 2023 - yob

# gender on survey response
gender_codes = ["X768D","X768C","X785Q","Y1bd8","Y1f4b"]
gender_mapping = {
    "X768D": "Male",
    "X768C": "Female",
    "X785Q": "Intersex",
    "Y1bd8": "Non-binary",
    "Y1f4b": "Prefer not to say"
}
dataset.gender = op_baseline \
    .where(op_baseline.ctv3_code.is_in(gender_codes)) \
    .sort_by(op_baseline.consultation_id) \
    .first_for_patient() \
    .ctv3_code.map_values(gender_mapping)

# restrict to people with positive age
population_restriction = (dataset.age_at_baseline > 0) 
dataset.define_population(population_restriction)
