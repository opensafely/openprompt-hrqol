# where EHRQl is defined. Only really need Dastaset, the others are specific
from ehrql import days, case, when, Dataset
# import the schema to run the study with
from ehrql.tables.beta.tpp import (
    patients,
    practice_registrations,
    clinical_events,
    sgss_covid_all_tests,
    hospital_admissions,
    vaccinations,
    open_prompt
)
import datetime

from variable_lib import (
    age_as_of,
    address_as_of,
    create_sequential_variables,
    hospitalisation_diagnosis_matches,
    long_covid_events_during,
    long_covid_dx_during
)
import codelists

dataset = Dataset()
dataset.define_population(open_prompt.exists_for_patient())
study_start_date = datetime.date(2020, 3, 1)
end_date = datetime.date(2023, 7, 20)

minimum_registration = 90  # 3months of previous registration

# practice registration selection
registrations = practice_registrations \
    .except_where(practice_registrations.start_date >= end_date) \
    .except_where(practice_registrations.end_date <= study_start_date)

# get the number of registrations in this period to exclude anyone with >1 in the 'set_population' later
registrations_number = registrations.count_for_patient()

# need to get the start and end date of last registration only
registration = registrations \
    .sort_by(practice_registrations.start_date).last_for_patient()

dataset.pt_start_date = case(
    when(registration.start_date + days(minimum_registration) > study_start_date).then(registration.start_date + days(minimum_registration)),
    default=study_start_date,
)

dataset.pt_end_date = case(
    when(registration.end_date.is_null()).then(end_date),
    when(registration.end_date > end_date).then(end_date),
    default=registration.end_date,
)

# Demographic variables
dataset.sex = patients.sex
dataset.age = age_as_of(study_start_date)
dataset.msoa = address_as_of(study_start_date).msoa_code
dataset.practice_nuts = registration.practice_nuts1_region_name
dataset.imd = address_as_of(study_start_date).imd_rounded

# Ethnicity in 6 categories
dataset.ethnicity = clinical_events.where(clinical_events.ctv3_code.is_in(codelists.ethnicity)) \
    .sort_by(clinical_events.date) \
    .last_for_patient() \
    .ctv3_code.to_category(codelists.ethnicity)

# Long COVID 
long_covid_record = long_covid_events_during(dataset.pt_start_date, dataset.pt_end_date)
first_long_covid_record = long_covid_record.sort_by(long_covid_record.date).first_for_patient()

dataset.first_lc = first_long_covid_record.date
dataset.first_lc_code = first_long_covid_record.snomedct_code
dataset.n_lc_records = long_covid_record.count_for_patient()
dataset.n_distinct_lc_records = long_covid_record.snomedct_code.count_distinct_for_patient()
dataset.has_covid_dx = long_covid_record.where(long_covid_record.snomedct_code.is_in(codelists.long_covid_dx_codes)).count_for_patient()


# covid tests
all_test_positive = sgss_covid_all_tests \
    .where(sgss_covid_all_tests.is_positive) \
    .except_where(sgss_covid_all_tests.specimen_taken_date <= dataset.pt_start_date) \
    .except_where(sgss_covid_all_tests.specimen_taken_date >= dataset.pt_end_date)

dataset.all_test_positive = all_test_positive.count_for_patient()

dataset.all_tests = sgss_covid_all_tests \
    .except_where(sgss_covid_all_tests.specimen_taken_date <= dataset.pt_start_date) \
    .except_where(sgss_covid_all_tests.specimen_taken_date >= dataset.pt_end_date) \
    .count_for_patient()

dataset.latest_test_before_diagnosis = all_test_positive \
    .sort_by(sgss_covid_all_tests.specimen_taken_date).last_for_patient().specimen_taken_date

# covid hospitalisations
covid_hospitalisations = hospitalisation_diagnosis_matches(hospital_admissions, codelists.hosp_covid)
all_covid_hosp = covid_hospitalisations \
    .where(covid_hospitalisations.admission_date >= dataset.pt_start_date) \
    .except_where(covid_hospitalisations.admission_date >= dataset.pt_end_date)

dataset.all_covid_hosp = all_covid_hosp \
    .count_for_patient()

first_covid_hosp = all_covid_hosp \
    .sort_by(all_covid_hosp.admission_date) \
    .first_for_patient()

dataset.first_covid_hosp = first_covid_hosp.admission_date
dataset.first_covid_discharge = first_covid_hosp.discharge_date
dataset.first_covid_critical = first_covid_hosp.days_in_critical_care > 0
dataset.first_covid_hosp_primary_dx = first_covid_hosp.primary_diagnoses.is_in(codelists.hosp_covid)

# Any covid identification
primarycare_covid = clinical_events \
    .where(clinical_events.ctv3_code.is_in(codelists.any_primary_care_code)) 

dataset.latest_primarycare_covid = primarycare_covid \
    .sort_by(primarycare_covid.date) \
    .last_for_patient().date

