# Population Health Report 

A population health report lets the health care providers get an insight into the population they server and get actionable intelligence. In this solution we have created some reports based on data described above. These are just examples of the insights and tracking we can do with this kind of data. Some of the reports created are below.  


# **Patient Stats**
 
In this report we create a snapshot of patient population. We look at Total Admits by Age, Gender, Race, Income, Admit Type and Payer Type. Emergency visits can cost a lot. We also look at Total Admits and Total charge by Payer. We can compare different hospitals and over time.
![Solution Diagram Picture](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_PatientStats.PNG?token=AKE1nSBUFnKCy192GtbyvQxBlcqri7y2ks5ZLkWBwA%3D%3D)


# **Health Stats**

In this report we create a snapshot of medical condition of patient population. We look at Total Admits by Primary Diagnosis, MDC (Major Diagnostic Category) and most frequent Procedures performed. We also look at Total Admits for chronic conditions by Age and Gender.
![](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_HealthStats.PNG?token=AKE1ndf3KtvgAwUn5VB6seOiik2l-3E-ks5ZLkWowA%3D%3D)

# **Length of stay report**

In the length of stay report we look at the Average Length of stay by Payer Type, Gender, Age and Procedures. We also look at Average Total charge by Average Length of stay variation by Diagnosis (DXMCCS). We look at the performance of the length of stay model by comparing the true length of stay to predicted length of stay for historic data.
![](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_LengthofStayReport.PNG?token=AKE1nQONCsE1ujmuXQ06ZsW0AkX7Ghw6ks5ZLkYawA%3D%3D)

# **Cost report**

In the Cost Report, we look at the Total Charge , Total cost of chronic disease and what proportion it is of Total Charges, Total cost of Readmittance and what proportion it is of Total Charges. We look at Total Charges by Payer and Gender as well as Total charge per day by Payer type. We also look at % of admits contributing to Total cost.
![](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_CostReport.PNG?token=AKE1nYYUHPYH1QaSFirbdQ6H_lZLPCffks5ZLkXKwA%3D%3D)

# **Intervention Profile**

In this report we look at Most Readmitted Conditions, Readmittance by Payer and Age. To reduce readmision you get an insight into who to target and intervene to prevent, reduce readmittance.
![](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_InterventionProfile.PNG?token=AKE1nVkume5N4-ymiEcrIP8yAOuTi1F0ks5ZLkX7wA%3D%3D)

# **Readmittance Tracking**

In this report we track Readmittance rate for certain conditions for different hospitals. There is also a metric file that we use for this visualisation thaat contains the goal to be met by a hospital regarding their readmit rate. By monitoring how they are doing every month, they can by proactive about measures to meet their target.
![](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_ReadmissionTracking.PNG?token=AKE1nS883OG5_x_3yFGUnyWxicS6Q4nSks5ZLkZuwA%3D%3D)

# **Hot Spots**

In this report, we at geographic distribution of some chronic conditions. By monitoring the progression by location over time, we can identify hot spots for surge in certain conditions. 
![](https://raw.githubusercontent.com/Azure/cortana-intelligence-population-health-management/master/ManualDeploymentGuide/media/pbi_HotSpots.PNG?token=AKE1neFqxJwpvyxXRlNSjG1QewuEcF5lks5ZLkaRwA%3D%3D)

**DISCLAIMER**: The visuals are based on simulated data. They do not represent real world. The insights are for illustrative and demo purposes only and should not be used as facts or alternative facts.

Questions on Visualization and Data: Contact @Shaheen_Gauher
