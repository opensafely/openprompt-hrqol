from ehrql import Dataset
from openprompt_survey_responses import add_survey_responses
from ehrql.tables.beta.tpp import open_prompt
from variable_lib import get_consultation_ids

dataset = Dataset()

get_consultation_ids(dataset)

survey1 = open_prompt.where(open_prompt.consultation_id == dataset.cons_id_1)

dataset = Dataset()
add_survey_responses(dataset, survey1)

dataset.define_population(survey1.exists_for_patient())