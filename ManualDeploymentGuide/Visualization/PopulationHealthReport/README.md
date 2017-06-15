# Population Health Report 

A population health report helps the health care providers gain insight into the population they serve and get actionable intelligence. It sheds light on the quality of care being provided and allows monitoring and bench-marking of critical metrics. In the Power BI-based visualization section of this solution, we have created some example reports showing the types of summarization and tracking we can do with this kind of data. Some of the reports created are described below.  

# **Patient Stats**
 
In this report, we create a snapshot of the patient population. We look at Total Admits by Age, Gender, Race, Income, Admit Type, Payer Type, Total Admits and Total Charge by Payer. Such demographic breakdowns of the population can help the hospitals better understand and serve their patients. The selectors on the right-hand side of the report allow us to compare results across different hospitals and over time.
![Solution Diagram Picture](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_PatientStats.PNG?raw=true)

# **Health Stats**

In this report, we create an overview of the medical condition of the patient population. Knowing which diagnosis and procedures are most frequent at a given hospital can help with resource planning. In this report, we look at Total Admits by Primary Diagnosis, MDC (Major Diagnostic Category) and Most Frequent Procedures Performed. We also look at Total Admits for Chronic Conditions, broken down by Age and Gender.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_HealthStats.PNG?raw=true)

# **Length of stay report**
Extended stays costs hospitals millions of dollars a year<sup>[ref](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb180-Hospitalizations-United-States-2012.pdf)</sup>. Recent legislative changes have standardized payments for procedures performed in hospitals, regardless of the number of days the patient actually spends in the hospital. In this new pay-for-value model, hospitals are hard-pressed to use resources more efficiently and find ways to accommodate more patients with the same volume of resources. An insight into the conditions and demographic subgroups with the longest length of stay can help hospitals devise measures to reduce the average length of stay.

In the length of stay report, we display the average length of stay by payer type, gender, age and procedures. We also look at variation in average length of stay by condition (diagnosis) and the associated average total charge. Additionally, we show the performance of the length of stay model by comparing the true length of stay to predicted length of stay for historic data.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_LengthofStayReport.PNG?raw=true)

# **Cost report**

The majority of total health care expenses come from a small percent of the total population<sup>[ref](https://archive.ahrq.gov/research/findings/factsheets/costs/expriach/)</sup>. Insight into how costs are distributed across different segments of the population (e.g. patient age, disease and payer type) can be very helpful in devising strategies to reduce health care costs. In this report, we look at Total Charges by Payer and Gender as well as the total charge per day broken down by payer type. We also identify populations that contribute the most to costs. 

Chronic diseases are the leading causes of death and disability in the United States<sup>[ref](https://www.cdc.gov/chronicdisease/overview/)</sup> and treating them incurs a huge economic burden<sup>[ref](http://www.milkeninstitute.org/publications/view/321)</sup>. Eighty-six percent of all health care spending in 2010 was spent on people with one or more chronic medical conditions<sup>[ref](https://www.ahrq.gov/sites/default/files/wysiwyg/professionals/prevention-chronic-care/decision/mcc/mccchartbook.pdf)</sup>. In this report, we look at total costs and also what proportion of total costs went towards treating patients with chronic disease. Reduction by even a few percent could result in millions of dollars in savings.

Readmissions increase hospital costs by billions of dollars. According to the Agency for Healthcare Research and Quality, $41.3 billion was spent by hospitals between January and November 2011 to treat readmission patients<sup>[ref](http://www.fiercehealthcare.com/finance/readmissions-lead-to-41-3b-additional-hospital-costs)</sup>. In this report, we look at the costs associated with readmissions for each hospital. We also identify the [most expensive](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb204-Most-Expensive-Hospital-Conditions.jsp) health conditions and calculate [mean hospital costs](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb181-Hospital-Costs-United-States-2012.pdf) per day per visit.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_CostReport.PNG?raw=true)

# **Intervention Profile**

Hospital readmissions has been identified as one of the key areas that has the potential for cost savings. Readmissions not only place patients at greater risk of complications and healthcare-associated infections, they are very costly. Nearly one in five hospital patients covered by Medicare are readmitted within 30 days, accounting for $15 billion a year<sup>[ref](https://www.ahrq.gov/news/blog/ahrqviews/112015.html)</sup>. In this report, we identify the [conditions](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb172-Conditions-Readmissions-Payer.pdf) that cause the most readmissions and related costs, broken down by [payer and age](https://www.hcup-us.ahrq.gov/reports/statbriefs/sb199-Readmissions-Payer-Age.pdf). These insights can help identify populations to target with interventions that prevent or reduce readmission, enhancing care quality and improving cost-reduction efforts. This report also examines prevalence of chronic conditions by age.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_InterventionProfile.PNG?raw=true)

# **Readmission Tracking**
Hospital readmission is a key measure for assessing the performance of the health care system. In this solution, we identify readmission using the same "all-cause" definition as Medicare: if a patient is admitted to *any* hospital within 30 days after being discharged from an earlier hospitalization, for *any* reason (including unrelated medical issues), the hospital visit is considered a readmission. The readmission rate is the percentage of index admissions (i.e. the original hospital stay) that are readmitted within 30 days. If the denominator is the number of index admissions discharged in say six months, the numerator would be the number of index admissions in the denominator that had a readmission for any cause within 30 days.
 
Medicare Hospital Readmissions Reduction Program (HRRP), which took effect in 2013, provides a financial incentive to hospitals to lower readmission rates. The current focus of the HRRP is on readmissions occurring after initial hospitalizations for selected conditions — namely, heart attack, heart failure, pneumonia, chronic obstructive pulmonary disease (COPD), elective hip or knee replacement, and coronary artery bypass graft (CABG). [Readmission penalties](http://khn.org/news/more-than-half-of-hospitals-to-be-penalized-for-excess-readmissions/) can cost hospitals millions of dollars. In this report we track readmission rate for the HRRP conditions (and some other common conditions) at each hospital. There is also a metric file used for this visualization that contains the goals set by a hospital regarding their readmission rate. By regularly monitoring the readmission rate, hospitals can be proactive and empirical in their approaches to meeting their target. For example, hospitals can monitor progress on any ongoing efforts to improve discharge and care transition practices in order to reduce readmissions.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_ReadmissionTracking.PNG?raw=true)


# **Hot Spots**

In this report, we look at geographic distribution of some chronic conditions. By monitoring the progression of certain conditions by location over time, hospitals can identify hot spots where these conditions occur more frequently, allowing them to identify potential gaps in resources/facilities and to recommend preemptive action in primary care.

![](https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/pbi_HotSpots.PNG?raw=true)

**DISCLAIMER**: The visuals in these reports are based on simulated data. While the simulation reflects some trends present in real-world  data, the results should be treated as fictitious. Any insights derived from these data are for illustrative and demo purposes only, and should not be used as facts or alternative facts.

If you have questions on the visualizations or underlying data, please contact @Shaheen_Gauher.
