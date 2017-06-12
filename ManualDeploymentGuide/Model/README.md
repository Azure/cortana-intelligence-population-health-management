# Outline

- [Read HCUP data](#hcup)
- [Create length of stay model using lm()](#lm) 
- [Create length of stay model using xgboost()](#xg) 


<a name="hcup"></a>
## Read HCUP Data


![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/hcuplogo3.PNG?raw=true)

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/hcuplogo2.PNG?raw=true)

The Healthcare Cost and Utilization Project ([HCUP](https://www.hcup-us.ahrq.gov/)) includes the largest collection of longitudinal hospital care data in the United States. The data can be purchased from [here](https://www.hcup-us.ahrq.gov/tech_assist/centdist.jsp).  
In this notebook we will show you how to read HCUP State Inpatient Data ([SID](https://www.hcup-us.ahrq.gov/sidoverview.jsp)) data for analysis and modelling.  
The HCUP SID data comes as ascii files as shown in samples [here](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide/Model/SampleHCUPdata). The description of each of these files can be found at   
https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_CORE.loc  
https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_CHGS.loc  
https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_SEVERITY.loc  
https://www.hcup-us.ahrq.gov/db/state/sidc/tools/filespecs/WA_SID_2011_DX_PR_GRPS.loc   
We will use these description files and the sample ascii data files to create csv files with headers to be used for analysis.

See notebook [here](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/Model/ReadHCUPdata.ipynb)

<a name="lm"></a>
## Length of stay model using lm
See notebook [here](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/Model/Length%20Of%20Stay%20Models%20-%20lm.ipynb).

<a name="xg"></a>
## Length of stay model using xgboost
See notebook [here](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/Model/Length%20Of%20Stay%20Models%20-%20xgboost.ipynb).