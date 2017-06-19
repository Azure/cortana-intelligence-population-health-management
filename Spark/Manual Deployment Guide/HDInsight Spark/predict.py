'''
predict.py

To call this script from the command line, provide the storage account
name and key, e.g.

python predict.py <account_name> <account_key>
'''

import sys, os
import numpy as np
import pandas as pd
from pyspark import SparkContext, SQLContext
from pyspark.ml.classification import RandomForestClassificationModel
from pyspark.ml.pipeline import PipelineModel
from pyspark.ml.feature import StringIndexerModel, VectorAssembler
from azure.storage.blob import BlobService
from azure.storage._common_error import AzureMissingResourceHttpError
from datetime import datetime, timedelta
from functools import reduce
from io import StringIO

def get_most_recent_date(blob_service, glucose_levels_container):
    blob_dates = list(set([i.name[:10] for i in blob_service.list_blobs(container_name=glucose_levels_container)]))
    date_df = pd.DataFrame([], columns=['blob_format', 'datetime_format'])
    date_df['blob_format'] = blob_dates
    date_df['datetime_format'] = date_df['blob_format'].apply(lambda x: pd.to_datetime(x))
    return(date_df.loc[date_df['datetime_format'] == date_df['datetime_format'].max(),
                       'blob_format'].values[0])

def get_df_from_blob(blob_service, glucose_levels_container, patient_records_container, day_to_predict):
    glucose_files = [b.name for b in blob_service.list_blobs(container_name=glucose_levels_container) if
                     b.name.startswith(day_to_predict)]
    glucose_vals = [blob_service.get_blob_to_text(container_name=glucose_levels_container,
                                                      blob_name=b) for b in glucose_files]
    dfs = [pd.read_csv(StringIO(i),
                       skiprows=1,
                       names=['patient_nbr',
                                'glucose_min', 'glucose_max', 'glucose_mean', 'glucose_var', 'timestamp']) for i in glucose_vals]
    df_glucose = pd.concat(dfs)
    df_glucose = df_glucose.groupby('patient_nbr', as_index=False).mean()  # agg by patient
    
    patient_record_dfs = []
    for nbr in df_glucose['patient_nbr']:
        try:
            patient_record = blob_service.get_blob_to_text(container_name=patient_records_container,
                                                           blob_name='{}.csv'.format(nbr))
            patient_record_dfs.append(pd.read_csv(StringIO(patient_record)))
        except AzureMissingResourceHttpError:
            continue
    df_patients = pd.concat(patient_record_dfs)
    
    df = pd.merge(df_patients, df_glucose)
    missing_val_indicator_cols = ['diag_1_missing', 'diag_2_missing', 'diag_3_missing', 'race_missing',
                              'weight_missing', 'payer_code_missing', 'medical_specialty_missing']
    for c in missing_val_indicator_cols:
        df[c] = 'n'

    df['discharge_date'] = '-'.join(str(day_to_predict).split('/'))
    return(df)

def main(account_name, account_key):
    sc = SparkContext()
    sqlContext = SQLContext(sc)

    patient_records_container = 'patientrecords'
    glucose_levels_container = 'glucoselevelsaggs'
    preds_container = 'predictions'

    blob_service = BlobService(account_name=account_name, account_key=account_key)
    blob_service.create_container(preds_container)
    
    day_to_predict = get_most_recent_date(blob_service, glucose_levels_container)
    df = get_df_from_blob(blob_service, glucose_levels_container, patient_records_container, day_to_predict)
    
    project_path = 'wasb://model@{}.blob.core.windows.net/{}'
    si_pipe_model = PipelineModel.read().load(path=project_path.format(account_name, 'si_pipe_model'))
    oh_pipe_model = PipelineModel.read().load(path=project_path.format(account_name, 'oh_pipe_model'))
    model = RandomForestClassificationModel.read().load(path=project_path.format(account_name, 'model'))
    
    df_spark = sqlContext.createDataFrame(df)
    df_preds = si_pipe_model.transform(df_spark)
    df_preds = oh_pipe_model.transform(df_preds)
    
    num_var_names = ['time_in_hospital', 'num_lab_procedures', 'num_procedures', 'num_medications', 'number_outpatient',
                     'number_emergency', 'number_inpatient', 'diag_1', 'diag_2', 'diag_3', 'number_diagnoses', 'glucose_min',
                     'glucose_max', 'glucose_mean', 'glucose_var']
    cat_var_names = ['race', 'gender', 'age', 'weight', 'admission_type_id', 'discharge_disposition_id',
                     'admission_source_id', 'payer_code', 'medical_specialty', 'max_glu_serum', 'A1Cresult', 'metformin',
                     'repaglinide', 'nateglinide', 'chlorpropamide', 'glimepiride', 'acetohexamide', 'glipizide', 'glyburide',
                     'tolbutamide', 'pioglitazone', 'rosiglitazone', 'acarbose', 'miglitol', 'troglitazone', 'tolazamide',
                     'insulin', 'glyburide-metformin', 'glipizide-metformin', 'glimepiride-pioglitazone',
                     'metformin-rosiglitazone', 'metformin-pioglitazone', 'change', 'diabetesMed', 'diag_1_missing',
                     'diag_2_missing', 'diag_3_missing', 'race_missing', 'weight_missing', 'payer_code_missing',
                     'medical_specialty_missing']
    va = VectorAssembler(inputCols=(num_var_names + [c + "__encoded__" for c in cat_var_names]), outputCol='features')
    df_preds = va.transform(df_preds).select('features')
    
    df_preds = model.transform(df_preds)
    df_preds_pandas = df_preds.toPandas()
    df_preds_pandas = pd.concat([df[['patient_nbr', 'discharge_date']],
                                 df_preds_pandas['probability'].map(lambda x: x[1])], axis=1)
    
    # Save the predictions
    blob_service.put_block_blob_from_text(blob_name='-'.join(str(day_to_predict).split('/')) + '.csv',
                                          container_name=preds_container,
                                          text=df_preds_pandas.to_csv(index=False))
    return

if __name__ == '__main__':
    main(sys.argv[1], sys.argv[2])