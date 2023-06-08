import argparse

from ehrql import Dataset
from ehrql.tables.beta.tpp import open_prompt
from questions_research import questions_research

parser = argparse.ArgumentParser()
parser.add_argument(
    "--day",
    type=int,
    help="The day a survey was completed, relative to the day the first survey was completed",
)
args = parser.parse_args()
print(f"{args.day=}")

# The number of days from the date of the earliest response to the date of the current
# response. We expect this to be >= 0.
consult_offset = (
    open_prompt.consultation_date - open_prompt.consultation_date.minimum_for_patient()
).days

dataset = Dataset()

dataset.define_population(open_prompt.exists_for_patient())

# A row represents a response to a question in a questionnaire. There are six
# questionnaires, which are administered in four surveys on day 0, 30, 60, and 90. For
# more information, see DATA.md.
for question in questions_research:
    # fetch the row containing the last response to the current question from the survey
    # administered on day 0
    response_row = (
        open_prompt.where(consult_offset == 0)
        .where(open_prompt.ctv3_code.is_in(question.ctv3_codes))
        .sort_by(open_prompt.consultation_id)  # arbitrary but deterministic
        .first_for_patient()
    )
    # the response itself may be a CTV3 code or a numeric value
    response_value = getattr(response_row, question.value_property)
    setattr(dataset, question.id, response_value)
