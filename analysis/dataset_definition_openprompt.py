from databuilder.ehrql import Dataset, days, case, when
from databuilder.query_language import table_from_file, PatientFrame, Series 
from databuilder.tables.beta.tpp import (
#  OpenPROMPT,
  patients,
  practice_registrations
)
from dataset_definition_lc import add_tpp_data
from datetime import date


@table_from_file("output/dummy_openprompt.csv")
class OpenPROMPT(PatientFrame):
    sex = Series(str)
    age = Series(int)
    number_surveys = Series(int)
    long_covid_date = Series(date)
    breathlessness = Series(int)
    fatigue = Series(int)
    productivity = Series(int)


dataset = Dataset()
registration = practice_registrations
# this currently only allows for an & not | in the last row
# so we exclude anyone without TPP in OpenPROMPT as it stands
dataset.define_population(
    (patients.age_on(date.today()) >= 18)
    & registration.exists_for_patient()
    & OpenPROMPT.exists_for_patient()
)

add_tpp_data(dataset, population=patients.exists_for_patient())

dataset.op_sex = OpenPROMPT.sex
dataset.op_age = OpenPROMPT.age
dataset.op_number_surveys = OpenPROMPT.number_surveys
dataset.op_long_covid_date = OpenPROMPT.long_covid_date
dataset.op_breathlessness = OpenPROMPT.breathlessness
dataset.op_fatigue = OpenPROMPT.fatigue
dataset.op_productivity = OpenPROMPT.productivity