dataset.total_primarycare_covid = primarycare_covid \
    .count_for_patient()

# vaccine code
create_sequential_variables(
    dataset,
    "covid_vacc_{n}_adm",
    num_variables=5,
    events=clinical_events.where(clinical_events.snomedct_code.is_in(codelists.vac_adm_combine)),
    column="date"
)

# Vaccine schema - one record per day
all_vacc = vaccinations \
    .where(vaccinations.date < dataset.pt_end_date) \
    .where(vaccinations.target_disease == "SARS-2 CORONAVIRUS")

dataset.no_prev_vacc = all_vacc \
    .sort_by(vaccinations.date) \
    .count_for_patient()
dataset.date_last_vacc = all_vacc.sort_by(all_vacc.date).last_for_patient().date
dataset.last_vacc_gap = (dataset.pt_end_date - dataset.date_last_vacc).days

# comorbidities
# define baseline variables on day _before_ study date
baseline_date = dataset.pt_start_date - days(1)

prior_events = clinical_events.where(clinical_events.date.is_on_or_before(baseline_date))

def has_prior_event(codelist, where=True):
    return (
        prior_events.where(where)
        .where(prior_events.ctv3_code.is_in(codelist))
        .sort_by(prior_events.date)
        .last_for_patient().date
    )

def has_prior_event_numeric(codelist, where=True):
    prior_events_exists = prior_events.where(where) \
        .where(prior_events.ctv3_code.is_in(codelist)) \
        .exists_for_patient()
    return (
        case(
            when(prior_events_exists).then(1),
            when(~prior_events_exists).then(0)
        )
    )

dataset.haem_cancer = has_prior_event(codelists.haem_cancer)
dataset.lung_cancer = has_prior_event(codelists.lung_cancer)
dataset.other_cancer = has_prior_event(codelists.other_cancer)
dataset.asthma = has_prior_event(codelists.asthma_codes)
dataset.chronic_cardiac_disease = has_prior_event(codelists.chronic_cardiac_disease_code)
dataset.chronic_liver_disease = has_prior_event(codelists.chronic_liver_disease_code)
dataset.chronic_respiratory_disease = has_prior_event(codelists.copd)
dataset.other_neuro = has_prior_event(codelists.other_neuro_code)
dataset.stroke_gp = has_prior_event(codelists.stroke_code)
dataset.dementia = has_prior_event(codelists.dementia_code)
dataset.ra_sle_psoriasis = has_prior_event(codelists.ra_sle_psoriasis_code)
dataset.psychosis_schizophrenia_bipolar = has_prior_event(codelists.psychosis_schizophrenia_bipolar_codes)
dataset.permanent_immune = has_prior_event(codelists.permanent_immune_code)
dataset.temp_immune = has_prior_event(codelists.temporary_immune_code)

binary_haem_cancer = has_prior_event_numeric(codelists.haem_cancer)
binary_lung_cancer = has_prior_event_numeric(codelists.lung_cancer)
binary_other_cancer = has_prior_event_numeric(codelists.other_cancer)
binary_asthma = has_prior_event_numeric(codelists.asthma_codes)
binary_chronic_cardiac_disease = has_prior_event_numeric(codelists.chronic_cardiac_disease_code)
binary_chronic_liver_disease = has_prior_event_numeric(codelists.chronic_liver_disease_code)
binary_chronic_respiratory_disease = has_prior_event_numeric(codelists.copd)
binary_other_neuro = has_prior_event_numeric(codelists.other_neuro_code)
binary_stroke_gp = has_prior_event_numeric(codelists.stroke_code)
binary_dementia = has_prior_event_numeric(codelists.dementia_code)
binary_ra_sle_psoriasis = has_prior_event_numeric(codelists.ra_sle_psoriasis_code)
binary_psychosis_schizophrenia_bipolar = has_prior_event_numeric(codelists.psychosis_schizophrenia_bipolar_codes)
binary_permanent_immune = has_prior_event_numeric(codelists.permanent_immune_code)
binary_temp_immune = has_prior_event_numeric(codelists.temporary_immune_code)

dataset.comorbid_count = binary_haem_cancer + \
    binary_lung_cancer + \
    binary_other_cancer + \
    binary_asthma + \
    binary_chronic_cardiac_disease + \
    binary_chronic_liver_disease + \
    binary_chronic_respiratory_disease + \
    binary_other_neuro + \
    binary_stroke_gp + \
    binary_dementia + \
    binary_ra_sle_psoriasis + \
    binary_psychosis_schizophrenia_bipolar + \
    binary_permanent_immune + \
    binary_temp_immune

# Exclusion criteria - consistent with protocols
# remove missing age and anyone not male/female
population = (dataset.age <= 100) & (dataset.age >= 18) & (dataset.sex.contains("male")) & (registrations_number == 1)
dataset.define_population(population)

dataset.configure_dummy_dataset(population_size=5000)