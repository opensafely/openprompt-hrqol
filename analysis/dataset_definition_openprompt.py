from dataset_definition_lc import add_tpp_data
from datetime import date

from ehrql import case, when, Dataset

from ehrql.tables.beta.tpp import open_prompt, patients, practice_registrations

from variable_lib import (
  create_sequential_variables
)
import codelists


dataset = Dataset()

dataset.current_tpp_reg = practice_registrations \
    .where(practice_registrations.end_date > date(2023, 1, 1)).exists_for_patient()
dataset.ever_tpp_reg = practice_registrations.exists_for_patient()

dataset.pt_sex = patients.sex
dataset.pt_age = patients.age_on(date(2023, 6, 30))

# special stuff for baseline variables -------------------------------------------------
op_baseline_id = open_prompt \
    .sort_by(open_prompt.consultation_date) \
    .first_for_patient().consultation_id

op_baseline = open_prompt.where(open_prompt.consultation_id == op_baseline_id)
dataset.n_baseline_rows = op_baseline.count_for_patient()

# Ethnicity in 6 categories
dataset.ethnicity = op_baseline.where(op_baseline.ctv3_code.is_in(codelists.ethnicity)) \
    .sort_by(op_baseline.consultation_id) \
    .first_for_patient() \
    .ctv3_code.to_category(codelists.ethnicity)

yob = open_prompt \
    .where(open_prompt.ctv3_code == "9155.") \
    .sort_by(open_prompt.consultation_id) \
    .first_for_patient().numeric_value

dataset.age_at_baseline = 2023 - yob


registration = practice_registrations
# this currently only allows for an & not | in the last row
# so we exclude anyone without TPP in OpenPROMPT as it stands
dataset.define_population(
    (patients.age_on(date.today()) >= 18)
    & registration.exists_for_patient()
    & open_prompt.exists_for_patient()
)

add_tpp_data(dataset, population=patients.exists_for_patient())

population_restriction = (dataset.pt_age > 0) & (dataset.pt_age < 110)
dataset.define_population(population_restriction)
