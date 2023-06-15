import argparse
import sys

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
# Printing to stderr means we can pipe generate-dataset/dump-dataset-sql safely
# (i.e. we don't end up with unwanted strings in our CSV/SQL).
print(f"{args.day=}", file=sys.stderr)

# The date of the earliest response
index_date = open_prompt.where(
    # Only include responses to a compulsory question on the Eq-5D
    # questionnaire. Unlike the baseline questionnaire, this questionnaire was
    # administered in each survey. Surveys that are associated with these
    # responses are valid OpenPROMPT surveys.
    open_prompt.ctv3_code.is_in(["13VC.", "1152.", "XaR8E"])
).consultation_date.minimum_for_patient()
# The number of days from the date of the earliest response to the date of each
# response. We expect this to be >= 0.
offset_from_index_date = (open_prompt.consultation_date - index_date).days

dataset = Dataset()

dataset.define_population(open_prompt.exists_for_patient())

dataset.consult_date = (
    open_prompt.where(offset_from_index_date >= args.day - 5)
    .where(offset_from_index_date <= args.day + 5)
    .sort_by(open_prompt.consultation_date)
    .last_for_patient()
    .consultation_date
    )
dataset.days_since_baseline = (dataset.consult_date - index_date).days

# A row represents a response to a question in a questionnaire. There are six
# questionnaires. For more information, see DATA.md.
for question in questions_research:
    response_row = (
        open_prompt.where(offset_from_index_date >= args.day - 5)
        .where(offset_from_index_date <= args.day + 5)
        .where(open_prompt.ctv3_code.is_in(question.ctv3_codes))
        # If the response is a CTV3 code, then the numeric value should be zero and
        # sorting by the numeric value should have no effect. However, if the response
        # is a numeric value, then zero may represent:
        #
        # 1. a missing value, because the question was not compulsory
        # 2. a missing value, because the response failed form-validation
        # 3. a measured value
        #
        # In each case, we think that sorting by numeric value should give the true
        # response because if there are two responses, then:
        #
        # 1. the responses are identical
        # 2. the first response failed form-validation; the second response passed
        #
        # We acknowledge that the true response for 3. is undetermined.
        .sort_by(open_prompt.numeric_value)
        .last_for_patient()
    )
    # the response itself may be a CTV3 code or a numeric value
    response_value = getattr(response_row, question.value_property)
    setattr(dataset, f"{question.id}", response_value)
