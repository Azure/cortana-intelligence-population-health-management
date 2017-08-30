# Outline

- [Read HCUP data](#hcup)
- [Problem Statement](#prob)
- [Create length of stay model using lm()](#lm) 
- [Create length of stay model using xgboost()](#xg) 
- [Azure Data Lake Analytics and R Integration](#usqlr)
- [Get Started with using ADLA with R](#adlawithr)  


<a name="hcup"></a>
## Read HCUP Data


![](../../ManualDeploymentGuide/media/hcuplogo3.PNG?raw=true)

![](../../ManualDeploymentGuide/media/hcuplogo2.PNG?raw=true)

 
The Healthcare Cost and Utilization Project ([HCUP](https://www.hcup-us.ahrq.gov/)) is a group of healthcare databases that contain the largest collection of longitudinal hospital care data in the United States. The data can be purchased from [here](https://www.hcup-us.ahrq.gov/tech_assist/centdist.jsp). It is a national information resource for encounter-level health care data that captures information extracted from administrative data (patients' billing records) after a patient is discharged from the hospital. HCUP's State Inpatient Databases (SID) contain inpatient care records from community hospitals in each state. With forty-eight states participating, SID now encompass about 97 percent of all U.S. community hospital discharges. The SID files contain a core set of clinical and demographic information on all patients, providing a unique view of inpatient care over time. In this notebook we will show you how to read HCUP State Inpatient Data ([SID](https://www.hcup-us.ahrq.gov/sidoverview.jsp)) data for analysis and modelling.  

The HCUP SID dataset consists of four files in ASCII format:
- Core data, including diagnoses, procedures, and patient demographics [[sample](../../ManualDeploymentGuide/Model/SampleHCUPdata/Sample_WA_SID_2011_CORE.asc) | [full description](https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_CORE.loc)]
- Charges associated with each inpatient visit [[sample](../../ManualDeploymentGuide/Model/SampleHCUPdata/Sample_WA_SID_2011_CHGS.asc) | [full description](https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_CHGS.loc)]
- Severity of pre-existing conditions that may affect outcomes [[sample](../../ManualDeploymentGuide/Model/SampleHCUPdata/Sample_WA_SID_2011_SEVERITY.asc) | [full description](https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_SEVERITY.loc)]  
- Diagnostic and procedure groups [[sample](../../ManualDeploymentGuide/Model/SampleHCUPdata/Sample_WA_SID_2011_DX_PR_GRPS.asc) | [full description](https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_DX_PR_GRPS.loc)] 

We will use these description files to help convert the sample ASCII data files to CSV files with headers, which we can then be used for subsequent analysis. 

See notebook [here](../../ManualDeploymentGuide/Model/ReadHCUPdata.ipynb)

<a name="lm"></a>
## Problem Statement

### Why predict the length of a hospital stay?
Recent legislative changes have standardized payments for procedures performed, regardless of the number of days a patient actually spends in the hospital. Hospitals are therefore strongly incentivized to use resources more efficiently and find ways to accommodate more patients with the same volume of resources. An accurate prediction of each patient's length of stay can help hospitals:  
- Manage bed occupancy  
- Effectively schedule elective admissions  
- Improve patient satisfaction during their hospital stay     

Extended lengths of stay costs hospitals millions of dollars a year. By identifying patients at risk for an extended stay, the hospital can take proactive measures to formulate a treatment plan to reduce the expected length of stay.

### When should the prediction be used?
Hospitals want to predict the length of each patient's stay at the time of admission and provide this information to the admitting nurse or staff for resource allocation purposes. The models are created using only features that are available for each patient at the time of their admission.

### Data for modeling
Our model is trained using encounter-level records for a million or so patients. The schema for data matches the State Inpatient Databases (SID) data from HCUP to facilitate the solution's use with real HCUP data. It is suitable for use on similar patient populations, though we recommend that hospitals retrain the model using their own historical patient data for best results. The solution simulates 610 clinical and demographic features, including age, gender, zipcode, diagnoses, procedures, charges, etc. for about a million patients across 23 hospitals. To be applied to newly-admitted patients, the model must be trained using only features that are available for each patient at the time of their admission.

<a name="lm"></a>
## Length of stay model using lm
See notebook [here](../../ManualDeploymentGuide/Model/Length%20Of%20Stay%20Models%20-%20lm.ipynb).

<a name="xg"></a>
## Length of stay model using xgboost
See notebook [here](../../ManualDeploymentGuide/Model/Length%20Of%20Stay%20Models%20-%20xgboost.ipynb).

<a name="usqlr"></a>
## Azure Data Lake Analytics and R Integration
R Extensions for U-SQL enable developers to perform massively parallel execution of R code for end to end data science scenarios covering: merging various data files, feature engineering (FE), partitioned data model building, and post deployment, massively parallel FE and scoring. In order to deploy R code in we need to install the usqlext in our azure data lake analytics account and within the usql script use the REFERENCE ASSEMBLY statement to enable R extensions for the U-SQL Script. Currently we do not have the capability to train the models in Data Lake. In this solution we upload the trained models ([notebooks](../../ManualDeploymentGuide/Model/Length%20Of%20Stay%20Models%20-%20lm.ipynb) to create the models above) to our Data Lake Store and declare it as a resource in the U-SQL [script](../../ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamscore.usql). More sample codes for using R can also be found in the following folder in your Data Lake Store:<your_account_address>/usqlext/samples/R.

<a name="adlawithr"></a>
## [Get Started with using ADLA with R](https://github.com/Azure/ADLAwithR-GettingStarted)  
To get started with using Azure data lake Analytics with R, you can follow the tutorial [here](https://github.com/Azure/ADLAwithR-GettingStarted).  

