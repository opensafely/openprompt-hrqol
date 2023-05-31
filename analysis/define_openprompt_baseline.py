from ehrql import case, when, Dataset
from ehrql.tables.beta.tpp import open_prompt


import codelists

dataset = Dataset()

op_baseline_id = open_prompt \
    .sort_by(open_prompt.consultation_id) \
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

population_restriction = (dataset.age_at_baseline > 0) 
dataset.define_population(population_restriction)
