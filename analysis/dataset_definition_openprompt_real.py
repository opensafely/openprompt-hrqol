from ehrql import case, when, Dataset

from ehrql.tables.beta.tpp import open_prompt, patients, practice_registrations, vaccinations

import datetime

dataset = Dataset()

dataset.tpp_reg = practice_registrations \
    .where(practice_registrations.start_date> datetime.date(2020, 11, 1)).exists_for_patient()

dataset.first_vacc = vaccinations \
    .where(vaccinations.target_disease.contains("SARS")) \
    .where(open_prompt.exists_for_patient()) \
    .sort_by(vaccinations.date) \
    .first_for_patient().date

dataset.sex = patients.sex

op_baseline = open_prompt \
    .sort_by(open_prompt.consultation_date) \
    .first_for_patient()

dataset.ethnicity = case(
    when(op_baseline.snomedct_code == "976631000000101").then("White"),
    when(op_baseline.snomedct_code == "976651000000108").then("White"),
    when(op_baseline.snomedct_code == "976671000000104").then("White"),
    when(op_baseline.snomedct_code == "976691000000100").then("White"),
    default="Not white"
)   

# yob = op_baseline \
#     .where(op_baseline.ctv3_code == "9155.").numeric_value

# dataset.age_at_baseline = 2023 - yob
dataset.pt_age = patients.age_on(datetime.date(2023, 6, 30))

population_restriction = (dataset.pt_age > 0) & (dataset.pt_age < 110)
dataset.define_population(population_restriction)
