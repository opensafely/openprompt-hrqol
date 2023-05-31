from ehrql import case, when, Dataset
import codelists 
import datetime
#from ehrql.tables.beta.tpp import open_prompt, patients, practice_registrations

long_covid = {
    0: "Less than 2 weeks",
    1: "2-3 weeks",
    2: "4-12 weeks",
    3: "More than 12 weeks"
}

recovered_codes = ["Y3a99","Y3a9a"]
recovered_or_not = {
    "Y3a99": "Fully recovered",
    "Y3a9a": "Not recovered"
}

eq5d_scores = {
    1: "No problems",
    2: "Slight problems", 
    3: "Moderate problems",
    4: "Severe problems",
    5: "Unable"     
}

previous_covid_codes = ["Y26b2","Y31ce","Y25a5","Y3a94","Y3a95","Y3a96"]
covid_codes_mapping = {
    "Y26b2": "Yes, confirmed by a positive test",
    "Y31ce": "Yes, based on medical advice",
    "Y25a5": "Yes, based on strong personal suspicion",
    "Y3a94": "Unsure",
    "Y3a95": "No",
    "Y3a96": "Prefer not to say"
}

vaccine_codes = ["Y3a9b","Y3a9c","Y3a9d"]
vaccine_mapping = {
    "Y3a9b": "Yes",
    "Y3a9c": "No",
    "Y3a9d": "Prefer not to say"
}

def add_survey_responses(dataset, survey):
    dataset.survey_date = survey \
        .sort_by(survey.consultation_id) \
        .first_for_patient().consultation_date

    dataset.eq5d_mobility = survey \
        .where(survey.snomedct_code=="821551000000108") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_selfcare = survey \
        .where(survey.snomedct_code=="821561000000106") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_usualactivities = survey \
        .where(survey.snomedct_code=="821581000000102") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_paindiscomfort = survey \
        .where(survey.snomedct_code=="821591000000100") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_anxiousdepressed = survey \
        .where(survey.snomedct_code=="821611000000108") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.euroqol_vis_score = survey \
        .where(survey.snomedct_code=="736535009") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.longest_covid = survey \
        .where(survey.ctv3_code=="Y3a7f") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value

    dataset.recovered = survey \
        .where(survey.ctv3_code.is_in(recovered_codes)) \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .ctv3_code.map_values(recovered_or_not)

    dataset.previous_covid = survey \
        .where(survey.ctv3_code.is_in(previous_covid_codes)) \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .ctv3_code.map_values(covid_codes_mapping)
    
    dataset.n_covids = survey \
        .where(survey.ctv3_code == "Y3a98") \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .numeric_value

    dataset.vaccinated = survey \
        .where(survey.ctv3_code.is_in(vaccine_codes)) \
        .sort_by(survey.consultation_id) \
        .first_for_patient() \
        .ctv3_code.map_values(vaccine_mapping)
