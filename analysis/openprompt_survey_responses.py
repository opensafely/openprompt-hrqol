from ehrql import case, when, Dataset
import codelists 
import datetime
from ehrql.tables.beta.tpp import open_prompt, patients, practice_registrations

def add_survey_responses(dataset, survey):
    dataset.eq5d_mobility = survey \
        .where(open_prompt.snomedct_code=="821551000000108") \
        .sort_by(open_prompt.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_selfcare = survey \
        .where(open_prompt.snomedct_code=="821561000000106") \
        .sort_by(open_prompt.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_usualactivities = survey \
        .where(open_prompt.snomedct_code=="821581000000102") \
        .sort_by(open_prompt.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_paindiscomfort = survey \
        .where(open_prompt.snomedct_code=="821591000000100") \
        .sort_by(open_prompt.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.eq5d_anxiousdepressed = survey \
        .where(open_prompt.snomedct_code=="821611000000108") \
        .sort_by(open_prompt.consultation_id) \
        .first_for_patient() \
        .numeric_value
    
    dataset.euroqol_vis_score = survey \
        .where(open_prompt.snomedct_code=="736535009") \
        .sort_by(open_prompt.consultation_id) \
        .first_for_patient() \
        .numeric_value    
    