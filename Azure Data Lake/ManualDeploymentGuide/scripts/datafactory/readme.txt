In folder 'scripts_blob', there are four usql scripts. These need to be uploaded to your storage account in container 'scripts'
The AzCopy copy command provided in azCopy_command_scripts_toblob.txt will transfer these files to your storage container.

Folder 'forphmdeploymentbyadf' contains the files that will eventually need to be in Data Lake Store. These will be two R scripts,  four csv files and eleven pretrained models. All these will be used by Data Factory pipeline. 
All these seventeen files reside in a public Azure storage container. The two R scripts have also been uploaded to git here in folder forphmdeploymentbyadf. Using the AzCopy command provided (azCopy_command_forphmdeploymentbyadf_toblob.txt) they can be transferred directly to your storage account. Once they are in your storage account, we will use one time ADF copy activity to transfer to Data Lake Store.

After executing the command in azCopy_command_forphmdeploymentbyadf_toblob.txt you should see the following seventeen files in "forphmdeploymentbyadf" container in your storage account. After the adl copy activity you should see these files in "forphmdeploymentbyadf" folder in your Data Lake Store.
 
allotherhosp_LOSmodel.rds          881M
data4visualization_hist.csv        546M
hcadfstreamforpbi.R                23K
hcadfstreamscore.R                 6.7K
hosp_1_LOSmodel.rds                144M
hosp_10_LOSmodel.rds               69M
hosp_2_LOSmodel.rds                92M
hosp_3_LOSmodel.rds                60M
hosp_4_LOSmodel.rds                85M
hosp_5_LOSmodel.rds                82M
hosp_6_LOSmodel.rds                65M
hosp_7_LOSmodel.rds                51M
hosp_8_LOSmodel.rds                81M
hosp_9_LOSmodel.rds                99M
ReadmittanceTarget.csv             1.5K
Single_LevelCCS_Diagnoses_csv.csv  11K
Single_LevelCCS_Procedures_csv.csv 11K




