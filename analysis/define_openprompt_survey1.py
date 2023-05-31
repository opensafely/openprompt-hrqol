from ehrql import Dataset
from openprompt_survey_responses import add_survey_responses
from ehrql.tables.beta.tpp import open_prompt
from variable_lib import create_sequential_variables

dataset = Dataset()

create_sequential_variables(
    dataset, 
    "cons_id_{n}", 
    num_variables=5, 
    events=open_prompt.where(open_prompt.ctv3_code == "XaYwo"),
    column="consultation_id"
)

survey1 = open_prompt.where(open_prompt.consultation_id == dataset.cons_id_1)

dataset = Dataset()
add_survey_responses(dataset, survey1)

dataset.define_population(survey1.exists_for_patient())