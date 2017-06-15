# Population Health Report 

A population health report lets the health care providers get an insight into the population they server and get actionable intelligence. It gives insight into the quality of care being provided and allows monitoring and benchmarking of some critical measures. In this solution we have created some reports based on in-patient data. These are just examples of the insights and tracking we can do with this kind of data. Some of the reports created are described below.  


# **Patient Stats**
 
In this report we create a snapshot of patient population. We look at Total Admits by Age, Gender, Race, Income, Admit Type and Payer Type. A demographic breakdown of population can help the hospitals better understand and serve their patients. We also look at Total Admits and Total charge by Payer. We can compare across different hospitals and over time.
![Solution Diagram Picture](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_PatientStats.PNG?raw=true)


# **Health Stats**

In this report we create a snapshot of medical condition of patient population. An insight into most frequent diagnosis and procedures at the hospital can help with resource planning. In this report we look at Total Admits by Primary Diagnosis, MDC (Major Diagnostic Category) and most frequent Procedures performed. We also look at Total Admits for chronic conditions by Age and Gender.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_HealthStats.PNG?raw=true)

# **Length of stay report**
Extended lengths of stay costs hospitals millions of dollars a year<sup>[ref](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb180-Hospitalizations-United-States-2012.pdf)</sup>. Recent legislative changes have standardized payments for procedures performed in hospitals, regardless of the number of days the patient actually spends in the hospital. In this new new pay-for-value model the hospitals are hard pressed to use resources more efficiently and find ways to accommodate more patients with the same volume of resources. An insight into the conditions and populations with longest length of stay can help devise measures to reduce the length of stay.
In the length of stay report we look at the average length of stay by payer type, gender, age and procedures. We also look at variation in average length of stay by condition (Diagnosis) and the associated average total charge. Additionally we also look at the performance of the length of stay model by comparing the true length of stay to predicted length of stay for historic data.


![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_LengthofStayReport.PNG?raw=true)

# **Cost report**

Insight into how costs are distributed across different segments of the population, by payer, by age and by disease can be very helpful in devising strategies to reduce healthcare costs. Majority of total health care expenses come from a small percent of total population<sup>[ref](https://archive.ahrq.gov/research/findings/factsheets/costs/expriach/)</sup>. In this report we look at Total Charges by Payer and Gender as well as Total charge per day by Payer type. We also identify population that contribute to most costs.  
Chronic Diseases are the leading causes of death and disability in the United States<sup>[ref](https://www.cdc.gov/chronicdisease/overview/)</sup> and treating them incurs a huge economic burden<sup>[ref](http://www.milkeninstitute.org/publications/view/321)</sup> and readmissions. Eighty-six percent of all health care spending in 2010 was for people with one or more chronic medical conditions<sup>[ref](https://www.ahrq.gov/sites/default/files/wysiwyg/professionals/prevention-chronic-care/decision/mcc/mccchartbook.pdf)</sup>. In this report, we look at total costs and also what proportion of total costs went towards treating patients with chronic disease. Reduction by even a few percent could result in millions of dollars in savings.  
Readmissions cause additional hospital costs to the tune of billions of dollars. According to the Agency for Healthcare Research and Quality (AHRQ) $41.3 billion was spent by hospitals between January and November 2011 to treat readmission patients<sup>[ref](http://www.fiercehealthcare.com/finance/readmissions-lead-to-41-3b-additional-hospital-costs)<sup>. In this report we look at the costs associated with readmissions for each hospital. We also identify the [most expensive](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb204-Most-Expensive-Hospital-Conditions.jsp) health conditions and [Mean hospital costs](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb181-Hospital-Costs-United-States-2012.pdf) per day per visit.


![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_CostReport.PNG?raw=true)

# **Intervention Profile**

Hospital readmissions has been identified as one of the key areas that has the potential for cost savings. Readmissions not only place patients at greater risk of complications and healthcare-associated infections, they are very costly. Nearly one in five of all hospital patients covered by Medicare are readmitted within 30 days, accounting for $15 billion a year<sup>[ref](https://www.ahrq.gov/news/blog/ahrqviews/112015.html)</sup>. In this report we identify [conditions](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf) that cause most readmissions and related costs, readmission by [payer and age](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb199-Readmissions-Payer-Age.pdf). These insights can help identify population to target and intervene to prevent and reduce readmission in order to maximize quality improvement and cost-reduction efforts. Additionally we also look at prevalence of chronic conditions by age.


![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_InterventionProfile.PNG?raw=true)

# **Readmission Tracking**
Hospital readmission is a good measure for assessing the performance of the health care system. In this solution we have used the same definition of readmission as Medicare. Medicare uses an “all-cause” definition of readmission, meaning that if a patient is admitted to a hospital within 30 days after being discharged from an earlier (initial) hospitalization, to any hospital, not just the hospital at which the patient was originally hospitalized, regardless of the reason for the readmission, it is considered a readmission.
 
Medicare Hospital Readmissions Reduction Program (HRRP) which took effect in 2013 provides a financial incentive to hospitals to lower readmission rates. The current focus in the HRRP is on readmissions occurring after initial hospitalizations for selected conditions — namely, heart attack, heart failure, pneumonia, chronic obstructive pulmonary disease (COPD), elective hip or knee replacement, and coronary artery bypass graft (CABG). [Readmission penalties](http://khn.org/news/more-than-half-of-hospitals-to-be-penalized-for-excess-readmissions/) can cost hospitals millions of dollars. In this report we track Readmission rate for these and some other conditions for different hospitals. There is also a metric file that we use for this visualization that contains the goal set by a hospital regarding their readmission rate. By monitoring how they are doing every month, they can by proactive about measures to meet their target. They can also monitor progress on any ongoing efforts to improve discharge and care transition practices in order to reduce readmissions.


![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_ReadmissionTracking.PNG?raw=true)


# **Hot Spots**

In this report, we look at geographic distribution of some chronic conditions. By monitoring the progression of certain conditions by location over time, we can identify hot spots for surge in those conditions which can allow us to take preemptive action. It can also help identify potential gaps in resources or facilities to combat certain conditions. 

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_HotSpots.PNG?raw=true)

**DISCLAIMER**: The visuals are based on simulated data. They do not represent real world. The insights are for illustrative and demo purposes only and should not be used as facts or alternative facts.

Questions on Visualization and Data: Contact @Shaheen_Gauher
