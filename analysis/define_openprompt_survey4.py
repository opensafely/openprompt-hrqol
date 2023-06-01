from ehrql import Dataset
from openprompt_survey_responses import add_survey_responses
from ehrql.tables.beta.tpp import open_prompt
from variable_lib import get_consultation_ids

dataset = Dataset()

get_consultation_ids(dataset)

survey4 = open_prompt.where(open_prompt.consultation_id == dataset.cons_id_4)

dataset = Dataset()
add_survey_responses(dataset, survey4)

dataset.define_population(survey4.exists_for_patient())