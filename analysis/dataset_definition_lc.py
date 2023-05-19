from databuilder.ehrql import Dataset, days, case, when
from databuilder.tables.beta.tpp import (
  patients,
  practice_registrations,
  clinical_events,
  sgss_covid_all_tests,
  hospital_admissions
)

from variable_lib import (
  age_as_of,
  has_died,
  address_as_of,
  create_sequential_variables,
  hospitalisation_diagnosis_matches
)

import datetime
import codelists

# Registered at a GP 3 months prior to start date
study_start_date = datetime.date(2020, 3, 1)
study_end_date = datetime.date(2023, 5, 1)
minimum_registration = 90


def add_tpp_data(dataset, population):
    # Restrict to people with one practice & for 3month before start date
    registrations = practice_registrations \
        .except_where(practice_registrations.end_date <= study_start_date)

    # Get the number of registrations in this period to exclude anyone with >1 in 'set-population later'
    registrations_number = registrations.count_for_patient()

    # Need to get the start and end date of last registration only
    registration = registrations \
        .sort_by(practice_registrations.start_date).last_for_patient()

    dataset.pt_start_date = case(
        when(registration.start_date + days(minimum_registration) > study_start_date).then(registration.start_date + days(minimum_registration)),
        default=study_start_date,
    )

    dataset.pt_end_date = case(
        when(registration.end_date.is_null()).then(study_end_date),
        when(registration.end_date > study_end_date).then(study_end_date),
        default=registration.end_date,
    )

    dataset.start_date = registration.start_date
    dataset.end_date = registration.end_date

    # get NHS region one by one
    dataset.practice_nuts = registration.practice_nuts1_region_name

    # Common codes
    # Demographic variables
    dataset.sex = patients.sex
    dataset.age = age_as_of(study_start_date)
    dataset.has_died = has_died(study_start_date)
    dataset.msoa = address_as_of(study_start_date).msoa_code
    dataset.imd = address_as_of(study_start_date).imd_rounded
    dataset.death_date = patients.date_of_death

    # Ethnicity in 6 categories
    dataset.ethnicity = clinical_events.where(clinical_events.ctv3_code.is_in(codelists.ethnicity)) \
        .sort_by(clinical_events.date) \
        .last_for_patient() \
        .ctv3_code.to_category(codelists.ethnicity)

    # Covid tests
    all_test_positive = sgss_covid_all_tests \
        .where(sgss_covid_all_tests.is_positive) \
        .except_where(sgss_covid_all_tests.specimen_taken_date <= dataset.pt_start_date) \
        .except_where(sgss_covid_all_tests.specimen_taken_date >= dataset.pt_end_date)

    dataset.all_test_positive = all_test_positive.count_for_patient()

    dataset.all_tests = sgss_covid_all_tests \
        .except_where(sgss_covid_all_tests.specimen_taken_date <= dataset.pt_start_date) \
        .except_where(sgss_covid_all_tests.specimen_taken_date >= dataset.pt_end_date) \
        .count_for_patient()

    # Find any records of long COVID
    long_covid = clinical_events \
        .where(clinical_events.snomedct_code.is_in(codelists.long_covid_combined))

    # Split them by Dx and Rx
    dataset.long_covid_first_dx = long_covid \
        .where(long_covid.snomedct_code.is_in(codelists.long_covid_dx_codes)) \
        .sort_by(long_covid.date) \
        .first_for_patient().date

    dataset.long_covid_first_rx = long_covid \
        .where(long_covid.snomedct_code.is_in(codelists.long_covid_referral_codes)) \
        .sort_by(long_covid.date) \
        .first_for_patient().date

    dataset.long_covid_n_rx = long_covid \
        .where(long_covid.snomedct_code.is_in(codelists.long_covid_referral_codes)) \
        .where(long_covid.date > datetime.date(2020, 12, 31)) \
        .where(long_covid.date >= dataset.long_covid_first_dx) \
        .count_for_patient()

    # Apply some restrictions
    # and output a dataset
    population_restriction = (dataset.age > 0) & (dataset.age < 110) & (registrations_number == 1)
    dataset.define_population(population_restriction)
