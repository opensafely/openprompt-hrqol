import argparse
import sys

from ehrql import Dataset
from ehrql.tables.beta.tpp import open_prompt
from questions import questions

parser = argparse.ArgumentParser()
parser.add_argument(
    "--day",
    type=int,
    help="The day a survey was completed, relative to the day the first survey was completed",
)
parser.add_argument(
    "--window",
    type=int,
    default=0,
    help="The number of days +/- the day a survey was completed",
)
args = parser.parse_args()
# Printing to stderr means we can pipe generate-dataset/dump-dataset-sql safely
# (i.e. we don't end up with unwanted strings in our CSV/SQL).
print(f"{args.day=}", file=sys.stderr)
print(f"{args.window=}", file=sys.stderr)

# Printing to stderr means we can pipe generate-dataset/dump-dataset-sql safely
# (i.e. we don't end up with unwanted strings in our CSV/SQL).
print(f"{args.day=}", file=sys.stderr)

# The date of the earliest response from teh `creation_date` column
index_date = (
    open_prompt
    .creation_date.minimum_for_patient()
)

# The number of days from the date of the earliest response to the date of each
# response. We expect this to be >= 0.
offset_from_index_date = (open_prompt.creation_date - index_date).days

# Filter opne_prompt table to only include responses recorded within 5 days 
# of the --days argument
filtered_open_prompt = (
    open_prompt.where(offset_from_index_date >= args.day - args.window).where(offset_from_index_date <= args.day + args.window)
)

dataset = Dataset()

dataset.define_population(filtered_open_prompt.exists_for_patient())

dataset.creation_date = (
    filtered_open_prompt
    .sort_by(open_prompt.creation_date)
    .last_for_patient()
    .creation_date
    )
dataset.days_since_baseline = (dataset.creation_date - index_date).days

dataset.configure_dummy_dataset(population_size=5000)

# A row represents a response to a question in a questionnaire. There are six
# questionnaires. For more information, see DATA.md.
for question in questions:
    if (args.day > 0) and question.id.startswith("base_"):
        # don't extract responses to baseline questionnaire after the index date
        continue
    
    response_row = (
        filtered_open_prompt
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
    
    # the response itself may be a CTV3 code, snomedct code, a numeric value or a date
    response_value = getattr(response_row, question.value_property)
    setattr(dataset, f"{question.id}", response_value)

    # the date of this response may be different from the dates of the other responses
    setattr(dataset, f"{question.id}_creation_date", response_row.creation_date)