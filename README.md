# Population Health Management for Healthcare - A Cortana Intelligence Solution

According to [Centers for Medicaid and Medicare Services](https://www.cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/nationalhealthexpenddata/nationalhealthaccountshistorical.html), U.S. health care spending reached $3.2 trillion or $9,990 per person in 2015 accounting for 17.8 percent of the Gross Domestic Product. One-third of this health care expenditure comes from hospital inpatient care. With spending [projected](https://www.cms.gov/research-statistics-data-and-systems/statistics-trends-and-reports/medicare-provider-charge-data/downloads/publiccomments.pdf) to reach $4.8 trillion in 2021, health care has become the [top concern](http://big.assets.huffingtonpost.com/tabsHPTrumpIssues20170320.pdf) for Americans even surpassing economy. Concerted efforts are being made to reduce spending. The recent shift in government [payment models](https://www.healthcatalyst.com/hospital-transitioning-fee-for-service-value-based-reimbursements) from fee-for-service to pay-for-value is aimed specifically at reducing the government’s spending on health care and curtail the growing budget deficits. In this model disease prevention and management is rewarded while poor outcomes are penalized.

 ***Population Health Management*** is an important tool that is increasingly being used by Health care providers to manage and control the escalating costs. The crux of Population Health Management is to use data to improve health outcomes. Tracking, monitoring and bench marking are the three bastions of Population Health Management aimed at improving clinical and health outcomes while managing and reducing cost. A successful population health management initiative requires establishing a repository that can collect data from multiple sources and in all and any formats whether it be structured, semi structured or unstructured. By analyzing patient population and getting an insight into the social-economic and demographic constitution of the population and their overall medical condition across different longitudes the health care providers can get an insight into the quality of care being provided and identify areas of improvement and cost savings. In this solution guide we will be leveraging the clinical and socioeconomic in-patient data (simulated) generated by the hospitals for population health reporting. Additionally, we will also be making predictions for the length of hospital stay. The hospitals can use these results to optimize care management systems and focus the clinical resources on patients with more urgent need. Understanding the community it serves through population health reporting can help the hospitals transition from fee-for-service payments to value-based care while saving costs and providing better care.

# Population Health Report

<p>The snapshot below shows how we use PowerBI for Population Health reporting.
<a href="https://github.com/Azure/cortana-intelligence-churn-prediction-solution/blob/master/Technical%20Deployment%20Guide/media/customer-churn-dashboard-2.png" target="_blank"><img src="https://github.com/Azure/cortana-intelligence-population-health-management/blob/master/ManualDeploymentGuide/media/PHMmainpage.PNG?raw=true" alt="Insights" style="max-width:100%;"></a></p>

# Getting Started #

This solution package contains materials to help both technical and business audiences understand our Population Health Management solution for Health care built on the [Cortana Intelligence Suite](https://www.microsoft.com/en-us/server-cloud/cortana-intelligence-suite/Overview.aspx).

# Business Audiences

In this repository you will find a folder labeled [*Solution Overview for Business Audiences*](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/SolutionOverviewforBusinessAudiences) which contains a  presentation covering this solution and benefits of using the Cortana Intelligence Suite

For more information on how to tailor Cortana Intelligence to your needs [connect with one of our partners](http://aka.ms/CISFindPartner).

# Technical Audiences

For Technical Audiences we have put together a manual deployment guide as well as an automatic deployment guide. The manual deployment guide is geared towards the more technically bent who want to understand how to spin up the different components and how they can be connected together to build an end to end pipeline. The automatic deployment guide is for seeing the entire solution in action without having to do all the wiring manually. 

## [Manual Deployment Guide](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide)
In this folder you will find instructions on how to put together and deploy from the ground up a population Health Management solution using the Cortana Intelligence Suite.  It will walk you through how to manually set up and deploy all the individual services used in this solution (e.g. Azure Event Hub, Data Lake Store, Azure Stream Analytics etc.). 


## [Automated Deployment Guide](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/AutomatedDeploymentGuide)
There is also deployable Population Health Management solution in the Cortana Intelligence Gallery. (one click deployment of all services required for this solution!). In this folder you will find instructions on how to monitor the progress of your automatic deployment (takes about 20 minutes to deploy). 

## [Visualization](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/Visualization)
At the end of deployment (whether [manual](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/ManualDeploymentGuide) or [automatic](https://github.com/Azure/cortana-intelligence-population-health-management/tree/master/AutomaticDeploymentGuide)), we want to visualise the insights from the data and the results of the predictions. In this folder you will find instructions on how to connect your Power BI to the data in your Data Lake Store and also to your real time stream through Azure Stream Analytics. We have provided a power BI file with an example Population Health report and will guide you though creating some visuals and publishing a dashboard.
 