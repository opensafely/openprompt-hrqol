from databuilder.ehrql import codelist_from_csv

# 1. long COVID from multiple codelists
long_covid_assessment_codes = codelist_from_csv(
    "codelists/opensafely-assessment-instruments-and-outcome-measures-for-long-covid.csv",
    column = "code"
)

long_covid_dx_codes = codelist_from_csv(
    "codelists/opensafely-nice-managing-the-long-term-effects-of-covid-19.csv",
    column = "code"
)

long_covid_referral_codes = codelist_from_csv(
    "codelists/opensafely-referral-and-signposting-for-long-covid.csv",
    column = "code"
)

# Combine codelists 
long_covid_combined = (
    long_covid_dx_codes
    + long_covid_referral_codes
    + long_covid_assessment_codes
)

# Ethnicity
ethnicity = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    column="Code",
    category_column="Grouping_6",
)

# Administered vaccines codes
vac_adm_1 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm1.csv",
    column="code"
)
vac_adm_2 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm2.csv",
    column="code"
)
vac_adm_3 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm3_cod.csv",
    column="code"
)
vac_adm_4 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm4_cod.csv",
    column="code"
)
vac_adm_5 = codelist_from_csv(
    "codelists/primis-covid19-vacc-uptake-covadm5_cod.csv",
    column="code"
)
vac_adm_combine = (
    vac_adm_1 +
    vac_adm_2 +
    vac_adm_3 +
    vac_adm_4 +
    vac_adm_5
)

# Mental health codelists
psychosis_schizophrenia_bipolar_codes = codelist_from_csv(
    "codelists/opensafely-psychosis-schizophrenia-bipolar-affective-disease.csv",
    column="CTV3Code",
)
depression_codes = codelist_from_csv(
    "codelists/opensafely-depression.csv",
    column="CTV3Code"
)
mental_health_all = (
    psychosis_schizophrenia_bipolar_codes
    + depression_codes
)

# COVID identification
hosp_covid = codelist_from_csv(
    "codelists/opensafely-covid-identification.csv",
    column="icd10_code",
)
covid_primary_care_positive_test = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-positive-test.csv",
    column="CTV3ID",
)
covid_primary_care_code = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-clinical-code.csv",
    column="CTV3ID",
)
covid_primary_care_sequalae = codelist_from_csv(
    "codelists/opensafely-covid-identification-in-primary-care-probable-covid-sequelae.csv",
    column="CTV3ID",
)
any_primary_care_code = (
    covid_primary_care_code +
    covid_primary_care_positive_test +
    covid_primary_care_sequalae
)

# Comorbidities
# Cancer codelists
lung_cancer = codelist_from_csv(
    "codelists/opensafely-lung-cancer.csv",
    column="CTV3ID"
)
haem_cancer = codelist_from_csv(
    "codelists/opensafely-haematological-cancer.csv",
    column="CTV3ID"
)
other_cancer = codelist_from_csv(
    "codelists/opensafely-cancer-excluding-lung-and-haematological.csv",
    column="CTV3ID"
)
cancer_combined = (
    lung_cancer
    + other_cancer
    + haem_cancer
)

# Respiratory codes
asthma_codes = codelist_from_csv(
    "codelists/opensafely-asthma-diagnosis.csv",
    column="CTV3ID",
)
copd = codelist_from_csv(
    "codelists/opensafely-chronic-respiratory-disease.csv",
    column="CTV3ID",
)

# Other codes
organ_transplant_code = codelist_from_csv(
    "codelists/opensafely-solid-organ-transplantation.csv",
    column="CTV3ID",
)
chronic_cardiac_disease_code = codelist_from_csv(
    "codelists/opensafely-chronic-cardiac-disease.csv",
    column="CTV3ID",
)
chronic_liver_disease_code = codelist_from_csv(
    "codelists/opensafely-chronic-liver-disease.csv",
    column="CTV3ID",
)
stroke_code = codelist_from_csv(
    "codelists/opensafely-stroke-updated.csv",
    column="CTV3ID",
)
dementia_code = codelist_from_csv(
    "codelists/opensafely-dementia.csv",
    column="CTV3ID",
)
other_neuro_code = codelist_from_csv(
    "codelists/opensafely-other-neurological-conditions.csv",
    column="CTV3ID",
)
ra_sle_psoriasis_code = codelist_from_csv(
    "codelists/opensafely-ra-sle-psoriasis.csv",
    column="CTV3ID",
)
asplenia_code = codelist_from_csv(
    "codelists/opensafely-asplenia.csv",
    column="CTV3ID",
)
hiv_code = codelist_from_csv(
    "codelists/opensafely-hiv.csv",
    column="CTV3ID",
)
aplastic_anemia_code = codelist_from_csv(
    "codelists/opensafely-aplastic-anaemia.csv",
    column="CTV3ID",
)
permanent_immune_code = codelist_from_csv(
    "codelists/opensafely-permanent-immunosuppression.csv",
    column="CTV3ID",
)
temporary_immune_code = codelist_from_csv(
    "codelists/opensafely-temporary-immunosuppression.csv",
    column="CTV3ID",
)
comorbidities_codelist = (
    haem_cancer +
    lung_cancer +
    other_cancer +
    asthma_codes +
    chronic_cardiac_disease_code +
    chronic_liver_disease_code +
    copd +
    other_neuro_code +
    stroke_code +
    dementia_code +
    ra_sle_psoriasis_code +
    psychosis_schizophrenia_bipolar_codes +
    permanent_immune_code +
    temporary_immune_code
)