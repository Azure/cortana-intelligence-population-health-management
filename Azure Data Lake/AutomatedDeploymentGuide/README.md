# Population Health Management - Automated Deployment Guide  

We described [here](../ManualDeploymentGuide/README.md) what constitutes Population Health Management and its importance for the healthcare domain. We briefly discussed why Azure Data Lake is the right tool for creating a Population Health Management solution. In the Manual Deployment Guide section of this solution we showed you how to put together and deploy from the ground up a population Health Management solution using the Cortana Intelligence Suite. To see the entire Population Health Management for Health care using Cortana Intelligence Suit in action without having to spin up and connect all the components manually, there is a one click deployment option available in Cortana Intelligence Gallery. To start a new solution deployment, visit the gallery page [here](https://gallery.cortanaintelligence.com/). This folder contains the post-deployment instructions for the automated deployable Population Health Management solution for Health care in the Cortana Intelligence Gallery. You will also see these steps outlined in the last screen at the end of a successful automated deployment along with the list of services provisioned. The architecture diagram below shows the data flow and the end-to-end pipeline.


## Architecture
![Solution Diagram Picture](../ManualDeploymentGuide/media/PHMarchitecture.PNG?raw=true)

The architecture diagram above shows the solution design for Population Health Management Solution for Healthcare. The solution is composed of several Azure components that perform various tasks, viz. data ingest, data storage, data movement, advanced analytics and visualization.  [Azure Event Hub](https://azure.microsoft.com/en-us/services/event-hubs/) is the ingestion point of raw records that will be processed in this solution. These are then pushed to Data Lake Store for storage and further processing by [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/). A second Stream Analytics job sends selected data to [PowerBI](https://powerbi.microsoft.com/) for near real time visualizations. [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) orchestrates, on a schedule, the scoring of the raw events from the Azure Stream Analytics job
 by utilizing [Azure Data Lake Analytics](https://azure.microsoft.com/en-us/services/data-lake-analytics/) for processing with both [USQL](https://msdn.microsoft.com/en-us/library/azure/mt591959.aspx) and [R](https://docs.microsoft.com/en-us/azure/machine-learning/machine-learning-r-quickstart). Results of the scoring are then stored in [Azure Data Lake Store](https://azure.microsoft.com/en-us/services/data-lake-store/) and visualized using Power BI.
All the resources listed above besides Power BI are already deployed in your subscription. The following instructions will guide you on how to monitor things that you have deployed and carry out some post deployment steps.


## Monitor Progress
Once the solution is deployed to the subscription, you can see the services deployed by clicking the resource group name on the final deployment screen in the CIS.

This will show all the resources under this resource groups on [Azure management portal](https://portal.azure.com/).

After successful deployment, the entire solution is automatically started on cloud. You can monitor the progress from the following resources.
 
## Post Deployment Steps
  Data is now streaming into the Azure Event Hub and the HealthCareColdPath Azure Stream Analytics job is pushing data to the gsciqs1w6yadls Azure Data Lake Store account. There are a few manual steps that are required for the whole pipeline to be completed. The source code of the solution as well as manual deployment instructions can be found here.
 

## Authorize Stream Analytics Outputs for Hot Path

 - Go to the Azure Stream Analytics Hot Path job here 
 - Click on Outputs 
 - For the stream analytics outputs LosDataset1 and LosDataset2
 - Click on the output in the Outputs list
 - Click on Renew authorization
 - Complete authorization
 - Click Save
 - Authorize Stream Analytics Outputs for Cold Path
   
## Authorize Stream Analytics Outputs for Cold Path
  
  - Go to the Azure Stream Analytics Cold Path job here 
  - Click on Outputs
  - For the stream analytics outputs ChargesOutput, CoreOutput, SeverityOutput, and DxprOutput
  - Click on the output in the Outputs list
  - Click on Renew authorization
  - Complete authorization
  - Click Save

## Visualization

 Congratulations! You have successfully deployed a Cortana Intelligence Solution. By authorizing the hot path, streaming data has started flowing into your Power BI. By authorzing the cold path, the PBI can connect to data stored in Data Lake Store for visualization. A picture is worth a thousand words. Lets head over to the [visualization](../ManualDeploymentGuide/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to build reports and dashboards using your data!

## Customization

For solution customization, you can refer to the manual deployment guide offered [here](../ManualDeploymentGuide/) to gain an inside view of how the solution is built, the function of each component and access to all the source codes used in the demo solution. You can customize the components accordingly to satisfy the business needs of your organization. Or you can [connect with one of our partners](https://appsource.microsoft.com/en-us/product/cortana-intelligence/microsoft-cortana-intelligence.quality-assurance-for-manufacturing?tab=Partners) for more information on how to tailor Cortana Intelligence to your needs.