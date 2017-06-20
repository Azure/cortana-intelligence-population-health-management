# Population Health Management - Automated Deployment Guide  

We described [here](../ManualDeploymentGuide/README.md) what constitutes Population Health Management and its importance for the healthcare industry. We briefly discussed why Azure Data Lake is the right tool for creating a Population Health Management solution. In the Manual Deployment Guide section of this solution we showed you how to put together and deploy from the ground up a population Health Management solution using the Cortana Intelligence Suite. To see the entire Population Health Management for Health care using Cortana Intelligence Suit in action without having to spin up and connect all the components manually, there is a one click deployment option available in Cortana Intelligence Gallery. To start a new solution deployment, visit the gallery page [here](https://gallery.cortanaintelligence.com/). The 'Deploy' button will launch a workflow that will deploy an instance of the solution within a Resource Group in the Azure subscription you specify. This folder contains the post-deployment instructions for the automated deployable Population Health Management solution for Health care in the Cortana Intelligence Gallery. You will also see these steps outlined in the last screen at the end of a successful automated deployment along with the list of services provisioned. The architecture diagram below shows the data flow and the end-to-end pipeline.


## Architecture
![Solution Diagram Picture](../ManualDeploymentGuide/media/PHMarchitecture.PNG?raw=true)

The architecture diagram above shows the solution design for Population Health Management Solution for Healthcare. The solution is composed of several Azure components that perform various tasks, viz. data ingestion, data storage, data movement, advanced analytics and visualization. [Azure Function](https://docs.microsoft.com/en-us/azure/azure-functions/functions-overview) App is used to host the onine data generator web job that feeds the system with data. [Azure Event Hub](https://azure.microsoft.com/en-us/services/event-hubs/) is the ingestion point of raw records that will be processed in this solution. It is used to ingest the data from the online data generator. [Azure Stream Analytics](https://azure.microsoft.com/en-us/services/stream-analytics/) is used to process the data from event hub and redirect the data to multiple outputs. The first Stream Analytics job pushes the incoming data to Data Lake Store for storage and further processing. [Azure Data Lake Store](https://docs.microsoft.com/en-us/azure/data-lake-store/data-lake-store-overview) is used as durable storage for raw and processed events. A second Stream Analytics job sends selected data to [PowerBI](https://powerbi.microsoft.com/) for near real time visualizations. [Azure Data Factory](https://azure.microsoft.com/en-us/services/data-factory/) orchestrates, on a schedule, the scoring of the raw events from the Azure Stream Analytics job
 by utilizing [Azure Data Lake Analytics](https://azure.microsoft.com/en-us/services/data-lake-analytics/) for processing with both [USQL](https://msdn.microsoft.com/en-us/library/azure/mt591959.aspx) and [R](https://docs.microsoft.com/en-us/azure/machine-learning/machine-learning-r-quickstart). Results of the scoring are then stored in Azure Data Lake Store and visualized using Power BI. All the resources listed above besides Power BI are already deployed in your subscription. The following instructions will guide you on how to monitor things that you have deployed and carry out some post deployment steps.

## Post Deployment Steps
  Once the solution is deployed to the subscription, you can see the various services deployed by clicking the resource group name on the final deployment screen. Alternatively you can use [Azure management portal](https://portal.azure.com/) to see the resources provisioned in your resource group in your subscription. The source code of the solution as well as manual deployment instructions can be found [here](../ManualDeploymentGuide/). There are a few manual steps however that are required for the whole pipeline to be completed. The post deployment steps constitute monitoring the health of your deployment and visualizing Data from Data Lake Store and Real-time Data Stream by connecting Power BI to these data sources.
 
### Monitor
  After successful deployment, the entire solution is automatically started on cloud. There are several ways you can monitor the health of your deployment and ensure that data is flowing in uninterrupted and being stored and processed correctly. 

#### Azure Web Job  
  - The simulated data is streamed by the newly deployed Azure Web Jobs. To ensure data is flowing we will look at the Web Job logs. 
   - Navigate to your Resource group in [Azure Management Portal](https://portal.azure.com/) and from the list of services provisioned by your deployment select the App Service just created. You can also click on `Azure Function App` link from the last screen of your deployment.
   - Across the top of the right blade pick `Platform features`.
   - Under `GENERAL SETTINGS` click on `All settings`.
   - Search for WebJobs in the App Service menu on the left under `SETTINGS` and select it. 
   - The WebJob *HealthcareGenerator* from the deployment will appear in the WebJobs list.
   - Select the WebJob and click on Logs at the top of the screen. You should [see](../ManualDeploymentGuide/media/webjob2.PNG?raw=true) similar messages like below:   
    ```
    EVENTHUB: Upload 600 Records Complete   
    EVENTHUB: Starting Raw Upload    
    EVENTHUB: Upload 600 Records Complete    
    ```

   - Monitoring the logs can also help troubleshoot in the event of an interruption.

#### Azure Event Hub  
  - This synthetic data feeds into the Azure Event Hubs as data points/events, that will be consumed in the rest of the solution flow and stored in Azure Data Lake Store. 
   - Navigate to your Resource group in [Azure Management Portal](https://portal.azure.com/) and from the list of services provisioned by your deployment select the Event Hub just created.
   - In the Event Hub `Overview`, you should [see](../ManualDeploymentGuide/media/datageneratorstarted.PNG?raw=true) finite `INCOMING MESSAGES`.
   - After the Stream Analytics job *HealthCareColdPath* is started, the `OUTGOING MESSAGES` will be finite as well.
   
 
#### Azure Data Factory  
  - The last activity in Azure Data Factory pipeline executes a [USQL script](../ManualDeploymentGuide/scripts/datafactory/scripts_blob/hcadfstreamappend.usql) that in effect creates a file at the location `/pbidataforPHM/data4visualization_latest.csv` in your Azure Data Lake Store. If you see this file being created and has a finite size, your Data Factory is running correctly.
   - Navigate to your Resource group in [Azure Management Portal](https://portal.azure.com/) and from the list of services provisioned by your deployment select the Data Lake Store just created.
   - Click on `Data Explorer' at the top of the page.
   - You should see the folder `pbidataforPHM` in the list. This folder will appear ~ 15-20 mins after the deployment.
   - Click on the folder when it appears and select the file `data4visualization_latest.csv` to look at the data.
   - For more on how to monitor and manage Data Factory pipelines, read [here](https://docs.microsoft.com/en-us/azure/data-factory/data-factory-monitor-manage-pipelines).
   

### [Visualization](../ManualDeploymentGuide/Visualization)

 Once the Cortana Intelligence Solution for Population Health is successfully deployed simulated patient data and predictions will begin to accumulate. We want to display and glean insights from the data using Power BI. Lets head over to the [visualization](../ManualDeploymentGuide/Visualization) folder where you will find instructions on how to use [Power BI](https://powerbi.microsoft.com/) to build reports and dashboards using your data and create a Population Health Report! 

### Customization

For solution customization, you can refer to the manual deployment guide offered [here](../ManualDeploymentGuide/) to gain an inside view of how the solution is built, the function of each component and access to all the source codes used in the demo solution. You can customize the components accordingly to satisfy the business needs of your organization. Or you can [connect with one of our partners](https://appsource.microsoft.com/en-us/product/cortana-intelligence/microsoft-cortana-intelligence.quality-assurance-for-manufacturing?tab=Partners) for more information on how to tailor Cortana Intelligence to your needs.


#### Disclaimer

©2017 Microsoft Corporation. All rights reserved.  This information is provided "as-is" and may change without notice. Microsoft makes no warranties, express or implied, with respect to the information provided here.  Third party data was used to generate the solution.  You are responsible for respecting the rights of others, including procuring and complying with relevant licenses in order to create similar datasets.